"""Compatibility promises for the proposed 0.3.0 public interface.

The fixture is the reviewed caller contract, not a fixture to regenerate when
an implementation changes. Additive optional keyword arguments and diagnostic
fields are permitted; removals, reordered arguments and changed defaults fail.
Numerical validity is tested separately against independent references.
"""
import importlib
import inspect
import json
from pathlib import Path
import warnings

import mpmath as mp
import pytest

import ramanujan_qft as rq

CONTRACT = json.loads((Path(__file__).parent / 'data/public_api_contract.json').read_text())


@pytest.mark.parametrize('name', CONTRACT['callables'])
def test_existing_call_signatures_and_import_paths(name):
    baseline = CONTRACT['callables'][name]
    function = getattr(rq, name)
    assert function is getattr(importlib.import_module(baseline['module']), name)
    parameters = list(inspect.signature(function).parameters.values())
    required = baseline['parameters']
    assert len(parameters) >= len(required)
    for current, old in zip(parameters, required):
        assert current.name == old['name']
        assert current.kind.name == old['kind']
        default = None if current.default is inspect.Parameter.empty else repr(current.default)
        assert default == old['default']
    for added in parameters[len(required):]:
        assert added.kind is inspect.Parameter.KEYWORD_ONLY
        assert added.default is not inspect.Parameter.empty


def _sunset(q):
    return rq.ScalarGraph([rq.ScalarEdge(0, 1, '1') for _ in range(3)],
                          {0: [str(q)], 1: [str(-q)]})


def test_mellin_diagnostics_and_precision_context():
    with mp.workdps(17):
        value, info = rq.product_integral(rq.exponential(1), rq.bessel_j(0, 3),
                                           dps=30, return_info=True)
        assert mp.mp.dps == 17
    assert set(CONTRACT['mellin_info_keys']) <= info.keys()
    assert isinstance(value, mp.mpf)
    assert isinstance(info['method'], str)
    assert info['terms'] > 0 and info['working_dps'] >= 30
    with mp.workdps(45):
        assert abs(value - 1 / mp.sqrt(10)) < mp.mpf('1e-30')
        assert mp.isfinite(info['error_estimate']) and info['error_estimate'] >= 0


@pytest.mark.parametrize('method,q,result_type', [
    (rq.integrate_graph_rmt, 10, rq.RMTSeriesResult),
    (rq.integrate_sunset_taylor, 0, rq.SunsetTaylorResult),
])
def test_named_result_fields_and_precision_context(method, q, result_type):
    with mp.workdps(17):
        result = method(_sunset(q), D=2, dps=20)
        assert mp.mp.dps == 17
    assert isinstance(result, result_type)
    assert all(hasattr(result, name) for name in CONTRACT['result_fields'][result_type.__name__])
    assert isinstance(result.value, mp.mpf) and result.value > 0
    assert result.converged is True
    assert isinstance(result.method, str)
    assert result.terms > 0 and result.working_dps >= 20
    assert 0 <= result.convergence_ratio < 1
    assert 0 <= result.truncation_bound <= result.error_estimate
    if result_type is rq.RMTSeriesResult:
        assert result.chart == 'momentum' and result.shells > 0


def test_graph_input_contract():
    graph = _sunset(10)
    assert graph.loops == 2
    assert graph.vertices == (0, 1)
    assert len(graph.edges) == 3
    assert graph.external_momenta[0] == (10,)
    assert graph.external_momenta[1] == (-10,)
    assert all(edge.mass_squared == 1 and edge.power == 1 for edge in graph.edges)
    with pytest.raises(ValueError):
        rq.ScalarEdge(0, 1, 0)
    with pytest.raises(ValueError):
        rq.ScalarGraph(graph.edges, {0: [1], 1: [1]})


def test_series_refusals_keep_distinct_types_and_no_fallback():
    # Equal-mass vacuum is valid for Taylor, but RMT must not switch methods.
    with pytest.raises(rq.RMTDomainError) as outside:
        rq.integrate_graph_rmt(_sunset(0))
    assert isinstance(outside.value, ValueError)
    with pytest.raises(NotImplementedError):
        rq.integrate_graph_rmt(_sunset(10), D=4)
    with pytest.raises(TypeError):
        rq.integrate_graph_rmt(object())
    with pytest.raises(rq.SeriesConvergenceError) as boundary:
        rq.product_integral(rq.exponential(1), rq.bessel_j(0, 1))
    assert isinstance(boundary.value, ArithmeticError)


@pytest.mark.parametrize('method,options,error_type,result_type', [
    (rq.integrate_graph_rmt, {'max_shells': 1}, rq.RMTSeriesConvergenceError, rq.RMTSeriesResult),
    (rq.integrate_sunset_taylor, {'max_terms': 1}, rq.SunsetTaylorConvergenceError, rq.SunsetTaylorResult),
])
def test_budget_refusals_expose_optional_partial_result(method, options, error_type, result_type):
    with pytest.raises(error_type) as caught:
        method(_sunset(10), dps=30, **options)
    assert isinstance(caught.value, ArithmeticError)
    result = caught.value.result
    assert result is None or isinstance(result, result_type)
    if result is not None:
        assert result.converged is False


@pytest.mark.slow
def test_derivative_spellings_match_independent_massless_pair_reference():
    # For squared masses (0, 0, M), the closed-form expansion of the
    # twice-subtracted sunset starts -s**2/(12*M), hence S''(0)=-1/(6*M).
    # This reference neither differentiates nor calls the implementation.
    with warnings.catch_warnings():
        warnings.simplefilter('error', DeprecationWarning)
        with mp.workdps(17):
            new = rq.sunset_second_derivative(s='0', m1sq='0', m2sq='0', m3sq='4', dps=25)
            old = rq.sunset_d2('0', '0', '0', '4', dps=25)
            assert mp.mp.dps == 17
    with mp.workdps(40):
        assert abs(new + mp.mpf(1) / 24) < mp.mpf('1e-25')
    assert new == old


def test_both_derivative_spellings_reject_the_same_domain():
    for function in (rq.sunset_d2, rq.sunset_second_derivative):
        with pytest.raises(ValueError):
            function(9, 1, 1, 1)
