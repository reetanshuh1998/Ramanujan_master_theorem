"""
ramanujan_continuation.py
=========================
Ramanujan Algebraic Series Continuation Engine for Feynman Integrals

This module implements exact algebraic continuation identities for hypergeometric
series. It enforces the physical +iε prescription entirely through algebraic phase
tracking (e.g., (-z)^(-a) = e^{i*pi*a} z^(-a)), producing exact branch cuts and 
imaginary parts without any numerical contour integration.
"""

import mpmath

class RamanujanContinuationEngine:
    def __init__(self, precision=50):
        self.precision = precision
        mpmath.mp.dps = precision

    def hypergeom_continuation_2F1(self, a, b, c, z):
        """
        Algebraic continuation of 2F1(a, b; c; z) for |z| > 1 into the Minkowski region.
        
        Applies the Gauss hypergeometric transformation:
        2F1(a,b;c;z) = [ Gamma(c)Gamma(b-a) / (Gamma(b)Gamma(c-a)) ] * (-z)^{-a} * 2F1(a, a-c+1; a-b+1; 1/z)
                     + [ Gamma(c)Gamma(a-b) / (Gamma(a)Gamma(c-b)) ] * (-z)^{-b} * 2F1(b, b-c+1; b-a+1; 1/z)
                     
        Physical Phase Tracking (+iε):
        For z > 1, the physical prescription z -> z + iε dictates that 
        (-z) = e^{-i*pi} * z. Thus (-z)^{-a} = e^{i*pi*a} * z^{-a}.
        This generates the exact imaginary part associated with the particle production threshold.
        """
        z_mp = mpmath.mpc(z)
        inv_z = 1 / z_mp
        
        # Term A: Expansion in z^{-a}
        phase_a = mpmath.exp(mpmath.j * mpmath.pi * a) * mpmath.power(z_mp, -a)
        coeff_a = (mpmath.gamma(c) * mpmath.gamma(b - a)) / (mpmath.gamma(b) * mpmath.gamma(c - a))
        hyp_a = mpmath.hyp2f1(a, a - c + 1, a - b + 1, inv_z)
        term_a = coeff_a * phase_a * hyp_a
        
        # Term B: Expansion in z^{-b}
        phase_b = mpmath.exp(mpmath.j * mpmath.pi * b) * mpmath.power(z_mp, -b)
        coeff_b = (mpmath.gamma(c) * mpmath.gamma(a - b)) / (mpmath.gamma(a) * mpmath.gamma(c - b))
        hyp_b = mpmath.hyp2f1(b, b - c + 1, b - a + 1, inv_z)
        term_b = coeff_b * phase_b * hyp_b
        
        return term_a + term_b

    def Li2_phys(self, z):
        """
        Physical Dilogarithm Li2(z + i*epsilon) for Feynman branch control.
        Consistently handles branch cuts across multi-term expressions.
        """
        eps = mpmath.mpf('1e-30')
        # We use a small imaginary part to select the correct sheet
        # for all polylogarithm evaluations globally.
        return mpmath.polylog(2, z + mpmath.mpc(0, eps))

    def algebraic_continuation_Li2(self, z):
        """
        Algebraic continuation of the Dilogarithm Li_2(z) for |z| > 1 into the Minkowski region.
        
        Applies the standard polylogarithm inversion identity:
        Li_2(z) = -Li_2(1/z) - pi^2/6 - 1/2 * ln^2(-z)
        
        Physical Phase Tracking (+iε):
        For z > 1, the physical prescription z -> z + iε dictates that 
        (-z) = e^{-i*pi} * z. 
        Thus ln(-z) = ln(z) - i*pi.
        This explicitly generates the imaginary part associated with the 
        unequal-mass threshold branch cuts, avoiding any numerical contour integrals.
        """
        z_mp = mpmath.mpc(z)
        if z_mp.real > 1:
            inv_z = 1 / z_mp
            log_z = mpmath.log(z_mp)
            # Physical phase: ln(-z) = ln(z) - i*pi
            phase_log = log_z - mpmath.j * mpmath.pi
            
            term1 = -mpmath.polylog(2, inv_z)
            term2 = - (mpmath.pi**2) / 6
            term3 = - 0.5 * phase_log**2
            
            return term1 + term2 + term3
        else:
            return mpmath.polylog(2, z_mp)
