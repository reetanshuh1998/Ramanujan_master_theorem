# Try it in your browser

Run ramanujan-qft without installing anything. The console below runs the
package with [Pyodide](https://pyodide.org), a build of CPython for WebAssembly.
Everything runs **locally in your browser**; no code or result is sent to a
server.

* Pick an example or write your own code, then press **Run** (or
  <kbd>Ctrl</kbd>+<kbd>Enter</kbd>). The value of the last line is shown, as in a
  notebook, and variables persist between runs.
* The first run downloads Python, NumPy, mpmath and SymPy (tens of MB). Your
  browser caches them, so later visits start faster.
* **Stop** ends a long calculation. Python then restarts on the next run.
* To see the Ramanujan method on a coupled integral, choose **Two-loop sunset:
  graph to multivariate RMT**. It displays the exponent matrix, Gamma families,
  result and error diagnostics. The separate Taylor example covers equal-mass
  vacuum and checks it against a Clausen reference.

```{raw} html
<link rel="stylesheet" href="_static/try_it.css">
<div id="rq-console" class="rq-console">
  <div class="rq-toolbar">
    <label for="rq-example">Example</label>
    <select id="rq-example"></select>
    <button id="rq-run" type="button" class="rq-primary" title="Run (Ctrl+Enter)">Run</button>
    <button id="rq-stop" type="button" disabled>Stop</button>
    <button id="rq-clear" type="button">Clear output</button>
    <button id="rq-reset" type="button">Reset</button>
  </div>
  <textarea id="rq-code" spellcheck="false" autocapitalize="off" autocomplete="off" aria-label="Python code"></textarea>
  <span id="rq-status" class="rq-status" role="status" aria-live="polite">The console needs JavaScript.</span>
  <pre id="rq-output" class="rq-output" aria-live="polite" aria-label="Output"></pre>
</div>
<noscript><p><strong>The console needs JavaScript.</strong> Use the Colab notebook below, or install the package.</p></noscript>
<script defer src="_static/try_it.js"></script>
```

## Good to know

* **Speed.** WebAssembly is slower than native Python, typically by a factor of
  a few. Most examples take well under a second once Python is loaded.
  `sunset_subtracted` and `sunset_d2` take 10–20 s natively, so expect minutes here.
* **Version.** The console installs the package built from the same commit as this
  documentation.
* **Limits.** One calculation runs at a time. Files and plots are not supported.
  NumPy, mpmath and SymPy are loaded before the package starts. Other Pyodide
  packages are loaded when your code imports them explicitly. For the hybrid
  graph evaluator, include `import scipy` before calling `integrate_graph`;
  its optional SciPy dependency is not needed for the sunset series examples.
* **If it does not start:** the console needs a recent browser with WebAssembly
  and access to `cdn.jsdelivr.net`, where Pyodide is hosted. Corporate networks
  sometimes block it. Use Colab or a local installation instead.

## Run it in Google Colab

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/quickstart.ipynb)

The [quickstart notebook](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/quickstart.ipynb)
installs the package in a Colab session and walks through the main functions.
Colab runs native Python, so it is faster than the browser console.

## Install it

For your own calculations, install the package locally
({doc}`getting_started/installation`):

```bash
pip install "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"
```
