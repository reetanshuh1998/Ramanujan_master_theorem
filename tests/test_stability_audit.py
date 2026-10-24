"""The audit must expose inadequate references and underestimated errors."""
import mpmath as mp
import pytest
from tools.audit_stability import assess, checked_reference, series_cases, hybrid_cases


def test_separate_accuracy_from_error_coverage():
    with mp.workdps(40):
        r = assess(mp.mpf('1.000001'), mp.mpf('1e-8'), mp.mpf(1), mp.mpf('1e-30'), mp.mpf('1e-4'))
    assert r['target_met'] and not r['error_covered']


def test_zero_reference_uses_absolute_target():
    r = assess(mp.mpf('0.001'), mp.mpf('0.002'), mp.mpf(0), mp.mpf(0), mp.mpf('0.01'), mp.mpf('0.002'))
    assert r['relative_error'] is None and r['target_met'] and r['error_covered']


@pytest.mark.parametrize('bad', [mp.inf, mp.nan, mp.mpf(-1)])
def test_invalid_error_is_not_success(bad):
    with pytest.raises(ArithmeticError):
        assess(mp.mpf(1), bad, mp.mpf(1), mp.mpf(0), mp.mpf('0.01'))


def test_unresolved_reference_fails_bounded_search():
    calls = []
    def unstable(wp):
        calls.append(wp)
        return mp.mpf(wp)
    with pytest.raises(ArithmeticError, match='unresolved'):
        checked_reference(unstable, 15)
    assert calls == [35, 55, 75, 105]


def test_reference_precision_is_actually_increased():
    def evaluate(wp):
        with mp.workdps(wp):
            return mp.sqrt(2)
    value, error, precisions = checked_reference(evaluate, 20)
    with mp.workdps(80):
        assert abs(value-mp.sqrt(2)) <= error
    assert precisions == [40, 60]


def test_grid_declares_domains_budgets_and_independent_hybrid_values():
    cases = series_cases()
    assert len({c['name'] for c in cases}) == len(cases)
    assert {c['expected'] for c in cases} == {'value', 'domain', 'budget'}
    assert len([c for c in cases if c['name'].startswith('permutation_')]) == 6
    for name, graph, D, ref in hybrid_cases():
        assert graph.loops >= 1 and D in (1, 2)
        assert ref(40) > 0


def test_hybrid_reference_failure_is_visible(monkeypatch):
    from tools import audit_stability as audit
    def fail(*args):
        raise ArithmeticError('reference unresolved')
    monkeypatch.setattr(audit, 'checked_reference', fail)
    rows = audit.audit_hybrid(seeds=(1729,))
    assert len(rows) == 4
    assert all(r['outcome'] == 'unresolved_reference' and not r['passed'] for r in rows)


def test_review_packet_rejects_mismatched_source(tmp_path):
    import json
    from tools.prepare_review_packet import prepare
    source = tmp_path/'source'
    source.mkdir()
    (source/'code.py').write_text('changed')
    audit = tmp_path/'audit.json'
    audit.write_text(json.dumps({'passed': True, 'source_sha256': {'code.py': 'wrong'}}))
    output = tmp_path/'packet'
    with pytest.raises(ValueError, match='mismatch'):
        prepare(audit, output, source)
    assert not output.exists()
