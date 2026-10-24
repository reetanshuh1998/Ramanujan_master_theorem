"""The exported trace must describe the actual series without losing precision."""
import hashlib
import json
from pathlib import Path

import jsonschema
import mpmath as mp
import numpy as np
import pytest
import sympy as sp

from ramanujan_qft import (ScalarEdge, ScalarGraph, RMTDomainError, compile_sunset_rmt,
                           explain_sunset_rmt, integrate_graph_rmt, sunset_rmt_schema)


def graph(masses=(1, 1, 1), q=10):
    return ScalarGraph([ScalarEdge('left', 'right', m) for m in masses],
                       {'left': [q], 'right': [-q]})


def validate(trace):
    # A genuine JSON round trip, rather than accepting Python-only types.
    jsonschema.Draft202012Validator(sunset_rmt_schema()).validate(
        json.loads(json.dumps(trace, allow_nan=False)))


@pytest.mark.parametrize('masses,q', [((1, 1, 1), 10), ((1, 4, 100), 1), ((1, 4, 100), 0)])
def test_trace_matches_exact_compiler(masses, q):
    g = graph(masses, q)
    trace = explain_sunset_rmt(g)
    validate(trace)
    plan = compile_sunset_rmt(g)
    parameters, U, F = g.symanzik()
    assert trace['polynomials'] == dict(parameters=list(map(str, parameters)), U=str(U), F=str(F))
    assert trace['bracket_system']['matrix'] == [[str(x) for x in row] for row in plan.bracket_system.matrix.tolist()]
    assert trace['pole_limit']['coefficient_expression'] == str(plan.coefficient_expression)
    assert trace['convergence']['rho_upper'] == str(plan.rho_upper)
    assert plan.rho_upper < 1
    for family, exported, term in zip(plan.families, trace['families'], plan.gamma_terms):
        assert plan.bracket_system.matrix*sp.Matrix(family.values)+plan.bracket_system.offsets == sp.zeros(4, 1)
        assert exported['gamma_term'] == str(term)
        assert exported['solved_indices'] == list(map(str, family.values))
        assert 'formal' in exported['status']
    # Only documented rational graph inputs are parsed, never symbolic expressions.
    saved = trace['graph']
    rebuilt = ScalarGraph([ScalarEdge(e['source'], e['target'], sp.Rational(e['mass_squared']),
                                     sp.Rational(e['power'])) for e in saved['edges']],
                          {v: list(map(sp.Rational, p)) for v, p in zip(saved['vertices'], saved['external_momenta'])})
    assert rebuilt.symanzik() == g.symanzik()
    assert trace['evaluation']['status'] == 'not_requested'


def test_default_does_not_evaluate(monkeypatch):
    def fail(*args, **kwargs):
        pytest.fail('compile-only explanation attempted evaluation')
    monkeypatch.setattr('ramanujan_qft.sunset_rmt.SunsetRMTSeries.evaluate', fail)
    validate(explain_sunset_rmt(graph()))


def test_exact_binary_encoding_preserves_precision_and_context():
    with mp.workdps(12):
        trace = explain_sunset_rmt(graph(), evaluate=True, dps=np.int64(60), max_shells=np.int64(128))
        reference = integrate_graph_rmt(graph(), dps=60)
        assert mp.mp.dps == 12
    validate(trace)
    encoded = trace['evaluation']['diagnostics']['value']
    with mp.workdps(100):
        recovered = (-1)**encoded['sign'] * mp.ldexp(mp.mpf(int(encoded['mantissa_hex'], 16)), encoded['exponent2'])
        assert recovered == reference.value
        assert abs(recovered-mp.mpf(encoded['decimal'])) < mp.mpf('1e-67')
    assert trace['evaluation']['diagnostics']['working_dps'] > 60


@pytest.mark.parametrize('budget', [dict(max_shells=1), dict(max_terms=1), dict(max_dps=30)])
def test_budget_failure_is_not_a_success(budget):
    trace = explain_sunset_rmt(graph(), evaluate=True, **budget)
    validate(trace)
    evaluation = trace['evaluation']
    assert evaluation['status'] == 'budget_exceeded'
    assert evaluation['exception']
    assert evaluation['diagnostics'] is None or not evaluation['diagnostics']['converged']


def test_unsupported_domain_raises_without_fallback():
    with pytest.raises(RMTDomainError):
        explain_sunset_rmt(graph(q=1), evaluate=True)
    with pytest.raises(TypeError, match='evaluate'):
        explain_sunset_rmt(graph(), evaluate='yes')


def test_schema_and_source_provenance():
    schema = sunset_rmt_schema()
    jsonschema.Draft202012Validator.check_schema(schema)
    schema.clear()
    assert sunset_rmt_schema()['type'] == 'object'
    trace = explain_sunset_rmt(graph(), evaluate=True, dps=10)
    import ramanujan_qft.explain as module
    for name, digest in trace['provenance']['source_sha256'].items():
        assert digest == hashlib.sha256(Path(module.__file__).with_name(name).read_bytes()).hexdigest()
    trace['evaluation']['diagnostics']['value']['mantissa_hex'] = 'not-hex'
    with pytest.raises(jsonschema.ValidationError):
        validate(trace)
    trace['evaluation']['diagnostics'] = None
    with pytest.raises(jsonschema.ValidationError):
        validate(trace)
