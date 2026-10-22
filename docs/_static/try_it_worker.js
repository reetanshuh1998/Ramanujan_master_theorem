/* ramanujan-qft "Try it" console: Python (Pyodide) in a Web Worker.
 *
 * Messages in:  {type: "init", config}   config = {indexURL, packages, wheels, packageWheel}
 *               {type: "run", id, code}
 * Messages out: {type: "status", text} | {type: "ready", version} | {type: "error", text}
 *               {type: "stdout" | "stderr", id, text} | {type: "done", id, seconds}
 */
"use strict";

let pyodide = null;
let currentRun;     // id of the run in progress (undefined while starting)

// Pyodide reports some download failures only as unhandled promise rejections
// (loadPyodide then never settles): turn them into an error message.
self.addEventListener("unhandledrejection", (event) => {
  const reason = event.reason;
  postMessage({ type: "error", id: currentRun, text: String(reason && reason.message ? reason.message : reason) });
});

const RUNNER = `
import ast, sys, time, traceback

_rq_globals = {"__name__": "__main__"}

def _rq_run(src):
    t0 = time.perf_counter()
    try:
        tree = ast.parse(src, "<console>", "exec")
        last = None
        if tree.body and isinstance(tree.body[-1], ast.Expr):
            last = ast.Expression(tree.body.pop().value)
        exec(compile(tree, "<console>", "exec"), _rq_globals)
        if last is not None:
            value = eval(compile(last, "<console>", "eval"), _rq_globals)
            if value is not None:
                print(repr(value))
    except BaseException:
        etype, evalue, tb = sys.exc_info()
        # hide the console's own frames: show the user's code and the library
        while tb is not None and tb.tb_frame.f_code.co_filename != "<console>":
            tb = tb.tb_next
        traceback.print_exception(etype, evalue, tb)
    finally:
        sys.stdout.flush()
        sys.stderr.flush()
    return time.perf_counter() - t0
`;

async function fetchWheel(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`could not download ${url} (HTTP ${response.status})`);
  pyodide.unpackArchive(await response.arrayBuffer(), "wheel");
}

async function init(config) {
  postMessage({ type: "status", text: "Downloading Python (Pyodide)…" });
  importScripts(config.indexURL + "pyodide.js");
  pyodide = await loadPyodide({ indexURL: config.indexURL });
  postMessage({ type: "status", text: "Installing mpmath and SymPy…" });
  if (config.wheels && config.wheels.length) {
    for (const url of config.wheels) await fetchWheel(url);
  } else {
    await pyodide.loadPackage(config.packages);
  }
  postMessage({ type: "status", text: "Installing ramanujan-qft…" });
  await fetchWheel(config.packageWheel);
  pyodide.runPython(RUNNER);
  const version = pyodide.runPython("import ramanujan_qft; ramanujan_qft.__version__");
  postMessage({ type: "ready", version });
}

async function run(id, code) {
  currentRun = id;
  pyodide.setStdout({ batched: (text) => postMessage({ type: "stdout", id, text: text + "\n" }) });
  pyodide.setStderr({ batched: (text) => postMessage({ type: "stderr", id, text: text + "\n" }) });
  try {
    await pyodide.loadPackagesFromImports(code);
  } catch (e) {
    postMessage({ type: "stderr", id, text: `could not load a package imported by this code: ${e}\n` });
  }
  pyodide.globals.set("_rq_src", code);
  const seconds = pyodide.runPython("_rq_run(_rq_src)");
  postMessage({ type: "done", id, seconds });
}

onmessage = async (event) => {
  const msg = event.data;
  try {
    if (msg.type === "init") await init(msg.config);
    else if (msg.type === "run") await run(msg.id, msg.code);
  } catch (e) {
    postMessage({ type: "error", id: msg.id, text: String(e && e.message ? e.message : e) });
  }
};
