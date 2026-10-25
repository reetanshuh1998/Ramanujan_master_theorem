"""Check that an sdist retains the files needed for isolated review reproduction."""
import argparse
from pathlib import Path
import tarfile


def check(archive, root):
    root = Path(root)
    # These directories contain imported test helpers and the workflow tests read.
    required = {'pyproject.toml', 'README.md', 'LICENSE', 'CHANGELOG.md', 'CITATION.cff',
                'MANIFEST.in', 'CONTRIBUTING.md', 'AUDIT.md', 'THIRD_PARTY_NOTICES.md',
                'requirements.txt', 'setup.py', '.gitignore'}
    for folder, pattern in [('tests', '*.py'), ('tools', '*.py'), ('benchmarks', '*.py'),
                            ('benchmarks/data', '*.json'), ('.github/workflows', '*.yml')]:
        required.update(str(p.relative_to(root)) for p in (root/folder).rglob(pattern)
                        if '_build' not in p.parts and '__pycache__' not in p.parts)
    with tarfile.open(archive, 'r:gz') as package:
        names = {m.name.split('/', 1)[1] for m in package.getmembers() if m.isfile() and '/' in m.name}
    missing = sorted(required-names)
    if missing:
        raise ValueError('source archive omits review dependencies: ' + ', '.join(missing))
    print(f'{len(required)} review-support files present in {Path(archive).name}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive', type=Path)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    check(args.archive, args.root)
