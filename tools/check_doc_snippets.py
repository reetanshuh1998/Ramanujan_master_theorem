"""Run the code examples in the Markdown documentation pages.

Usage:  python tools/check_doc_snippets.py [FILES_OR_DIRS ...]   (default: docs/)

Rules, per page (all blocks of a page share one namespace, in document order):

* a fenced block tagged ``pycon`` (or any ``python`` block containing ``>>>``) is run as a
  doctest, with ELLIPSIS and NORMALIZE_WHITESPACE;
* any other ``python`` block is executed; if the next fenced block (with only blank lines
  in between) is tagged ``text``, the printed output must match it (whitespace-normalised;
  ``...`` matches anything);
* a block preceded by the line ``<!-- skip-test -->`` is not run.

Exit status 1 if any example fails.
"""
import contextlib
import doctest
import io
import pathlib
import re
import sys
import time

FENCE = re.compile(r"^(?P<indent>[ \t]*)(?P<fence>`{3,}|~{3,})(?P<info>[^\n`]*)$")


def blocks(text):
    """Yield (line_number, info, code, skip) for every fenced block of a Markdown page."""
    lines = text.splitlines()
    i, prev = 0, ""
    while i < len(lines):
        m = FENCE.match(lines[i])
        if not m:
            if lines[i].strip():
                prev = lines[i].strip()
            i += 1
            continue
        fence, info, start = m["fence"], m["info"].strip(), i
        body = []
        i += 1
        while i < len(lines) and not (lines[i].strip().startswith(fence) and lines[i].strip().strip(fence[0]) == ""):
            body.append(lines[i])
            i += 1
        yield start + 1, info.split()[0] if info else "", "\n".join(body) + "\n", prev == "<!-- skip-test -->", i
        prev = ""
        i += 1


def normalise(s):
    return " ".join(s.split())


def matches(expected, got):
    pattern = ".*".join(re.escape(part) for part in normalise(expected).split("..."))
    return re.fullmatch(pattern, normalise(got), re.S) is not None


def check_page(path):
    text = path.read_text(encoding="utf-8")
    found = list(blocks(text))
    lines = text.splitlines()
    namespace = {"__name__": "__doc_snippets__"}
    parser = doctest.DocTestParser()
    runner = doctest.DocTestRunner(optionflags=doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE)
    failures = ran = 0
    for k, (line, info, code, skip, end) in enumerate(found):
        lang = info.lower()
        if skip or lang not in ("python", "py", "pycon", "python3"):
            continue
        ran += 1
        if lang == "pycon" or ">>>" in code:
            test = parser.get_doctest(code, namespace, f"{path}:{line}", str(path), line)
            out = io.StringIO()
            result = runner.run(test, out=out.write, clear_globs=False)
            namespace.update(test.globs)  # DocTest works on a copy of the namespace
            if result.failed:
                failures += 1
                print(out.getvalue())
            continue
        expected = None
        if k + 1 < len(found):
            nline, ninfo, ncode, nskip, _ = found[k + 1]
            between = lines[end + 1:nline - 1]
            if ninfo.lower() == "text" and all(not s.strip() for s in between):
                expected = ncode
        buf = io.StringIO()
        try:
            with contextlib.redirect_stdout(buf):
                exec(compile(code, f"{path}:{line}", "exec"), namespace)
        except Exception as exc:  # noqa: BLE001
            failures += 1
            print(f"{path}:{line}: block raised {type(exc).__name__}: {exc}")
            continue
        if expected is not None and not matches(expected, buf.getvalue()):
            failures += 1
            print(f"{path}:{line}: printed output differs from the text block below it\n"
                  f"--- expected\n{expected}--- got\n{buf.getvalue()}")
    return ran, failures


def main(argv):
    targets = [pathlib.Path(a) for a in argv] or [pathlib.Path("docs")]
    pages = []
    for t in targets:
        pages += sorted(p for p in t.rglob("*.md") if "_build" not in p.parts) if t.is_dir() else [t]
    total = bad = 0
    for page in pages:
        t0 = time.time()
        ran, failures = check_page(page)
        total += ran
        bad += failures
        if ran:
            status = "FAIL" if failures else "ok"
            print(f"{status:4}  {page}  ({ran} blocks, {time.time() - t0:.1f} s)")
    print(f"{total} blocks run, {bad} failing")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
