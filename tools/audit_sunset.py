"""Reproducible numerical audit against independent parameter integration.

Run: python tools/audit_sunset.py --output benchmarks/data/sunset_audit.json
The reference uses Cheng-Wu x+y=1 and analytically integrates the remaining
positive quadratic in z. It imports no package evaluation routine. The audit
driver imports the package only to obtain the values under test.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import random
import subprocess
import time

try:  # Package import and direct script execution both work without Git.
    from .audit_encoding import exact_fields
except ImportError:
    from audit_encoding import exact_fields

import mpmath as mp


def _base_commit(root):
    """Optional checkout context; source hashes identify the evaluated files."""
    try:
        return subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=root,
                              capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def reference(masses, q2, dps):
    """Independent one-dimensional parameter integral, normalized d^2k/pi."""
    with mp.workdps(dps):
        m = [mp.mpf(str(v)) for v in masses]
        q = mp.mpf(str(q2))
        scale = max(m+[q])
        ma, mb, mc = [v/scale for v in m]
        q /= scale
        def integrand(x):
            a = x*(1-x)
            if not a:
                return mp.mpf(0)
            A = ma*x+mb*(1-x)
            B = A+mc*a+q*a
            C = a*A
            delta = (A-mc*a)**2+q*a*(2*(A+mc*a)+q*a)
            root = mp.sqrt(delta)
            return 2*mp.asinh(root/(2*mp.sqrt(mc*C)))/root if root else 2/B
        return mp.quad(integrand, [0, mp.mpf('.5'), 1])/scale


def cases():
    rows = []
    def add(name, masses, p, backend, expected='value', **budget):
        rows.append(dict(name=name, mass_squared=list(map(str, masses)),
                         momentum=str(p), backend=backend, expected=expected, budget=budget))
    for p in (0, '0.001', 1, 2, 3, 6, 10):
        add(f'equal_taylor_{p}', (1, 1, 1), p, 'taylor', max_terms=1024)
    for p in (6, 10, 100):
        add(f'equal_rmt_{p}', (1, 1, 1), p, 'rmt')
    rng = random.Random(1729)
    for i in range(8):
        a, b, c = [rng.randint(1, 6) for _ in range(3)]
        add(f'unequal_momentum_{i}', (a*a, b*b, c*c), 2*(a+b+c), 'rmt')
    for i in range(5):
        a, b, p = [rng.randint(1, 4) for _ in range(3)]
        M = 4*(a+b+p)
        add(f'unequal_mass_{i}', (a*a, b*b, M*M), p, 'rmt')
    add('mass_vacuum', (1, 4, 100), 0, 'rmt')
    add('mass_hierarchy', ('1e-16', 1, '1e16'), 1, 'rmt')
    for scale, p in [('1e-60', '1e-30'), ('1e60', '1e30')]:
        add(f'taylor_scale_{scale}', (scale,)*3, p, 'taylor')
    add('rmt_boundary', (1, 1, 1), 3, 'rmt', 'domain')
    add('rmt_gap', (1, 1, 1), 1, 'rmt', 'domain')
    add('mass_boundary', (1, 4, 16), 1, 'rmt', 'domain')
    add('rmt_near_boundary_budget', (1, 1, 1), '3.0000000000000000000001', 'rmt',
        'budget', max_shells=6)
    add('rmt_term_budget', (1, 1, 1), 10, 'rmt', 'budget', max_terms=1)
    add('taylor_term_budget', (1, 1, 1), 2, 'taylor', 'budget', max_terms=6)
    add('taylor_precision_budget', (1, 1, 1), 6, 'taylor', 'budget', max_dps=80)
    return rows


def audit(dps=20):
    import sympy as sp
    from ramanujan_qft import (ScalarEdge, ScalarGraph, integrate_graph_rmt,
                               integrate_sunset_taylor, RMTDomainError,
                               RMTSeriesConvergenceError, SunsetTaylorConvergenceError, __version__)
    rows = []
    for case in cases():
        row = dict(case)
        start = time.perf_counter()
        p = sp.Rational(case['momentum'])
        g = ScalarGraph([ScalarEdge(0, 1, m) for m in case['mass_squared']],
                        {0: [p], 1: [-p]})
        function = integrate_graph_rmt if case['backend'] == 'rmt' else integrate_sunset_taylor
        result = None
        try:
            result = function(g, dps=dps, **case['budget'])
            outcome = 'value'
        except RMTDomainError as error:
            outcome = 'domain'
            row['exception'] = str(error)
        except (RMTSeriesConvergenceError, SunsetTaylorConvergenceError) as error:
            outcome = 'budget'
            result = error.result
            row['exception'] = str(error)
        row['outcome'] = outcome
        row['passed'] = outcome == case['expected']
        if result is not None:
            with mp.workdps(dps+120):
                q2 = mp.mpf(case['momentum'])**2
                a = reference(case['mass_squared'], q2, dps+15)
                low_dps = dps+15
                for high_dps in (dps+30, dps+55, dps+80, dps+105):
                    b = reference(case['mass_squared'], q2, high_dps)
                    reference_error = abs(a-b)+abs(b)*mp.mpf(10)**(-high_dps+5)
                    if reference_error < abs(b)*mp.mpf(10)**(-dps-8):
                        break
                    if high_dps < dps+105:
                        a, low_dps = b, high_dps
                actual = abs(result.value-b)
                allowance = result.error_estimate+reference_error
                row.update(exact=exact_fields(value=result.value, reference=b,
                                             reported_error=result.error_estimate,
                                             reference_uncertainty=reference_error,
                                             actual_error=actual, allowance=allowance),
                           value=mp.nstr(result.value, dps+5), reference=mp.nstr(b, dps+30),
                           reference_precision_difference=mp.nstr(abs(a-b), 8),
                           reference_working_dps=[low_dps, high_dps],
                           actual_error=mp.nstr(actual, 8),
                           reported_error=mp.nstr(result.error_estimate, 8),
                           error_ratio=mp.nstr(actual/allowance, 8),
                           terms=result.terms, working_dps=result.working_dps,
                           method=result.method)
                row['passed'] &= reference_error < abs(b)*mp.mpf(10)**(-dps-8)
                row['passed'] &= actual <= allowance
        row['seconds'] = round(time.perf_counter()-start, 4)
        rows.append(row)
        print(f"{'PASS' if row['passed'] else 'FAIL'} {row['name']} ({row['seconds']} s)", flush=True)
    root = Path(__file__).resolve().parents[1]
    paths = ['ramanujan_qft/sunset_rmt.py', 'ramanujan_qft/sunset_taylor.py',
             'ramanujan_qft/brackets.py', 'ramanujan_qft/multiloop.py', 'tools/audit_sunset.py',
             'ramanujan_qft/__init__.py', 'pyproject.toml', 'tools/audit_encoding.py']
    hashes = {p: hashlib.sha256((root/p).read_bytes()).hexdigest() for p in paths}
    commit = _base_commit(root)
    return dict(schema_version=2, package_version=__version__, dps=dps, random_seed=1729, python=platform.python_version(),
                mpmath=mp.__version__, sympy=sp.__version__, base_commit=commit,
                source_sha256=hashes, reference='Cheng-Wu parameter integral; two working precisions',
                external_scientific_review='See docs/SCIENTIFIC_REVIEW.md for scope and review record', passed=all(r['passed'] for r in rows), cases=rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('benchmarks/data/sunset_audit.json'))
    parser.add_argument('--dps', type=int, default=20)
    args = parser.parse_args()
    if args.dps < 10:
        parser.error('--dps must be at least 10')
    report = audit(args.dps)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
