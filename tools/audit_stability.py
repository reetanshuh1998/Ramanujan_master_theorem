"""Declared stability grid; independent references and empirical error coverage.

Run from a checkout: python tools/audit_stability.py --output /tmp/stability.json
This supplements, rather than overwrites, the released 34-case sunset audit.
"""
import argparse
from collections import Counter
import hashlib
from itertools import permutations
import json
from pathlib import Path
import platform
import sys
import time

import mpmath as mp
import sympy as sp

# Also support direct invocation, without an editable package installation.
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from tools.audit_sunset import reference, _base_commit
from tools.audit_encoding import exact_fields
import ramanujan_qft as rq

SEEDS = (1729, 1730, 1731, 1732, 1733, 1734, 1735, 1736)


def checked_reference(evaluate, dps):
    """Bound the precision search; agreement is numerical evidence, not proof."""
    low_dps = dps + 20
    low = evaluate(low_dps)
    for high_dps in (dps+40, dps+60, dps+90):
        high = evaluate(high_dps)
        with mp.workdps(high_dps+10):
            uncertainty = abs(high-low) + max(abs(high), mp.mpf('1e-100')) * mp.power(10, -high_dps+5)
            if (mp.isfinite(high) and mp.isfinite(low) and
                    uncertainty <= max(abs(high), mp.mpf('1e-100')) * mp.power(10, -dps-8)):
                return high, uncertainty, [low_dps, high_dps]
        low, low_dps = high, high_dps
    raise ArithmeticError('independent reference unresolved within precision budget')


def assess(value, error, ref, uncertainty, rtol, atol=0):
    """Keep error-estimate coverage separate from accuracy-target attainment."""
    if not all(mp.isfinite(x) for x in (value, error, ref, uncertainty, rtol, atol)):
        raise ArithmeticError('non-finite value or error in audit')
    if min(error, uncertainty, rtol, atol) < 0:
        raise ArithmeticError('negative error or tolerance in audit')
    actual = abs(value-ref)
    allowance = error+uncertainty
    target = max(atol, rtol*abs(ref))
    return dict(exact=exact_fields(value=value, reference=ref, reported_error=error,
                                  reference_uncertainty=uncertainty, actual_error=actual,
                                  allowance=allowance, target=target, rtol=rtol, atol=atol),
                actual_error=mp.nstr(actual, 18),
                relative_error=mp.nstr(actual/abs(ref), 18) if ref else None,
                reference_uncertainty=mp.nstr(uncertainty, 18),
                reported_error=mp.nstr(error, 18), tolerance=mp.nstr(target, 18),
                error_ratio=mp.nstr(actual/allowance, 18) if allowance else None,
                error_covered=bool(actual <= allowance),
                target_met=bool(actual <= target+uncertainty))


def series_cases():
    rows = []
    def add(name, masses, q, method='rmt', expected='value', **budget):
        rows.append(dict(name=name, mass_squared=list(map(str, masses)), momentum=str(q),
                         method=method, expected=expected, budget=budget))
    for i, masses in enumerate(permutations((1, 4, 9))):
        add(f'permutation_{i}', masses, 10)
    add('momentum_nearer_boundary', (1, 4, 9), 8, max_shells=200, max_terms=1400000)
    add('mass_chart', (1, 4, 100), 1)
    add('mass_vacuum', (1, 4, 100), 0)
    add('mass_hierarchy', ('1e-16', 1, '1e16'), 1)
    add('equal_vacuum', (1, 1, 1), 0, 'taylor')
    add('overlap_rmt', (1, 1, 1), 6)
    add('overlap_taylor', (1, 1, 1), 6, 'taylor', max_terms=1024)
    for exponent in (-40, 40):
        add(f'scale_{exponent}', (f'1e{exponent}',)*3, f'6e{exponent//2}')
    for q in ('2.99999999999999999999', '3', '0'):
        add(f'momentum_domain_{q}', (1, 1, 1), q, expected='domain')
    add('momentum_just_inside', (1, 1, 1), '3.00000000000000000001', expected='budget', max_shells=2)
    add('mass_boundary', (1, 4, 16), 1, expected='domain')
    add('mass_just_inside', (1, 4, '16.00000000000000000001'), 1, expected='budget', max_shells=2)
    add('terms_rmt', (1, 1, 1), 10, expected='budget', max_terms=1)
    add('precision_rmt', (1, 1, 1), 10, expected='budget', max_dps=30)
    add('terms_taylor', (1, 1, 1), 2, 'taylor', 'budget', max_terms=1)
    add('precision_taylor', (1, 1, 1), 6, 'taylor', 'budget', max_dps=40)
    return rows


def sunset_graph(masses, q):
    q = sp.Rational(q)
    return rq.ScalarGraph([rq.ScalarEdge(0, 1, m) for m in masses], {0: [q], 1: [-q]})


def audit_series(dps):
    rows, values = [], {}
    for case in series_cases():
        row = dict(case)
        start = time.perf_counter()
        result = None
        try:
            function = rq.integrate_graph_rmt if case['method'] == 'rmt' else rq.integrate_sunset_taylor
            result = function(sunset_graph(case['mass_squared'], case['momentum']), dps=dps, **case['budget'])
            outcome = 'value'
        except rq.RMTDomainError as exc:
            outcome = 'domain'
            row['exception'] = str(exc)
        except (rq.RMTSeriesConvergenceError, rq.SunsetTaylorConvergenceError) as exc:
            outcome = 'budget'
            row['exception'] = str(exc)
            row['partial_result_available'] = exc.result is not None
        except Exception as exc:
            outcome = 'unexpected_exception'
            row['exception'] = f'{type(exc).__name__}: {exc}'
        row.update(outcome=outcome, passed=outcome == case['expected'])
        if result is not None:
            try:
                with mp.workdps(dps+110):
                    q2 = mp.mpf(case['momentum'])**2
                    ref, uncertainty, precisions = checked_reference(
                        lambda wp: reference(case['mass_squared'], q2, wp), dps)
                    row.update(assess(result.value, result.error_estimate, ref, uncertainty, mp.power(10, -dps)))
                    row.update(reference=mp.nstr(ref, dps+30), reference_working_dps=precisions,
                               value=mp.nstr(result.value, dps+15), terms=result.terms,
                               working_dps=result.working_dps, reference_resolved=True)
                    row['passed'] &= row['error_covered'] and row['target_met']
                    values[case['name']] = (result.value, result.error_estimate)
            except Exception as exc:
                row.update(passed=False, reference_resolved=False,
                           reference_exception=f'{type(exc).__name__}: {exc}')
        row['seconds'] = round(time.perf_counter()-start, 4)
        rows.append(row)
        print(row['name'], row['outcome'], row['passed'], flush=True)
    relations = []
    pairs = [(f'permutation_{i}', 'permutation_0', '1') for i in range(1, 6)]
    pairs += [('overlap_taylor', 'overlap_rmt', '1'),
              ('scale_-40', 'overlap_rmt', '1e-40'), ('scale_40', 'overlap_rmt', '1e40')]
    with mp.workdps(dps+50):
        for left, right, scale in pairs:
            if left not in values or right not in values:
                relations.append(dict(left=left, right=right, passed=False, reason='missing accepted value'))
                continue
            a, ea = values[left]; b, eb = values[right]; factor = mp.mpf(scale)
            difference = abs(factor*a-b)
            allowance = abs(factor)*ea+eb+mp.eps*abs(b)*8
            relations.append(dict(left=left, right=right, scale=scale,
                                  difference=mp.nstr(difference, 18), allowance=mp.nstr(allowance, 18),
                                  exact=exact_fields(difference=difference, allowance=allowance),
                                  passed=bool(difference <= allowance)))
    return rows, relations


def hybrid_cases():
    """Analytic Fourier/factorization references, independent of sector sampling."""
    rows = []
    for n in (2, 3, 4):
        masses = list(range(1, n+1))
        graph = sunset_graph([m*m for m in masses], 2)
        def ref(wp, masses=tuple(masses)):
            with mp.workdps(wp):
                total = sum(masses)
                return mp.pi**(mp.mpf(len(masses)-1)/2)*total/(mp.fprod(masses)*(total**2+4))
        rows.append((f'banana_D1_L{n-1}', graph, 1, ref))
    graph = rq.ScalarGraph([rq.ScalarEdge(0, 0, 2, 2), rq.ScalarEdge(0, 1, 3, 2),
                           rq.ScalarEdge(1, 1, 5, 2)], {0: [2], 1: [-2]})
    def bridge_ref(wp):
        with mp.workdps(wp):
            return mp.mpf(1)/(2*5*7**2)
    rows.append(('bridge_D2_L2', graph, 2, bridge_ref))
    return rows


def audit_hybrid(seeds=SEEDS):
    rows = []
    for name, graph, dimension, evaluate_ref in hybrid_cases():
        try:
            ref, uncertainty, precisions = checked_reference(evaluate_ref, 15)
        except Exception as exc:
            rows.append(dict(name=name, outcome='unresolved_reference', passed=False,
                             reference_exception=f'{type(exc).__name__}: {exc}'))
            continue
        for seed in seeds:
            result = None
            row = dict(name=name, D=dimension, seed=seed, epsrel=0.001, epsabs=0,
                       reference_working_dps=precisions)
            try:
                result = rq.integrate_graph(graph, D=dimension, epsrel=row['epsrel'], seed=seed,
                                            max_evaluations=4000000)
                row['outcome'] = 'value'
            except rq.MultiloopConvergenceError as exc:
                result = exc.result
                row.update(outcome='budget', exception=str(exc))
            except Exception as exc:
                row.update(outcome='unexpected_exception', exception=f'{type(exc).__name__}: {exc}')
            row['passed'] = False
            if result is not None:
                with mp.workdps(60):
                    row.update(assess(mp.mpf(result.value), mp.mpf(result.error_estimate), ref,
                                      uncertainty, mp.mpf(str(row['epsrel']))))
                    row.update(value=repr(result.value), reference=mp.nstr(ref, 45),
                               evaluations=result.evaluations, standard_error=result.standard_error,
                               converged=result.converged)
                    # Accuracy and empirical coverage are separate checks for this
                    # experimental statistical backend. Every miss remains visible.
                    row['passed'] = row['outcome'] == 'value' and row['target_met']
            rows.append(row)
            print(name, seed, row['outcome'], row['passed'], flush=True)
    return rows


def coverage_summary(rows):
    """Descriptive counts only; heterogeneous fixed graphs are not IID trials."""
    assessed = [r for r in rows if r.get('outcome') == 'value' and 'error_covered' in r]
    outliers = [dict(name=r['name'], seed=r.get('seed'), error_ratio=r.get('error_ratio'))
                for r in assessed if not r['error_covered']]
    failures = [dict(name=r['name'], seed=r.get('seed'), outcome=r['outcome'])
                for r in rows if not r['passed']]
    return dict(hybrid_samples=len(rows), hybrid_assessed=len(assessed),
                hybrid_covered=sum(r['error_covered'] for r in assessed),
                hybrid_outliers=outliers, hybrid_failures=failures,
                hybrid_coverage_requires_review=bool(outliers or failures),
                hybrid_coverage_by_graph={name: dict(
                    covered=sum(r['error_covered'] for r in assessed if r['name'] == name),
                    assessed=sum(r['name'] == name for r in assessed))
                    for name in sorted({r['name'] for r in rows})})


def run(dps=15, seeds=SEEDS):
    if not 10 <= dps <= 30:
        raise ValueError('audit dps must be between 10 and 30; grid budgets are bounded')
    import numpy as np
    import scipy
    series, invariants = audit_series(dps)
    hybrid = audit_hybrid(seeds)
    # Include transitive numerical implementation, reference and package metadata.
    paths = sorted(ROOT.glob('ramanujan_qft/**/*.py')) + [Path(__file__), ROOT/'tools/audit_sunset.py', ROOT/'tools/audit_encoding.py', ROOT/'pyproject.toml']
    return dict(schema_version=2, package_version=rq.__version__, dps=dps,
                python=platform.python_version(), mpmath=mp.__version__, sympy=sp.__version__,
                numpy=np.__version__, scipy=scipy.__version__,
                base_commit=_base_commit(ROOT),
                source_sha256={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
                human_review='pending; this executable audit is not human peer review',
                reference_limits='Precision agreement is not an interval enclosure. Invariants share evaluators.',
                hybrid_limits='Empirical fixed-grid coverage, not a confidence level or universal guarantee.',
                series=series, invariants=invariants, hybrid=hybrid,
                hybrid_policy='Acceptance requires resolved references and accuracy targets; coverage misses require review, not silent removal.',
                summary=dict(series_outcomes=dict(Counter(r['outcome'] for r in series)),
                             **coverage_summary(hybrid)),
                passed=all(r['passed'] for r in series+invariants+hybrid))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--dps', type=int, default=15)
    parser.add_argument('--seed-start', type=int, default=1729)
    parser.add_argument('--seed-count', type=int, default=8)
    args = parser.parse_args()
    if args.seed_count < 1 or args.seed_count > 128 or args.seed_start < 0:
        parser.error('seed-count must be 1..128 and seed-start nonnegative')
    report = run(args.dps, seeds=tuple(range(args.seed_start, args.seed_start+args.seed_count)))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, allow_nan=False)+'\n')
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
