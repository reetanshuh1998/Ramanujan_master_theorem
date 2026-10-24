"""Freeze an audited source snapshot and instructions for a scientific reviewer.

No review is performed by this tool. The output directory must not exist.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]


def prepare(report_path, output, root=ROOT):
    report_path, output, root = Path(report_path), Path(output), Path(root).resolve()
    report = json.loads(report_path.read_text())
    if not report.get('passed') or not report.get('source_sha256'):
        raise ValueError('a passing audit with source hashes is required')
    # Check all bindings before creating or copying anything.
    for name, digest in report['source_sha256'].items():
        source = (root/name).resolve()
        source.relative_to(root)
        if hashlib.sha256(source.read_bytes()).hexdigest() != digest:
            raise ValueError(f'audit source mismatch: {name}; rerun the audit on the final source')
    output.mkdir(parents=True, exist_ok=False)
    files = set()
    for folder in ('ramanujan_qft', 'tools', 'tests', 'docs'):
        for p in (root/folder).rglob('*'):
            if p.is_file() and p.suffix in ('.py', '.md', '.json', '.csv', '.txt') and not any(
                    part in ('__pycache__', '_build', 'auto_examples') for part in p.parts):
                files.add(p)
    for name in ('pyproject.toml', 'README.md', 'LICENSE', 'CHANGELOG.md', 'CITATION.cff', 'MANIFEST.in'):
        files.add(root/name)
    for source in sorted(files):
        target = output/'source'/source.relative_to(root)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
    shutil.copyfile(report_path, output/'stability-audit.json')
    (output/'REVIEW_REQUEST.md').write_text('''# Scientific review request

Status: pending human scientific review. This packet contains automated evidence,
not a completed independent review or an endorsement of the software.

Review the exact source files in `source/`. `stability-audit.json` identifies the
numerical implementation by SHA-256; `SHA256SUMS` binds the entire packet.
The audit's commit field is checkout context, not a substitute for file hashes.

Please assess normalization and Euclidean signs, bracket-family selection,
coalescing-pole limits, convergence domains, tail bounds, arithmetic estimates,
and the limits of the hybrid statistical error diagnostic. The expanded grid
includes exact boundary inputs, budget refusals, permutations, scaling, overlap
and repeated seeds. Shared formulas and reference precision limits are documented.

Reproduction (Python 3.12):

```bash
cd source
python -m pip install ".[test]"
python -m pytest -q
python tools/audit_stability.py --output ../reviewer-audit.json
```

Start with `docs/SCIENTIFIC_REVIEW.md`, `docs/STABILITY_AUDIT.md`,
`docs/user_guide/sunset_rmt.md` and `docs/user_guide/sunset_taylor.md`.
Record reviewer identity, methods, source hashes, findings, severities and
reproduction inputs in a separate report. State explicitly which mathematics
and domains were examined. Keep the supplied audit and source unchanged.
''')
    manifest = []
    for p in sorted(output.rglob('*')):
        if p.is_file():
            manifest.append(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p.relative_to(output)))
    (output/'SHA256SUMS').write_text('\n'.join(manifest)+'\n')
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--audit', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    print(prepare(args.audit, args.output))
