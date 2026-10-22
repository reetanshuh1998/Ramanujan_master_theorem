# Installation

`ramanujan-qft` is a pure-Python package. It needs **Python 3.9 or later** and
three dependencies, which pip installs automatically:

| package | version | used for |
|---|---|---|
| [mpmath](https://mpmath.org) | ≥ 1.3.0 | arbitrary-precision arithmetic and RMT factors |
| [SymPy](https://www.sympy.org) | ≥ 1.12 | exact graph algebra and the legacy 0.1 modules |
| [NumPy](https://numpy.org) | ≥ 1.24 | numerical multiloop sectors and the legacy 0.1 module `core` |

There is nothing to compile.

## Install from GitHub

This is the recommended way until the first release on PyPI:

```bash
pip install "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"
```

To include the test dependencies (pytest, SciPy):

```bash
pip install "ramanujan-qft[test] @ git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"
```

## Install from a clone

Clone the repository if you want to run the tests, build the documentation or
change the code:

```bash
git clone https://github.com/reetanshuh1998/Ramanujan_master_theorem
cd Ramanujan_master_theorem
pip install .            # the package
pip install ".[test]"    # the package plus pytest and SciPy, for the test suite
pip install ".[multiloop]"  # plus SciPy for hybrid graph integration; RMT series need only the base package
```

For development, add `-e` (`pip install -e ".[test]"`) so that changes to the
source take effect without reinstalling.

## PyPI

`ramanujan-qft` is **not yet released on PyPI**. Once it is, the command will
be:

```bash
pip install ramanujan-qft
```

## Check the installation

```pycon
>>> import ramanujan_qft
>>> ramanujan_qft.__version__
'0.2.0'
>>> from ramanujan_qft import B0
>>> B0(5, 1, 1)
mpc(real='1.5695910590359961', imag='1.4049629462081452')
```

The last value agrees with LoopTools 2.16, which gives
`1.56959105903599583 + 1.40496294620814521 i`
(`tests/data/looptools_reference.csv`).

## Run the tests

From the root of a clone, with the `[test]` extra installed:

```bash
python -m pytest -q -m "not slow" tests     # fast regressions and multiloop checks
python -m pytest -q tests                   # includes slow checks; several minutes
```

The tests marked `slow` are independent nested quadratures (for example the
Feynman-parameter checks of the two-loop sunset) and take seconds each.
{doc}`/validation` describes what is tested against what.

## Build the documentation locally

```bash
pip install ".[multiloop]" -r docs/requirements.txt
python -m sphinx -b html docs docs/_build/html
```

Then open `docs/_build/html/index.html` in a browser. The first build runs the
scripts in `examples/` through sphinx-gallery; the two-loop sunset example
alone takes about a minute and a half. Later builds reuse the results of
examples that did not change. To skip running the examples, add
`-D plot_gallery=0`.

## Use it without installing

* **In the browser.** The {doc}`/try_it` page runs the package in your browser
  with [Pyodide](https://pyodide.org) (Python compiled to WebAssembly). Nothing
  is installed on your machine.
* **In Google Colab.** Open the
  [quickstart notebook in Colab](https://colab.research.google.com/github/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/quickstart.ipynb).
  Its first cell installs the package into the Colab session:

  <!-- skip-test -->
  ```python
  %pip install -q "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"
  ```

Next: the [quickstart](quickstart.md), a ten-minute tour of the package.
