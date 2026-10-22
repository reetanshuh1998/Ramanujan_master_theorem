"""Mellin residue summation (RACE) against closed forms and quadrature."""
import mpmath as mp
import pytest

from ramanujan_qft import (SeriesConvergenceError, bessel_j, cosine, exponential, gaussian,
                           gaussian_bessel, inverse_power, product_integral, sine)
from ramanujan_qft.core import AnalyticalConvolutionEngine, TripleProductEngine


def rel(a, b):
    return abs(a - b) / abs(b)


@pytest.mark.parametrize("k,b", [(3, 4), (4, 3), (1, 0.5), (1, 10), (1, 1e3), (1, 1e5), (0.01, 7)])
def test_exp_bessel_closed_form(k, b):
    with mp.workdps(30):
        val = product_integral(exponential(k), bessel_j(0, b), dps=30)
        assert rel(val, 1 / mp.sqrt(mp.mpf(k)**2 + mp.mpf(b)**2)) < 1e-27


def test_exp_bessel_nu_and_s():
    # Int x^(s-1) e^(-kx) J_nu(bx): compare with quadrature at s = 2.5, nu = 1.5
    with mp.workdps(25):
        val = product_integral(exponential(2), bessel_j(1.5, 0.7), s=2.5, dps=25)
        num = mp.quad(lambda x: x**1.5 * mp.exp(-2 * x) * mp.besselj(1.5, 0.7 * x), [0, mp.inf])
        assert rel(val, num) < 1e-20


@pytest.mark.parametrize("f,g,exact", [
    (exponential(1), cosine(3), mp.mpf(1) / 10),
    (exponential(2), sine(5), mp.mpf(5) / 29),
])
def test_exp_trig(f, g, exact):
    assert rel(product_integral(f, g), exact) < 1e-13


def test_exp_gaussian():
    with mp.workdps(25):
        num = mp.quad(lambda x: mp.exp(-5 * x - 2 * x * x), [0, mp.inf])
        assert rel(product_integral(exponential(5), gaussian(2), dps=25), num) < 1e-20


def test_pole_collision_gives_logarithmic_result():
    """Int e^(-2x)/(x+3) dx = e^6 E1(6): coinciding poles, needs the s +- delta scheme."""
    with mp.workdps(30):
        val = product_integral(exponential(2), inverse_power(3, 1), dps=30)
        assert rel(val, mp.exp(6) * mp.e1(6)) < 1e-25


def test_right_poles_are_included():
    with mp.workdps(25):
        val = product_integral(exponential(2), inverse_power(3, 2.5), s=1.5, dps=25)
        num = mp.quad(lambda x: mp.sqrt(x) * mp.exp(-2 * x) * (x + 3)**-2.5, [0, mp.inf])
        assert rel(val, num) < 1e-20


def test_bessel_over_linear():
    with mp.workdps(25):
        val = product_integral(bessel_j(0, 1), inverse_power(1, 1), dps=25)
        num = mp.quadosc(lambda x: mp.besselj(0, x) / (x + 1), [0, mp.inf], omega=1)
        assert rel(val, num) < 1e-15


@pytest.mark.parametrize("b", [1, 10, pytest.param(100, marks=pytest.mark.slow), pytest.param(500, marks=pytest.mark.slow)])
def test_triple_product(b):
    with mp.workdps(25):
        val = product_integral(exponential(2), gaussian_bessel(0.5, b, 1), dps=25)
        num = mp.quad(lambda x: mp.exp(-2 * x - 0.5 * x * x) * mp.besselj(1, b * x),
                      mp.linspace(0, 12, 4 * b + 4))
        assert rel(val, num) < 1e-18


def test_convergence_boundary_raises():
    """k = b sits on the boundary of both expansions: refuse rather than return a poor value."""
    with pytest.raises(SeriesConvergenceError):
        product_integral(exponential(1), bessel_j(0, 1), max_terms=500)


def test_legacy_engines():
    eng = AnalyticalConvolutionEngine(precision=20)
    r = eng.solve_product({"type": "exponential", "params": {"k": 3}}, {"type": "bessel_j0", "params": {"b": 4}})
    assert abs(r - mp.mpf("0.2")) < 1e-14
    t = TripleProductEngine(precision=20).solve_trio_benchmark(1, 1, 1, nu=1)
    num = mp.quad(lambda x: mp.exp(-x - x * x) * mp.besselj(1, x), [0, mp.inf])
    assert rel(t, num) < 1e-15
    with pytest.raises(ValueError):
        eng.solve_product({"type": "unknown"}, {"type": "gaussian", "params": {"a": 1}})
