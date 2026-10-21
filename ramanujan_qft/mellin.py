"""
Mellin-convolution (residue) evaluation of product integrals

    I(s) = Int_0^oo x^(s-1) f(x) g(x) dx .

By the Mellin-Parseval formula I(s) = (1/2 pi i) Int M_f(z) M_g(s - z) dz.
Closing the contour to the left picks up

  * the poles of M_f(z) at z = -p_n -- by Ramanujan's Master Theorem these are
    exactly the Taylor exponents of f at x = 0, with residues equal to the
    Taylor coefficients r_n, and
  * the poles of M_g(s - z) coming from the large-x expansion of g,
    g(x) ~ Sum q_n x^(-a_n), located at z = s - a_n with residues q_n:

    I(s) = Sum_n r_n M_g(s + p_n)  +  Sum_n q_n M_f(s - a_n).

The roles of f and g can be exchanged; :func:`product_integral` evaluates both
orderings when possible and keeps the better-converging one. Coinciding poles
(which produce logarithms) are handled by symmetric evaluation at s +- delta in
extra precision, using the analyticity of I(s).

This is the engine previously called RACE. It is most effective when the
expansion parameter is small, e.g. Int e^(-kx) J_0(bx) dx for b >> k, where
oscillatory quadrature is expensive; it degrades near the convergence boundary
(e.g. b ~ k), where it raises :class:`SeriesConvergenceError` instead of
returning an inaccurate number.
"""

from dataclasses import dataclass
from typing import Callable, Optional, Tuple

import mpmath

__all__ = [
    "MellinFunction", "SeriesConvergenceError", "product_integral",
    "exponential", "gaussian", "bessel_j", "cosine", "sine", "inverse_power",
    "gaussian_bessel",
]


class SeriesConvergenceError(ArithmeticError):
    """Raised when no residue expansion converges to the requested tolerance."""


class _PoleCollision(Exception):
    pass


@dataclass
class MellinFunction:
    """
    A function f(x) on (0, oo) described by its Mellin data.

    func  : x -> f(x)                     (numerical cross-checks / quadrature fallback)
    M     : s -> Int_0^oo x^(s-1) f(x) dx  (analytically continued)
    left  : n -> (p_n, r_n)  Taylor data at 0:   f(x) = Sum r_n x^(p_n)
    right : n -> (a_n, q_n)  expansion at oo:    f(x) ~ Sum q_n x^(-a_n)  (None: decays faster
            than any power or oscillates, i.e. M has no poles to the right)
    """
    name: str
    func: Callable
    M: Callable
    left: Optional[Callable[[int], Tuple]] = None
    right: Optional[Callable[[int], Tuple]] = None


def _m(x):
    return mpmath.mpmathify(x)


def exponential(k):
    """exp(-k x), k > 0."""
    k = _m(k)
    return MellinFunction(
        f"exp(-{k} x)",
        lambda x: mpmath.exp(-k * x),
        lambda s: k**(-s) * mpmath.gamma(s),
        left=lambda n: (n, (-k)**n / mpmath.factorial(n)),
    )


def gaussian(a):
    """exp(-a x^2), a > 0."""
    a = _m(a)
    return MellinFunction(
        f"exp(-{a} x^2)",
        lambda x: mpmath.exp(-a * x * x),
        lambda s: a**(-s / 2) * mpmath.gamma(s / 2) / 2,
        left=lambda n: (2 * n, (-a)**n / mpmath.factorial(n)),
    )


def bessel_j(nu, b):
    """J_nu(b x), b > 0."""
    nu, b = _m(nu), _m(b)
    return MellinFunction(
        f"J_{nu}({b} x)",
        lambda x: mpmath.besselj(nu, b * x),
        lambda s: 2**(s - 1) * b**(-s) * mpmath.gamma((nu + s) / 2) * mpmath.rgamma((nu - s) / 2 + 1),
        left=lambda n: (2 * n + nu, (-1)**n * (b / 2)**(2 * n + nu)
                        / (mpmath.factorial(n) * mpmath.gamma(n + nu + 1))),
    )


def cosine(b):
    """cos(b x), b > 0."""
    b = _m(b)
    return MellinFunction(
        f"cos({b} x)",
        lambda x: mpmath.cos(b * x),
        lambda s: b**(-s) * mpmath.gamma(s) * mpmath.cospi(s / 2),
        left=lambda n: (2 * n, (-1)**n * b**(2 * n) / mpmath.factorial(2 * n)),
    )


def sine(b):
    """sin(b x), b > 0."""
    b = _m(b)
    return MellinFunction(
        f"sin({b} x)",
        lambda x: mpmath.sin(b * x),
        lambda s: b**(-s) * mpmath.gamma(s) * mpmath.sinpi(s / 2),
        left=lambda n: (2 * n + 1, (-1)**n * b**(2 * n + 1) / mpmath.factorial(2 * n + 1)),
    )


def inverse_power(m, v):
    """(x + m)^(-v), m > 0."""
    m, v = _m(m), _m(v)
    coef = lambda n: (-1)**n * mpmath.rf(v, n) / mpmath.factorial(n)
    return MellinFunction(
        f"(x + {m})^(-{v})",
        lambda x: (x + m)**(-v),
        lambda s: m**(s - v) * mpmath.gamma(s) * mpmath.gamma(v - s) / mpmath.gamma(v),
        left=lambda n: (n, coef(n) * m**(-v - n)),
        right=lambda n: (v + n, coef(n) * m**n),
    )


def gaussian_bessel(a, b, nu):
    """exp(-a x^2) J_nu(b x): Mellin transform in closed form via 1F1 (usable as the
    non-expanded factor, e.g. together with an exponential)."""
    a, b, nu = _m(a), _m(b), _m(nu)

    def M(s):
        h = (s + nu) / 2
        return ((b / 2)**nu / (2 * a**h * mpmath.gamma(nu + 1))
                * mpmath.gamma(h) * mpmath.hyp1f1(h, nu + 1, -b * b / (4 * a)))

    return MellinFunction(f"exp(-{a} x^2) J_{nu}({b} x)",
                          lambda x: mpmath.exp(-a * x * x) * mpmath.besselj(nu, b * x), M)


# ---------------------------------------------------------------------------

def _sum_series(term, tol, max_terms):
    """Direct summation with a tail test; Levin-type acceleration as a fallback."""
    total, window, mags = mpmath.mpf(0), [], []
    for n in range(max_terms):
        t = term(n)
        total += t
        a = abs(t)
        window = (window + [a])[-6:]
        mags.append(a)
        if n >= 10 and max(window) <= tol * max(abs(total), tol):
            return total, max(window), n + 1
        if n >= 40 and a > 1e8 * max(min(mags), mpmath.mpf(10)**(-mpmath.mp.dps)) and a > abs(total):
            return None, mpmath.inf, n + 1          # clearly divergent
    try:
        val, err = mpmath.nsum(term, [0, mpmath.inf], error=True)
        return val, err, max_terms
    except Exception:
        return None, mpmath.inf, max_terms


def _ordering_terms(f, g, s):
    """Terms of the residue series with f expanded at 0 (and g at infinity)."""
    def term(n):
        try:
            p, r = f.left(n)
            t = r * g.M(s + p)
            if g.right is not None:
                a, q = g.right(n)
                t += q * f.M(s - a)
        except (ValueError, ZeroDivisionError) as exc:   # gamma pole -> coinciding poles
            raise _PoleCollision from exc
        if not mpmath.isfinite(t):
            raise _PoleCollision
        return t
    return term


def _evaluate(f, g, s, tol, max_terms):
    candidates = []
    for A, B in ((f, g), (g, f)):
        if A.left is None:
            continue
        val, err, n = _sum_series(_ordering_terms(A, B, s), tol, max_terms)
        if val is not None:
            candidates.append((err, val, f"expand {A.name}", n))
    return candidates


def product_integral(f, g, s=1, dps=None, tol=None, max_terms=3000, return_info=False):
    """
    Evaluate Int_0^oo x^(s-1) f(x) g(x) dx by Mellin residue summation.

    Parameters
    ----------
    f, g : MellinFunction
    s : number, Mellin exponent (s = 1 gives the plain integral)
    dps : working precision in decimal digits (default mpmath.mp.dps)
    tol : relative tolerance of the series tail (default 10^(-dps))
    return_info : also return a dict with the chosen expansion, error estimate, terms

    Raises
    ------
    SeriesConvergenceError if no expansion reaches the tolerance.
    """
    dps = dps if dps is not None else mpmath.mp.dps
    with mpmath.workdps(dps):
        tol_ = mpmath.mpf(tol) if tol is not None else mpmath.mpf(10)**(-dps)
        s = mpmath.mpmathify(s)
        try:
            cands = _evaluate(f, g, s, tol_, max_terms)
            collided = False
        except _PoleCollision:
            collided = True
        if collided:
            # Coinciding poles: I(s) is analytic, so average I(s+d) and I(s-d); the error
            # is O(d^2). d is kept well above the working epsilon because mpmath's gamma
            # loses accuracy extremely close to its poles.
            with mpmath.workdps(2 * dps + 20):
                d = mpmath.mpf(10)**(-(dps // 2 + 3))
                cp = _evaluate(f, g, s + d, tol_ / 10, max_terms)
                cm = _evaluate(f, g, s - d, tol_ / 10, max_terms)
                cands = []
                for (ep, vp, how, n), (em, vm, _, _) in zip(sorted(cp, key=lambda c: c[0]),
                                                           sorted(cm, key=lambda c: c[0])):
                    cands.append((max(ep, em), (vp + vm) / 2, how + " (pole collision, s +- delta)", n))
        if not cands:
            raise SeriesConvergenceError(f"no residue expansion of {f.name} * {g.name} converged")
        err, val, how, n = min(cands, key=lambda c: c[0])
        if err > tol_ * max(abs(val), 1) * 100:
            raise SeriesConvergenceError(
                f"residue series for {f.name} * {g.name} only reached error ~{mpmath.nstr(err, 3)} "
                f"(tolerance {mpmath.nstr(tol_, 3)}); the expansion parameter is close to the "
                f"convergence boundary - use numerical quadrature for this point")
        val = +val
        if return_info:
            return val, {"method": how, "error_estimate": err, "terms": n}
        return val
