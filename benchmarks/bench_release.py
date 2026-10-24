"""Accuracy-checked, same-precision product-integral timings.

Run from an installed source tree: python benchmarks/bench_release.py
Results describe these inputs and methods only, not a library-wide ranking.
"""
import argparse
import hashlib
import json
import platform
from pathlib import Path
import statistics
import subprocess
import time

import mpmath as mp
import ramanujan_qft as rq


def _base_commit(root):
    """Optional checkout context; source hashes identify the evaluated files."""
    try:
        return subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=root,
                              capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def triple_reference(frequency):
    """Gaussian Fourier/angular representation, independent of Bessel quadrature.

    DLMF 10.9.2 gives J1(z) = 2/pi int_0^(pi/2) cos(t) sin(z cos(t)) dt.
    Complete the square in int_0^inf exp(-x*x/2 - 2*x + i*b*x) dx
    to obtain sqrt(pi/2)*exp((2-i*b)**2/2)*erfc((2-i*b)/sqrt(2)).
    Absolute Gaussian decay justifies interchanging the two integrals.
    No package evaluator, Bessel routine, or quadosc is used here.
    """
    def angular(theta):
        c = mp.cos(theta)
        z = (2-mp.j*frequency*c)/mp.sqrt(2)
        transform = mp.sqrt(mp.pi/2)*mp.exp(z*z)*mp.erfc(z)
        return c*mp.im(transform)
    return 2/mp.pi*mp.quad(angular, [0, mp.pi/4, mp.pi/2])


def benchmark(repetitions):
    dps = 30
    rows = []
    for triple, frequency in ((False, 3), (False, 1000), (True, 1), (True, 100)):
        def integrand(x):
            if triple:
                return mp.exp(-2*x-x*x/2)*mp.besselj(1, frequency*x)
            return mp.exp(-x)*mp.besselj(0, frequency*x)

        def closed():
            return 1/mp.sqrt(1+mp.mpf(frequency)**2)

        def oscillatory():
            return mp.quadosc(integrand, [0, mp.inf], omega=frequency)

        references = []
        for precision in (50, 70):
            with mp.workdps(precision):
                references.append(triple_reference(frequency) if triple else closed())
        with mp.workdps(80):
            reference = references[-1]
            reference_difference = abs(references[0]-reference)/abs(reference)
            if reference_difference > mp.mpf('1e-40'):
                raise RuntimeError('Reference precision agreement failed')

        def race():
            second = rq.gaussian_bessel('0.5', frequency, 1) if triple else rq.bessel_j(0, frequency)
            return rq.product_integral(rq.exponential(2 if triple else 1), second, dps=dps)

        methods = {'RACE': race, 'mpmath.quadosc': oscillatory,
                   'mpmath.quad/tanh-sinh': lambda: mp.quad(integrand, [0, 1, mp.inf], method='tanh-sinh', maxdegree=8),
                   'mpmath.quad/gauss-legendre': lambda: mp.quad(integrand, [0, 1, mp.inf], method='gauss-legendre', maxdegree=8)}
        if not triple:
            methods['closed form'] = closed
        row = {'integral': f'exp(-2*x-x*x/2)*J1({frequency}*x)' if triple else f'exp(-x)*J0({frequency}*x)',
               'reference': mp.nstr(reference, 75),
               'reference_method': 'Gaussian Fourier/angular integral at 50/70 digits' if triple else 'closed form at 50/70 digits',
               'reference_relative_difference': mp.nstr(reference_difference, 8), 'methods': {}}
        for name, function in methods.items():
            samples, errors = [], []
            with mp.workdps(dps):
                # One unmeasured call warms the node/zero caches for every method.
                function()
                for _ in range(repetitions):
                    start = time.perf_counter()
                    value = function()
                    samples.append(time.perf_counter()-start)
                    with mp.workdps(80):
                        errors.append(abs(value-reference)/abs(reference))
            error = max(errors)
            row['methods'][name] = {'seconds': samples, 'median_seconds': statistics.median(samples),
                                    'max_relative_error': mp.nstr(error, 8),
                                    'meets_30_digit_target': bool(error <= mp.mpf('1e-30'))}
            print(row['integral'], name, row['methods'][name], flush=True)
        rows.append(row)
    root = Path(__file__).resolve().parents[1]
    paths = ['benchmarks/bench_release.py', 'ramanujan_qft/mellin.py', 'ramanujan_qft/__init__.py']
    return {'schema_version': 1, 'package_version': rq.__version__, 'python': platform.python_version(),
            'platform': platform.platform(), 'processor': platform.processor(), 'mpmath': mp.__version__,
            'base_commit': _base_commit(root),
            'source_sha256': {p: hashlib.sha256((root/p).read_bytes()).hexdigest() for p in paths},
            'requested_dps': dps, 'repetitions': repetitions, 'summary': 'median after one warm-up; caches retained',
            'quadrature_maxdegree': 8, 'quadrature_intervals': '[0, 1, infinity]',
            'limitations': 'Selected product integrals, not Feynman graph benchmarks. Reference agreement is not an interval proof. Failed accuracy targets must not be ranked as successful evaluations.',
            'cases': rows}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('benchmarks/data/release_comparison.json'))
    parser.add_argument('--repetitions', type=int, default=3)
    args = parser.parse_args()
    if args.repetitions < 1:
        parser.error('--repetitions must be positive')
    report = benchmark(args.repetitions)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    if not all(row['methods']['RACE']['meets_30_digit_target'] for row in report['cases']):
        raise SystemExit('RACE missed an accuracy target; inspect the report before making claims')
