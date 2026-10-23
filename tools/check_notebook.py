"""Execute trusted repository notebook code cells without Jupyter dependencies.

This checker supports the plain-Python research notebook; magics are deliberately
not supported. --write records stream outputs for a reviewable notebook artifact.
"""
import argparse
import contextlib
import io
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('notebook', type=Path)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    notebook = json.loads(args.notebook.read_text(encoding='utf-8'))
    namespace = {'__name__': '__notebook_check__'}
    count = 0
    for cell in notebook['cells']:
        if cell['cell_type'] != 'code':
            continue
        count += 1
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream), contextlib.redirect_stderr(stream):
            exec(compile(''.join(cell['source']), f'{args.notebook}:cell{count}', 'exec'), namespace)
        print(stream.getvalue(), end='')
        if args.write:
            cell['execution_count'] = count
            cell['outputs'] = ([{'output_type': 'stream', 'name': 'stdout',
                                 'text': stream.getvalue().splitlines(keepends=True)}]
                               if stream.getvalue() else [])
    if args.write:
        args.notebook.write_text(json.dumps(notebook, indent=1)+'\n', encoding='utf-8')
    print(f'{count} notebook code cells passed')


if __name__ == '__main__':
    main()
