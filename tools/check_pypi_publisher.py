"""Verify PyPI or TestPyPI OIDC trust in GitHub Actions without uploading files.

Run only in publish.yml's protected pypi environment. Credentials are kept in
memory and never printed or written to artifacts. This verifies authentication,
not an upload. On PyPI, minting the first token can activate a pending
publisher and create its empty project.
"""
import argparse
import json
import os
import urllib.error
import urllib.parse
import urllib.request


def rejection_codes(error):
    """Return only known public error codes, never raw authentication data."""
    known = {'invalid-payload', 'not-enabled', 'invalid-token',
             'invalid-pending-publisher', 'rate-limited', 'invalid-reuse-token',
             'invalid-publisher'}
    try:
        payload = json.loads(error.read(16384))
    except (ValueError, UnicodeError):
        return []
    if not isinstance(payload, dict) or not isinstance(payload.get('errors'), list):
        return []
    return sorted({item['code'] for item in payload['errors']
                   if isinstance(item, dict) and isinstance(item.get('code'), str)
                   and item['code'] in known})


def main(index='pypi'):
    host, audience, label = {
        'pypi': ('pypi.org', 'pypi', 'Production PyPI'),
        'testpypi': ('test.pypi.org', 'testpypi', 'TestPyPI'),
    }[index]
    endpoint = os.environ['ACTIONS_ID_TOKEN_REQUEST_URL']
    parsed = urllib.parse.urlsplit(endpoint)
    query = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    query = [(key, value) for key, value in query if key != 'audience']
    query.append(('audience', audience))
    endpoint = urllib.parse.urlunsplit(parsed._replace(query=urllib.parse.urlencode(query)))
    request = urllib.request.Request(endpoint, headers={
        'Authorization': 'Bearer '+os.environ['ACTIONS_ID_TOKEN_REQUEST_TOKEN']})
    with urllib.request.urlopen(request, timeout=30) as response:
        identity = json.load(response)['value']
    request = urllib.request.Request(f'https://{host}/_/oidc/mint-token',
        data=json.dumps({'token': identity}).encode(),
        headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            credential = json.load(response)
    except urllib.error.HTTPError as error:
        # Never dump an auth response, request headers or identity tokens.
        print(f'{label} rejected publisher authentication (HTTP {error.code}).')
        for code in rejection_codes(error):
            print(f'PyPI rejection code: {code}')
        print(f'Check the publisher on {host}: project ramanujan-qft; owner '
              'reetanshuh1998; repository Ramanujan_master_theorem; '
              'workflow publish.yml; environment pypi.')
        return 1
    if not credential.get('token'):
        print('PyPI returned no publishing credential; authentication was not verified.')
        return 1
    print(f'{label} accepted this publisher identity. No files were uploaded.')
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', choices=('pypi', 'testpypi'), default='pypi')
    raise SystemExit(main(parser.parse_args().index))
