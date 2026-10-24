"""Install a built artifact in a fresh environment outside the source checkout.

Run separately for wheel and sdist. The program uses only the standard library;
pip installs declared base dependencies into the isolated environment.
"""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile
import venv


SMOKE = r'''
import builtins
import importlib.metadata
from pathlib import Path
import sys

# The series backends must work with base dependencies only.
original_import = builtins.__import__
def no_scipy(name, *args, **kwargs):
    if name == 'scipy' or name.startswith('scipy.'):
        raise ImportError('SciPy deliberately unavailable in release smoke test')
    return original_import(name, *args, **kwargs)
builtins.__import__ = no_scipy
import mpmath as mp
import ramanujan_qft as rq
source_root = Path(sys.argv[1]).resolve()
installed = Path(rq.__file__).resolve()
assert source_root not in installed.parents, installed
assert rq.__version__ == importlib.metadata.version('ramanujan-qft')
g = rq.ScalarGraph([rq.ScalarEdge(0, 1, 1)]*3, {0: [10], 1: [-10]})
r = rq.integrate_graph_rmt(g, dps=30)
assert mp.nstr(r.value, 30) == '0.629016707590614149590827253884'
vacuum = rq.ScalarGraph([rq.ScalarEdge(0, 1, 1)]*3)
t = rq.integrate_sunset_taylor(vacuum, dps=30)
assert mp.nstr(t.value, 25) == '2.343907238689458890601562'
assert len(rq.compile_sunset_rmt(g).gamma_terms) == 8
assert rq.sunset_second_derivative is not None
from ramanujan_qft.solvers.feynman_mob_solver import FeynmanMoBSolver
from ramanujan_qft.utils.ramanujan_continuation import RamanujanContinuationEngine
import json
trace = rq.explain_sunset_rmt(g)
assert json.loads(json.dumps(trace)) == trace
assert trace['schema_version'] == 1
assert rq.sunset_rmt_schema()['properties']['schema_version']['const'] == 1
builtins.__import__ = original_import
print('Installed', rq.__version__, 'from', installed)
print('RMT/Taylor values, legacy imports and bundled explanation schema passed without SciPy')
'''

MULTILOOP_SMOKE = r'''
import math
import scipy
graph = rq.ScalarGraph([rq.ScalarEdge(0, 1, m*m) for m in (1, 2, 3)],
                      {0: [2], 1: [-2]})
result = rq.integrate_graph(graph, D=1, epsrel=3e-3, max_evaluations=4000000, seed=1729)
reference = math.pi*6/(6*(36+4))
assert abs(result.value-reference) <= result.error_estimate
print('Optional SciPy hybrid evaluation passed against Fourier reference')
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dist', type=Path, default=Path('dist'))
    parser.add_argument('--format', choices=('wheel', 'sdist'), required=True)
    parser.add_argument('--upgrade-from', choices=('0.3.0a5',), help='Install the published baseline first')
    parser.add_argument('--with-multiloop', action='store_true', help='Install and exercise the optional SciPy extra')
    args = parser.parse_args()
    suffix = '*.whl' if args.format == 'wheel' else '*.tar.gz'
    artifacts = list(args.dist.resolve().glob(suffix))
    if len(artifacts) != 1:
        parser.error(f'expected exactly one {args.format} artifact, found {len(artifacts)}')
    root = Path(__file__).resolve().parents[1]
    environment = os.environ.copy()
    environment.pop('PYTHONPATH', None)
    environment.pop('PYTHONHOME', None)
    with tempfile.TemporaryDirectory(prefix='ramanujan-release-') as temporary:
        work = Path(temporary)
        venv.EnvBuilder(with_pip=True).create(work/'venv')
        executable = work/'venv'/('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
        extra = '[multiloop]' if args.with_multiloop else ''
        if args.upgrade_from:
            subprocess.run([str(executable), '-m', 'pip', 'install', '--index-url',
                            'https://pypi.org/simple/', 'ramanujan-qft'+extra+'=='+args.upgrade_from],
                           cwd=work, env=environment, check=True)
            subprocess.run([str(executable), '-c',
                            "import ramanujan_qft as rq; assert rq.__version__ == '0.3.0a5'"],
                           cwd=work, env=environment, check=True)
        subprocess.run([str(executable), '-m', 'pip', 'install', '--upgrade', str(artifacts[0])+extra],
                       cwd=work, env=environment, check=True)
        # Check the installed version against the artifact, not just its own metadata.
        wheel = artifacts[0].name.endswith('.whl')
        version = artifacts[0].name.split('-')[1] if wheel else artifacts[0].name.removesuffix('.tar.gz').split('-')[-1]
        check_version = '\nassert rq.__version__ == ' + repr(version) + '\n'
        subprocess.run([str(executable), '-c', SMOKE + check_version + (MULTILOOP_SMOKE if args.with_multiloop else ''), str(root)],
                       cwd=work, env=environment, check=True)


if __name__ == '__main__':
    main()
