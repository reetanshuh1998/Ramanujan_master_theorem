"""The authentication-only check must never upload or expose credentials."""
import importlib.util
import io
import json
from pathlib import Path
import urllib.error
import urllib.parse

import pytest


@pytest.fixture
def preflight(monkeypatch):
    path = Path(__file__).resolve().parents[1]/'tools/check_pypi_publisher.py'
    spec = importlib.util.spec_from_file_location('publisher_preflight', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    monkeypatch.setenv('ACTIONS_ID_TOKEN_REQUEST_URL', 'https://example.invalid/token?x=1&audience=old')
    monkeypatch.setenv('ACTIONS_ID_TOKEN_REQUEST_TOKEN', 'request-secret')
    return module


@pytest.mark.parametrize('outcome', ['success', 'rejected', 'missing-token'])
def test_only_authentication_endpoints_and_no_credential_output(preflight, monkeypatch, capsys, outcome):
    requests = []

    def urlopen(request, timeout):
        requests.append(request)
        if len(requests) == 1:
            assert request.get_header('Authorization') == 'Bearer request-secret'
            assert urllib.parse.parse_qs(urllib.parse.urlsplit(request.full_url).query) == {
                'x': ['1'], 'audience': ['pypi']}
            return io.StringIO(json.dumps({'value': 'identity-secret'}))
        assert len(requests) == 2
        assert request.full_url == 'https://pypi.org/_/oidc/mint-token'
        assert request.get_method() == 'POST'
        assert json.loads(request.data) == {'token': 'identity-secret'}
        if outcome == 'rejected':
            raise urllib.error.HTTPError(request.full_url, 400, 'Bad request', {},
                                         io.BytesIO(b'identity-secret'))
        return io.StringIO(json.dumps({'token': 'publishing-secret'} if outcome == 'success' else {}))

    monkeypatch.setattr(preflight.urllib.request, 'urlopen', urlopen)
    assert preflight.main() == (0 if outcome == 'success' else 1)
    assert len(requests) == 2
    output = capsys.readouterr()
    assert 'secret' not in output.out+output.err
