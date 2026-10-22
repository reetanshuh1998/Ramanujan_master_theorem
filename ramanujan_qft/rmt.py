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
    r"""
    Mellin transform by Ramanujan's Master Theorem.

    If :math:`f(x) = \sum_{n\ge0} \varphi(n)\,(-x)^n/n!`, then

    .. math:: \int_0^\infty x^{s-1} f(x)\,dx = \Gamma(s)\,\varphi(-s).

    This function returns the right-hand side, ``Gamma(s) * phi(-s)``.

    Parameters
    ----------
    phi : callable
        The analytic continuation of the Taylor-coefficient function. It is called
        once, with the mpmath number ``-s``, at the working precision, so write it
        with mpmath functions (``mpmath.gamma``, ``mpmath.rgamma``, ``mpmath.rf``, ...).
    s : number or str
        The Mellin variable. It should lie in the strip where the integral converges;
        outside it the analytic continuation is returned. Strings are exact decimals.
    dps : int, optional
        Decimal digits of working precision (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpf or mpmath.mpc

    Notes
    -----
    The theorem holds for the continuation of :math:`\varphi` that satisfies Hardy's
    growth condition: with :math:`\lambda(v) = \varphi(v)/\Gamma(1+v)` analytic for
    :math:`\operatorname{Re} v \ge -\delta`, :math:`|\lambda(v + iw)| < C e^{Pv + A|w|}`
    with :math:`A < \pi`. A function that agrees with :math:`\varphi` on the integers
    but grows faster (for example :math:`\varphi(v) + \sin(\pi v)`) gives a wrong
    value. This cannot be detected from a black-box callable, so check new uses with
    :func:`mellin_numeric`.

    References
    ----------
    G. H. Hardy, *Ramanujan: Twelve Lectures on Subjects Suggested by His Life and
    Work*, Cambridge University Press (1940), ch. XI. T. Amdeberhan, O. Espinosa,
    I. Gonzalez, M. Harrison, V. H. Moll, A. Straub, *Ramanujan's Master Theorem*,
    Ramanujan J. 29 (2012) 103.

    Examples
    --------
    :math:`e^{-x}` has :math:`\varphi(n) = 1`, so its Mellin transform is :math:`\Gamma(s)`:

    >>> import mpmath
    >>> ramanujan_master_theorem(lambda n: 1, 2.5)
    mpf('1.329340388179137')

    :math:`(1+x)^{-3}` has :math:`\varphi(n) = \Gamma(3+n)/\Gamma(3)`, which gives the
    Beta function :math:`B(s, 3-s)`:

    >>> ramanujan_master_theorem(lambda n: mpmath.gamma(3 + n) / 2, 1.25)
    mpf('0.41652027545234682')
    >>> mpmath.beta(1.25, 1.75)
    mpf('0.41652027545234682')
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        s = mpmath.mpmathify(s)
        return +(mpmath.gamma(s) * phi(-s))


def mellin_numeric(f, s, dps=None):
    r"""
    Numerical Mellin transform :math:`\int_0^\infty x^{s-1} f(x)\,dx`, for cross-checks.

    Intended for non-oscillatory ``f`` that behave like a power :math:`x^{p_0}` as
    :math:`x \to 0` and decay like a power (or faster) as :math:`x \to \infty`.

    Parameters
    ----------
    f : callable
        The integrand factor; called with mpmath numbers.
    s : number or str
        The Mellin variable; ``Re s > 0`` is required.
    dps : int, optional
        Decimal digits of working precision (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpf or mpmath.mpc
        The integral, accepted only if the quadrature error estimate is below
        :math:`10^{-\lfloor dps/2 \rfloor}` relative to the value. Ask for more
        digits than you want to compare.

    Raises
    ------
    ValueError
        If ``Re s <= 0``; if ``f`` vanishes at sample points; if ``f`` is not in its
        power-law regime on :math:`[10^{-12}, 10^{-4}]` or :math:`[10^{4}, 10^{12}]`
        (oscillating or logarithmic behaviour); or if the integral diverges, or
        nearly so, at either end.
    ArithmeticError
        If the quadrature error estimate does not reach about half of the working
        digits.

    Notes
    -----
    The exponent :math:`p_0` is estimated from samples at :math:`x = 10^{-4}, \dots,
    10^{-12}` and the decay :math:`f \sim x^{-a}` from samples at :math:`x = 10^{4},
    \dots, 10^{12}`. The algebraic endpoint behaviour is removed by the substitutions
    :math:`x = y^{1/\sigma}` on :math:`[0, 1]`, with :math:`\sigma = \operatorname{Re} s + p_0`,
    and :math:`x = y^{-1/c}` on :math:`[1, \infty)`, with :math:`c = a - \operatorname{Re} s`,
    before tanh-sinh quadrature (``mpmath.quad``).

    Examples
    --------
    >>> import mpmath
    >>> mellin_numeric(lambda x: (1 + x)**-3, 1.25)
    mpf('0.41652027545234682')
    >>> mellin_numeric(lambda x: 1 / (1 + x), 1)
    Traceback (most recent call last):
    ...
    ValueError: the Mellin integral diverges (or nearly so) at infinity for this s
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
    r"""
    Radial integral of a massive propagator in :math:`D` dimensions, by RMT.

    .. math::

        \int_0^\infty dq^2\,(q^2)^{D/2-1}\,\frac{1}{q^2+m^2}
        = (m^2)^{D/2-1}\,\Gamma(D/2)\,\Gamma(1-D/2).

    The expansion :math:`1/(q^2+m^2) = \sum_n \Gamma(n+1)(m^2)^{-n-1}(-q^2)^n/n!` gives
    :math:`\varphi(n) = \Gamma(n+1)/(m^2)^{n+1}`, and the theorem is applied at
    :math:`s = D/2`.

    Parameters
    ----------
    msq : number or str
        The squared mass :math:`m^2 > 0`.
    D : number or str
        The dimension. The integral converges for :math:`0 < D < 2`; elsewhere the
        analytic continuation in :math:`D` is returned, which is dimensional
        regularisation. At :math:`D = 2, 4, 6, \dots` the continuation has a pole and
        mpmath raises ``ValueError``.
    dps : int, optional
        Decimal digits of working precision (default: ``mpmath.mp.dps``).

    Returns
    -------
    mpmath.mpf or mpmath.mpc

    Raises
    ------
    ValueError
        If ``msq`` is not positive, or at a pole in ``D``.

    Notes
    -----
    Dividing by :math:`\Gamma(D/2)` gives the Euclidean tadpole
    :math:`\int d^Dq_E/\pi^{D/2}\,(q_E^2+m^2)^{-1} = \Gamma(1-D/2)\,(m^2)^{D/2-1}`.

    Examples
    --------
    >>> massive_propagator_rmt(2.5, 1.5)
    mpf('3.533294752055899')
    >>> print(massive_propagator_rmt(4, 3))     # D = 3 by continuation: -2 pi
    -6.28318530717959
    """
    with mpmath.workdps(dps if dps is not None else mpmath.mp.dps):
        m2, D = mpmath.mpf(msq), mpmath.mpmathify(D)
        if not m2 > 0:
            raise ValueError("msq must be positive")
        phi = lambda n: mpmath.gamma(n + 1) / m2**(n + 1)
        return ramanujan_master_theorem(phi, D / 2)
