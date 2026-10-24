"""Measure default RMT work budgets; successful values use a parameter reference.

Run: python tools/audit_sunset_budgets.py
An interior point can exhaust its budget. This grid is not a universal rho cutoff.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import time

import mpmath as mp
import sympy as sp

from audit_sunset import _base_commit, reference
from ramanujan_qft import (ScalarEdge, ScalarGraph, compile_sunset_rmt,
                          RMTSeriesConvergenceError, __version__)


def audit():
    rows = []
    for masses, momentum in [((1, 1, 1), 10), ((1, 1, 1), 6),
                             ((1, 1, 1), '30/7'), ((1, 1, 1), 4),
                             ((1, 1, 4), 5), ((1, 1, 16), 1)]:
        p = sp.Rational(momentum)
        graph = ScalarGraph([ScalarEdge(0, 1, m) for m in masses], {0: [p], 1: [-p]})
        series = compile_sunset_rmt(graph)
        with mp.workdps(65):
            q2 = (mp.mpf(int(p.p))/int(p.q))**2
            low, high = [reference(masses, q2, dps) for dps in (45, 60)]
            reference_error = abs(low-high) + abs(high)*mp.mpf('1e-55')
            if reference_error > abs(high)*mp.mpf('1e-38'):
                raise RuntimeError('Reference precision agreement failed')
        for dps in (10, 20, 30):
            start = time.perf_counter()
            try:
                result = series.evaluate(dps=dps)
                outcome = 'value'
            except RMTSeriesConvergenceError as error:
                result, outcome = error.result, 'budget'
            row = dict(mass_squared=list(masses), momentum=str(p), chart=series.chart,
                       rho_upper=str(series.rho_upper), dps=dps, outcome=outcome,
                       seconds=time.perf_counter()-start,
                       terms=result.terms if result else None,
                       shells=result.shells if result else None)
            if outcome == 'value':
                with mp.workdps(65):
                    actual = abs(result.value-high)
                    row.update(relative_error=mp.nstr(actual/abs(high), 10),
                               within_reported_error=bool(actual <= result.error_estimate+reference_error))
                    if actual > abs(high)*mp.mpf(10)**(-dps) or not row['within_reported_error']:
                        raise RuntimeError(f'Accuracy check failed: {row}')
            rows.append(row)
            print(row, flush=True)
    root = Path(__file__).resolve().parents[1]
    paths = ['tools/audit_sunset_budgets.py', 'tools/audit_sunset.py',
             'ramanujan_qft/sunset_rmt.py', 'ramanujan_qft/brackets.py',
             'ramanujan_qft/multiloop.py', 'ramanujan_qft/__init__.py']
    return dict(schema_version=1, package_version=__version__,
                python=platform.python_version(), mpmath=mp.__version__, sympy=sp.__version__,
                base_commit=_base_commit(root),
                source_sha256={p: hashlib.sha256((root/p).read_bytes()).hexdigest() for p in paths},
                defaults=dict(max_shells=128, max_terms=250000),
                reference='Cheng-Wu parameter integral at 45/60 digits', cases=rows)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('benchmarks/data/sunset_budgets.json'))
    args = parser.parse_args()
    report = audit()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
