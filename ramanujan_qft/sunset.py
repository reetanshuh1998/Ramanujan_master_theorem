"""
Two-loop massive sunset S(p^2; m1^2, m2^2, m3^2) -- the scheme-independent parts.

Normalisation (same per-loop measure as LoopTools / pySecDec):

    S = Int d^Dk d^Dl / (i pi^(D/2))^2  1 / ((k^2 - m1^2)(l^2 - m2^2)((p-k-l)^2 - m3^2)),

with +i0 on every propagator, D = 4 - 2 eps.

What is provided (all UV finite, hence free of scheme ambiguities):

* :func:`sunset_im`         Im S(s), exact 1-D phase-space representation
                            Im S = -(pi/s) Int dt lambda^(1/2)(s,t,m1^2) lambda^(1/2)(t,m2^2,m3^2)/t
* :func:`sunset_subtracted` S(s) - S(0) - s S'(0) from a twice-subtracted
                            dispersion relation (complex above threshold)
* :func:`sunset_d2`         d^2 S / ds^2, from the same dispersion relation

The full finite part of S additionally needs the scheme-dependent constants S(0) and
S'(0) (known in closed form, e.g. Davydychev & Tausk, Nucl. Phys. B397 (1993) 123);
they are not implemented here.

Validation: the tests compare :func:`sunset_im` and :func:`sunset_d2` with independent
two-dimensional Feynman-parameter integrations.
"""

import mpmath

__all__ = ["sunset_threshold", "sunset_im", "sunset_subtracted", "sunset_d2"]


def _kallen(a, b, c):
    return a * a + b * b + c * c - 2 * (a * b + b * c + c * a)


def sunset_threshold(m1sq, m2sq, m3sq):
    """Three-particle threshold (m1 + m2 + m3)^2."""
    return (mpmath.sqrt(m1sq) + mpmath.sqrt(m2sq) + mpmath.sqrt(m3sq))**2


def _ordered(msq):
    # Im S is symmetric in the masses; integrate over the pair with the narrowest cut.
    return sorted(mpmath.mpf(m) for m in msq)


def sunset_im(s, m1sq, m2sq, m3sq, dps=None):
    """Imaginary part of the sunset (zero below the three-particle threshold)."""
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s = mpmath.mpf(s)
        m3, m2, m1 = _ordered((m1sq, m2sq, m3sq))   # m1: heaviest, integrated outside
        if min(m1, m2, m3) < 0:
            raise ValueError("squared masses must be non-negative")
        if s <= sunset_threshold(m1, m2, m3):
            return mpmath.mpf(0)

        def integrand(t):
            l1 = _kallen(s, t, m1)
            l2 = _kallen(t, m2, m3)
            if l1 <= 0 or l2 <= 0:
                return mpmath.mpf(0)
            return mpmath.sqrt(l1 * l2) / t

        lo = (mpmath.sqrt(m2) + mpmath.sqrt(m3))**2
        hi = (mpmath.sqrt(s) - mpmath.sqrt(m1))**2
        return -mpmath.pi / s * mpmath.quad(integrand, [lo, hi])


def _dispersion(s, msq, kernel_power, dps):
    """
    PV Int_th^oo dt Im S(t) / (t^k (t - s))  (k = kernel_power) and the delta-function part.
    Returns the complex value of  (1/pi) Int dt Im S(t) / (t^k (t - s - i0)).
    """
    th = sunset_threshold(*msq)
    h = lambda t: sunset_im(t, *msq) / t**kernel_power
    if s < th:
        val = mpmath.quad(lambda t: h(t) / (t - s), [th, 2 * th, mpmath.inf])
        return mpmath.mpc(val / mpmath.pi)
    if s == th:
        raise ValueError("the dispersion integral is evaluated off the threshold point")
    hs = h(s)
    # symmetric subtraction around the pole, then the tail
    near = mpmath.quad(lambda t: (h(t) - hs) / (t - s), [th, s, 2 * s - th])
    far = mpmath.quad(lambda t: h(t) / (t - s), [2 * s - th, mpmath.inf])
    return mpmath.mpc((near + far) / mpmath.pi, hs)


def sunset_subtracted(s, m1sq, m2sq, m3sq, dps=15):
    """
    S(s) - S(0) - s S'(0) = (s^2/pi) Int_th^oo dt Im S(t) / (t^2 (t - s - i0)).

    Finite and scheme independent. Cost: a nested 1-D quadrature (seconds at dps=15).
    """
    with mpmath.workdps(dps):
        s = mpmath.mpf(s)
        if s == 0:
            return mpmath.mpc(0)
        msq = [mpmath.mpf(m) for m in (m1sq, m2sq, m3sq)]
        return +(s * s * _dispersion(s, msq, 2, dps))


def sunset_d2(s, m1sq, m2sq, m3sq, dps=15):
    """d^2 S/ds^2 = (2/pi) Int_th^oo dt Im S(t) / (t - s)^3, for s below threshold."""
    with mpmath.workdps(dps):
        s = mpmath.mpf(s)
        msq = [mpmath.mpf(m) for m in (m1sq, m2sq, m3sq)]
        th = sunset_threshold(*msq)
        if s >= th:
            raise ValueError("sunset_d2 is implemented below threshold only")
        val = mpmath.quad(lambda t: sunset_im(t, *msq) / (t - s)**3, [th, 2 * th, mpmath.inf])
        return 2 * val / mpmath.pi
