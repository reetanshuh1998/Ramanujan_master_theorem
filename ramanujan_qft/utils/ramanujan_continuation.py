"""
ramanujan_continuation.py
=========================
Algebraic continuation identities for hypergeometric functions and
polylogarithms with the Feynman +i0 prescription.
"""

import mpmath

from ramanujan_qft import sunset


class RamanujanContinuationEngine:
    def __init__(self, precision=30):
        self.precision = precision

    def hypergeom_continuation_2F1(self, a, b, c, z):
        """
        2F1(a, b; c; z + i0) for real z > 1 via the 1/z transformation
        (requires a - b not an integer):

          2F1 = G(c)G(b-a)/(G(b)G(c-a)) (-z)^(-a) 2F1(a, a-c+1; a-b+1; 1/z)
              + G(c)G(a-b)/(G(a)G(c-b)) (-z)^(-b) 2F1(b, b-c+1; b-a+1; 1/z),

        with (-z - i0)^(-a) = e^(i pi a) z^(-a).
        """
        with mpmath.workdps(self.precision):
            zz = mpmath.mpmathify(z)
            if mpmath.im(zz) != 0 or not zz > 1:
                raise ValueError("hypergeom_continuation_2F1 is defined for real z > 1 (z + i0) only")
            if mpmath.isint(a - b):
                raise ValueError("a - b is an integer: the 1/z formula degenerates; "
                                 "use mpmath.hyp2f1 and take the conjugate for z > 1")
            z_mp = mpmath.mpc(z)
            inv_z = 1 / z_mp
            term_a = (mpmath.gamma(c) * mpmath.gamma(b - a) / (mpmath.gamma(b) * mpmath.gamma(c - a))
                      * mpmath.exp(1j * mpmath.pi * a) * z_mp**(-a)
                      * mpmath.hyp2f1(a, a - c + 1, a - b + 1, inv_z))
            term_b = (mpmath.gamma(c) * mpmath.gamma(a - b) / (mpmath.gamma(a) * mpmath.gamma(c - b))
                      * mpmath.exp(1j * mpmath.pi * b) * z_mp**(-b)
                      * mpmath.hyp2f1(b, b - c + 1, b - a + 1, inv_z))
            return term_a + term_b

    def Li2_phys(self, z):
        """Li2(z + i0): for real z > 1 the imaginary part is +pi log z."""
        with mpmath.workdps(self.precision):
            z = mpmath.mpc(z)
            if z.imag == 0 and z.real > 1:
                return mpmath.mpc(mpmath.polylog(2, z.real).real, mpmath.pi * mpmath.log(z.real))
            return mpmath.polylog(2, z)

    def algebraic_continuation_Li2(self, z):
        """Li2(z + i0) via Li2(z) = -Li2(1/z) - pi^2/6 - (1/2) log^2(-z - i0)."""
        with mpmath.workdps(self.precision):
            z_mp = mpmath.mpc(z)
            if z_mp.imag == 0 and z_mp.real > 1:
                phase_log = mpmath.log(z_mp.real) - 1j * mpmath.pi
                return -mpmath.polylog(2, 1 / z_mp) - mpmath.pi**2 / 6 - phase_log**2 / 2
            return mpmath.polylog(2, z_mp)

    def phase_space_3body(self, s, m1sq, m2sq, m3sq):
        """
        Imaginary part of the two-loop sunset (LoopTools/pySecDec normalisation).

        Note: version 0.1 used the prefactor pi/(16 s) and a positive sign; the correct
        value is -pi/s * Int(...), i.e. 16x larger in magnitude. This is the
        "16x normalisation" observed against pySecDec.
        """
        return sunset.sunset_im(s, m1sq, m2sq, m3sq, dps=self.precision)

    def sunset_real_dispersion(self, s, m_sq):
        raise NotImplementedError(
            "sunset_real_dispersion used fixed placeholder subtraction constants (-0.5, 0.1). "
            "Use ramanujan_qft.sunset.sunset_subtracted, which returns S(s) - S(0) - s S'(0).")

    def evaluate_minkowski_residues(self, m_sq, p2, D=4):
        raise NotImplementedError(
            "use ramanujan_qft.sunset.sunset_im and sunset_subtracted (the full finite part also "
            "needs the scheme-dependent constants S(0), S'(0), which are not implemented)")
