"""
One-loop scalar integrals in arbitrary precision.

Conventions (identical to LoopTools / FF, so results can be compared 1:1):

    B0(p2; m1sq, m2sq) = mu^(4-D) / (i pi^(D/2) r_Gamma) * Int d^D q
                          1 / ((q^2 - m1sq) ((q+p)^2 - m2sq))

with D = 4 - 2 eps. The UV pole is returned through the parameter ``delta``
(LoopTools' ``Delta = 1/eps - gamma_E + log(4 pi)``); the default ``delta=0``
reproduces LoopTools' default output.

    C0(0, 0, s; m1sq, m2sq, m3sq)  -- UV and IR finite for non-zero masses.

All internal masses are *squared* masses. The Feynman ``+i0`` prescription is
implemented exactly (no small numerical imaginary parts), so results are
reliable at any working precision.

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


def _check_masses(*msq):
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
        Decimal digits of working precision (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpc
    """
    with _prec(dps):
        p2, m1, m2 = (mpmath.mpf(x) for x in (p2, m1sq, m2sq))
        mu2, delta = mpmath.mpf(mu2), mpmath.mpf(delta)
        _check_masses(m1, m2)
        if p2 == 0 and m1 == 0 and m2 == 0:
            raise ValueError("B0(0; 0, 0) is scaleless (zero in dimensional regularisation)")
        res = delta + mpmath.log(mu2) - _int_log_delta(p2, m1, m2)
        return +mpmath.mpc(res)


def B0_mob(p2, msq, mu2=1, delta=0, dps=None):
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
        if m <= 0:
            raise ValueError("B0_mob requires a positive mass")
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


def C0_mob(s, msq, dps=None):
    """
    Equal-mass C0(0, 0, s; m^2, m^2, m^2).

    The MoB representation is C0 = -(1/(2 m^2)) [2F1(1/2, 1/2; 3/2; s/(4 m^2))]^2
    = -(2/s) arcsin^2(sqrt(s/(4m^2))), whose analytic continuation is

        C0 = (1/(2s)) log^2((beta - 1)/(beta + 1)),  beta = sqrt(1 - 4 m^2/(s + i0)).
    """
    with _prec(dps):
        s, m = mpmath.mpf(s), mpmath.mpf(msq)
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

    # Imaginary part: exact residue at the roots of s x^2 + (m1 - m2 - s) x + m2
    im = mpmath.mpf(0)
    bq = m1 - m2 - s
    dq = bq * bq - 4 * s * m2
    if dq > 0:
        sq = mpmath.sqrt(dq)
        xp, xm = (-bq + sq) / (2 * s), (-bq - sq) / (2 * s)
        if 0 < xp < 1 and 0 < xm < 1:
            im = -(mpmath.pi / s) * mpmath.log(abs((m2 - m3 - s * xp) / (m2 - m3 - s * xm)))
    return mpmath.mpc(res.real / p1, im)


def C0(s, m1sq, m2sq, m3sq, dps=None):
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
        if min(ma, mb, mc) == 0:
            raise ValueError("C0(0,0,s) with a vanishing internal mass is IR divergent; not supported")
        if ma == mb == mc:
            return C0_mob(s, ma)
        if s == 0:
            # C0(0,0,0) = -Int dx dy 1/(x1 ma + x2 mb + x3 mc): elementary closed form
            # via divided differences of m log m; use a regular 1-D integral for safety.
            def inner(b):
                al = ma - mb
                be = (1 - b) * mb + b * mc
                return (1 - b) / be if al == 0 else (mpmath.log(al * (1 - b) + be) - mpmath.log(be)) / al
            return mpmath.mpc(-mpmath.quad(inner, [0, 1]))
        return +_C0_unequal(s, ma, mb, mc)


# ---------------------------------------------------------------------------
#  Bubble in D = 3
# ---------------------------------------------------------------------------

def bubble_3d(p2, m1sq, m2sq, dps=None):
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
        M = mpmath.sqrt(m1) + mpmath.sqrt(m2)
        pref = mpmath.sqrt(mpmath.pi)
        if p2 == 0:
            if M == 0:
                raise ValueError("bubble_3d(0; 0, 0) is scaleless")
            return mpmath.mpc(pref * 2 / M)
        if p2 < 0:
            Q = mpmath.sqrt(-p2)
            return mpmath.mpc(pref * 2 / Q * mpmath.atan(Q / M))
        k = mpmath.sqrt(p2)
        if k < M:
            return mpmath.mpc(pref * 2 / k * mpmath.atanh(k / M))
        if k == M:
            raise ValueError("bubble_3d is singular exactly at threshold p2 = (m1 + m2)^2")
        return +mpmath.mpc(pref * 2 / k * mpmath.log((k + M) / (k - M)) / 2, pref * mpmath.pi / k)
