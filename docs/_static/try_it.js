/* ramanujan-qft "Try it" console.
 *
 * Runs the package in the browser with Pyodide (CPython compiled to WebAssembly),
 * inside a Web Worker so that long calculations do not freeze the page.
 * Nothing is sent to a server: the code runs on the visitor's machine.
 *
 * Configuration (for offline tests or mirrors): set window.RQFT_CONFIG before this
 * script runs, e.g. {indexURL: "http://localhost:8000/pyodide/", wheels: [...]}.
 *   indexURL    Pyodide distribution (default: jsDelivr, Pyodide 0.26.4)
 *   packages    Pyodide packages to load (default: numpy, mpmath, sympy)
 *   wheels      if set, pure-Python dependency wheels instead of `packages`;
 *               NumPy is always loaded from the Pyodide distribution
 *   wheelIndex  JSON file {"wheel": "<file name>"} naming the ramanujan-qft wheel,
 *               which lies next to it (default: wheels/latest.json next to this script)
 * Relative URLs in RQFT_CONFIG are resolved against the page.
 */
(function () {
  "use strict";

  // this script's own URL: the worker and the bundled wheel live next to it
  const SCRIPT_URL = (document.currentScript && document.currentScript.src) || document.baseURI;

  const DEFAULTS = {
    indexURL: "https://cdn.jsdelivr.net/pyodide/v0.26.4/full/",
    packages: ["numpy", "mpmath", "sympy"],
    wheels: null,
    wheelIndex: new URL("wheels/latest.json", SCRIPT_URL).href,
  };

  const EXAMPLES = [
    {
      title: "Three reference-checked calculations",
      code: "import json\nimport mpmath as mp\nimport scipy  # Explicit import also loads SciPy in the browser console.\nfrom ramanujan_qft import (B0, ScalarEdge, ScalarGraph, explain_sunset_rmt,\n                           integrate_graph, RMTDomainError)\n\n# 1. B0: LoopTools finite-part convention, Delta=0, mu^2=1; p^2=-2.\n# Independent Feynman-parameter reference, evaluated with extra precision.\nbubble = B0(-2, 1, 4, dps=30)\nwith mp.workdps(45):\n    reference = -mp.quad(lambda x: mp.log(x + 4*(1-x) + 2*x*(1-x)), [0, 1])\n    difference = abs(bubble-reference)\n    assert difference < mp.mpf('1e-29')\nprint('B0:', mp.nstr(bubble, 30), 'absolute reference difference:', mp.nstr(difference, 4))\nprint('B0 returns a precision-checked scalar, not a separate error estimate.')\n\n# 2. D=2 sunset: positive Euclidean propagators; d^2k d^2l / pi^2.\n# Q=10 > m1+m2+m3=3 selects the momentum RMT chart.\nsunset = ScalarGraph([ScalarEdge(0, 1, 1)]*3, {0: [10], 1: [-10]})\ntrace = explain_sunset_rmt(sunset, evaluate=True, dps=25)\ndiagnostics = trace['evaluation']['diagnostics']\nassert trace['evaluation']['status'] == 'converged'\n# Reference from independent simplex quadrature at 40 and 55 digits:\n# tests/data/sunset_rmt_reference.json (precision difference < 2.4e-42).\nwith mp.workdps(45):\n    reference = mp.mpf('0.6290167075906141495908272538835833416123070767')\n    encoded = diagnostics['value']\n    exact_value = (-1)**encoded['sign'] * mp.ldexp(mp.mpf(int(encoded['mantissa_hex'], 16)), encoded['exponent2'])\n    difference = abs(exact_value-reference)\n    assert difference <= mp.mpf(diagnostics['error_estimate']['decimal']) + mp.mpf('3e-42')\nprint('RMT value:', diagnostics['value']['decimal'])\nprint('RMT chart:', trace['convergence']['chart'], 'condition:', trace['convergence']['condition'])\nprint('RMT tail bound:', diagnostics['truncation_bound']['decimal'])\nprint('RMT estimated error before display rounding:', diagnostics['error_estimate']['decimal'])\nprint('Gamma families:', len(trace['families']), 'terms:', diagnostics['terms'])\nexported_json = json.dumps(trace, indent=2)  # Inspect without evaluating expression strings.\ntry:\n    explain_sunset_rmt(ScalarGraph([ScalarEdge(0, 1, 1)]*3))\nexcept RMTDomainError as error:\n    print('Expected domain refusal:', error)\nelse:\n    raise AssertionError('The RMT chart must refuse equal-mass vacuum')\n\n# 3. D=1 three-loop banana: d^1k / sqrt(pi) for each of three loops.\n# Fourier convolution gives pi^(3/2)*sum(m)/(prod(m)*(sum(m)^2+Q^2)).\nbanana = ScalarGraph([ScalarEdge(0, 1, m*m) for m in (1, 2, 3, 4)], {0: [2], 1: [-2]})\nhybrid = integrate_graph(banana, D=1, epsrel=3e-3, max_evaluations=4000000, seed=1729)\nreference = float(mp.pi**mp.mpf('1.5')*10/(24*(100+4)))\nassert abs(hybrid.value-reference) <= hybrid.error_estimate\nprint('Hybrid value:', hybrid.value, '+/-', hybrid.error_estimate)\nprint('Fourier reference:', reference)\nprint('Hybrid method:', hybrid.method)\nprint('The hybrid estimate is float64 with statistical errors; it is not a full RMT series.')\n",
    },
    {
      title: "Ramanujan's Master Theorem",
      code: `import mpmath as mp
from ramanujan_qft import ramanujan_master_theorem, mellin_numeric

# (1 + x)^-3 = sum phi(n) (-x)^n / n!  with  phi(n) = Gamma(3 + n) / Gamma(3)
phi = lambda n: mp.gamma(3 + n) / mp.gamma(3)

print("RMT       :", ramanujan_master_theorem(phi, 1.25))
print("Beta      :", mp.beta(1.25, 1.75))
print("quadrature:", mellin_numeric(lambda x: (1 + x)**-3, 1.25))
`,
    },
    {
      title: "Oscillatory product integral",
      code: `import mpmath as mp
from ramanujan_qft import product_integral, exponential, bessel_j

# Int_0^oo exp(-x) J_0(10^5 x) dx = 1/sqrt(1 + 10^10), to 30 digits
value, info = product_integral(exponential(1), bessel_j(0, 1e5), dps=30, return_info=True)
print(mp.nstr(value, 30))
with mp.workdps(30):
    print(mp.nstr(1 / mp.sqrt(1 + mp.mpf(10)**10), 30), "(closed form)")
print(info)
`,
    },
    {
      title: "Exponential, Gaussian and Bessel product",
      code: `import mpmath as mp
from ramanujan_qft import product_integral, exponential, gaussian_bessel

# Int_0^oo exp(-2x) exp(-x^2/2) J_1(b x) dx
for b in (1, 10, 100):
    v = product_integral(exponential(2), gaussian_bessel("0.5", b, 1), dps=30)
    print(f"b = {b:>3}:", mp.nstr(v, 30))
`,
    },
    {
      title: "Convergence and divergence refusals",
      code: `from ramanujan_qft import product_integral, exponential, bessel_j, cosine, SeriesConvergenceError

# Int exp(-x) J_0(x) dx = 1/sqrt(2) exists, but its residue series sit on the
# convergence boundary rho = 1: the engine refuses instead of guessing.
try:
    product_integral(exponential(1), bessel_j(0, 1))
except SeriesConvergenceError as err:
    print("SeriesConvergenceError:", err)

# Int cos(x) cos(2x) dx diverges: ValueError, with the strip where it exists
try:
    product_integral(cosine(1), cosine(2))
except ValueError as err:
    print("ValueError:", err)
`,
    },
    {
      title: "One-loop B0 and C0 (LoopTools conventions)",
      code: `import mpmath as mp
from ramanujan_qft import B0, C0

# squared masses; p^2 > 0 is time-like; Delta = 0, mu^2 = 1 as in LoopTools
print("B0(10; 1, 2)    =", B0(10, 1, 2))
print("  LoopTools 2.16:  0.622592073090541875 + 2.01160080643417860 i")
print("C0(0,0,10;1,2,3) =", C0(10, 1, 2, 3))
print("  LoopTools 2.16: -0.421932531674735434 - 0.336732268033680282 i")
print()
print("C0 to 50 digits:", mp.nstr(C0(10, 1, 2, 3, dps=50), 50))
`,
    },
    {
      title: "Precision and exact inputs",
      code: `import mpmath as mp
from ramanujan_qft import B0

x = B0(10, 1, 2, dps=40)
print(x)                  # printed at the global mp.mp.dps = 15
print(mp.nstr(x, 40))     # all 40 digits

# floats are binary numbers; strings are exact decimals
print(mp.nstr(B0(0.1, 1, 2, dps=30), 30))
print(mp.nstr(B0("0.1", 1, 2, dps=30), 30))
`,
    },
    {
      title: "Two-loop sunset: imaginary part",
      code: `import mpmath as mp
from ramanujan_qft import sunset_im, sunset_threshold

m = (1, 2, 3)   # squared masses
print("threshold:", sunset_threshold(*m))
for s in (20, 50, 100):
    print(f"Im S({s}) =", mp.nstr(sunset_im(s, *m), 15))
`,
    },
    {
      title: "Two-loop sunset: graph to multivariate RMT",
      code: `import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, compile_sunset_rmt

# Positive Euclidean propagators; squared masses = 1, D = 2, Q = 10 > 3m.
# This backend sums generated Gamma series without numerical integration.
graph = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)],
                    external_momenta={0: [10], 1: [-10]})
series = compile_sunset_rmt(graph)
print("Exponent matrix:", series.bracket_system.matrix)
print("Gamma families:", len(series.families))
result = series.evaluate(dps=25)
print("Chart:", result.chart)
print("Integral:", mp.nstr(result.value, 25))
print("Truncation bound:", mp.nstr(result.truncation_bound, 5))
print("Estimated error:", mp.nstr(result.error_estimate, 5))
`,
    },
    {
      title: "Two-loop sunset: equal-mass Taylor continuation",
      code: `import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_sunset_taylor

# Separate Taylor method: equal-mass vacuum is outside the RMT charts.
graph = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)])
result = integrate_sunset_taylor(graph, dps=25)
print("Method:", result.method)
print("Vacuum integral:", mp.nstr(result.value, 25))
with mp.workdps(35):
    print("Clausen reference:", mp.nstr(4 * mp.clsin(2, mp.pi / 3) / mp.sqrt(3), 25))
print("Estimated error:", mp.nstr(result.error_estimate, 5))
`,
    },
    {
      title: "Your own calculation",
      code: `import mpmath as mp
from ramanujan_qft import *

# Write your calculation here and press Run (or Ctrl+Enter).
# The value of the last line is shown, as in a notebook.
# Variables persist between runs until you press Reset.

mp.nstr(product_integral(gaussian(1), cosine(3), dps=25), 25)
`,
    },
  ];

  function ready(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
  }

  ready(function () {
    const root = document.getElementById("rq-console");
    if (!root) return;
    const $ = (id) => document.getElementById(id);
    const editor = $("rq-code"), output = $("rq-output"), status = $("rq-status");
    const runButton = $("rq-run"), stopButton = $("rq-stop"), resetButton = $("rq-reset");
    const clearButton = $("rq-clear"), picker = $("rq-example");
    const config = Object.assign({}, DEFAULTS, window.RQFT_CONFIG || {});

    let worker = null, starting = null, busy = false, runId = 0;

    function setStatus(text, kind) {
      status.textContent = text;
      status.dataset.kind = kind || "";
    }

    function write(text, kind) {
      const span = document.createElement("span");
      if (kind) span.className = "rq-" + kind;
      span.textContent = text;          // text only: output is never interpreted as HTML
      output.appendChild(span);
      output.scrollTop = output.scrollHeight;
    }

    function setBusy(value) {
      busy = value;
      runButton.disabled = value;
      stopButton.disabled = !value;
      root.classList.toggle("rq-busy", value);
    }

    function absolute(url, base) {
      return new URL(url, base || document.baseURI).href;
    }

    async function resolveConfig() {
      const indexURL = absolute(config.indexURL.endsWith("/") ? config.indexURL : config.indexURL + "/");
      const wheels = config.wheels ? config.wheels.map((w) => absolute(w)) : null;
      const index = absolute(config.wheelIndex);
      const response = await fetch(index, { cache: "no-cache" });
      if (!response.ok) throw new Error(`could not find the ramanujan-qft wheel (${index}: HTTP ${response.status})`);
      const name = (await response.json()).wheel;
      return { indexURL, packages: config.packages, wheels, packageWheel: absolute(name, index) };
    }

    function startWorker() {
      if (starting) return starting;
      starting = new Promise(function (resolve, reject) {
        resolveConfig().then(function (resolved) {
          worker = new Worker(new URL("try_it_worker.js", SCRIPT_URL).href);
          worker.onmessage = function (event) {
            const msg = event.data;
            if (msg.type === "status") setStatus(msg.text, "loading");
            else if (msg.type === "ready") {
              setStatus(`Python is ready (ramanujan-qft ${msg.version}). Ctrl+Enter runs the code.`, "ready");
              resolve();
            } else if (msg.type === "stdout") { if (msg.id === runId) write(msg.text); }
            else if (msg.type === "stderr") { if (msg.id === runId) write(msg.text, "stderr"); }
            else if (msg.type === "done") {
              if (msg.id === runId) {
                setBusy(false);
                setStatus(`Done in ${msg.seconds.toFixed(2)} s.`, "ready");
              }
            } else if (msg.type === "error") {
              if (msg.id === undefined) { fail(msg.text); reject(new Error(msg.text)); }
              else if (msg.id === runId) { write(msg.text + "\n", "stderr"); setBusy(false); setStatus("Error.", "error"); }
            }
          };
          worker.onerror = function (event) {
            event.preventDefault();
            const text = event.message || "the Python worker could not be started";
            fail(text);
            reject(new Error(text));
          };
          worker.postMessage({ type: "init", config: resolved });
        }).catch(function (err) { fail(err.message || String(err)); reject(err); });
      });
      return starting;
    }

    function fail(text) {
      setBusy(false);
      stopWorker();
      setStatus("Python could not be loaded.", "error");
      write(
        `Could not start Python in this browser: ${text}\n\n` +
        "The console needs a recent browser with WebAssembly, and access to cdn.jsdelivr.net.\n" +
        "Alternatives: the Colab notebook (link on this page), or install the package:\n" +
        '  pip install "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"\n',
        "stderr");
    }

    function stopWorker() {
      if (worker) worker.terminate();
      worker = null;
      starting = null;
    }

    async function run() {
      if (busy) return;
      setBusy(true);
      const code = editor.value;
      const id = ++runId;
      write(">>> run\n", "prompt");
      try {
        if (!worker || !starting) setStatus("Starting Python… (the first start downloads Python and its dependencies)", "loading");
        await startWorker();
      } catch (err) {
        return;
      }
      if (id !== runId) return;
      setStatus("Running…", "loading");
      worker.postMessage({ type: "run", id, code });
    }

    function stop() {
      if (!busy) return;
      runId++;
      stopWorker();
      setBusy(false);
      write("Stopped. Python will restart on the next run; variables were cleared.\n", "stderr");
      setStatus("Stopped.", "error");
    }

    function loadExample(index) {
      editor.value = EXAMPLES[index].code;
    }

    EXAMPLES.forEach(function (ex, i) {
      const option = document.createElement("option");
      option.value = String(i);
      option.textContent = ex.title;
      picker.appendChild(option);
    });
    picker.addEventListener("change", function () { loadExample(Number(picker.value)); });
    loadExample(0);

    runButton.addEventListener("click", run);
    stopButton.addEventListener("click", stop);
    clearButton.addEventListener("click", function () { output.textContent = ""; });
    resetButton.addEventListener("click", function () {
      if (busy) stop();
      stopWorker();
      output.textContent = "";
      loadExample(Number(picker.value));
      setStatus("Reset: the example is restored and Python will restart on the next run.", "");
    });

    editor.addEventListener("keydown", function (event) {
      if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
        event.preventDefault();
        run();
      } else if (event.key === "Tab" && !event.shiftKey && !event.ctrlKey && !event.metaKey && !event.altKey) {
        event.preventDefault();
        const start = editor.selectionStart, end = editor.selectionEnd;
        editor.setRangeText("    ", start, end, "end");
      }
    });

    root.classList.add("rq-enabled");
    stopButton.disabled = true;
    setStatus("Python is not loaded yet. Press Run (or Ctrl+Enter) to start it.", "");
  });
})();
