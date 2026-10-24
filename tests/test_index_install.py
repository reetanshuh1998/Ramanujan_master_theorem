"""Release retry policy: missing version only, bounded attempts, no smoke retries."""
import subprocess
from types import SimpleNamespace

import pytest
from tools.install_from_index import INDEXES, install, missing_version

REQUIREMENT = 'ramanujan-qft==0.3.0rc1'
MISSING = ('Looking in indexes: https://test.pypi.org/simple/\n'
           'ERROR: Could not find a version that satisfies the requirement '
           + REQUIREMENT + ' (from versions: 0.3.0a5)\n'
           'ERROR: No matching distribution found for ' + REQUIREMENT + '\n')


def test_eventual_visibility_and_selected_index():
    calls, sleeps = [], []
    def run(command, **kwargs):
        calls.append(command)
        assert kwargs['timeout'] == 120
        return SimpleNamespace(returncode=1 if len(calls) < 3 else 0, stdout=MISSING if len(calls) < 3 else 'Installed')
    install('0.3.0rc1', INDEXES[1], runner=run, sleep=sleeps.append)
    assert len(calls) == 3 and sleeps == [15, 15]
    assert all(c[-2:] == [INDEXES[1], REQUIREMENT] for c in calls)
    assert '--no-deps' in calls[0] and '--no-cache-dir' in calls[0]
    assert missing_version(MISSING.replace('0.3.0a5)', 'none)'), REQUIREMENT)


def test_exhaustion_keeps_failure():
    sleeps = []
    def run(*args, **kwargs):
        return SimpleNamespace(returncode=1, stdout=MISSING)
    with pytest.raises(subprocess.CalledProcessError) as error:
        install('0.3.0rc1', INDEXES[0], attempts=3, delay=0, runner=run, sleep=sleeps.append)
    assert sleeps == [0, 0] and error.value.output == MISSING


@pytest.mark.parametrize('failure', [
    'ERROR: Could not install packages due to an OSError: disk full',
    'ERROR: THESE PACKAGES DO NOT MATCH THE HASHES',
    MISSING.replace(REQUIREMENT, 'numpy==1.24'),
    'WARNING: Retrying after connection broken\n' + MISSING,
    'ERROR: Ignored versions that require a different python version\n' + MISSING,
    MISSING + 'ERROR: Failed building wheel for another-package\n',
    'Traceback (most recent call last):\n' + MISSING,
])
def test_other_install_failures_are_not_retried(failure):
    def run(*args, **kwargs):
        return SimpleNamespace(returncode=1, stdout=failure)
    def forbidden_sleep(delay):
        pytest.fail('permanent/unrecognized failure was retried')
    with pytest.raises(subprocess.CalledProcessError):
        install('0.3.0rc1', INDEXES[0], runner=run, sleep=forbidden_sleep)


def test_timeout_is_not_retried():
    calls = []
    def run(command, **kwargs):
        calls.append(command)
        raise subprocess.TimeoutExpired(command, kwargs['timeout'])
    with pytest.raises(subprocess.TimeoutExpired):
        install('0.3.0rc1', INDEXES[0], runner=run)
    assert len(calls) == 1


@pytest.mark.parametrize('kwargs', [dict(attempts=0), dict(attempts=11), dict(delay=-1), dict(delay=61)])
def test_invalid_retry_budget(kwargs):
    with pytest.raises(ValueError):
        install('0.3.0rc1', INDEXES[0], **kwargs)
