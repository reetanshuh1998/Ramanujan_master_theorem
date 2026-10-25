"""Release evidence must remain reproducible without checkout metadata."""
import subprocess

import mpmath as mp
import pytest

from benchmarks import bench_release
from tools import audit_sunset


@pytest.mark.parametrize('module', [audit_sunset, bench_release])
def test_report_commit_outside_checkout(module, tmp_path):
    assert module._base_commit(tmp_path) is None


@pytest.mark.parametrize('module', [audit_sunset, bench_release])
def test_report_commit_without_git(module, tmp_path, monkeypatch):
    def missing(*args, **kwargs):
        raise FileNotFoundError('git is not installed')
    monkeypatch.setattr(subprocess, 'run', missing)
    assert module._base_commit(tmp_path) is None


@pytest.mark.parametrize('frequency', [1, 100])
def test_angular_reference_against_oscillatory_representation(frequency):
    with mp.workdps(40):
        angular = bench_release.triple_reference(frequency)
        oscillatory = mp.quadosc(
            lambda x: mp.exp(-2*x-x*x/2)*mp.besselj(1, frequency*x),
            [0, mp.inf], omega=frequency)
        assert abs(angular-oscillatory) < mp.mpf('1e-35')*abs(angular)


def test_sdist_guard_rejects_missing_review_imports(tmp_path):
    import io
    import tarfile
    from tools.check_sdist_contents import check
    root = tmp_path/'source'
    (root/'benchmarks').mkdir(parents=True)
    (root/'benchmarks/bench_release.py').write_text('# required test import\n')
    archive = tmp_path/'incomplete.tar.gz'
    with tarfile.open(archive, 'w:gz') as package:
        member = tarfile.TarInfo('package/pyproject.toml')
        content = b'[project]\n'
        member.size = len(content)
        package.addfile(member, io.BytesIO(content))
    with pytest.raises(ValueError, match='benchmarks/bench_release.py'):
        check(archive, root)
