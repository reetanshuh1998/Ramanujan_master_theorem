"""Ramanujan's Master Theorem on classical examples (Amdeberhan et al. 2012)."""
import mpmath as mp
import pytest

from ramanujan_qft import massive_propagator_rmt, mellin_numeric, ramanujan_master_theorem as rmt

CASES = [
    # f(x) = Sum phi(n) (-x)^n / n!        phi(n)                              strip
    ("exp(-x)", lambda x: mp.exp(-x), lambda n: 1, [0.5, 2.5]),
    ("(1+x)^-3", lambda x: (1 + x)**-3, lambda n: mp.gamma(3 + n) / mp.gamma(3), [0.5, 1.7, 2.9]),
    ("J0(2 sqrt x)", lambda x: mp.besselj(0, 2 * mp.sqrt(x)), lambda n: mp.rgamma(n + 1), [0.1, 0.3, 0.7]),
    ("1/(1+x)", lambda x: 1 / (1 + x), lambda n: mp.gamma(n + 1), [0.2, 0.5, 0.9]),
]


@pytest.mark.parametrize("name,f,phi,svals", CASES, ids=[c[0] for c in CASES])
def test_rmt_matches_numerical_mellin(name, f, phi, svals):
    with mp.workdps(25):
        for s in svals:
            exact = rmt(phi, s)
            if "J0" in name:
                # independent reference: DLMF 10.22.43, Int t^(mu-1) J_0(t) dt = 2^(mu-1) G(mu/2)/G(1-mu/2);
                # x = (t/2)^2 gives Int x^(s-1) J0(2 sqrt x) dx = 2^(1-2s) * [mu = 2s]
                mu = 2 * s
                num = 2**(1 - 2 * s) * 2**(mu - 1) * mp.gamma(mu / 2) / mp.gamma(1 - mu / 2)
            else:
                num = mellin_numeric(f, s)
            assert abs(exact - num) < 1e-12 * abs(exact), (name, s)


@pytest.mark.parametrize("D", [0.5, 1, 1.5])
def test_massive_propagator(D):
    m2 = mp.mpf(2.5)
    exact = m2**(D / 2 - 1) * mp.gamma(D / 2) * mp.gamma(1 - D / 2)
    num = mellin_numeric(lambda q2: 1 / (q2 + m2), D / 2)
    val = massive_propagator_rmt(m2, D)
    assert abs(val - exact) < 1e-13 * abs(exact)
    assert abs(val - num) < 1e-10 * abs(exact)


def test_massive_propagator_dimreg_continuation():
    # D = 3 (outside the convergence strip) is defined by continuation: -2 pi m in these units
    assert abs(massive_propagator_rmt(4, 3) - (-mp.pi * 2)) < 1e-13 * 2 * mp.pi
