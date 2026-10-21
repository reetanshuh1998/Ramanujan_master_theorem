"""
Dispersion-Linked Method of Brackets (DL-MoB): generic subtracted dispersion relation

    I(s) = Sum_{k<n} c_k s^k + (s^n/pi) Int_th^oo dt Im I(t) / (t^n (t - s - i0)),

where the subtraction constants c_k = I^(k)(0)/k! come from a Euclidean (MoB)
evaluation and Im I from the cut. The principal value above threshold is taken
with a symmetric subtraction around t = s.

For the sunset, see :mod:`ramanujan_qft.sunset`, which is validated against
independent Feynman-parameter integrations.
"""

import mpmath


class DispersionMoBEngine:
    def __init__(self, precision=15):
        self.precision = precision

    def compute_spectral_density(self, topology_res_func, s_val, params):
        """Im I(s) from a user-supplied cut function."""
        return topology_res_func(s_val, *params)

    def reconstruct_complex(self, s, threshold, subtractions, im_func, im_params):
        """
        s            : kinematic point
        threshold    : lowest threshold of the cut
        subtractions : [c_0, c_1, ...] Taylor coefficients of I at s = 0 (c_k = I^(k)(0)/k!)
        im_func      : t -> Im I(t) (called as im_func(t, *im_params))
        """
        n = len(subtractions)
        if n == 0:
            raise ValueError("at least one subtraction constant is required")
        with mpmath.workdps(self.precision):
            s, th = mpmath.mpf(s), mpmath.mpf(threshold)
            poly = sum(mpmath.mpf(c) * s**k for k, c in enumerate(subtractions))
            h = lambda t: im_func(t, *im_params) / t**n
            if s < th:
                disp = mpmath.quad(lambda t: h(t) / (t - s), [th, 2 * th, mpmath.inf]) / mpmath.pi
                im = mpmath.mpf(0)
            elif s == th:
                raise ValueError("evaluate off the threshold point")
            else:
                hs = h(s)
                near = mpmath.quad(lambda t: (h(t) - hs) / (t - s), [th, s, 2 * s - th])
                far = mpmath.quad(lambda t: h(t) / (t - s), [2 * s - th, mpmath.inf])
                disp = (near + far) / mpmath.pi
                im = hs
            return mpmath.mpc(poly + s**n * disp, s**n * im)


def demo_dl_mob_sunset():
    """Twice-subtracted sunset, S(s) - S(0) - s S'(0), at s = 100, m^2 = (1, 2, 3)."""
    from ramanujan_qft.sunset import sunset_im, sunset_threshold
    msq = [1.0, 2.0, 3.0]
    engine = DispersionMoBEngine(precision=15)
    res = engine.reconstruct_complex(100.0, sunset_threshold(*msq), [0, 0], sunset_im, msq)
    print("S(100) - S(0) - 100 S'(0) =", res)


if __name__ == "__main__":
    demo_dl_mob_sunset()
