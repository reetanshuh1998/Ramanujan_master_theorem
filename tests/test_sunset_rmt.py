"""Independent graph, Gamma-pole, quadrature, and convergence checks for RMT."""
import json
from dataclasses import replace
from pathlib import Path

import mpmath as mp
import pytest
import sympy as sp

from ramanujan_qft import (ScalarEdge, ScalarGraph, schwinger_brackets,
                           compile_sunset_rmt, integrate_graph_rmt,
                           integrate_graph, RMTDomainError, RMTSeriesConvergenceError)


def sunset(masses=(1, 1, 1), p=10, powers=(1, 1, 1)):
    return ScalarGraph([ScalarEdge('a', 'b', m, a) for m, a in zip(masses, powers)],
                       {'a': [p], 'b': [-p]})


@pytest.fixture(scope='module')
def references():
    return json.loads((Path(__file__).parent/'data/sunset_rmt_reference.json').read_text())['cases']


@pytest.fixture(scope='module')
def plans():
    return [compile_sunset_rmt(sunset()),
            compile_sunset_rmt(sunset((1, 4, 100), 0)),
            compile_sunset_rmt(sunset((1, 4, 100), 1)),
            compile_sunset_rmt(sunset((1, 4, 9), 20))]


def test_graph_to_exact_schwinger_matrix():
    eta = sp.Symbol('eta')
    system = schwinger_brackets(sunset(), propagator_shifts=(eta,)*3)
    assert system.matrix == sp.Matrix([
        [1, 1, 0, 0, 1, 1, 0], [1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 1, 0, 1, 1], [1, 0, 0, 0, 1, 1, 1]])
    assert system.offsets == sp.Matrix([1+eta, 1+eta, 1+eta, 1])
    assert system.coefficients == (100, 1, 1, 1, 1, 1, 1)
    solution = system.solve((0, 4, 5, 6))
    m0, m1, m2 = system.indices[1:4]
    assert solution.determinant == -1
    assert solution.values[0] == -1-3*eta-m0-m1-m2
    assert solution.values[4:] == (m2+eta, m1+eta, m0+eta)
    assert system.matrix*sp.Matrix(solution.values)+system.offsets == sp.zeros(4, 1)


def test_square_graph_bracket_integral():
    # A single tree edge is an elementary propagator, independently of D.
    graph = ScalarGraph([ScalarEdge(0, 1, 5, 2)])
    system = schwinger_brackets(graph, D=sp.Symbol('D', positive=True))
    result = system.solve((0, 1))
    assert sp.simplify(result.term) == sp.Rational(1, 25)


def test_exact_basis_with_bad_float_conditioning():
    base = schwinger_brackets(ScalarGraph([ScalarEdge(0, 1, 5)]))
    n = 10**20
    system = replace(base, matrix=sp.ImmutableMatrix([[n, n+1], [n+1, n+2]]))
    solution = system.solve((0, 1))
    assert solution.determinant == -1
    assert system.matrix*sp.Matrix(solution.values)+system.offsets == sp.zeros(2, 1)


@pytest.mark.parametrize('bound', [(0, 1), (0, 1, 1, 3), (0, 1, 2, 8), (0, 1, 2, -1), (False, 1, 2, 3), ([], 1, 2, 3)])
def test_invalid_bases(bound):
    with pytest.raises(ValueError, match='bound_columns'):
        schwinger_brackets(sunset()).solve(bound)


def test_nonsingular_is_not_a_convergence_certificate():
    system = schwinger_brackets(sunset(p=1))
    assert system.solve((0, 4, 5, 6)).determinant != 0
    with pytest.raises(RMTDomainError):
        compile_sunset_rmt(sunset(p=1))
    with pytest.raises(ValueError, match='singular'):
        system.solve((0, 1, 6, 2))  # k0 = m0 + u2 in the exponent matrix.


@pytest.mark.parametrize('plan_index,indices',
                         [(p, n) for p in (0, 1, 2)
                          for n in ((0, 0, 0), (1, 0, 0), (1, 1, 0))]
                         + [(0, (0, 0, 1)), (2, (0, 0, 1)),
                            (3, (0, 0, 0)), (3, (1, 1, 1))])
def test_generated_gamma_families_coalesce_to_finite_coefficient(plans, plan_index, indices):
    plan = plans[plan_index]
    assert len(plan.families) == (8 if plan.chart == 'momentum' else 4)
    assert all(abs(f.determinant) == 1 for f in plan.families)
    substitution = dict(zip(plan.summation_indices, indices))
    # This evaluates the independently generated *regulated Gamma families*,
    # not the harmonic-number expression used by the numerical backend.
    functions = [sp.lambdify(plan.regulator, term.subs(substitution), modules='mpmath')
                 for term in plan.gamma_terms]
    with mp.workdps(90):
        delta = mp.mpf('1e-14')
        plus = [f(delta) for f in functions]
        minus = [f(-delta) for f in functions]
        assert max(abs(v) for v in plus) > mp.mpf('1e20')
        finite = (mp.fsum(plus)+mp.fsum(minus))/2
        coefficient = plan.coefficient(indices, dps=60)
        assert abs(finite-coefficient) < mp.mpf('1e-25')*max(1, abs(coefficient))


@pytest.mark.parametrize('case_index', range(4))
def test_high_precision_independent_reference(references, case_index):
    case = references[case_index]
    graph = sunset(case['mass_squared'], sp.sqrt(case['p_e_squared']))
    result = integrate_graph_rmt(graph, dps=30)
    with mp.workdps(60):
        expected = mp.mpf(case['value'])
        assert abs(result.value-expected) <= result.error_estimate + mp.mpf('1e-38')*abs(expected)
        assert result.error_estimate < mp.mpf('1e-30')*abs(result.value)
        assert result.truncation_bound <= result.error_estimate
    assert result.converged and result.terms > 1
    assert result.working_dps > 30


@pytest.mark.parametrize('case_index', [0, 2, 3])
def test_analytic_tail_bounds_cover_truncated_series(references, case_index):
    case = references[case_index]
    graph = sunset(case['mass_squared'], sp.sqrt(case['p_e_squared']))
    with pytest.raises(RMTSeriesConvergenceError) as caught:
        integrate_graph_rmt(graph, dps=30, max_shells=6)
    result = caught.value.result
    with mp.workdps(60):
        assert abs(result.value-mp.mpf(case['value'])) <= result.truncation_bound
    assert not result.converged and result.shells == 6
    assert result.terms == (21 if case['p_e_squared'] == 0 else 56)


@pytest.mark.parametrize('masses,p', [((1, 1, 1), 10), ((1, 4, 100), 1)])
def test_against_existing_sector_backend(masses, p):
    graph = sunset(masses, p)
    series = integrate_graph_rmt(graph, dps=20)
    numeric = integrate_graph(graph, D=2, epsrel=2e-3, max_evaluations=4000000)
    assert float(series.value) == pytest.approx(numeric.value, rel=2e-3)


@pytest.mark.parametrize('masses,p', [((1, 1, 1), 3), ((1, 4, 9), 0),
                                      ((1, 4, 16), 1), ((1, 1, 1), 0), ((1, 4, 9), 2)])
def test_boundaries_and_uncovered_region(masses, p):
    with pytest.raises(RMTDomainError):
        compile_sunset_rmt(sunset(masses, p))


def test_exact_domain_decisions_next_to_boundary():
    above = compile_sunset_rmt(sunset(p=sp.Rational(3)+sp.Rational(1, 10**80)))
    assert above.rho_upper < 1 and above.domain_digits > 80
    with pytest.raises(RMTDomainError):
        compile_sunset_rmt(sunset(p=sp.Rational(3)-sp.Rational(1, 10**80)))
    with pytest.raises(RMTSeriesConvergenceError):
        above.evaluate(dps=15, max_shells=2)


def test_irrational_mass_domain_is_enclosed_rationally():
    plan = compile_sunset_rmt(sunset((1, 2, 100), 1))
    with mp.workdps(70):
        rho = ((1+mp.sqrt(2)+1)/10)**2
        upper = mp.mpf(int(plan.rho_upper.p))/int(plan.rho_upper.q)
        assert rho <= upper < 1


def test_work_limits_and_precision_restore(plans):
    with mp.workdps(17):
        for kwargs in ({'max_terms': 1}, {'max_shells': 1}, {'max_dps': 20}):
            with pytest.raises(RMTSeriesConvergenceError):
                plans[0].evaluate(dps=20, **kwargs)
            assert mp.mp.dps == 17
        result = plans[0].evaluate(dps=20)
        assert result.converged and mp.mp.dps == 17


@pytest.mark.parametrize('kwargs', [{'dps': 0}, {'dps': 15.5}, {'max_terms': 0},
                                    {'max_shells': True}, {'max_dps': -1}])
def test_invalid_budgets(plans, kwargs):
    with pytest.raises(ValueError):
        plans[0].evaluate(**kwargs)


@pytest.mark.parametrize('exponent', [-80, 80])
def test_common_scale_preserved_at_high_precision(exponent):
    scale = sp.Rational(10)**exponent
    a = integrate_graph_rmt(sunset(), dps=30)
    b = integrate_graph_rmt(sunset((scale,)*3, 10*sp.Rational(10)**(exponent//2)), dps=30)
    with mp.workdps(60):
        scale_mp = mp.mpf(int(scale.p))/int(scale.q)
        assert abs(a.value-b.value*scale_mp) < mp.mpf('1e-29')*abs(a.value)


def test_graph_relabeling_and_edge_order():
    a = sunset((1, 4, 9), 20)
    b = ScalarGraph([ScalarEdge(7, 5, e.mass_squared) for e in reversed(a.edges)],
                    {5: [-20], 7: [20]})
    first, second = integrate_graph_rmt(a, dps=25), integrate_graph_rmt(b, dps=25)
    assert first.value == second.value
    assert first.terms == second.terms


def test_no_quadrature_or_qmc_fallback(monkeypatch, plans):
    def forbidden(*args, **kwargs):
        raise AssertionError('numerical integration is forbidden in the RMT backend')
    import ramanujan_qft.multiloop as multiloop
    monkeypatch.setattr(mp, 'quad', forbidden)
    monkeypatch.setattr(multiloop, 'integrate_graph', forbidden)
    assert plans[0].evaluate(dps=20).converged
    assert plans[2].evaluate(dps=20).converged


def test_supported_domain_is_explicit():
    with pytest.raises(NotImplementedError, match='D=2'):
        compile_sunset_rmt(sunset(), D='2.00000000000001')
    with pytest.raises(NotImplementedError, match='unit'):
        compile_sunset_rmt(sunset(powers=(1, 2, 1)))
    with pytest.raises(NotImplementedError, match='parallel'):
        compile_sunset_rmt(ScalarGraph([ScalarEdge(0, 0, 1)]))
    with pytest.raises(NotImplementedError, match='parallel'):
        compile_sunset_rmt(ScalarGraph([ScalarEdge(0, 0, 1), ScalarEdge(0, 1, 1), ScalarEdge(1, 1, 1)]))
    with pytest.raises(ValueError, match='chart'):
        compile_sunset_rmt(sunset(), chart='unknown')
    with pytest.raises(RMTDomainError):
        compile_sunset_rmt(sunset(), chart='mass')
    with pytest.raises(RMTDomainError):
        compile_sunset_rmt(sunset((1, 4, 100), 0), chart='momentum')


def test_formal_brackets_reject_invalid_scalar_parameters():
    for dimension in (True, [2], sp.oo, sp.nan, 0, -2, sp.I):
        with pytest.raises(ValueError):
            schwinger_brackets(sunset(), D=dimension)
    for shifts in ((0,), (0, 0, sp.oo), (0, [], 0)):
        with pytest.raises(ValueError):
            schwinger_brackets(sunset(), propagator_shifts=shifts)


@pytest.mark.slow
def test_live_independent_parameter_quadrature():
    # Recompute an unequal-mass, nonzero-momentum case from the original
    # simplex representation. This contains no RMT or Bessel series machinery.
    with mp.workdps(28):
        def outer(u):
            def inner(v):
                x, y, z = u*v, u*(1-v), 1-u
                F = (x*y+x*z+y*z)*(x+4*y+100*z)+x*y*z
                return u/F if F else mp.mpf(0)
            return mp.quad(inner, [0, mp.mpf('.5'), 1])
        expected = mp.quad(outer, [0, mp.mpf('.5'), 1])
        value = integrate_graph_rmt(sunset((1, 4, 100), 1), dps=23).value
        assert abs(value-expected) < mp.mpf('1e-23')*abs(expected)
