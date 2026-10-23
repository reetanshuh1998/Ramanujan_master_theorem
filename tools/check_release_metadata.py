"""Check release version consistency without importing the source package."""
import argparse
import ast
from pathlib import Path
import re
import tomllib


def check(root, tag=None):
    root = Path(root)
    project = tomllib.loads((root/'pyproject.toml').read_text(encoding='utf-8'))['project']
    version = project['version']
    tree = ast.parse((root/'ramanujan_qft/__init__.py').read_text(encoding='utf-8'))
    values = [ast.literal_eval(n.value) for n in tree.body if isinstance(n, ast.Assign)
              and any(isinstance(t, ast.Name) and t.id == '__version__' for t in n.targets)]
    citation = re.search(r'^version:\s*["\']?([^\s"\']+)',
                         (root/'CITATION.cff').read_text(encoding='utf-8'), re.M)
    if values != [version] or citation is None or citation.group(1) != version:
        raise ValueError('pyproject, __version__ and CITATION.cff must have the same version')
    if tag is not None and tag != 'v'+version:
        raise ValueError(f'release tag must be v{version}, got {tag!r}')
    print(version)
    return version


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--tag')
    args = parser.parse_args()
    check(args.root, args.tag)
