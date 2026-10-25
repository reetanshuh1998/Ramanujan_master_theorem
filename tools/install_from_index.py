"""Install a just-published release, retrying only the missing-version response.

Never uploads or rebuilds artifacts. Other installation failures propagate on
first occurrence; the separate installed-package smoke check is never retried.
"""
import argparse
import re
import subprocess
import sys
import time

INDEXES = ('https://pypi.org/simple/', 'https://test.pypi.org/simple/')


def missing_version(output, requirement):
    """Recognize pip's two-line missing-version error, without masking other errors."""
    lines = output.splitlines()
    errors = [line for line in lines if line.startswith('ERROR:')]
    if any(re.search(r'\b(WARNING|Traceback|Exception|SSL|ConnectionError)\b', line) for line in lines):
        return False
    return (len(errors) == 2
            and re.fullmatch(r'ERROR: Could not find a version that satisfies the requirement '
                             + re.escape(requirement) + r' \(from versions: [^\n]*\)', errors[0]) is not None
            and errors[1] == 'ERROR: No matching distribution found for ' + requirement)


def install(version, index_url, *, attempts=6, delay=15, runner=subprocess.run, sleep=time.sleep):
    if index_url not in INDEXES:
        raise ValueError('index_url must select production PyPI or TestPyPI')
    if not re.fullmatch(r'[0-9][0-9A-Za-z.!+_-]*', version):
        raise ValueError('invalid release version')
    if not 1 <= attempts <= 10 or not 0 <= delay <= 60:
        raise ValueError('attempts must be 1..10 and delay 0..60 seconds')
    requirement = 'ramanujan-qft==' + version
    command = [sys.executable, '-m', 'pip', '--isolated', 'install', '--no-deps',
               '--no-cache-dir', '--disable-pip-version-check', '--index-url', index_url, requirement]
    for attempt in range(1, attempts+1):
        result = runner(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        output = result.stdout or ''
        print(output, end='' if output.endswith('\n') else '\n', flush=True)
        if result.returncode == 0:
            return
        if attempt == attempts or not missing_version(output, requirement):
            raise subprocess.CalledProcessError(result.returncode, command, output=output)
        print(f'{requirement} is not visible yet; retry {attempt+1}/{attempts} in {delay}s', flush=True)
        sleep(delay)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', required=True)
    parser.add_argument('--index-url', choices=INDEXES, required=True)
    parser.add_argument('--attempts', type=int, default=6)
    parser.add_argument('--delay', type=float, default=15)
    args = parser.parse_args()
    install(args.version, args.index_url, attempts=args.attempts, delay=args.delay)


if __name__ == '__main__':
    main()
