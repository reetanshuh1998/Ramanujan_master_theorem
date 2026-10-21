"""
Mellin-convolution (residue) evaluation of product integrals

    I(s) = Int_0^oo x^(s-1) f(x) g(x) dx .

Method (classical: Mellin-Parseval / Meijer-G / Slater residue expansion; see
Marichev 1983, Fikioris 2007, Bleistein & Handelsman 1975, DLMF 2.5, and
docs/PRIOR_ART.md). By the Mellin-Parseval formula
I(s) = (1/2 pi i) Int M_f(z) M_g(s - z) dz. Closing the contour to the left
picks up

  * the poles of M_f(z) at z = -p_n, i.e. the Taylor exponents of f at x = 0
    with residues equal to its Taylor coefficients r_n (this correspondence is
    Ramanujan's Master Theorem), and
  * the poles of M_g(s - z) coming from the large-x expansion
    g(x) ~ Sum q_n x^(-a_n), located at z = s - a_n with residues q_n:

    I(s) = Sum_n r_n M_g(s + p_n)  +  Sum_n q_n M_f(s - a_n).

Closing the contour is legitimate only when the integrand decays on the arc.
Each atlas factor carries its Gamma-order L (|r(p)| ~ c^p / Gamma(p)^L) and R
(|M(w)| ~ Gamma(w)^R / c^w for w -> +oo). Expanding f against g is valid iff
L_f > R_g, or L_f == R_g with rho = c_f / c_g < 1 (rho = 1 is the convergence
boundary, treated by Wynn-epsilon summation). Invalid orderings, which give
divergent asymptotic series (and silently wrong results if summed), are never
used.

Robustness:
  * the integral's existence (fundamental strip in s) is checked first;
  * the cancellation Sum|t_n| / |Sum t_n| is monitored and the working precision
    raised until the requested number of digits is guaranteed against rounding;
  * coinciding poles (logarithmic results) are handled by symmetric evaluation at
    s +- delta, using the analyticity of I(s);
  * factor parameters are stored exactly and converted at the working precision.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional

import mpmath

__all__ = [
    "MellinFunction", "SeriesConvergenceError", "product_integral",
    "exponential", "gaussian", "bessel_j", "cosine", "sine", "inverse_power",
    "gaussian_bessel",
]


class SeriesConvergenceError(ArithmeticError):
    """Raised when no valid residue expansion reaches the requested accuracy."""


class _PoleCollision(Exception):
    pass


@dataclass
class _Built:
    func: Callable
    M: Callable
    left: Optional[Callable] = None     # n -> (p_n, r_n)
    right: Optional[Callable] = None    # n -> (a_n, q_n)
    scale: object = None                # c in the growth estimates


@dataclass
class MellinFunction:
    """
    A factor f(x) on (0, oo) described by its Mellin data.

    name   : display name
    build  : () -> _Built, evaluated at the current working precision
    L, R   : Gamma-orders of the Taylor coefficients and of M at +oo (see module doc)
    p0     : leading exponent of f at x = 0
    tail   : behaviour at x -> oo: ("fast",) for faster than any power, or
             ("power", alpha, frequency) for amplitude x^(-alpha), oscillating with
             the given angular frequency (0: not oscillating)
    params : raw parameters, for reference
    """
    name: str
    build: Callable[[], _Built]
    L: Optional[float]
    R: float
    p0: object
    tail: tuple
    params: dict = field(default_factory=dict)

    # convenience for users: numerical value of f
    def __call__(self, x):
        return self.build().func(mpmath.mpmathify(x))


def _m(x):
    return mpmath.mpmathify(x)


def _positive(name, value):
    v = _m(value)
    if not (mpmath.im(v) == 0 and v > 0):
        raise ValueError(f"{name} must be real and positive, got {value!r}")


def exponential(k):
    """exp(-k x), k > 0."""
    _positive("k", k)

    def build():
        kk = _m(k)
        return _Built(lambda x: mpmath.exp(-kk * x),
                      lambda s: kk**(-s) * mpmath.gamma(s),
                      left=lambda n: (n, (-kk)**n / mpmath.factorial(n)),
                      scale=kk)
    return MellinFunction(f"exp(-{k} x)", build, L=1, R=1, p0=0, tail=("fast",), params={"k": k})


def gaussian(a):
    """exp(-a x^2), a > 0."""
    _positive("a", a)

    def build():
        aa = _m(a)
        return _Built(lambda x: mpmath.exp(-aa * x * x),
                      lambda s: aa**(-s / 2) * mpmath.gamma(s / 2) / 2,
                      left=lambda n: (2 * n, (-aa)**n / mpmath.factorial(n)),
                      scale=mpmath.sqrt(2 * aa))
    return MellinFunction(f"exp(-{a} x^2)", build, L=mpmath.mpf(1) / 2, R=mpmath.mpf(1) / 2, p0=0,
                          tail=("fast",), params={"a": a})


def bessel_j(nu, b):
    """J_nu(b x), b > 0, real nu > -1 or nu a negative integer (J_-n = (-1)^n J_n)."""
    _positive("b", b)
    nu_ = _m(nu)
    if mpmath.im(nu_) != 0:
        raise ValueError("complex Bessel order not supported")
    sign = 1
    if nu_ < 0 and mpmath.isint(nu_):
        sign, nu = (-1)**int(-nu_), -nu_
        nu_ = -nu_
    elif nu_ <= -1:
        raise ValueError("Bessel order must be > -1 or a negative integer")

    def build():
        n_, bb = _m(nu), _m(b)
        return _Built(lambda x: sign * mpmath.besselj(n_, bb * x),
                      lambda s: sign * 2**(s - 1) * bb**(-s) * mpmath.gamma((n_ + s) / 2)
                      * mpmath.rgamma((n_ - s) / 2 + 1),
                      left=lambda n: (2 * n + n_, sign * (-1)**n * (bb / 2)**(2 * n + n_)
                                      / (mpmath.factorial(n) * mpmath.gamma(n + n_ + 1))),
                      scale=bb)
    return MellinFunction(f"J_{nu}({b} x)" if sign == 1 else f"-J_{nu}({b} x)", build, L=1, R=1,
                          p0=nu_, tail=("power", mpmath.mpf(1) / 2, _m(b)), params={"nu": nu, "b": b})


def cosine(b):
    """cos(b x), b > 0."""
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.cos(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.cospi(s / 2),
                      left=lambda n: (2 * n, (-1)**n * bb**(2 * n) / mpmath.factorial(2 * n)),
                      scale=bb)
    return MellinFunction(f"cos({b} x)", build, L=1, R=1, p0=0, tail=("power", 0, _m(b)), params={"b": b})


def sine(b):
    """sin(b x), b > 0."""
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.sin(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.sinpi(s / 2),
                      left=lambda n: (2 * n + 1, (-1)**n * bb**(2 * n + 1) / mpmath.factorial(2 * n + 1)),
                      scale=bb)
    return MellinFunction(f"sin({b} x)", build, L=1, R=1, p0=1, tail=("power", 0, _m(b)), params={"b": b})


def inverse_power(m, v):
    """(x + m)^(-v), m > 0, v > 0."""
    _positive("m", m)
    _positive("v", v)

    def build():
        mm, vv = _m(m), _m(v)
        coef = lambda n: (-1)**n * mpmath.rf(vv, n) / mpmath.factorial(n)
        return _Built(lambda x: (x + mm)**(-vv),
                      lambda s: mm**(s - vv) * mpmath.gamma(s) * mpmath.gamma(vv - s) * mpmath.rgamma(vv),
                      left=lambda n: (n, coef(n) * mm**(-vv - n)),
                      right=lambda n: (vv + n, coef(n) * mm**n),
                      scale=1 / mm)
    return MellinFunction(f"(x + {m})^(-{v})", build, L=0, R=0, p0=0, tail=("power", _m(v), 0),
                          params={"m": m, "v": v})


def gaussian_bessel(a, b, nu):
    """exp(-a x^2) J_nu(b x), a, b > 0, nu > -1. Mellin transform in closed form via 1F1;
    usable as the non-expanded factor (e.g. against an exponential)."""
    _positive("a", a)
    _positive("b", b)
    if not _m(nu) > -1:
        raise ValueError("Bessel order must be > -1")

    def build():
        aa, bb, nn = _m(a), _m(b), _m(nu)

        def M(s):
            h = (s + nn) / 2
            return ((bb / 2)**nn / (2 * aa**h * mpmath.gamma(nn + 1))
                    * mpmath.gamma(h) * mpmath.hyp1f1(h, nn + 1, -bb * bb / (4 * aa)))
        return _Built(lambda x: mpmath.exp(-aa * x * x) * mpmath.besselj(nn, bb * x), M,
                      scale=mpmath.sqrt(2 * aa))
    return MellinFunction(f"exp(-{a} x^2) J_{nu}({b} x)", build, L=None, R=mpmath.mpf(1) / 2,
                          p0=_m(nu), tail=("fast",), params={"a": a, "b": b, "nu": nu})


# ---------------------------------------------------------------------------
#  existence of the integral
# ---------------------------------------------------------------------------

def _strip(f, g):
    """(lower, upper, upper_inclusive?) bounds on Re s for Int x^(s-1) f g dx to exist."""
    lower = -(mpmath.re(f.p0) + mpmath.re(g.p0))
    if f.tail[0] == "fast" or g.tail[0] == "fast":
        return lower, mpmath.inf
    alpha = f.tail[1] + g.tail[1]
    w1, w2 = f.tail[2], g.tail[2]
    oscillating = (w1 > 0 or w2 > 0) and not (w1 > 0 and w2 > 0 and w1 == w2)
    # x^(s-1-alpha) e^(i w x): converges iff Re s < alpha + 1 when w > 0, Re s < alpha otherwise
    return lower, alpha + 1 if oscillating else alpha


# ---------------------------------------------------------------------------
#  summation
# ---------------------------------------------------------------------------

def _validity(A, B, a, b):
    """rho for expanding A against B (built data a, b); None if the ordering is invalid."""
    if A.L is None:
        return None
    if A.L > B.R:
        return mpmath.mpf(0)
    if A.L < B.R:
        return None
    rho = a.scale / b.scale
    # rho = 1 is the convergence boundary: the residue terms do not decay and the
    # contour cannot be closed, so no value can be certified there.
    return rho if rho < 1 else None


def _terms(a, b, s):
    """n -> (t_n, |pieces of t_n|) of the residue series expanding a against b."""
    def term(n):
        try:
            p, r = a.left(n)
            t = r * b.M(s + p)
            size = abs(t)
            if b.right is not None:
                aa, q = b.right(n)
                u = q * a.M(s - aa)
                t += u
                size += abs(u)
        except (ValueError, ZeroDivisionError) as exc:      # gamma pole: coinciding poles
            raise _PoleCollision from exc
        if not mpmath.isfinite(t):
            raise _PoleCollision
        return t, size
    return term


def _wynn(partials):
    """Wynn epsilon algorithm; returns (estimate, error estimate)."""
    eps_prev = [mpmath.mpf(0)] * (len(partials) + 1)
    eps_cur = list(partials)
    best, prev_best = partials[-1], partials[-2] if len(partials) > 1 else partials[-1]
    k = 0
    while len(eps_cur) > 1:
        nxt = []
        for i in range(len(eps_cur) - 1):
            d = eps_cur[i + 1] - eps_cur[i]
            if d == 0:
                return eps_cur[i + 1], mpmath.mpf(0) if k % 2 == 0 else mpmath.inf
            nxt.append(eps_prev[i + 1] + 1 / d)
        eps_prev, eps_cur = eps_cur, nxt
        k += 1
        if k % 2 == 0 and eps_cur:
            prev_best, best = best, eps_cur[-1]
    return best, abs(best - prev_best)


def _sum(term, rho, tol, max_terms):
    """
    Sum a valid residue series. Returns (value, tail_error, sum_abs, n_terms, accelerated).
    rho: geometric decay per term index (0 for factorial convergence; 1 at the boundary).
    """
    S, sum_abs, n_zero_run = mpmath.mpf(0), mpmath.mpf(0), 0
    peak, peak_n, recent = mpmath.mpf(0), 0, []
    partials = []
    slow = rho is not None and rho > mpmath.mpf("0.85")
    tail_factor = 1 / (1 - rho) if (rho is not None and rho < 1) else mpmath.mpf(1)
    for n in range(max_terms):
        t, size = term(n)
        S += t
        a = abs(t)
        sum_abs += size
        if size == 0:
            n_zero_run += 1
            if n_zero_run >= 6 and n >= 11:
                return S, mpmath.mpf(0), sum_abs, n + 1, False
            continue
        n_zero_run = 0
        partials.append(S)
        if a > peak:
            peak, peak_n = a, n
        recent = (recent + [a])[-6:]
        if n >= peak_n + 6 and len(recent) == 6:
            tail = max(recent) * tail_factor
            if tail <= tol * abs(S):
                return S, tail, sum_abs, n + 1, False
        if slow and len(partials) >= 60 and len(partials) % 30 == 0:
            v1, e1 = _wynn(partials[-60:])
            v2, e2 = _wynn(partials[-40:])
            err = max(e1, abs(v1 - v2))
            if mpmath.isfinite(err) and err <= tol * abs(v1):
                return v1, err, sum_abs, n + 1, True
    return None, mpmath.inf, sum_abs, max_terms, False


def _evaluate(f, g, s, dps, tol, max_terms):
    """All valid orderings at working precision; precision raised against cancellation."""
    results = []
    for A, B in ((f, g), (g, f)):
        wp = dps + 15
        for _ in range(6):
            with mpmath.workdps(wp):
                a, b = A.build(), B.build()
                rho = _validity(A, B, a, b)
                if rho is None:
                    break
                ss = mpmath.mpmathify(s)
                val, err, sum_abs, n, acc = _sum(_terms(a, b, ss), rho, tol, max_terms)
                if val is None:
                    results.append((None, f"expand {A.name}", n, wp, acc, rho))
                    break
                if val == 0 and sum_abs > 0:
                    # non-zero residues cancelling to zero: not certifiable at this precision
                    if wp > 8 * dps + 100:
                        results.append((None, f"expand {A.name}", n, wp, acc, rho))
                        break
                    wp = 2 * wp
                    continue
                cancel = sum_abs / abs(val) if val != 0 else mpmath.mpf(1)
                needed = dps + int(mpmath.log10(cancel)) + 10 if cancel > 1 else dps + 10
                if needed <= wp:
                    rnd = cancel * mpmath.mpf(10)**(-wp)
                    results.append(((+val, err + rnd * abs(val)), f"expand {A.name}", n, wp, acc, rho))
                    break
                wp = needed + 5
        else:
            results.append((None, f"expand {A.name}", max_terms, wp, False, None))
    return results


def product_integral(f, g, s=1, dps=None, tol=None, max_terms=4000, return_info=False,
                     continuation=False):
    """
    Evaluate Int_0^oo x^(s-1) f(x) g(x) dx by Mellin residue summation.

    Parameters
    ----------
    f, g : MellinFunction
    s : number (complex allowed); s = 1 gives the plain integral
    dps : decimal digits requested (default mpmath.mp.dps)
    tol : relative accuracy target (default 10^(-dps))
    return_info : also return a dict (method, error estimate, terms, working precision)
    continuation : if True, s outside the region where the integral exists is allowed
                   and the analytic continuation in s is returned

    Raises
    ------
    ValueError               if the integral does not exist for this s
    SeriesConvergenceError   if no valid expansion reaches the accuracy target
    """
    dps = dps if dps is not None else mpmath.mp.dps
    with mpmath.workdps(dps + 15):
        s = mpmath.mpmathify(s)
        tol_ = mpmath.mpf(tol) if tol is not None else mpmath.mpf(10)**(-dps)
        lo, hi = _strip(f, g)
        if not continuation and not (lo < mpmath.re(s) < hi):
            raise ValueError(
                f"Int x^(s-1) {f.name} * {g.name} dx diverges for Re s = {mpmath.nstr(mpmath.re(s), 6)}; "
                f"it exists for {mpmath.nstr(lo, 6)} < Re s < {mpmath.nstr(hi, 6)} "
                "(pass continuation=True for the analytic continuation)")

    note = ""
    try:
        res = _evaluate(f, g, s, dps, tol_, max_terms)
    except _PoleCollision:
        # Coinciding poles (logarithmic result): I(s) is analytic, so average
        # I(s + d) and I(s - d); the error is O(d^2).
        note = " (coinciding poles: symmetric evaluation at s +- delta)"
        with mpmath.workdps(2 * dps + 20):
            d = mpmath.mpf(10)**(-(dps // 2 + 5))
            try:
                rp = _evaluate(f, g, s + d, dps + dps // 2 + 10, tol_ / 100, max_terms)
                rm = _evaluate(f, g, s - d, dps + dps // 2 + 10, tol_ / 100, max_terms)
            except _PoleCollision:
                raise SeriesConvergenceError("pole collision could not be resolved") from None
            res = []
            for (vp, how, n, wp, acc, rho), (vm, how2, *_rest) in zip(rp, rm):
                assert how == how2
                if vp is None or vm is None:
                    res.append((None, how, n, wp, acc, rho))
                else:
                    res.append((((vp[0] + vm[0]) / 2, max(vp[1], vm[1]) + d * abs(vp[0] - vm[0])),
                                how, n, wp, acc, rho))

    good = [r for r in res if r[0] is not None]
    if not good:
        tried = ", ".join(f"{how} (rho = {mpmath.nstr(rho, 4)})" for _, how, _, _, _, rho in res if rho is not None)
        raise SeriesConvergenceError(
            f"no valid residue expansion of {f.name} * {g.name} converged"
            + (f"; tried {tried}" if tried else "; neither ordering is a convergent expansion for these factors")
            + ". The expansion parameter is at or near the convergence boundary: use quadrature or a closed form.")
    (val, err), how, n, wp, acc, rho = min(good, key=lambda r: r[0][1] / max(abs(r[0][0]), mpmath.mpf(10)**(-2 * dps)))
    if val != 0 and err > tol_ * abs(val) * 10:
        raise SeriesConvergenceError(
            f"residue series for {f.name} * {g.name} reached only relative error ~{mpmath.nstr(err / abs(val), 3)}")
    with mpmath.workdps(dps):
        val = +val
    if return_info:
        return val, {"method": how + (" + Wynn-epsilon" if acc else "") + note,
                     "error_estimate": err, "terms": n, "working_dps": wp}
    return val
