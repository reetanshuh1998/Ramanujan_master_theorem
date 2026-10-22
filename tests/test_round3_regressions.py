"""
Regression tests for the third adversarial audit (sunset accuracy at threshold and
at extreme scales). References: the closed form for masses (0, 0, M),

    Im S = -pi [ (s^2 - M^2)/(2s) - M log(s/M) ],
    S(s) - S(0) - s S'(0) = G(s) - M/2 - (5/4) s,
    G(s) = (s^2 - M^2)/(2s) log(1 - s/M) + M Li2(s/M)   (s -> s + i0),

and the exact homogeneity Im S(lam s; lam m) = lam Im S(s; m).
"""
import mpmath as mp
import pytest

from ramanujan_qft import sunset_d2, sunset_im, sunset_subtracted


def _closed(s, M, wp=120):
    with mp.workdps(wp):
        s, M = mp.mpf(s), mp.mpf(M)
        im = -mp.pi * ((s**2 - M**2) / (2 * s) - M * mp.log(s / M)) if s > M else mp.mpf(0)
        x = s / M
        if x < 1:
            G = (s**2 - M**2) / (2 * s) * mp.log(1 - x) + M * mp.polylog(2, x)
        else:
            G = ((s**2 - M**2) / (2 * s) * mp.mpc(mp.log(x - 1), -mp.pi)
                 + M * mp.mpc(mp.polylog(2, x).real, mp.pi * mp.log(x)))
        return im, G - M / 2 - mp.mpf(5) / 4 * s


def rel(a, b):
    with mp.workdps(80):
        return abs(mp.mpmathify(a) - b) / abs(b)


@pytest.mark.parametrize("s,M,dps", [(1.00000001, 1, 15), (1.0000000001, 1, 15), (1.000000000001, 1, 15),
                                     (1.000000000001, 1, 30), (1.0000000001, 1, 50), (1.01e-12, 1e-12, 30),
                                     (9.000000000000002, 9, 15), (1e14, 1e12, 15)])
def test_im_near_threshold_and_scales(s, M, dps):
    exact = _closed(s, M)[0]
    with mp.workdps(dps + 20):
        assert rel(sunset_im(s, 0, 0, M, dps=dps), exact) < mp.mpf(10)**(-dps + 1)


@pytest.mark.parametrize("k", [-60, -40, 0, 40])
def test_im_scale_invariance(k):
    lam = mp.mpf(2)**k
    v = sunset_im(100 * lam, lam, 2 * lam, 3 * lam, dps=20)
    with mp.workdps(30):
        assert rel(v / lam, mp.mpf("-88.18499555155591471028413")) < 1e-19


def test_im_light_mass_hierarchy():
    v = sunset_im(1.001, 1e-12, 1e-12, 1.0)
    assert rel(v, mp.mpf("-5.2273388039779894e-10")) < 1e-14


@pytest.mark.slow
@pytest.mark.parametrize("s,M", [(-5e12, 1e12), (2e12, 1e12), (-5e-12, 1e-12), (0.5, 1), (10, 1), (1.0000001, 1)])
def test_subtracted_vs_closed_form(s, M):
    assert rel(sunset_subtracted(s, 0, 0, M), _closed(s, M)[1]) < 1e-14


@pytest.mark.slow
@pytest.mark.parametrize("s,M", [(5e11, 1e12), (-2, 1), (0.9, 1)])
def test_d2_vs_closed_form(s, M):
    with mp.workdps(70):
        h = mp.mpf("1e-12") * max(abs(mp.mpf(s)), mp.mpf(M))
        exact = mp.diff(lambda z: _closed(z, M, wp=90)[1].real, mp.mpf(s), 2, h=h)
    assert rel(sunset_d2(s, 0, 0, M), exact) < 1e-14


@pytest.mark.slow
def test_general_masses_large_scale():
    L = 2.0**40
    assert rel(sunset_subtracted(-5 * L, L, 2 * L, 3 * L) / L, mp.mpf("-0.18287306043947604")) < 1e-12
    assert rel(sunset_d2(3 * L, L, 2 * L, 3 * L) * L, mp.mpf("-0.017710964853913942")) < 1e-12


def test_non_finite_rejected():
    with pytest.raises(ValueError):
        sunset_im(float("nan"), 1, 2, 3)
