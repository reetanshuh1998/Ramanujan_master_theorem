"""
One-loop scalar integrals in arbitrary precision.

Conventions (identical to LoopTools / FF, so results can be compared 1:1):

    B0(p2; m1sq, m2sq) = mu^(4-D) / (i pi^(D/2) r_Gamma) * Int d^D q
                          1 / ((q^2 - m1sq) ((q+p)^2 - m2sq))

with D = 4 - 2 eps. The UV pole is returned through the parameter ``delta``
(LoopTools' ``Delta = 1/eps - gamma_E + log(4 pi)``); the default ``delta=0``
reproduces LoopTools' default output.

    C0(0, 0, s; m1sq, m2sq, m3sq)  -- UV finite; IR finite unless m1 = m2 = 0 or m2 = m3 = 0
                                      (and, at s = 0, unless two masses vanish).

All internal masses are *squared* masses. The Feynman ``+i0`` prescription is
implemented exactly (no small numerical imaginary parts).

Every public function is *certified*: the formula is evaluated at two working
precisions, which are raised until the results agree to the requested number
of digits (inputs are exact binary or decimal numbers, so this removes the
cancellation that closed forms suffer for p2 << m^2, hierarchical or nearly
degenerate masses, or s >> m^2). If agreement cannot be reached an
ArithmeticError is raised.

Two evaluation strategies are offered for B0:

* :func:`B0` -- closed form valid for all kinematics and arbitrary masses.
* :func:`B0_mob` -- the Method-of-Brackets / Ramanujan-Master-Theorem series
  representation for equal masses,
  ``B0 = delta - log(m^2/mu^2) + (2w/3) 2F1(1, 1; 5/2; w)``, ``w = p^2/(4 m^2)``,
  continued across the threshold w = 1 with the +i0 prescription.
"""

import mpmath

__all__ = ["B0", "B0_mob", "C0", "C0_mob", "bubble_3d"]


def _prec(dps):
    """Context manager: work at ``dps`` digits (default: current mp.dps)."""
    return mpmath.workdps(dps if dps is not None else mpmath.mp.dps)


def _xlogabs(x):
    """x * log|x| with the limit 0 at x = 0."""
    return mpmath.mpf(0) if x == 0 else x * mpmath.log(abs(x))


def _check_finite(*vals):
    for v in vals:
        if not mpmath.isfinite(v):
            raise ValueError(f"inputs must be finite, got {v}")


def _check_masses(*msq):
    _check_finite(*msq)
    for m in msq:
        if m < 0:
            raise ValueError(f"squared masses must be non-negative, got {m}")


# ---------------------------------------------------------------------------
#  B0
# ---------------------------------------------------------------------------

def _int_log_delta(p2, m1, m2):
    """
    L = Int_0^1 dx log(Delta(x) - i0),  Delta(x) = x m1 + (1-x) m2 - x(1-x) p2.

    Evaluated exactly: log|Delta| integrates to elementary functions of the
    roots of Delta, and the -i0 prescription gives Im L = -pi * |{x : Delta < 0}|.
    """
    if p2 == 0:
        if m1 == m2:
            return mpmath.log(m1)
        return (_xlogabs(m1) - _xlogabs(m2)) / (m1 - m2) - 1

    # Delta(x) = a x^2 + b x + c
    a, b, c = p2, m1 - m2 - p2, m2
    disc = b * b - 4 * a * c

    if disc < 0:
        # complex-conjugate roots: Delta > 0 on [0, 1], purely real result
        r = (-b + mpmath.sqrt(mpmath.mpc(disc))) / (2 * a)
        F = (1 - r) * mpmath.log(1 - r) + r * mpmath.log(-r) - 1
        return mpmath.log(a) + 2 * F.real

    sq = mpmath.sqrt(disc)
    q = -(b + (sq if b >= 0 else -sq)) / 2      # numerically stable roots
    r1 = q / a
    r2 = c / q if q != 0 else -b / a - r1
    re = mpmath.log(abs(a))
    for r in (r1, r2):
        re += _xlogabs(1 - r) + _xlogabs(r) - 1   # Int_0^1 log|x - r| dx

    lo, hi = min(r1, r2), max(r1, r2)
    clip = lambda x: min(max(x, mpmath.mpf(0)), mpmath.mpf(1))
    inside = clip(hi) - clip(lo)                  # length of [lo, hi] in [0, 1]
    negative_len = inside if a > 0 else 1 - inside
    return mpmath.mpc(re, -mpmath.pi * negative_len)


def _B0_kernel(p2, m1sq, m2sq, mu2=1, delta=0, dps=None):
    """
    Finite part (plus ``delta`` times the pole) of the scalar two-point function.

    Parameters
    ----------
    p2 : real
        External momentum squared (Minkowski metric, p2 > 0 is time-like).
    m1sq, m2sq : real >= 0
        Internal squared masses.
    mu2 : real > 0
        Renormalisation scale squared.
    delta : real
        Value assigned to the UV divergence ``1/eps - gamma_E + log 4pi``.
    dps : int, optional
        Decimal digits of working precision (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpc
    """
    with _prec(dps):
        p2, m1, m2 = (mpmath.mpf(x) for x in (p2, m1sq, m2sq))
        mu2, delta = mpmath.mpf(mu2), mpmath.mpf(delta)
        _check_masses(m1, m2)
        _check_finite(p2, mu2, delta)
        if not mu2 > 0:
            raise ValueError("mu2 must be positive")
        if p2 == 0 and m1 == 0 and m2 == 0:
            raise ValueError("B0(0; 0, 0) is scaleless (zero in dimensional regularisation)")
        res = delta + mpmath.log(mu2) - _int_log_delta(p2, m1, m2)
        return +mpmath.mpc(res)


def _B0_mob_kernel(p2, msq, mu2=1, delta=0, dps=None):
    """
    Equal-mass B0 from its Method-of-Brackets hypergeometric representation.

    The MoB / Ramanujan Master Theorem evaluation of the Feynman-parameter
    integral gives  B0(eps) = Gamma(eps) (m^2)^(-eps) 2F1(eps, 1; 3/2; w).
    Expanding in eps (d/da (a)_n |_(a=0) = (n-1)!) yields the exact series

        B0 = delta - log(m^2/mu^2) + Sum_{n>=1} Gamma(n)/(3/2)_n w^n
           = delta - log(m^2/mu^2) + (2w/3) 2F1(1, 1; 5/2; w),

    with w = p2/(4 m^2). The series converges for |w| < 1; above threshold
    (w > 1) the Feynman prescription w -> w + i0 is applied exactly.
    """
    with _prec(dps):
        p2, m = mpmath.mpf(p2), mpmath.mpf(msq)
        mu2, delta = mpmath.mpf(mu2), mpmath.mpf(delta)
        _check_finite(p2, m, mu2, delta)
        if m <= 0:
            raise ValueError("B0_mob requires a positive mass")
        if not mu2 > 0:
            raise ValueError("mu2 must be positive")
        w = p2 / (4 * m)
        hyp = mpmath.hyp2f1(1, 1, mpmath.mpf(5) / 2, w)
        if w > 1:
            # mpmath returns the value continuous from below the cut (w - i0);
            # the Feynman prescription selects w + i0.
            hyp = mpmath.conj(hyp)
        return +mpmath.mpc(delta - mpmath.log(m / mu2) + 2 * w / 3 * hyp)


# ---------------------------------------------------------------------------
#  C0(0, 0, s; m1, m2, m3)
# ---------------------------------------------------------------------------

def _Li2(z):
    """Dilogarithm on the physical sheet, z -> z + i0 (relative to |z|)."""
    z = mpmath.mpc(z)
    if z.imag == 0 and z.real > 1:
        # Li2(x + i0) = Re Li2(x) + i pi log x   for x > 1
        return mpmath.mpc(mpmath.polylog(2, z.real).real, mpmath.pi * mpmath.log(z.real))
    return mpmath.polylog(2, z)


def _C0_mob_kernel(s, msq, dps=None):
    """
    Equal-mass C0(0, 0, s; m^2, m^2, m^2).

    The MoB representation is C0 = -(1/(2 m^2)) [2F1(1/2, 1/2; 3/2; s/(4 m^2))]^2
    = -(2/s) arcsin^2(sqrt(s/(4m^2))), whose analytic continuation is

        C0 = (1/(2s)) log^2((beta - 1)/(beta + 1)),  beta = sqrt(1 - 4 m^2/(s + i0)).
    """
    with _prec(dps):
        s, m = mpmath.mpf(s), mpmath.mpf(msq)
        _check_finite(s, m)
        if m <= 0:
            raise ValueError("C0_mob requires a positive mass")
        if s == 0:
            return mpmath.mpc(-1 / (2 * m))
        x = 1 - 4 * m / s
        if s > 4 * m:
            beta = mpmath.sqrt(x)
            r = (beta - 1) / (beta + 1)            # negative real, approached from above
            L = mpmath.mpc(mpmath.log(-r), mpmath.pi)
        elif s < 0:
            beta = mpmath.sqrt(x)                  # beta > 1, r in (0, 1)
            L = mpmath.log((beta - 1) / (beta + 1))
        else:
            if s == 4 * m:
                return mpmath.mpc(-mpmath.pi**2 / (2 * s))
            beta = mpmath.mpc(0, mpmath.sqrt(-x))  # |r| = 1, L purely imaginary
            L = mpmath.log((beta - 1) / (beta + 1))
            return mpmath.mpc((L * L / (2 * s)).real)
        return +mpmath.mpc(L * L / (2 * s))


def _C0_unequal(s, ma, mb, mc):
    """'t Hooft-Veltman dilogarithm form of C0(0,0,s; ma, mb, mc), s != 0."""
    # Relabel so that p1^2 = s in the LoopTools/FF permutation used below.
    p1 = s
    m1, m2, m3 = mc, ma, mb
    m12, m23, m13 = m1 - m2, m2 - m3, m1 - m3

    res = mpmath.mpc(0)
    if m13 != 0:
        c = m23 + p1 * m3 / m13
        res += _Li2((m23 - p1) / c) - _Li2(m23 / c)

    y1 = -2 * p1 * m23
    y2 = -2 * p1 * (m23 - p1)
    c2 = p1 * (p1 - m13 - m23)
    disc = (p1 - m12)**2 - 4 * p1 * m2
    b2 = p1 * mpmath.sqrt(mpmath.mpc(disc))
    y3, y4 = c2 - b2, c2 + b2
    ctop = 4 * p1**2 * (p1 * m3 + m13 * m23)    # y3 * y4, used to avoid cancellation
    if abs(y3) < abs(y4):
        y3 = ctop / y4
    else:
        y4 = ctop / y3
    res += _Li2(y1 / y3) + _Li2(y1 / y4) - _Li2(y2 / y3) - _Li2(y2 / y4)
    return res.real / p1


def _C0_im(s, m1, m2, m3):
    """
    Im C0(0,0,s; m1,m2,m3) (LoopTools mass order), from the Feynman-parameter form
    C0 = -Int_0^1 db [log(top(b) - i0) - log(beta(b))] / alpha(b), with
    alpha = m1 - m2 - b s, beta = (1-b) m2 + b m3, top = s b^2 - (s + m1 - m3) b + m1:
    Im C0 = pi Int db theta(-top)/alpha = -(pi/s) log|alpha(b+)/alpha(b-)|,
    b- < b+ the roots of top, clipped to [0, 1].
    """
    if s <= 0:
        return mpmath.mpf(0)
    B = -(s + m1 - m3)
    disc = B * B - 4 * s * m1
    if disc <= 0:
        return mpmath.mpf(0)
    sq = mpmath.sqrt(disc)
    q = -(B - sq) / 2 if B < 0 else -(B + sq) / 2          # stable roots
    r1 = q / s
    r2 = m1 / q if q != 0 else -B / s - r1
    lo, hi = max(min(r1, r2), mpmath.mpf(0)), min(max(r1, r2), mpmath.mpf(1))
    if hi <= lo:
        return mpmath.mpf(0)
    alpha = lambda b: m1 - m2 - b * s
    return -(mpmath.pi / s) * (mpmath.log(abs(alpha(hi))) - mpmath.log(abs(alpha(lo))))


def _C0_s0(a, b, c):
    """C0(0,0,0; a,b,c) = -f[a,b,c], the second divided difference of f(m) = m log m."""
    f = _xlogabs
    df = lambda m: mpmath.log(m) + 1
    if a == b == c:
        return -1 / (2 * a)
    if a == b or b == c or a == c:
        x, y = (a, c) if a == b else ((b, a) if b == c else (a, b))   # x is the repeated mass
        if x == 0:
            raise ValueError("C0(0,0,0) with two vanishing internal masses is IR divergent")
        f_xy = (f(y) - f(x)) / (y - x)
        return -(f_xy - df(x)) / (y - x)
    return -(f(a) / ((a - b) * (a - c)) + f(b) / ((b - a) * (b - c)) + f(c) / ((c - a) * (c - b)))


def _C0_kernel(s, m1sq, m2sq, m3sq, dps=None):
    """
    Scalar three-point function C0(0, 0, s; m1sq, m2sq, m3sq).

    Equivalent to LoopTools ``C0(0, 0, s, m1sq, m2sq, m3sq)``. Equal masses use
    the closed MoB form (:func:`C0_mob`); unequal masses use the exact
    't Hooft-Veltman dilogarithm reduction with exact branch selection.
    """
    with _prec(dps):
        s = mpmath.mpf(s)
        ma, mb, mc = (mpmath.mpf(x) for x in (m1sq, m2sq, m3sq))
        _check_masses(ma, mb, mc)
        _check_finite(s)
        if (ma == 0 and mb == 0) or (mb == 0 and mc == 0):
            raise ValueError("C0(0,0,s) with m1 = m2 = 0 or m2 = m3 = 0 is IR (collinear) divergent")
        if ma == mb == mc:
            return _C0_mob_kernel(s, ma, dps=mpmath.mp.dps)
        if s == 0:
            return mpmath.mpc(_C0_s0(ma, mb, mc))
        im = _C0_im(s, ma, mb, mc)
        for args in ((ma, mb, mc), (mc, mb, ma)):    # C0 is symmetric under m1 <-> m3
            try:
                return mpmath.mpc(_C0_unequal(s, *args), im)
            except ZeroDivisionError:
                pass
        # an intermediate of the dilogarithm form vanishes at this regular point:
        # Re C0 is analytic in s here, so average s(1 +- d) (error O(d^2))
        wp = mpmath.mp.dps
        with mpmath.workdps(3 * wp):
            d = s * mpmath.mpf(10)**(-(wp + 5))
            re = (_C0_unequal(s + d, ma, mb, mc) + _C0_unequal(s - d, ma, mb, mc)) / 2
        return mpmath.mpc(+re, im)


# ---------------------------------------------------------------------------
#  Bubble in D = 3
# ---------------------------------------------------------------------------

def _bubble_3d_kernel(p2, m1sq, m2sq, dps=None):
    """
    Finite D = 3 bubble  Gamma(1/2) Int_0^1 dx (Delta(x) - i0)^(-1/2)
    (measure d^3q / (i pi^(3/2)), propagators 1/(q^2 - m^2)).

    Closed form, with M = m1 + m2 and k = sqrt(p2):
        p2 < 0      : sqrt(pi) (2/Q) arctan(Q/M),       Q = sqrt(-p2)
        0 < p2 < M^2: sqrt(pi) (2/k) artanh(k/M)
        p2 > M^2    : sqrt(pi) (2/k) [ (1/2) log((k+M)/(k-M)) + i pi/2 ]
    """
    with _prec(dps):
        p2 = mpmath.mpf(p2)
        m1, m2 = (mpmath.mpf(x) for x in (m1sq, m2sq))
        _check_masses(m1, m2)
        _check_finite(p2)
        M = mpmath.sqrt(m1) + mpmath.sqrt(m2)
        pref = mpmath.sqrt(mpmath.pi)
        if p2 == 0:
            if M == 0:
                raise ValueError("bubble_3d(0; 0, 0) is scaleless")
            return mpmath.mpc(pref * 2 / M)
        if p2 < 0:
            Q = mpmath.sqrt(-p2)
            if M == 0:
                return mpmath.mpc(pref * mpmath.pi / Q)
            return mpmath.mpc(pref * 2 / Q * mpmath.atan(Q / M))
        if M == 0:
            return mpmath.mpc(0, pref * mpmath.pi / mpmath.sqrt(p2))
        k = mpmath.sqrt(p2)
        if k < M:
            return mpmath.mpc(pref * 2 / k * mpmath.atanh(k / M))
        if k == M:
            raise ValueError("bubble_3d is singular exactly at threshold p2 = (m1 + m2)^2")
        return +mpmath.mpc(pref * 2 / k * mpmath.log((k + M) / (k - M)) / 2, pref * mpmath.pi / k)


# ---------------------------------------------------------------------------
#  certified public functions
# ---------------------------------------------------------------------------

def _certified(kernel, *args, dps=None, cert_step=20, **kw):
    """Evaluate kernel at increasing working precision until two consecutive
    results agree to the requested digits."""
    dps = dps if dps is not None else mpmath.mp.dps
    wp = dps + 10
    prev = kernel(*args, dps=wp, **kw)
    for _ in range(14):
        wp2 = wp + max(cert_step, wp // 2)
        cur = kernel(*args, dps=wp2, **kw)
        with mpmath.workdps(wp2):
            if (cur == 0 and prev == 0) or abs(cur - prev) <= mpmath.mpf(10)**(-(dps + 2)) * abs(cur):
                with mpmath.workdps(dps):
                    return +cur
        prev, wp = cur, wp2
    raise ArithmeticError(f"{kernel.__name__}: could not certify {dps} digits (working precision {wp})")


def B0(p2, m1sq, m2sq, mu2=1, delta=0, dps=None):
    """
    Finite part (plus ``delta`` times the pole) of the scalar two-point function.

    Parameters
    ----------
    p2 : real
        External momentum squared (Minkowski metric, p2 > 0 is time-like).
    m1sq, m2sq : real >= 0
        Internal squared masses.
    mu2 : real > 0
        Renormalisation scale squared.
    delta : real
        Value assigned to the UV divergence ``1/eps - gamma_E + log 4pi``.
    dps : int, optional
        Decimal digits requested (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpc
    """
    return _certified(_B0_kernel, p2, m1sq, m2sq, mu2=mu2, delta=delta, dps=dps)


def B0_mob(p2, msq, mu2=1, delta=0, dps=None):
    return _certified(_B0_mob_kernel, p2, msq, mu2=mu2, delta=delta, dps=dps)


def C0_mob(s, msq, dps=None):
    return _certified(_C0_mob_kernel, s, msq, dps=dps)


def C0(s, m1sq, m2sq, m3sq, dps=None):
    return _certified(_C0_kernel, s, m1sq, m2sq, m3sq, dps=dps)


def bubble_3d(p2, m1sq, m2sq, dps=None):
    return _certified(_bubble_3d_kernel, p2, m1sq, m2sq, dps=dps)


for _pub, _ker in ((B0_mob, _B0_mob_kernel), (C0_mob, _C0_mob_kernel), (C0, _C0_kernel),
                   (bubble_3d, _bubble_3d_kernel)):
    _pub.__doc__ = _ker.__doc__
del _pub, _ker
