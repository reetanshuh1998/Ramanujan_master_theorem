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
L_f > R_g, or L_f == R_g with rho = c_f / c_g < 1. rho = 1 is the convergence
boundary, where no value is returned. Invalid orderings, which give divergent
asymptotic series (and silently wrong results if summed), are never used.

Robustness:
  * the integral's existence (fundamental strip in s) is checked first, including
    equal-frequency oscillatory products whose non-oscillating beat term vanishes;
  * inputs are represented exactly next to the integer shifts p_n (so s + p_n near a
    zero or pole of a Gamma/trigonometric factor is formed without rounding);
  * the stopping rule waits until the terms are past their a-priori peak;
  * the cancellation Sum|t_n| / |Sum t_n| is monitored and the working precision
    raised until the requested number of digits is guaranteed against rounding;
  * slowly convergent alternating series (rho > 0.85) are accelerated by the Wynn
    epsilon algorithm with a conservative, disjoint-window error estimate;
  * coinciding poles (logarithmic results) are handled by symmetric evaluation at
    s +- delta (Richardson-extrapolated, delta scaled to the distance from the
    nearest singularity of I(s));
  * factor parameters are stored exactly and converted at the working precision.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional

import mpmath
from mpmath.libmp import NoConvergence

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
             ("power", alpha, frequency, phase) for amplitude x^(-alpha) cos(w x + phase),
             frequency 0 meaning not oscillating; phase in units of pi/4
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
                          p0=nu_, tail=("power", mpmath.mpf(1) / 2, b, -(2 * nu_ + 1)), params={"nu": nu, "b": b})


def cosine(b):
    """cos(b x), b > 0."""
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.cos(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.cospi(s / 2),
                      left=lambda n: (2 * n, (-1)**n * bb**(2 * n) / mpmath.factorial(2 * n)),
                      scale=bb)
    return MellinFunction(f"cos({b} x)", build, L=1, R=1, p0=0, tail=("power", 0, b, 0), params={"b": b})


def sine(b):
    """sin(b x), b > 0."""
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.sin(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.sinpi(s / 2),
                      left=lambda n: (2 * n + 1, (-1)**n * bb**(2 * n + 1) / mpmath.factorial(2 * n + 1)),
                      scale=bb)
    return MellinFunction(f"sin({b} x)", build, L=1, R=1, p0=1, tail=("power", 0, b, -2), params={"b": b})


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
    return MellinFunction(f"(x + {m})^(-{v})", build, L=0, R=0, p0=0, tail=("power", _m(v), 0, None),
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

def _same(x, y):
    with mpmath.workdps(60):
        return _m(x) == _m(y)


def _strip(f, g):
    """(lower, upper) bounds on Re s for Int x^(s-1) f g dx to exist."""
    lower = -(mpmath.re(f.p0) + mpmath.re(g.p0))
    if f.tail[0] == "fast" or g.tail[0] == "fast":
        return lower, mpmath.inf
    alpha = f.tail[1] + g.tail[1]
    (w1, ph1), (w2, ph2) = f.tail[2:4], g.tail[2:4]
    o1, o2 = _m(w1) > 0, _m(w2) > 0
    if not (o1 or o2):
        return lower, alpha                      # non-oscillating power law
    if o1 and o2 and _same(w1, w2):
        # cos(wx + ph1) cos(wx + ph2) = [cos(ph1 - ph2) + cos(2wx + ph1 + ph2)]/2:
        # a non-oscillating x^-alpha term survives unless cos(ph1 - ph2) = 0
        dq = _m(ph1) - _m(ph2)                   # in units of pi/4
        if mpmath.isint(dq) and int(dq) % 4 == 2:
            return lower, alpha + 1
        return lower, alpha
    return lower, alpha + 1                      # x^(s-1-alpha) e^(iwx) converges for Re s < alpha + 1


# ---------------------------------------------------------------------------
#  summation
# ---------------------------------------------------------------------------

class _OrderingFailed(Exception):
    pass


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


def _min_terms(A, B, a, b, rho):
    """Index beyond which the terms are in their asymptotic (decaying) regime."""
    if rho == 0:
        ratio = a.scale / b.scale
        if ratio <= 1:
            return 10
        p_star = ratio**(1 / (A.L - B.R))       # peak of ratio^p Gamma(p)^(R-L)
        step = a.left(1)[0] - a.left(0)[0]
        return int(2 * p_star / step) + 10
    return 10 + int(3 / (1 - rho))


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
        except NoConvergence as exc:
            raise _OrderingFailed("a special-function evaluation did not converge") from exc
        except (ValueError, ZeroDivisionError) as exc:      # gamma pole: coinciding poles
            raise _PoleCollision from exc
        if not mpmath.isfinite(t):
            raise _PoleCollision
        return t, size
    return term


def _wynn(partials):
    """Wynn epsilon algorithm; returns the last even-column estimate. A vanishing
    difference means that column has converged numerically: its value is returned
    as the estimate (its reliability is judged by the caller, not here)."""
    eps_prev = [mpmath.mpf(0)] * (len(partials) + 1)
    eps_cur = list(partials)
    best = partials[-1]
    k = 0
    while len(eps_cur) > 1:
        nxt = []
        for i in range(len(eps_cur) - 1):
            d = eps_cur[i + 1] - eps_cur[i]
            if d == 0:
                return eps_cur[-1] if k % 2 == 0 else best
            nxt.append(eps_prev[i + 1] + 1 / d)
        eps_prev, eps_cur = eps_cur, nxt
        k += 1
        if k % 2 == 0 and eps_cur:
            best = eps_cur[-1]
    return best


def _sum(term, rho, tol, max_terms, n_min):
    """
    Sum a valid residue series. Returns (value, tail_error, sum_abs, n_terms, accelerated).
    rho: geometric decay per term index (0 for factorial convergence).
    """
    S, sum_abs, n_zero_run = mpmath.mpf(0), mpmath.mpf(0), 0
    peak, peak_n, recent, last_terms = mpmath.mpf(0), 0, [], []
    partials, wynn_prev = [], None
    slow = rho > mpmath.mpf("0.85")
    tail_factor = 1 / (1 - rho)
    for n in range(max_terms):
        t, size = term(n)
        S += t
        a = abs(t)
        sum_abs += size
        if size == 0:
            n_zero_run += 1
            if n_zero_run >= 6 and n >= max(11, n_min):
                return S, mpmath.mpf(0), sum_abs, n + 1, False
            continue
        n_zero_run = 0
        partials.append(S)
        last_terms = (last_terms + [t])[-31:]
        if a > peak:
            peak, peak_n = a, n
        recent = (recent + [a])[-6:]
        if n >= max(peak_n + 6, n_min) and len(recent) == 6:
            tail = max(recent) * tail_factor
            if tail <= tol * abs(S):
                return S, tail, sum_abs, n + 1, False
        if slow and len(partials) >= 90 and len(partials) % 30 == 0:
            # Wynn epsilon is reliable for alternating-type series only
            ratios = [last_terms[i + 1] / last_terms[i] for i in range(len(last_terms) - 1)]
            alternating = sum(1 for r in ratios if mpmath.re(r) < 0) >= 0.8 * len(ratios)
            v1, v2 = _wynn(partials[-60:]), _wynn(partials[-90:-30])
            if alternating and v1 is not None and v2 is not None:
                err = 10 * abs(v1 - v2)
                if wynn_prev is not None:
                    err = max(err, 10 * abs(v1 - wynn_prev))
                if err <= tol * abs(v1) and wynn_prev is not None:
                    return v1, err, sum_abs, n + 1, True
                wynn_prev = v1
    return None, mpmath.inf, sum_abs, max_terms, False


def _input_dps(f, g, s):
    """Digits needed to represent all inputs exactly next to the integer shifts p_n
    (so that s + p_n, nu - s, ... are formed without rounding near lattice points)."""
    need = 0
    vals = list(f.params.values()) + list(g.params.values()) + [s]
    for x in vals:
        if isinstance(x, (mpmath.mpc, complex)):
            parts = (mpmath.re(x), mpmath.im(x))
        else:
            parts = (x,)
        for y in parts:
            if isinstance(y, str):
                with mpmath.workdps(30):
                    v = _m(y)
                    if v != 0 and abs(v) < 1:
                        need = max(need, 30 + int(-mpmath.log10(abs(v))))
                continue
            with mpmath.workdps(4000):
                v = _m(y)
            if not isinstance(v, mpmath.mpf) or v == 0:
                continue
            sign, man, exp, bc = v._mpf_
            bits = max(exp + bc, 12) - exp
            need = max(need, int(bits * 0.30103) + 3)
    return need


def _evaluate(f, g, s, dps, tol, max_terms, max_dps):
    """All valid orderings, with working precision raised against cancellation.
    Returns a list of (value-or-None, err, method, n, wp, accelerated, rho, reason)."""
    results = []
    base = max(dps + 15, _input_dps(f, g, s) + 10)
    for A, B in ((f, g), (g, f)):
        wp = base
        with mpmath.workdps(wp):
            rho = _validity(A, B, A.build(), B.build())
        if rho is None:
            continue
        how = f"expand {A.name}"
        for _ in range(12):
            if wp > max_dps:
                results.append((None, None, how, 0, wp, False, rho, f"needs more than max_dps={max_dps} digits"))
                break
            with mpmath.workdps(wp):
                a, b = A.build(), B.build()
                ss = mpmath.mpmathify(s)
                n_min = _min_terms(A, B, a, b, rho)
                if rho > mpmath.mpf("0.85"):
                    n_min = min(n_min, max_terms)      # slow geometric series: Wynn may still succeed
                if n_min > max_terms:
                    results.append((None, None, how, n_min, wp, False, rho,
                                    f"needs about {n_min} terms (max_terms={max_terms})"))
                    break
                try:
                    val, err, sum_abs, n, acc = _sum(_terms(a, b, ss), rho, tol, max_terms, n_min)
                except _OrderingFailed as exc:
                    results.append((None, None, how, 0, wp, False, rho, str(exc)))
                    break
                if val is None:
                    results.append((None, None, how, n, wp, acc, rho,
                                    f"not converged after {n} terms (rho = {mpmath.nstr(rho, 4)})"))
                    break
                if val == 0 and sum_abs > 0:
                    wp = 2 * wp          # non-zero residues cancelling to zero: not yet resolved
                    continue
                cancel = sum_abs / abs(val) if val != 0 else mpmath.mpf(1)
                needed = dps + int(mpmath.log10(cancel)) + 10 if cancel > 1 else dps + 10
                if needed <= wp:
                    rnd = cancel * mpmath.mpf(10)**(-wp)
                    results.append((+val, err + rnd * abs(val), how, n, wp, acc, rho, ""))
                    break
                wp = needed + 5
        else:
            results.append((None, None, how, 0, wp, False, rho, "precision escalation did not settle"))
    return results


def product_integral(f, g, s=1, dps=None, tol=None, max_terms=4000, return_info=False,
                     continuation=False, max_dps=None):
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
    max_dps : cap on the internal working precision (default max(20*dps, 1000))

    Raises
    ------
    ValueError               if the integral does not exist for this s
    SeriesConvergenceError   if no valid expansion reaches the accuracy target
    """
    dps = dps if dps is not None else mpmath.mp.dps
    max_dps = max_dps if max_dps is not None else max(20 * dps, 1000)
    tol_ = mpmath.mpf(tol) if tol is not None else mpmath.mpf(10)**(-dps)
    with mpmath.workdps(max(dps + 15, _input_dps(f, g, s) + 10)):
        s = mpmath.mpmathify(s)
        lo, hi = _strip(f, g)
        if not continuation and not (lo < mpmath.re(s) < hi):
            raise ValueError(
                f"Int x^(s-1) {f.name} * {g.name} dx diverges for Re s = {mpmath.nstr(mpmath.re(s), 6)}; "
                f"it exists for {mpmath.nstr(lo, 6)} < Re s < {mpmath.nstr(hi, 6)} "
                "(pass continuation=True for the analytic continuation)")

    note = ""
    try:
        res = _evaluate(f, g, s, dps, tol_, max_terms, max_dps)
    except _PoleCollision:
        # Coinciding poles (logarithmic result). I(s) is analytic in the strip, so use
        # A(d) = (I(s+d) + I(s-d))/2 = I(s) + O(d^2) and Richardson-extrapolate with A(2d).
        # d is scaled by the distance to the nearest singularity of I (the strip edges).
        note = " (coinciding poles: symmetric evaluation at s +- delta)"
        with mpmath.workdps(2 * dps + 20):
            dist = min(mpmath.re(s) - lo, hi - mpmath.re(s)) if not continuation else mpmath.mpf(1)
            d = min(mpmath.mpf(1), dist) * mpmath.mpf(10)**(-(dps // 2 + 5))
            sub = dps + dps // 2 + 10
            try:
                parts = [_evaluate(f, g, s + k * d, sub, tol_ / 100, max_terms, max_dps) for k in (1, -1, 2, -2)]
            except _PoleCollision:
                raise SeriesConvergenceError("pole collision could not be resolved") from None
            res = []
            for p1, m1, p2, m2 in zip(*parts):
                how, n, wp, acc, rho = p1[2], p1[3], p1[4], p1[5], p1[6]
                if any(r[0] is None for r in (p1, m1, p2, m2)):
                    reason = next(r[7] for r in (p1, m1, p2, m2) if r[0] is None)
                    res.append((None, None, how, n, wp, acc, rho, reason))
                    continue
                A1 = (p1[0] + m1[0]) / 2
                A2 = (p2[0] + m2[0]) / 2
                val = (4 * A1 - A2) / 3
                err = max(p1[1], m1[1], p2[1], m2[1]) + abs(A1 - A2)
                res.append((val, err, how, n, wp, acc, rho, ""))

    good = [r for r in res if r[0] is not None]
    if not good:
        if res:
            why = "; ".join(f"{r[2]}: {r[7]}" for r in res)
            raise SeriesConvergenceError(f"valid residue expansion of {f.name} * {g.name} did not reach "
                                         f"the target ({why}). Use quadrature or a closed form.")
        raise SeriesConvergenceError(
            f"neither ordering of {f.name} * {g.name} is a convergent residue expansion (the scales are at the "
            "convergence boundary rho = 1, or the factors cannot be expanded). Use quadrature or a closed form.")
    val, err, how, n, wp, acc, rho, _ = min(good, key=lambda r: r[1] / max(abs(r[0]), mpmath.mpf(10)**(-2 * dps)))
    if val != 0 and err > tol_ * abs(val) * 10:
        raise SeriesConvergenceError(
            f"residue series for {f.name} * {g.name} reached only relative error ~{mpmath.nstr(err / abs(val), 3)}")
    full = val
    with mpmath.workdps(dps):
        val = +val
    if return_info:
        with mpmath.workdps(wp):
            err_out = err + abs(full - val)
        return val, {"method": how + (" + Wynn-epsilon" if acc else "") + note,
                     "error_estimate": err_out, "terms": n, "working_dps": wp}
    return val
