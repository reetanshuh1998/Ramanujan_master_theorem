"""Run the deployed console and its scientific examples in a real Chromium browser.

Install playwright and its Chromium browser first. By default this serves the
built docs at docs/_build/html; --url checks an already deployed site instead.
"""
import argparse
import json
from contextlib import contextmanager
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread

from playwright.sync_api import sync_playwright


@contextmanager
def serve(directory):
    class QuietHandler(SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass

    server = ThreadingHTTPServer(
        ("127.0.0.1", 0), partial(QuietHandler, directory=str(directory.resolve()))
    )
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        yield f"http://127.0.0.1:{server.server_port}/try_it.html"
    finally:
        server.shutdown()
        server.server_close()
        thread.join()


def run_code(page, code=None):
    page.locator("#rq-clear").click()
    if code is not None:
        page.locator("#rq-code").fill(code)
    page.locator("#rq-run").click()
    page.wait_for_function("""() => {
        const status = document.querySelector('#rq-status');
        return status.dataset.kind === 'error' ||
            (!document.querySelector('#rq-run').disabled &&
             status.textContent.startsWith('Done in '));
    }""", timeout=180_000)
    output = page.locator("#rq-output").inner_text()
    status = page.locator("#rq-status").inner_text()
    assert page.locator("#rq-status").get_attribute("data-kind") == "ready", (status, output)
    assert page.locator("#rq-output .rq-stderr").count() == 0, output
    return output


NUMERICAL_CHECK = '''import mpmath as mp
from ramanujan_qft import (ScalarEdge, ScalarGraph, compile_sunset_rmt,
                           integrate_sunset_taylor, product_integral,
                           exponential, bessel_j)
with mp.workdps(35):
    value = product_integral(exponential(1), bessel_j(0, 3), dps=25)
    assert abs(value - 1 / mp.sqrt(10)) < mp.mpf("1e-24")
    graph = ScalarGraph([ScalarEdge(0, 1, 1)] * 3,
                        external_momenta={0: [10], 1: [-10]})
    result = compile_sunset_rmt(graph).evaluate(dps=25)
    # Independent parameter-integral reference, also in the native tests.
    assert abs(result.value - mp.mpf("0.629016707590614149590827253884")) < mp.mpf("1e-24")
    vacuum = integrate_sunset_taylor(ScalarGraph([ScalarEdge(0, 1, 1)] * 3), dps=25)
    assert abs(vacuum.value - 4 * mp.clsin(2, mp.pi / 3) / mp.sqrt(3)) < mp.mpf("1e-24")
print("BROWSER_NUMERICS_OK")
'''


def check(url, executable):
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(executable_path=executable)
        try:
            page = browser.new_page()
            page.goto(url, wait_until="domcontentloaded")
            picker = page.locator("#rq-example")
            page.wait_for_function("document.querySelector('#rq-example').options.length > 0")
            choices = picker.locator("option").evaluate_all(
                "options => options.map(o => ({value: o.value, title: o.textContent}))"
            )
            for choice in choices:
                picker.select_option(choice["value"])
                run_code(page)
                print("Passed browser example:", choice["title"], flush=True)
            assert "BROWSER_NUMERICS_OK" in run_code(page, NUMERICAL_CHECK)
            run_code(page, "session_marker = 1729")
            assert "1729" in run_code(page, "print(session_marker)")
            page.locator("#rq-reset").click()
            assert "RESET_OK" in run_code(
                page, "assert 'session_marker' not in globals(); print('RESET_OK')"
            )

            # Exercise the mirror/custom-wheel path in a fresh worker as well.
            # The pure-Python wheels must not bypass loading compiled NumPy.
            index_url = "https://cdn.jsdelivr.net/pyodide/v0.26.4/full/"
            lock = page.request.get(index_url + "pyodide-lock.json")
            assert lock.ok, f"Pyodide package manifest: HTTP {lock.status}"
            packages = lock.json()["packages"]
            wheels = [index_url + packages[name]["file_name"] for name in ("mpmath", "sympy")]
            context = browser.new_context()
            context.add_init_script("window.RQFT_CONFIG = " + json.dumps({"wheels": wheels}))
            mirror = context.new_page()
            mirror.goto(url, wait_until="domcontentloaded")
            assert "BROWSER_NUMERICS_OK" in run_code(mirror, NUMERICAL_CHECK)
            context.close()
            print("Browser numerical references, reset, and custom dependency wheels passed.", flush=True)
        finally:
            browser.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    location = parser.add_mutually_exclusive_group()
    location.add_argument("--site", type=Path, help="Built Sphinx HTML directory")
    location.add_argument("--url", help="Full URL of a deployed try_it.html page")
    parser.add_argument("--browser-executable", help="Optional installed Chrome/Chromium executable")
    args = parser.parse_args()
    if args.url:
        check(args.url, args.browser_executable)
    else:
        directory = args.site or Path("docs/_build/html")
        if not (directory / "try_it.html").is_file():
            parser.error(f"Build the documentation first: {directory}/try_it.html is missing")
        with serve(directory) as url:
            check(url, args.browser_executable)


if __name__ == "__main__":
    main()
