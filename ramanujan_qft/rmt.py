"""
Ramanujan's Master Theorem (RMT).

If  f(x) = Sum_{n>=0} phi(n) (-x)^n / n!  and phi extends to a suitable
analytic function (Hardy's growth conditions), then

    Int_0^oo x^(s-1) f(x) dx = Gamma(s) phi(-s)

for s in the fundamental strip. See T. Amdeberhan et al., "Ramanujan's Master
Theorem", Ramanujan J. 29 (2012) 103, and I. Gonzalez, V. H. Moll, I. Schmidt,
Adv. Appl. Math. 63 (2015) 214 for the connection with Feynman integrals
(the Method of Brackets).

The functions here are deliberately small: they implement the theorem exactly
and provide a numerical Mellin transform so every application can be checked.
"""

import mpmath

__all__ = ["ramanujan_master_theorem", "mellin_numeric", "massive_propagator_rmt"]


def ramanujan_master_theorem(phi, s, dps=None):
    """
    Mellin transform via RMT:  Int_0^oo x^(s-1) Sum phi(n)(-x)^n/n! dx = Gamma(s) phi(-s).

    Parameters
    ----------
    phi : callable
        Analytic continuation of the Taylor-coefficient function phi(n).
    s : number
        Mellin variable, inside the fundamental strip of the integral.

    Examples
    --------
    >>> import mpmath
    >>> # exp(-x): phi(n) = 1  ->  Gamma(s)
    >>> ramanujan_master_theorem(lambda n: 1, 2.5) - mpmath.gamma(2.5)
    mpf('0.0')
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s = mpmath.mpmathify(s)
        return +(mpmath.gamma(s) * phi(-s))


def mellin_numeric(f, s, dps=None):
    """
    Numerical Mellin transform Int_0^oo x^(s-1) f(x) dx (for cross-checks of
    non-oscillatory f, Re s > 0, f regular at 0).

    Algebraic endpoint behaviour is removed by substitution before tanh-sinh
    quadrature: x = y^(1/sigma) on [0, 1] (sigma = Re s), and x = y^(-1/c) on
    [1, oo), where c = a - sigma is estimated from the power-law decay
    f(x) ~ x^(-a) at large x.
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s = mpmath.mpmathify(s)
        sig = mpmath.re(s)
        if sig <= 0:
            raise ValueError("mellin_numeric requires Re(s) > 0")
        inner = mpmath.quad(lambda y: y**(s / sig - 1) * f(y**(1 / sig)) / sig if y > 0 else 0, [0, 1])

        X1, X2 = mpmath.mpf(10)**6, mpmath.mpf(10)**8
        f1, f2 = abs(f(X1)), abs(f(X2))
        a = mpmath.inf if f2 == 0 or f1 == 0 else -mpmath.log(f2 / f1) / mpmath.log(X2 / X1)
        c = a - sig
        if c <= 0:
            raise ValueError("the Mellin integral diverges at infinity for this s")
        c = min(c, mpmath.mpf(1))
        outer = mpmath.quad(lambda y: y**((-s - 1) / c + 1 / c - 1) * f(y**(-1 / c)) / c if y > 0 else 0, [0, 1])
        return inner + outer


def massive_propagator_rmt(msq, D, dps=None):
    """
    Radial integral of a massive propagator by RMT:

        Int_0^oo dq2 (q2)^(D/2 - 1) / (q2 + m^2) = (m^2)^(D/2 - 1) Gamma(D/2) Gamma(1 - D/2).

    Writing 1/(q2 + m^2) = Sum_n (-q2)^n n!/(n! (m^2)^(n+1)), i.e. phi(n) = Gamma(n+1)/(m^2)^(n+1),
    RMT with s = D/2 gives Gamma(D/2) phi(-D/2). Valid (convergent) for 0 < D < 2 and
    defined elsewhere by analytic continuation -- exactly dimensional regularisation.
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        m2, D = mpmath.mpf(msq), mpmath.mpmathify(D)
        phi = lambda n: mpmath.gamma(n + 1) / m2**(n + 1)
        return ramanujan_master_theorem(phi, D / 2)
