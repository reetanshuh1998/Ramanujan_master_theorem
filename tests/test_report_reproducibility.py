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
