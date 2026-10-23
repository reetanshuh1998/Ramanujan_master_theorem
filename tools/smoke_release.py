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
print('Installed', rq.__version__, 'from', installed)
print('RMT and Taylor values passed without SciPy')
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dist', type=Path, default=Path('dist'))
    parser.add_argument('--format', choices=('wheel', 'sdist'), required=True)
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
        subprocess.run([str(executable), '-m', 'pip', 'install', str(artifacts[0])],
                       cwd=work, env=environment, check=True)
        subprocess.run([str(executable), '-c', SMOKE, str(root)],
                       cwd=work, env=environment, check=True)


if __name__ == '__main__':
    main()
