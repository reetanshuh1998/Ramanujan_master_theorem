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


def test_review_packet_contains_shared_walkthrough_and_matches_manifest(tmp_path):
    import hashlib
    import json
    import runpy
    from tools.prepare_review_packet import prepare, ROOT
    report = tmp_path/'audit.json'
    report.write_text(json.dumps({'passed': True, 'source_sha256': {
        'pyproject.toml': hashlib.sha256((ROOT/'pyproject.toml').read_bytes()).hexdigest()}}))
    packet = prepare(report, tmp_path/'packet')
    shared = runpy.run_path(str(packet/'source/tests/test_first_calculations.py'))
    shared['test_shared_walkthrough']()
    assert (packet/'source/ramanujan_qft/schemas/sunset-rmt-v1.json').is_file()
    for line in (packet/'SHA256SUMS').read_text().splitlines():
        digest, name = line.split('  ', 1)
        assert hashlib.sha256((packet/name).read_bytes()).hexdigest() == digest


def test_packet_collects_tests_without_the_original_checkout(tmp_path):
    import hashlib
    import json
    import os
    import subprocess
    import sys
    from tools.prepare_review_packet import prepare, ROOT
    report = tmp_path/'audit.json'
    report.write_text(json.dumps({'passed': True, 'source_sha256': {
        'pyproject.toml': hashlib.sha256((ROOT/'pyproject.toml').read_bytes()).hexdigest()}}))
    packet = prepare(report, tmp_path/'packet')
    assert (packet/'source/benchmarks/bench_release.py').is_file()
    assert (packet/'source/benchmarks/data/sunset_budgets.json').is_file()
    environment = os.environ.copy()
    environment.pop('PYTHONPATH', None)
    environment['PYTEST_DISABLE_PLUGIN_AUTOLOAD'] = '1'
    result = subprocess.run([sys.executable, '-m', 'pytest', '--collect-only', '-q'],
                            cwd=packet/'source', env=environment,
                            capture_output=True, text=True, timeout=120)
    assert result.returncode == 0, result.stdout + result.stderr
    assert 'test_report_reproducibility.py::' in result.stdout


def test_statistical_miss_is_retained_separately_from_accuracy(monkeypatch):
    from types import SimpleNamespace
    from tools import audit_stability as audit
    monkeypatch.setattr(audit, 'hybrid_cases', lambda: [('example', None, 1, lambda wp: mp.mpf(1))])
    monkeypatch.setattr(audit.rq, 'integrate_graph', lambda *a, **k: SimpleNamespace(
        value=1.00001, error_estimate=0.000001, evaluations=100, standard_error=1e-7, converged=True))
    rows = audit.audit_hybrid(seeds=(1000, 2000))
    assert all(r['passed'] and r['target_met'] and not r['error_covered'] for r in rows)
    summary = audit.coverage_summary(rows)
    assert summary['hybrid_covered'] == 0
    assert summary['hybrid_assessed'] == 2
    assert len(summary['hybrid_outliers']) == 2
    assert summary['hybrid_coverage_requires_review']
    assert not summary['hybrid_failures']
    monkeypatch.setattr(audit.rq, 'integrate_graph', lambda *a, **k: SimpleNamespace(
        value=1.1, error_estimate=0.2, evaluations=100, standard_error=0.01, converged=True))
    failed = audit.audit_hybrid(seeds=(1000,))
    assert failed[0]['error_covered'] and not failed[0]['passed']
    assert audit.coverage_summary(failed)['hybrid_failures']


def test_exact_audit_encoding_retains_a_tiny_coverage_margin():
    from fractions import Fraction
    import json
    from tools.audit_encoding import exact_number
    def decode(number):
        return ((-1)**number['sign'] * Fraction(int(number['mantissa_hex'], 16))
                * Fraction(2)**number['exponent2'])
    with mp.workdps(100):
        value = mp.mpf(1)+mp.mpf('1e-50')
        allowance = mp.mpf('1e-50')+mp.mpf('1e-90')
        result = assess(value, allowance, mp.mpf(1), mp.mpf(0), mp.mpf('1e-40'))
    encoded = json.loads(json.dumps(result))['exact']
    assert abs(decode(encoded['value'])-decode(encoded['reference'])) <= decode(encoded['allowance'])
    assert decode(encoded['actual_error']) <= decode(encoded['allowance'])
    with mp.workdps(5):
        assert exact_number(value) == encoded['value']
    with pytest.raises(ValueError, match='finite'):
        exact_number(mp.inf)
