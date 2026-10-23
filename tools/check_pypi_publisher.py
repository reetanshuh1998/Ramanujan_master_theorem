"""Verify production PyPI OIDC trust in GitHub Actions without uploading files.

Run only in publish.yml's protected pypi environment. Credentials are kept in
memory and never printed or written to artifacts. This verifies authentication,
not an upload or the availability of a project name.
"""
import json
import os
import urllib.error
import urllib.parse
import urllib.request


def main():
    endpoint = os.environ['ACTIONS_ID_TOKEN_REQUEST_URL']
    parsed = urllib.parse.urlsplit(endpoint)
    query = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    query = [(key, value) for key, value in query if key != 'audience']
    query.append(('audience', 'pypi'))
    endpoint = urllib.parse.urlunsplit(parsed._replace(query=urllib.parse.urlencode(query)))
    request = urllib.request.Request(endpoint, headers={
        'Authorization': 'Bearer '+os.environ['ACTIONS_ID_TOKEN_REQUEST_TOKEN']})
    with urllib.request.urlopen(request, timeout=30) as response:
        identity = json.load(response)['value']
    request = urllib.request.Request('https://pypi.org/_/oidc/mint-token',
        data=json.dumps({'token': identity}).encode(),
        headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            credential = json.load(response)
    except urllib.error.HTTPError as error:
        # Never dump an auth response, request headers or identity tokens.
        print(f'Production PyPI rejected publisher authentication (HTTP {error.code}).')
        print('Check the PyPI pending publisher: project ramanujan-qft; owner '
              'reetanshuh1998; repository Ramanujan_master_theorem; '
              'workflow publish.yml; environment pypi.')
        return 1
    if not credential.get('token'):
        print('PyPI returned no publishing credential; authentication was not verified.')
        return 1
    print('Production PyPI accepted this publisher identity. No files were uploaded.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
