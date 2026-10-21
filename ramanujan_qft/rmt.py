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

    Notes
    -----
    The theorem holds only for the continuation of phi that satisfies Hardy's
    growth condition (|phi(v)| <= C e^(P Re v + A |Im v|) with A < pi, for Re v
    > -delta). A function agreeing with phi on the integers but growing faster
    (e.g. phi(v) + sin(pi v)) gives a wrong result, and no implementation can
    detect this from a black-box callable. See Amdeberhan et al., Ramanujan J.
    29 (2012) 103, Theorem 1.2.

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
    Numerical Mellin transform Int_0^oo x^(s-1) f(x) dx, intended for cross-checks
    of non-oscillatory f with power-law behaviour x^p0 at 0 and power-law (or
    faster) decay at infinity.

    Algebraic endpoint behaviour is removed by substitution before tanh-sinh
    quadrature: x = y^(1/sigma) on [0, 1] (sigma = Re s + p0), and x = y^(-1/c) on
    [1, oo), where c = a - sigma is estimated from the decay f(x) ~ x^(-a) at large x
    (sampled over several decades). Raises ValueError when the decay estimate is
    inconsistent or insufficient, and ArithmeticError when the quadrature error
    estimate does not reach about half of the working digits.
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s = mpmath.mpmathify(s)
        sig = mpmath.re(s)
        if sig <= 0:
            raise ValueError("mellin_numeric requires Re(s) > 0")
        tol = mpmath.mpf(10)**(-(mpmath.mp.dps // 2))
        # leading behaviour f(x) ~ x^p0 at x -> 0, from samples over several decades
        Y = [mpmath.mpf(10)**(-k) for k in (4, 6, 8, 10, 12)]
        fy = [abs(f(y)) for y in Y]
        if any(v == 0 for v in fy):
            raise ValueError("cannot estimate the behaviour of f at x -> 0 (zeros at sample points)")
        sl = [mpmath.log(fy[i + 1] / fy[i]) / mpmath.log(Y[i + 1] / Y[i]) for i in range(len(Y) - 1)]
        if max(sl) - min(sl) > mpmath.mpf("0.05") * max(1, abs(sl[-1])):
            raise ValueError("f is not in its power-law regime for x in [1e-12, 1e-4]")
        p0 = mpmath.nint(sl[-1] * 1000) / 1000      # snap to the nearest 1e-3
        sig0 = sig + p0
        if sig0 <= mpmath.mpf("0.01"):
            raise ValueError("the Mellin integral diverges (or nearly so) at x = 0 for this s")
        inner, e1 = mpmath.quad(lambda y: y**(s / sig0 - 1) * f(y**(1 / sig0)) / sig0 if y > 0 else 0,
                                [0, 1], error=True)

        X = [mpmath.mpf(10)**k for k in (4, 6, 8, 10, 12)]
        vals = [abs(f(x)) for x in X]
        if all(v == 0 for v in vals[1:]):
            a = mpmath.inf                     # faster than any power
        else:
            if any(v == 0 for v in vals):
                raise ValueError("cannot estimate the decay of f at infinity (zeros at sample points)")
            slopes = [-mpmath.log(vals[i + 1] / vals[i]) / mpmath.log(X[i + 1] / X[i]) for i in range(len(X) - 1)]
            if min(slopes) > 20:
                a = mpmath.inf                 # decays faster than x^-20 over the whole range
            elif max(slopes) - min(slopes) > mpmath.mpf("0.05") * max(1, abs(slopes[-1])):
                raise ValueError("f is not in its power-law regime for x in [1e4, 1e12]; decay estimate unreliable")
            else:
                a = slopes[-1]
        c = a - sig
        if c <= mpmath.mpf("0.01"):
            raise ValueError("the Mellin integral diverges (or nearly so) at infinity for this s")
        c = min(c, mpmath.mpf(1))
        outer, e2 = mpmath.quad(lambda y: y**((-s - 1) / c + 1 / c - 1) * f(y**(-1 / c)) / c if y > 0 else 0,
                                [0, 1], error=True)
        val = inner + outer
        if e1 + e2 > tol * max(abs(val), tol):
            raise ArithmeticError(f"quadrature did not converge (error estimate {mpmath.nstr(e1 + e2, 3)})")
        return val


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
        if not m2 > 0:
            raise ValueError("msq must be positive")
        phi = lambda n: mpmath.gamma(n + 1) / m2**(n + 1)
        return ramanujan_master_theorem(phi, D / 2)
