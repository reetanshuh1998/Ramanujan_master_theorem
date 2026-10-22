"""
Two-loop massive sunset S(p^2; m1^2, m2^2, m3^2) -- the scheme-independent parts.

Normalisation (same per-loop measure as LoopTools / pySecDec):

    S = Int d^Dk d^Dl / (i pi^(D/2))^2  1 / ((k^2 - m1^2)(l^2 - m2^2)((p-k-l)^2 - m3^2)),

with +i0 on every propagator, D = 4 - 2 eps.

What is provided (all UV finite, hence free of scheme ambiguities):

* :func:`sunset_im`         Im S(s) from its exact 1-D phase-space representation
                            Im S = -(pi/s) Int dt lambda^(1/2)(s,t,m1^2) lambda^(1/2)(t,m2^2,m3^2)/t
* :func:`sunset_subtracted` S(s) - S(0) - s S'(0) from a twice-subtracted
                            dispersion relation (complex above threshold)
* :func:`sunset_d2`         d^2 S / ds^2, from the same dispersion relation

Numerics: the exact homogeneity (Im S and S - S(0) - s S'(0) scale like lambda,
S'' like 1/lambda under s, m^2 -> lambda s, lambda m^2) is used to normalise to
unit scale; the Kallen functions are used in factored form with the substitution
t = lo + w sin^2(u/2), so the threshold width w is formed without cancellation;
every quadrature's error estimate is checked, and every public function is
certified by evaluation at two working precisions (as in :mod:`one_loop`).

The full finite part of S additionally needs the scheme-dependent constants S(0) and
S'(0) (known in closed form, e.g. Davydychev & Tausk, Nucl. Phys. B397 (1993) 123);
they are not implemented here.

Validation: the tests compare with independent two-dimensional Feynman-parameter
integrations and with the closed form for masses (0, 0, M).
"""

import mpmath

from ramanujan_qft.one_loop import _certified

__all__ = ["sunset_threshold", "sunset_im", "sunset_subtracted", "sunset_d2"]


def sunset_threshold(m1sq, m2sq, m3sq):
    """Three-particle threshold (m1 + m2 + m3)^2."""
    return (mpmath.sqrt(m1sq) + mpmath.sqrt(m2sq) + mpmath.sqrt(m3sq))**2


def _inputs(s, msq):
    s = mpmath.mpf(s)
    msq = [mpmath.mpf(m) for m in msq]
    for x in [s] + msq:
        if not mpmath.isfinite(x):
            raise ValueError("inputs must be finite")
    if min(msq) < 0:
        raise ValueError("squared masses must be non-negative")
    return s, sorted(msq)


def _quad(f, pts):
    """mpmath.quad with a relative error check (one retry at higher degree). The working
    precision is >= 10 digits above the requested accuracy, and the result is certified
    by evaluation at two precisions, so the check allows for those guard digits."""
    tol = mpmath.mpf(10)**(-(mpmath.mp.dps - 9))
    # mpmath.quad's error control is absolute: normalise the integrand by its magnitude
    # at interior sample points so that tiny or huge integrals are resolved relatively.
    finite = [p for p in pts if mpmath.isfinite(p)]
    samples = [abs(f(a + (b - a) * c)) for a, b in zip(finite, finite[1:]) for c in (mpmath.mpf(1) / 3, mpmath.mpf(2) / 3)]
    scale = max([x for x in samples if mpmath.isfinite(x)] + [mpmath.mpf(0)])
    if scale > 0:
        g = f
        f = lambda t: g(t) / scale
    else:
        scale = mpmath.mpf(1)
    v, e = mpmath.quad(f, pts, error=True)
    if e > tol * abs(v) and v != 0:
        v, e = mpmath.quad(f, pts, error=True, maxdegree=mpmath.mp.dps // 2 + 10)
        if e > tol * abs(v):
            raise ArithmeticError(f"quadrature did not converge (relative error {mpmath.nstr(e / abs(v), 3)})")
    return v * scale


def _im_unit(mo, ma, mb):
    """Im S at s = 1 with mass mo integrated outside (all arguments divided by s)."""
    rM, ra, rb = mpmath.sqrt(mo), mpmath.sqrt(ma), mpmath.sqrt(mb)
    gap = 1 - rM - ra - rb                       # distance to threshold, formed directly
    if gap <= 0:
        return mpmath.mpf(0)
    w = gap * (1 - rM + ra + rb)                 # hi - lo = (1 - rM)^2 - (ra + rb)^2
    lo = (ra + rb)**2
    c1, c2 = 4 * rM, 4 * ra * rb                 # P - hi and lo - q of the factored Kallen functions

    def f(u):
        sh, ch = mpmath.sin(u / 2), mpmath.cos(u / 2)
        S2, C2 = sh * sh, ch * ch
        t = lo + w * S2
        if t == 0:
            return mpmath.mpf(0)
        return (2 * sh * ch)**2 * mpmath.sqrt((c1 + w * C2) * (c2 + w * S2)) / t

    return -mpmath.pi * w * w / 4 * _quad(f, [0, mpmath.pi])


def _im_outer(s, mo, ma, mb):
    """Im S(s) with mo integrated outside; uses Im S(s; m) = s Im S(1; m/s)."""
    if s <= 0:
        return mpmath.mpf(0)
    return s * _im_unit(mo / s, ma / s, mb / s)


def _sunset_im_kernel(s, m1sq, m2sq, m3sq, dps=None):
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s, (ma, mb, mo) = _inputs(s, (m1sq, m2sq, m3sq))   # heaviest mass integrated outside
        if s <= sunset_threshold(ma, mb, mo):
            return mpmath.mpf(0)
        return +_im_outer(s, mo, ma, mb)


def _tail(g, T):
    """Int_T^oo g(t) dt via t = 1/v (one interval; tanh-sinh handles the log at v = 0)."""
    return _quad(lambda v: g(1 / v) / (v * v) if v > 0 else mpmath.mpf(0), [0, 1 / T])


def _sub_kernel(s, m1sq, m2sq, m3sq, dps=None):
    """S(s) - S(0) - s S'(0) at unit threshold scale, multiplied back."""
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s, msq = _inputs(s, (m1sq, m2sq, m3sq))
        if s == 0:
            return mpmath.mpc(0)
        th = sunset_threshold(*msq)
        if th == 0:
            raise ValueError("all-massless sunset: S'(0) does not exist, so S(s) - S(0) - s S'(0) is undefined")
        x = s / th
        ma, mb, mo = (m / th for m in msq)
        h = lambda t: _im_outer(t, mo, ma, mb) / (t * t)
        if x < 1:
            T = 4 * max(abs(x), 1)
            g = lambda t: h(t) / (t - x)
            disp = _quad(g, [1, 2, T]) + _tail(g, T)
            val = mpmath.mpc(disp / mpmath.pi)
        elif x == 1:
            raise ValueError("the dispersion integral is evaluated off the threshold point")
        else:
            hx = h(x)
            e = x * mpmath.mpf(10)**(-(mpmath.mp.dps // 2))
            dh = (h(x + e) - h(x - e)) / (2 * e) if x - e > 1 else mpmath.mpf(0)
            near = _quad(lambda t: dh if t == x else (h(t) - hx) / (t - x), [1, x, 2 * x - 1])
            T = 4 * x
            g = lambda t: h(t) / (t - x)
            far = _quad(g, [2 * x - 1, T]) + _tail(g, T)
            val = mpmath.mpc((near + far) / mpmath.pi, hx)
        return +(th * x * x * val)


def _d2_kernel(s, m1sq, m2sq, m3sq, dps=None):
    """d^2 S/ds^2 below threshold, at unit scale, multiplied back."""
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s, msq = _inputs(s, (m1sq, m2sq, m3sq))
        th = sunset_threshold(*msq)
        if s >= th:
            raise ValueError("sunset_d2 is implemented below threshold only")
        lam = th if th > 0 else -s
        x = s / lam
        ma, mb, mo = (m / lam for m in msq)
        start = th / lam
        T = 4 * max(abs(x), 1, start)
        g = lambda t: _im_outer(t, mo, ma, mb) / (t - x)**3
        val = _quad(g, [start, (start + T) / 2, T]) + _tail(g, T)
        return +(2 * val / mpmath.pi / lam)


def sunset_im(s, m1sq, m2sq, m3sq, dps=None):
    """Imaginary part of the sunset (zero below the three-particle threshold); certified."""
    return _certified(_sunset_im_kernel, s, m1sq, m2sq, m3sq, dps=dps)


def sunset_subtracted(s, m1sq, m2sq, m3sq, dps=None):
    """
    S(s) - S(0) - s S'(0) = (s^2/pi) Int_th^oo dt Im S(t) / (t^2 (t - s - i0)).

    Finite and scheme independent; certified. Cost: a nested 1-D quadrature at two
    working precisions (seconds).
    """
    return _certified(_sub_kernel, s, m1sq, m2sq, m3sq, dps=dps, cert_step=12)


def sunset_d2(s, m1sq, m2sq, m3sq, dps=None):
    """d^2 S/ds^2 = (2/pi) Int_th^oo dt Im S(t) / (t - s)^3, for s below threshold; certified."""
    return _certified(_d2_kernel, s, m1sq, m2sq, m3sq, dps=dps, cert_step=12)
