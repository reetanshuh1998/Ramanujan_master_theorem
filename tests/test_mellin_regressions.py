"""
Regression tests for the issues found in the adversarial audit of the Mellin
residue engine (see AUDIT.md, "RACE audit"). Every reference value is a closed
form or an independent high-precision quadrature.
"""
import time

import mpmath as mp
import pytest

from ramanujan_qft import (SeriesConvergenceError, bessel_j, cosine, exponential, gaussian,
                           inverse_power, product_integral, sine)


def rel(a, b):
    return abs(a - b) / abs(b) if b != 0 else abs(a)


# --- invalid contour closure: asymptotic "expand the Gaussian" series --------------

@pytest.mark.parametrize("f,g,s,exact", [
    (gaussian(1), cosine(1), 1, mp.sqrt(mp.pi) / 2 * mp.exp(-mp.mpf(1) / 4)),
    (gaussian(1), bessel_j(1, 1), 1, 1 - mp.exp(-mp.mpf(1) / 4)),
    (gaussian(1), bessel_j(0, 1), 2, mp.exp(-mp.mpf(1) / 4) / 2),            # Weber's integral
    (gaussian(1), sine(1), 2, mp.sqrt(mp.pi) / 4 * mp.exp(-mp.mpf(1) / 4)),
    (gaussian(1), cosine(10), 1, mp.sqrt(mp.pi) / 2 * mp.exp(-25)),
    (gaussian(0.5), bessel_j(0, 8), 1, mp.sqrt(2 * mp.pi) / 2 * mp.exp(-16) * mp.besseli(0, 16)),  # GR 6.618.1
])
def test_gaussian_times_oscillatory(f, g, s, exact):
    for a, b in ((f, g), (g, f)):                      # independent of argument order
        assert rel(product_integral(a, b, s=s), exact) < 1e-13


# --- balanced oscillatory pairs: Weber-Schafheitlin discontinuous integrals ----------

@pytest.mark.parametrize("f,g,exact", [
    (bessel_j(0, 2), cosine(1), 1 / mp.sqrt(3)),         # 1/sqrt(a^2-b^2), b < a
    (bessel_j(0, 1), cosine(2), 0),                       # 0 for b > a
    (bessel_j(0, 1), sine(2), 1 / mp.sqrt(3)),            # 1/sqrt(b^2-a^2), b > a
    (bessel_j(0, 2), sine(1), 0),                         # 0 for b < a
    (bessel_j(1, 2), bessel_j(0, 1), mp.mpf(1) / 2),      # 1/a for b < a
    (bessel_j(0, 2), bessel_j(1, 1), 0),                  # 0 for b > a
])
def test_weber_schafheitlin(f, g, exact):
    for a, b in ((f, g), (g, f)):
        v = product_integral(a, b)
        assert abs(v - exact) < 1e-13 * max(1, abs(exact))


def test_bessel_times_bessel_continuous_case():
    # Int J0(x) J0(2x) dx = (2/(pi*3)) K(4/9)  [Gradshteyn-Ryzhik 6.512.1 with a=1, b=2]
    v = product_integral(bessel_j(0, 1), bessel_j(0, 2))
    exact = mp.quadosc(lambda x: mp.besselj(0, x) * mp.besselj(0, 2 * x), [0, mp.inf], omega=1)
    assert rel(v, exact) < 1e-10


# --- cancellation, near collisions, tiny values, complex s ---------------------------

def test_cancellation_is_compensated():
    with mp.workdps(40):
        ex1 = mp.quad(lambda x: mp.exp(-x) * (x + 20)**mp.mpf(-1.5), [0, 1, 10, 100, mp.inf])
    assert rel(product_integral(exponential(1), inverse_power(20, 1.5)), ex1) < 1e-14
    with mp.workdps(40):
        ex2 = mp.quad(lambda x: mp.exp(-1.3629 * x - 0.0232 * x * x), [0, 10, 100, mp.inf])
    assert rel(product_integral(exponential(1.3629), gaussian(0.0232)), ex2) < 1e-14
    assert rel(product_integral(cosine(1), inverse_power(40, 1), dps=20),
               -mp.ci(40) * mp.cos(40) - (mp.si(40) - mp.pi / 2) * mp.sin(40)) < 1e-12


def test_complex_s():
    s = mp.mpc(1, 20)
    exact = mp.gamma(s) * ((2 - 5j)**(-s) + (2 + 5j)**(-s)) / 2
    assert rel(product_integral(exponential(2), cosine(5), s=s), exact) < 1e-13


@pytest.mark.parametrize("kw", [dict(v=1 + 1e-12), dict(v=1, s=1 + 1e-13), dict(v=1 + 1e-6)])
def test_near_pole_collision(kw):
    v, s = kw["v"], kw.get("s", 1)
    with mp.workdps(40):
        exact = mp.quad(lambda x: x**(mp.mpf(s) - 1) * mp.exp(-2 * x) * (x + 3)**(-mp.mpf(v)), [0, 1, 10, 100, mp.inf])
    assert rel(product_integral(exponential(2), inverse_power(3, v), s=s), exact) < 1e-13


def test_tiny_result_relative_accuracy():
    with mp.workdps(40):
        exact = (mp.sqrt(mp.mpf(1.25)) - 1)**50 / mp.mpf(0.5)**50 / mp.sqrt(mp.mpf(1.25))
    assert rel(product_integral(exponential(1), bessel_j(50, 0.5)), exact) < 1e-13


def test_parameters_kept_at_requested_precision():
    v = product_integral(exponential("0.1"), bessel_j(0, 1), dps=50)
    with mp.workdps(50):
        assert rel(v, 1 / mp.sqrt(mp.mpf("0.01") + 1)) < mp.mpf(10)**-48


# --- existence of the integral and parameter validation -------------------------------

@pytest.mark.parametrize("f,g,s", [
    (cosine(1), cosine(2), 1),                    # oscillating, not decaying
    (exponential(1), inverse_power(1, 1), 0),     # divergent at x = 0
    (inverse_power(1, 0.5), inverse_power(2, 0.4), 1),
    (gaussian(1), cosine(1), -0.5),
])
def test_divergent_integrals_raise(f, g, s):
    with pytest.raises(ValueError):
        product_integral(f, g, s=s)


def test_continuation_flag():
    # Int x^(s-1) e^(-x) e^(-2x) dx = 3^(-s) Gamma(s), continued to s = -1/2
    v = product_integral(exponential(1), exponential(2), s=-0.5, continuation=True)
    assert rel(v, mp.sqrt(3) * mp.gamma(-0.5)) < 1e-13


@pytest.mark.parametrize("make", [lambda: exponential(-1), lambda: gaussian(0), lambda: cosine(-2),
                                  lambda: inverse_power(-1, 1), lambda: inverse_power(1, -1),
                                  lambda: inverse_power(1, 0), lambda: bessel_j(-1.5, 1)])
def test_invalid_parameters(make):
    with pytest.raises(ValueError):
        make()


def test_negative_integer_bessel_order():
    assert rel(product_integral(exponential(2), bessel_j(-1, 1)), -(1 - 2 / mp.sqrt(5))) < 1e-14


# --- convergence boundary and performance ---------------------------------------------

@pytest.mark.parametrize("f,g", [(exponential(1), bessel_j(0, 1)), (exponential(1), cosine(1)),
                                 (inverse_power(1, 1), inverse_power(1, 1))])
def test_boundary_raises_quickly(f, g):
    t = time.perf_counter()
    with pytest.raises(SeriesConvergenceError):
        product_integral(f, g)
    assert time.perf_counter() - t < 2


def test_near_boundary_uses_acceleration():
    v, info = product_integral(exponential(1), bessel_j(0, 1.05), return_info=True)
    assert rel(v, 1 / mp.sqrt(1 + mp.mpf(1.05)**2)) < 1e-13


def test_log_case_fast():
    t = time.perf_counter()
    assert rel(product_integral(inverse_power(1, 1), inverse_power(2, 1)), mp.log(2)) < 1e-14
    assert time.perf_counter() - t < 2
