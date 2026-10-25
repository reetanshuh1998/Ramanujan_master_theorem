"""Upload refs must be tags even when a branch happens to match the version name."""
from pathlib import Path
import pytest

pytest.importorskip('tomllib', reason='Release metadata tooling runs on Python 3.12')
from tools.check_release_metadata import check


@pytest.fixture
def release_root(tmp_path):
    (tmp_path/'ramanujan_qft').mkdir()
    (tmp_path/'pyproject.toml').write_text('[project]\nversion = "0.3.0rc1"\n')
    (tmp_path/'ramanujan_qft/__init__.py').write_text('__version__ = "0.3.0rc1"\n')
    (tmp_path/'CITATION.cff').write_text('version: 0.3.0rc1\n')
    return tmp_path


def test_matching_version_tag(release_root):
    assert check(release_root, 'v0.3.0rc1', 'refs/tags/v0.3.0rc1') == '0.3.0rc1'


@pytest.mark.parametrize('ref', ['refs/heads/main', 'refs/heads/v0.3.0rc1', 'refs/tags/v0.3.0'])
def test_branch_or_different_ref_cannot_publish(release_root, ref):
    with pytest.raises(ValueError, match='matching refs/tags'):
        check(release_root, 'v0.3.0rc1', ref)


def test_tag_version_mismatch(release_root):
    with pytest.raises(ValueError, match='release tag'):
        check(release_root, 'v0.3.0', 'refs/tags/v0.3.0')


def test_both_upload_gates_are_wired():
    root = Path(__file__).resolve().parents[1]
    publish = (root/'.github/workflows/publish.yml').read_text()
    test_job = publish.split('\n  testpypi:\n')[1].split('\n  install-from-index:')[0]
    assert "startsWith(github.ref, 'refs/tags/v')" in test_job
    validate = (root/'.github/workflows/validate.yml').read_text()
    assert "github.event.inputs.operation == 'testpypi-release'" in validate
    assert '--tag "$RELEASE_TAG" --ref "$GITHUB_REF"' in validate
