"""
Regression tests for the second adversarial audit (AUDIT.md, round 2).
References are closed forms or independent quadratures, as reported and
re-derived by the independent reproducers.
"""
import time

import mpmath as mp
import pytest

from ramanujan_qft import (B0, C0, C0_mob, SeriesConvergenceError, bessel_j, bubble_3d, cosine,
                           exponential, gaussian, gaussian_bessel, inverse_power, mellin_numeric,
                           product_integral, sine, sunset_subtracted, sunset_threshold)
from ramanujan_qft.utils import HypergeometricConvergenceFilter, RamanujanContinuationEngine


def rel(a, b):
    return abs(a - b) / abs(b)


# --- RACE: inputs extremely close to lattice points -------------------------------------

@pytest.mark.parametrize("s", [1e-18, 1e-25, 1e-40])
@pytest.mark.parametrize("dps", [15, 30])
def test_tiny_s_near_lattice(s, dps):
    # Int x^(s-1) sin(x/2) cos(x) dx = (1/2) Gamma(s) sin(pi s/2) [(3/2)^-s - (1/2)^-s]
    with mp.workdps(dps + 40):
        S = mp.mpf(s)
        exact = mp.gamma(S) * mp.sinpi(S / 2) * (mp.mpf(1.5)**(-S) - mp.mpf(0.5)**(-S)) / 2
    v = product_integral(sine(0.5), cosine(1), s=s, dps=dps)
    with mp.workdps(dps + 40):
        assert rel(v, exact) < mp.mpf(10)**(-dps + 1)


def test_tiny_bessel_order():
    # nu -> 0: I(nu) = Int J_nu(x) cos(2x) dx ~ -9.0689968211710896e-26 at nu = 1e-25
    v = product_integral(bessel_j(1e-25, 1), cosine(2))
    assert rel(v, mp.mpf("-9.0689968211710896e-26")) < 1e-14


# --- RACE: a-priori peak of the terms (gaussian_bessel late hump) ------------------------

@pytest.mark.parametrize("f,g,s,exact", [
    (cosine(18), gaussian_bessel(1, 20, 1), 1, mp.mpf("0.02368725389505176")),
    (cosine(9), gaussian_bessel(0.25, 10, 1), 1, mp.mpf("0.04737450779010351")),
    (cosine(18), gaussian_bessel(1, 20, 2), 2, mp.mpf("-0.02793470099121504")),
    (bessel_j(0, 18), gaussian_bessel(1, 20, 1), 1, mp.mpf("0.0457866439807575")),
])
def test_gaussian_bessel_late_hump(f, g, s, exact):
    assert rel(product_integral(f, g, s=s), exact) < 1e-14


# --- RACE: pole collision close to a singularity of I(s) --------------------------------

def test_collision_near_strip_edge():
    v = product_integral(exponential(1), inverse_power(1, 1 + 2**-30), s=2**-30)
    assert rel(v, mp.mpf("1073741822.826437")) < 1e-14


# --- RACE: Wynn epsilon only where reliable ----------------------------------------------

@pytest.mark.parametrize("b", ["1.01", "1.002"])
def test_wynn_alternating_near_boundary(b):
    B = mp.mpf(b)
    v, info = product_integral(exponential(1), bessel_j(0, b), return_info=True)
    assert "Wynn" in info["method"]
    assert rel(v, 1 / mp.sqrt(1 + B**2)) < 1e-14


@pytest.mark.parametrize("f,g,s", [
    (sine("0.999245"), cosine(1), -0.98),
    (bessel_j(-0.5, "0.998636"), cosine(1), 1.499),
])
def test_fixed_sign_slow_series_refused(f, g, s):
    with pytest.raises(SeriesConvergenceError):
        product_integral(f, g, s=s)


# --- RACE: equal-frequency strip, refusals and errors ------------------------------------

@pytest.mark.parametrize("f,g,s", [(sine(1), cosine(1), 0), (bessel_j(0, 1), bessel_j(1, 1), 1),
                                   (cosine(1), bessel_j(0.5, 1), 1), (sine(1), bessel_j(-0.5, 1), 1)])
def test_equal_frequency_convergent_is_not_called_divergent(f, g, s):
    # these integrals exist (vanishing beat term); rho = 1, so the engine cannot
    # compute them, but it must not claim divergence
    with pytest.raises(SeriesConvergenceError):
        product_integral(f, g, s=s)


def test_equal_frequency_divergent():
    with pytest.raises(ValueError):
        product_integral(cosine(1), cosine(1), s=1)     # beat term cos(0) = 1 survives


def test_special_function_noconvergence_is_wrapped():
    t = time.perf_counter()
    with pytest.raises(SeriesConvergenceError):
        product_integral(cosine(18.5), gaussian_bessel(0.02, 20, 0))
    assert time.perf_counter() - t < 10


@pytest.mark.slow
def test_large_cancellation_succeeds_at_default_precision():
    # e^(km) = e^500 cancellation: needs ~230 working digits (about 30 s)
    v = product_integral(exponential(1), inverse_power(500, 3))
    with mp.workdps(40):
        exact = mp.quad(lambda x: mp.exp(-x) * (x + 500)**-3, [0, 10, 100, mp.inf])
    assert rel(v, exact) < 1e-14


def test_error_estimate_covers_rounding():
    v, info = product_integral(exponential(0.9), bessel_j(0, 1), return_info=True)
    with mp.workdps(40):
        exact = 1 / mp.sqrt(mp.mpf(0.9)**2 + 1)
        assert abs(v - exact) <= info["error_estimate"] * 2


# --- one-loop: cancellation in closed forms ----------------------------------------------

@pytest.mark.parametrize("args,exact", [
    ((1e-12, 1, 1e6), mp.mpf("-12.81552437348865")),
    ((1e-14, 1, 2), mp.mpf("-0.3862943611198895")),
    ((1e-10, 1, 1), mp.mpf("1.666666666683333e-11")),
    ((1, 1e12, 0), mp.mpf("-26.63102111592805")),
    ((1e-8, 0, 6464.16), mp.mpf("-7.774028352369068")),
    ((0, 100, 100.00000000000999), mp.mpf("-4.605170185988141")),
])
def test_B0_extreme_kinematics(args, exact):
    assert abs(B0(*args) - exact) < 1e-14 * max(1, abs(exact))


@pytest.mark.parametrize("args,exact", [
    ((1e-8, 1e6, 1, 1), mp.mpf("-1.2815537189026e-5")),
    ((1e-8, 1, 2, 3), mp.mpf("-0.26162407199851")),
    ((1e10, 1, 1e-6, 1), mp.mpc("4.7954896446795e-8", "-1.1574023645446e-8")),
    ((1e12, 1, 1, 1), mp.mpc("3.7680186175384e-10", "-8.6805412948979e-11")),
    ((-1e12, 1, 1, 1), mp.mpf("-3.817366639545e-10")),
])
def test_C0_extreme_kinematics(args, exact):
    assert rel(C0(*args), exact) < 1e-12


def _C0_quad(s, m1, m2, m3):
    s, m1, m2, m3 = (mp.mpf(x) for x in (s, m1, m2, m3))

    def inner(b):
        al = m1 - m2 - b * s
        be = (1 - b) * m2 + b * m3
        return (1 - b) / be if al == 0 else (mp.log(al * (1 - b) + be) - mp.log(be)) / al
    return -mp.quad(inner, [0, 1])


@pytest.mark.parametrize("args", [(0.5, 1, 2, 3), (1, 1, 2, 4), (1, 4, 2, 1)])
def test_C0_formerly_zero_division(args):
    with mp.workdps(30):
        assert rel(C0(*args), _C0_quad(*args)) < 1e-14


def test_C0_mob_large_s():
    assert rel(C0_mob(1e14, 1), C0(1e14, 1, 1, 1, dps=40)) < 1e-14


# --- sunset, D=3 bubble, helpers ---------------------------------------------------------

def test_sunset_massless_raises():
    with pytest.raises(ValueError):
        sunset_subtracted(5, 0, 0, 0)


def test_sunset_just_above_threshold():
    th = sunset_threshold(1, 2, 3)
    v = sunset_subtracted(th + 1e-4, 1, 2, 3)
    assert mp.isfinite(v) and abs(v.imag) < 1e-6


def test_bubble_3d_massless():
    assert rel(bubble_3d(-3, 0, 0), mp.pi**1.5 / mp.sqrt(3)) < 1e-14
    assert rel(bubble_3d(3, 0, 0), mp.mpc(0, mp.pi**1.5 / mp.sqrt(3))) < 1e-14


def test_mellin_numeric_divergent_at_zero():
    with pytest.raises(ValueError):
        mellin_numeric(lambda x: x**-0.5 / (1 + x), 0.3)
    assert rel(mellin_numeric(lambda x: x**-0.5 / (1 + x), 0.8), mp.pi / mp.sinpi(0.3)) < 1e-10


def test_hypergeom_continuation_rejects_complex():
    with pytest.raises(ValueError):
        RamanujanContinuationEngine().hypergeom_continuation_2F1(0.3, 0.8, 1.7, mp.mpc(4, -1))


def test_hcf_geometric_series():
    v = HypergeometricConvergenceFilter(precision=20).evaluate_series([1, 1], [1], 0.9)[0]
    assert abs(v - 10) < 1e-17


@pytest.mark.parametrize("call", [lambda: B0(5, 1, 1, mu2=-1), lambda: B0(5, 1, 1, mu2=0)])
def test_invalid_mu2(call):
    with pytest.raises(ValueError):
        call()
