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

from decimal import Decimal, InvalidOperation

import mpmath
from mpmath.libmp import NoConvergence

__all__ = [
    "MellinFunction", "SeriesConvergenceError", "product_integral",
    "exponential", "gaussian", "bessel_j", "cosine", "sine", "inverse_power",
    "gaussian_bessel",
]


class SeriesConvergenceError(ArithmeticError):
    r"""
    No valid residue expansion reaches the requested accuracy.

    Raised by :func:`product_integral` at the convergence boundary :math:`\rho = 1`,
    or when a valid series needs more than ``max_terms`` terms or more than
    ``max_dps`` digits. A subclass of :class:`ArithmeticError`.
    """


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
    r"""
    A factor :math:`f(x)` on :math:`(0, \infty)`, described by its Mellin data.

    Instances are created by the atlas constructors (:func:`exponential`,
    :func:`gaussian`, :func:`bessel_j`, :func:`cosine`, :func:`sine`,
    :func:`inverse_power`, :func:`gaussian_bessel`) and passed to
    :func:`product_integral`. Calling an instance evaluates the function:
    ``exponential(1)(2)`` is :math:`e^{-2}`.

    Attributes
    ----------
    name : str
        Display name, used in messages.
    build : callable
        Returns the Mellin data (function, transform, expansions, scale) at the
        current working precision. Its return type is internal, so defining new
        factors outside the package is not yet a stable interface.
    L, R : number or None
        Gamma orders: the Taylor coefficients decay like :math:`c^p/\Gamma(p)^L` and
        the Mellin transform grows like :math:`\Gamma(w)^R/c^w`. ``L`` is None for a
        factor that cannot be expanded.
    p0 : number or str
        Leading exponent of :math:`f` at :math:`x = 0`.
    tail : tuple
        Behaviour at :math:`x \to \infty`: ``("fast",)`` for faster than any power, or
        ``("power", alpha, frequency, phase)`` for :math:`x^{-\alpha}\cos(\omega x + \phi)`.
    params : dict
        The parameters as given, kept exact.

    Examples
    --------
    >>> f = bessel_j(0, 3)
    >>> f.name, f.L, f.R
    ('J_0(3 x)', 1, 1)
    >>> f(1)
    mpf('-0.26005195490193345')
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
    if not (mpmath.im(v) == 0 and mpmath.isfinite(v) and v > 0):
        raise ValueError(f"{name} must be real, finite and positive, got {value!r}")


def exponential(k):
    r"""
    The factor :math:`e^{-kx}`.

    Parameters
    ----------
    k : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`k^{-s}\Gamma(s)`; Gamma orders :math:`L = R = 1`, scale :math:`k`.

    Examples
    --------
    >>> product_integral(exponential(2), cosine(5))     # 2/29
    mpf('0.068965517241379309')
    """
    _positive("k", k)

    def build():
        kk = _m(k)
        return _Built(lambda x: mpmath.exp(-kk * x),
                      lambda s: kk**(-s) * mpmath.gamma(s),
                      left=lambda n: (n, (-kk)**n / mpmath.factorial(n)),
                      scale=kk)
    return MellinFunction(f"exp(-{k} x)", build, L=1, R=1, p0=0, tail=("fast",), params={"k": k})


def gaussian(a):
    r"""
    The factor :math:`e^{-ax^2}`.

    Parameters
    ----------
    a : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`\tfrac12 a^{-s/2}\Gamma(s/2)`; Gamma orders
        :math:`L = R = 1/2`, scale :math:`\sqrt{2a}`.

    Examples
    --------
    >>> product_integral(gaussian(1), cosine(3))        # sqrt(pi)/2 exp(-9/4)
    mpf('0.093407630728565852')
    """
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
    r"""
    The factor :math:`J_\nu(bx)`.

    Parameters
    ----------
    nu : number or str
        Real order :math:`\nu > -1`, or a negative integer (mapped to
        :math:`J_{-n} = (-1)^n J_n`).
    b : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`2^{s-1} b^{-s}\,\Gamma(\tfrac{\nu+s}{2})/\Gamma(\tfrac{\nu-s}{2}+1)`;
        Gamma orders :math:`L = R = 1`, scale :math:`b`.

    Raises
    ------
    ValueError
        For a complex order, an order :math:`\le -1` that is not an integer, or
        :math:`b \le 0`.

    Examples
    --------
    >>> product_integral(bessel_j(0, 2), cosine(1))     # 1/sqrt(3)
    mpf('0.57735026918962573')
    """
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
                          p0=nu, tail=("power", mpmath.mpf(1) / 2, b, ("J", nu)), params={"nu": nu, "b": b})


def cosine(b):
    r"""
    The factor :math:`\cos bx`.

    Parameters
    ----------
    b : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`b^{-s}\Gamma(s)\cos(\pi s/2)`; Gamma orders
        :math:`L = R = 1`, scale :math:`b`.

    Examples
    --------
    >>> product_integral(exponential(1), cosine(10**6), dps=20)     # 1/(1 + 10^12)
    mpf('9.99999999999e-13')
    """
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.cos(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.cospi(s / 2),
                      left=lambda n: (2 * n, (-1)**n * bb**(2 * n) / mpmath.factorial(2 * n)),
                      scale=bb)
    return MellinFunction(f"cos({b} x)", build, L=1, R=1, p0=0, tail=("power", 0, b, 0), params={"b": b})


def sine(b):
    r"""
    The factor :math:`\sin bx`.

    Parameters
    ----------
    b : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`b^{-s}\Gamma(s)\sin(\pi s/2)`; Gamma orders
        :math:`L = R = 1`, scale :math:`b`.

    Examples
    --------
    >>> product_integral(exponential(1), sine(2))       # 2/5
    mpf('0.40000000000000002')
    """
    _positive("b", b)

    def build():
        bb = _m(b)
        return _Built(lambda x: mpmath.sin(bb * x),
                      lambda s: bb**(-s) * mpmath.gamma(s) * mpmath.sinpi(s / 2),
                      left=lambda n: (2 * n + 1, (-1)**n * bb**(2 * n + 1) / mpmath.factorial(2 * n + 1)),
                      scale=bb)
    return MellinFunction(f"sin({b} x)", build, L=1, R=1, p0=1, tail=("power", 0, b, -2), params={"b": b})


def inverse_power(m, v):
    r"""
    The factor :math:`(x + m)^{-v}`.

    It carries both its Taylor expansion at :math:`x = 0` and its expansion
    :math:`\sum_n \binom{-v}{n} m^n x^{-v-n}` at large :math:`x`.

    Parameters
    ----------
    m, v : number or str
        Real, finite and positive.

    Returns
    -------
    MellinFunction
        Mellin transform :math:`m^{s-v}\Gamma(s)\Gamma(v-s)/\Gamma(v)`; Gamma orders
        :math:`L = R = 0`, scale :math:`1/m`.

    Examples
    --------
    >>> product_integral(exponential(1), inverse_power(1, 1))      # e E1(1)
    mpf('0.59634736232319407')
    """
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
    return MellinFunction(f"(x + {m})^(-{v})", build, L=0, R=0, p0=0, tail=("power", v, 0, None),
                          params={"m": m, "v": v})


def gaussian_bessel(a, b, nu):
    r"""
    The factor :math:`e^{-ax^2}J_\nu(bx)`.

    Its Mellin transform is known in closed form,

    .. math::

        M(s) = \frac{(b/2)^\nu\,\Gamma(h)}{2\,a^{h}\,\Gamma(\nu+1)}\,
        {}_1F_1\!\left(h;\nu+1;-\frac{b^2}{4a}\right), \qquad h = \frac{s+\nu}{2},

    but it is not expanded itself (:math:`L` is undefined), so it must be paired with a
    factor that can be expanded against :math:`R = 1/2`, such as an exponential. This
    handles three-factor products like :math:`e^{-2x}e^{-x^2/2}J_1(100x)`.

    Parameters
    ----------
    a, b : number or str
        Real, finite and positive.
    nu : number or str
        Real order :math:`\nu > -1`.

    Returns
    -------
    MellinFunction

    Examples
    --------
    >>> product_integral(exponential(2), gaussian_bessel("0.5", 1, 1))
    mpf('0.072735927988686319')
    """
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
                          p0=nu, tail=("fast",), params={"a": a, "b": b, "nu": nu})


# ---------------------------------------------------------------------------
#  existence of the integral
# ---------------------------------------------------------------------------

def _same(x, y):
    with mpmath.workdps(60):
        return _m(x) == _m(y)


def _phase(ph):
    """Asymptotic phase in units of pi/4 (J_nu: -(2 nu + 1))."""
    if isinstance(ph, tuple):
        return -(2 * _m(ph[1]) + 1)
    return _m(ph)


def _strip(f, g):
    """(lower, upper) bounds on Re s for Int x^(s-1) f g dx to exist. All edge data are
    converted from the raw parameters at the current (input-sized) precision."""
    lower = -(mpmath.re(_m(f.p0)) + mpmath.re(_m(g.p0)))
    if f.tail[0] == "fast" or g.tail[0] == "fast":
        return lower, mpmath.inf
    alpha = _m(f.tail[1]) + _m(g.tail[1])
    (w1, ph1), (w2, ph2) = f.tail[2:4], g.tail[2:4]
    o1, o2 = _m(w1) > 0, _m(w2) > 0
    if not (o1 or o2):
        return lower, alpha                      # non-oscillating power law
    if o1 and o2 and _same(w1, w2):
        # cos(wx + ph1) cos(wx + ph2) = [cos(ph1 - ph2) + cos(2wx + ph1 + ph2)]/2:
        # a non-oscillating x^-alpha term survives unless cos(ph1 - ph2) = 0
        dq = _phase(ph1) - _phase(ph2)           # in units of pi/4
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


def _offset(F):
    """Size of the parameters that shift the Gamma arguments of a factor (v of an inverse
    power, the Bessel order): the term asymptotics only set in once p_n exceeds them."""
    total = mpmath.mpf(0)
    for key in ("v", "nu"):
        if key in F.params:
            with mpmath.workdps(30):
                total += abs(_m(F.params[key]))
    return total


def _min_terms(A, B, a, b, rho, s):
    """Index beyond which the terms are in their asymptotic (decaying) regime: past the
    a-priori peak of ratio^p Gamma(p)^(R-L) (or of the geometric series) and past every
    shift of the Gamma arguments (s, v, nu), where a second peak can occur."""
    step = a.left(1)[0] - a.left(0)[0]
    shift = abs(s) + _offset(A) + _offset(B)
    n_shift = int(2 * shift / step) + 10
    if rho == 0:
        ratio = a.scale / b.scale
        if ratio <= 1:
            return max(10, n_shift)
        p_star = ratio**(1 / (A.L - B.R))       # peak of ratio^p Gamma(p)^(R-L)
        return int(2 * (p_star + shift) / step) + 10
    return max(10 + int(3 / (1 - rho)), n_shift)


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


def _decimal_digits(text):
    """Digits needed to hold a decimal string exactly next to integers (integer digits
    plus decimal places), or None if the string is not a plain decimal number."""
    try:
        d = Decimal(text.strip())
    except (InvalidOperation, ValueError):
        return None
    if not d.is_finite() or d == 0:
        return 0
    sign, digits, exp = d.as_tuple()
    int_digits = max(len(digits) + exp, 1)
    frac_digits = max(-exp, 0)
    return int_digits + frac_digits


def _input_dps(f, g, s, dps=15):
    """Digits needed to represent all inputs next to the integer shifts p_n to dps + 15
    significant digits of their distance from any lattice point or strip edge (so that
    s + p_n, nu - s, s + nu, ... are formed without rounding error that matters)."""
    need = 0
    vals = list(f.params.values()) + list(g.params.values()) + [s]
    for x in vals:
        if isinstance(x, (mpmath.mpc, complex)):
            parts = (mpmath.re(x), mpmath.im(x))
        else:
            parts = (x,)
        for y in parts:
            if isinstance(y, str):
                nd = _decimal_digits(y)
                if nd is None:          # e.g. '1/3' or an mpmath constant string
                    nd = 30
                need = max(need, nd + dps + 15)
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
    base = max(dps + 15, _input_dps(f, g, s, dps) + 10)
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
                n_min = _min_terms(A, B, a, b, rho, ss)
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
    r"""
    Evaluate :math:`\int_0^\infty x^{s-1} f(x)\,g(x)\,dx` by Mellin residue summation.

    One factor is expanded in its Taylor series at :math:`x = 0` (and the other at
    :math:`x = \infty` when it has such an expansion), and the residue series

    .. math:: I(s) = \sum_n r_n\,M_g(s + p_n) + \sum_n q_n\,M_f(s - a_n)

    is summed. Only expansions for which closing the Mellin-Barnes contour is
    legitimate are used (see the user guide), the existence of the integral is
    checked first, and the working precision is raised against cancellation.

    Parameters
    ----------
    f, g : MellinFunction
        Factors from the atlas: :func:`exponential`, :func:`gaussian`,
        :func:`bessel_j`, :func:`cosine`, :func:`sine`, :func:`inverse_power`,
        :func:`gaussian_bessel`.
    s : number or str, default 1
        The Mellin variable; ``s=1`` gives the plain integral. Complex values are
        allowed; strings are exact decimals.
    dps : int, optional
        Decimal digits requested (default: ``mpmath.mp.dps``). The result is rounded
        to ``dps`` digits.
    tol : number, optional
        Relative accuracy target (default :math:`10^{-dps}`).
    max_terms : int, default 4000
        Largest number of residue terms per series.
    return_info : bool, default False
        Also return a dict with the keys ``method`` (the expanded factor, and notes on
        Wynn acceleration or coinciding poles), ``error_estimate``, ``terms`` and
        ``working_dps``.
    continuation : bool, default False
        Allow ``s`` outside the strip where the integral exists, and return the
        analytic continuation of :math:`I(s)`.
    max_dps : int, optional
        Cap on the internal working precision (default ``max(20*dps, 1000)``).

    Returns
    -------
    mpmath.mpf or mpmath.mpc, or (value, dict) if ``return_info`` is true

    Raises
    ------
    ValueError
        If the integral does not exist for this ``s`` (the message gives the strip),
        or ``s`` is not finite.
    SeriesConvergenceError
        If no valid expansion reaches the accuracy target: the scales are at the
        convergence boundary :math:`\rho = 1` (for example :math:`e^{-x}J_0(x)`), or
        the series needs more than ``max_terms`` terms, or more than ``max_dps``
        digits.

    Notes
    -----
    The method is the classical Mellin-convolution (Meijer-G / Slater) residue
    expansion; see the prior-art page of the documentation (Marichev 1983;
    Adamchik and Marichev 1990; Slater 1966; DLMF 2.5).

    Examples
    --------
    >>> product_integral(exponential(1), bessel_j(0, 3))      # 1/sqrt(10)
    mpf('0.31622776601683794')
    >>> v, info = product_integral(exponential(1), bessel_j(0, 3), dps=30, return_info=True)
    >>> info['method'], info['terms'], info['working_dps']
    ('expand exp(-1 x)', 73, 45)
    >>> product_integral(exponential(1), bessel_j(0, 1))
    Traceback (most recent call last):
    ...
    ramanujan_qft.mellin.SeriesConvergenceError: neither ordering of exp(-1 x) * J_0(1 x) is a convergent residue expansion (the scales are at the convergence boundary rho = 1, or the factors cannot be expanded). Use quadrature or a closed form.
    """
    dps = dps if dps is not None else mpmath.mp.dps
    max_dps = max_dps if max_dps is not None else max(20 * dps, 1000)
    tol_ = mpmath.mpf(tol) if tol is not None else mpmath.mpf(10)**(-dps)
    if not mpmath.isfinite(mpmath.mpmathify(s)):
        raise ValueError(f"s must be finite, got {s!r}")
    with mpmath.workdps(max(dps + 15, _input_dps(f, g, s, dps) + 10)):
        s = mpmath.mpmathify(s)
        lo, hi = _strip(f, g)
        if not continuation and not (lo < mpmath.re(s) < hi):
            raise ValueError(
                f"Int x^(s-1) {f.name} * {g.name} dx diverges for Re s = {mpmath.nstr(mpmath.re(s), 30)}; "
                f"it exists for {mpmath.nstr(lo, 30)} < Re s < {mpmath.nstr(hi, 30)} "
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
