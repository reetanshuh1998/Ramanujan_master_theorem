"""Independent checks of the equal-mass analytic continuation chart."""
import mpmath as mp
import pytest
import sympy as sp

from ramanujan_qft import (ScalarEdge, ScalarGraph, compile_sunset_taylor,
                           integrate_sunset_taylor, integrate_graph_rmt,
                           SunsetTaylorConvergenceError)


def graph(p=0, mass=1):
    return ScalarGraph([ScalarEdge(0, 1, mass)]*3, {0: [p], 1: [-p]})


def parameter_reference(q2, dps=50):
    # Cheng-Wu x+y=1: integrate z analytically in the positive quadratic
    # z^2 + (1+a+q2*a)z + a, then quadrature in x. No series or Clausen seed.
    with mp.workdps(dps):
        def integrand(x):
            a = x*(1-x)
            if not a:
                return mp.mpf(0)
            B = 1+a+q2*a
            delta = (1-a)**2+q2*a*(2*(1+a)+q2*a)
            root = mp.sqrt(delta)
            return 2*mp.asinh(root/(2*mp.sqrt(a)))/root if root else 2/B
        return mp.quad(integrand, [0, mp.mpf('.5'), 1])


@pytest.mark.parametrize('p', [0, 1, 2, 3, 6])
def test_independent_parameter_reference(p):
    result = integrate_sunset_taylor(graph(p), dps=30)
    with mp.workdps(60):
        expected = parameter_reference(p*p)
        assert abs(result.value-expected) <= result.error_estimate+mp.mpf('1e-45')
        assert result.error_estimate < mp.mpf('1e-30')*abs(expected)
    assert result.converged and 'Taylor' in result.method


def test_vacuum_clausen_and_scaling():
    for exponent in (-80, 0, 80):
        mass = sp.Rational(10)**exponent
        result = integrate_sunset_taylor(graph(mass=mass), dps=50)
        with mp.workdps(70):
            expected = 4*mp.im(mp.polylog(2, mp.exp(mp.j*mp.pi/3)))/mp.sqrt(3)
            expected /= mp.mpf(10)**exponent
            assert abs(result.value-expected) < mp.mpf('1e-50')*abs(expected)
        assert result.terms == 1


def test_overlap_with_generated_rmt_series():
    g = graph(6)
    taylor = integrate_sunset_taylor(g, dps=23)
    rmt = integrate_graph_rmt(g, dps=23)
    with mp.workdps(50):
        assert abs(taylor.value-rmt.value) <= taylor.error_estimate+rmt.error_estimate


def test_partial_series_has_valid_tail_bound():
    with pytest.raises(SunsetTaylorConvergenceError) as caught:
        integrate_sunset_taylor(graph(2), dps=30, max_terms=6)
    result = caught.value.result
    with mp.workdps(50):
        assert abs(result.value-parameter_reference(4)) <= result.truncation_bound
    assert result.terms == 6 and not result.converged


def test_recurrence_precision_and_context_restoration():
    # 8**n contamination makes the recurrence unsafe at requested precision.
    with mp.workdps(17):
        result = integrate_sunset_taylor(graph(6), dps=25)
        assert result.working_dps > 200
        assert mp.mp.dps == 17
        with pytest.raises(SunsetTaylorConvergenceError, match='max_dps'):
            integrate_sunset_taylor(graph(6), dps=25, max_dps=100)
        assert mp.mp.dps == 17


def test_extreme_momentum_exhausts_budget_without_domain_rounding():
    series = compile_sunset_taylor(graph(10**80))
    assert 0 < series.ratio < 1
    with pytest.raises(SunsetTaylorConvergenceError):
        series.evaluate(max_terms=8)


@pytest.mark.parametrize('kwargs', [{'dps': 9}, {'max_terms': 0}, {'max_dps': True}])
def test_invalid_budgets(kwargs):
    with pytest.raises(ValueError):
        integrate_sunset_taylor(graph(), **kwargs)


def test_exact_equal_mass_domain_only():
    with pytest.raises(NotImplementedError, match='equal masses'):
        compile_sunset_taylor(ScalarGraph([ScalarEdge(0, 1, m) for m in (1, 1, '1.0000000000000001')]))
    with pytest.raises(NotImplementedError, match='D=2'):
        compile_sunset_taylor(graph(), D=4)
    with pytest.raises(NotImplementedError, match='unit'):
        compile_sunset_taylor(ScalarGraph([ScalarEdge(0, 1, 1, 2)]*3))
    with pytest.raises(NotImplementedError, match='parallel'):
        compile_sunset_taylor(ScalarGraph([ScalarEdge(0, 0, 1)]))
    with pytest.raises(TypeError):
        compile_sunset_taylor(None)


def test_no_quadrature_or_rmt_fallback(monkeypatch):
    def forbidden(*args, **kwargs):
        raise AssertionError('unexpected numerical fallback')
    import ramanujan_qft.sunset_rmt as rmt
    monkeypatch.setattr(mp, 'quad', forbidden)
    monkeypatch.setattr(rmt, 'integrate_graph_rmt', forbidden)
    assert integrate_sunset_taylor(graph(1), dps=20).converged
