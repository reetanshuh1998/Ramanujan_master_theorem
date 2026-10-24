# ramanujan-qft

[![tests](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/tests.yml/badge.svg)](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/tests.yml)
[![docs](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/docs.yml/badge.svg)](https://reetanshuh1998.github.io/Ramanujan_master_theorem/)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/quickstart.ipynb)

**Documentation:** <https://reetanshuh1998.github.io/Ramanujan_master_theorem/>. It includes a user guide, an API reference, examples, and an in-browser console
([Try it](https://reetanshuh1998.github.io/Ramanujan_master_theorem/try_it.html)) that needs no installation.

**Ramanujan's Master Theorem, Mellin residue summation and arbitrary-precision
Feynman integrals in pure Python.**

**Research-alpha scope:** see the [capability table](https://reetanshuh1998.github.io/Ramanujan_master_theorem/CAPABILITIES.html) for
supported domains, methods and error guarantees, and the
[release plan](https://reetanshuh1998.github.io/Ramanujan_master_theorem/RELEASE_PLAN.html) for validation and publication status.
The runnable [research notebook](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/research_alpha.ipynb) demonstrates
graph-generated RMT families, equal-mass vacuum and an independent reference.

```
f(x) = Σ φ(n) (-x)ⁿ / n!     ⟹     ∫₀^∞ x^(s-1) f(x) dx = Γ(s) φ(-s)
```

Ramanujan's Master Theorem (RMT) turns an integral into an evaluation of
analytically continued Taylor coefficients under the theorem’s hypotheses.
The package provides the following numerical methods and diagnostics:

1. **`rmt`**: the theorem itself, with a separate numerical Mellin transform
   for checking suitable non-oscillatory integrands. The caller must establish
   the theorem’s hypotheses.
2. **`mellin.product_integral`**: ∫ x^(s-1) f(x) g(x) dx as a residue series,
   using the Mellin-convolution (Meijer-G / Slater) method of Marichev and others.
   Before summing, it checks which expansion legitimately closes the contour.
   It compensates cancellation by raising the working precision, and it raises
   an error rather than return a number that fails its accuracy checks.
3. **Feynman integrals** with known hypergeometric or dispersive
   representations: one-loop B0 and C0, the D=3 bubble, and the
   scheme-independent part of the two-loop sunset. Results are checked at two
   working precisions and against independent references; the one-loop tests
   also compare with LoopTools.
4. **`multiloop.integrate_graph`**: an experimental graph-based evaluator for
   UV-convergent massive Euclidean scalar integrals. It builds Symanzik
   polynomials, checks all UV subgraphs, applies RMT to the Schwinger scale,
   and integrates the remaining Hepp sectors with scrambled Sobol sampling.
   This backend returns float64 estimates with statistical errors.
5. **`sunset_rmt.integrate_graph_rmt`**: multivariate RMT/Gamma series
   for the massive, unit-power two-loop sunset in D=2. Exact graph-derived
   bracket families, analytic pole resolution, justified convergence charts,
   and arbitrary-precision summation with an analytic truncation bound.
6. **`sunset_taylor.integrate_sunset_taylor`**: a separate equal-mass D=2
   Taylor-series evaluator covering vacuum and finite Euclidean momentum,
   with an analytic tail bound and precision control for its unstable recurrence.

**References.** The mathematical methods follow the cited literature. [docs/PRIOR_ART.md](https://reetanshuh1998.github.io/Ramanujan_master_theorem/PRIOR_ART.html)
credits the earlier work (Hardy, Marichev, Adamchik–Marichev, Slater,
Gonzalez–Moll–Schmidt, Prausa, Ananthanarayan–Banik–Friot–Ghosh, SymPy,
mpmath, …), with derivations and implementation details in the user guides.

*Dedicated to the memory of Srinivasa Ramanujan.*

## Why it can be useful

* **Precision.** Reference values at 30–100 digits can help check
  double-precision calculations and expressions with large cancellations.
* **Derivations.** The equal-mass bubble, for example, has the representation
  B0 = Δ − log(m²/μ²) + (2w/3)·₂F₁(1,1;5/2;w), with w = p²/4m².
  The documentation explains its domain, continuation and numerical checks.
* **Oscillatory products.** Residue summation can avoid resolving each
  oscillation by quadrature. The [measured comparisons](https://reetanshuh1998.github.io/Ramanujan_master_theorem/COMPARISON.html)
  report accuracy and timings for selected examples.

## Multiloop support and current limits

**Multiloop integration is implemented for UV-convergent massive Euclidean
scalar graphs.** `integrate_graph` accepts graph input without a fixed loop-count
limit; validation includes examples through four loops. Practical graph size is
limited by sector growth and explicit work budgets. It uses **RMT for the common
Schwinger scale and numerical Hepp-sector integration for the remaining
parameters**, returning float64 estimates with statistical error diagnostics.

The package has three distinct residue/series capabilities:

- **RACE (`mellin.product_integral`)** evaluates products of functions from the
  documented Mellin atlas by residue summation.
- **The multivariate RMT backend (`integrate_graph_rmt`)** generates and sums
  Gamma-function series for the massive, unit-power D=2 sunset in two justified
  convergence regions, without a numerical integration fallback.
- **The separate Taylor backend (`integrate_sunset_taylor`)** covers the
  equal-mass D=2 sunset at vacuum and finite Euclidean momentum, subject to budgets.

**General multiloop evaluation entirely through RACE/RMT residue series remains
a research goal.** The graph backend does not yet supply dimensional-regulator
expansions, overlapping-divergence subtraction, massless or tensor integrals,
or physical-region continuation. See the [capability table](https://reetanshuh1998.github.io/Ramanujan_master_theorem/CAPABILITIES.html)
and [multiloop guide](https://reetanshuh1998.github.io/Ramanujan_master_theorem/user_guide/multiloop.html).

Performance claims are limited to measured cases. In the recorded one-loop
benchmarks, LoopTools was roughly 300–450 times faster at double precision;
evaluation of known closed forms also beat residue summation in the measured
product-integral cases. These timings do not establish a speed ranking for the
new multiloop backends against pySecDec, FIESTA, AMFlow or TSIL.
For a measured strength of the Ramanujan/Mellin approach, the current 30-digit
product benchmark integrates `exp(-2x - x²/2) J₁(100x)` in **3.92 ms**, versus
**1021 ms** for `mpmath.quadosc`, with both meeting the accuracy target. At
frequency 1, RACE also beats the measured tanh–sinh and Gauss–Legendre calls.
These are selected product integrals, not a general Feynman-integral speed claim.
See [the reproducible comparisons](https://reetanshuh1998.github.io/Ramanujan_master_theorem/COMPARISON.html) and [audit](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/AUDIT.md).

Developed and maintained by **Reet**.

## Install

Install a published research alpha from PyPI (Python >= 3.9):

```bash
pip install --pre ramanujan-qft
```

For the latest development source or a local clone:

```bash
pip install "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"   # latest version, requires Python >= 3.9
pip install .            # from a clone
pip install ".[test]"    # + pytest, scipy for the test suite
pip install ".[multiloop]"  # + scipy for the experimental graph evaluator
```

## Quick start

```python
import mpmath as mp
from ramanujan_qft import (ramanujan_master_theorem, product_integral, exponential,
                           bessel_j, B0, C0, sunset_im)

# Ramanujan's Master Theorem: ∫ x^(s-1)(1+x)^-3 dx = Γ(s) φ(-s),  φ(n) = Γ(3+n)/Γ(3)
ramanujan_master_theorem(lambda n: mp.gamma(3 + n) / 2, 1.25)     # = B(1.25, 1.75)

# Oscillatory product integral by Mellin residues: ∫ e^(-x) J0(1e5 x) dx
product_integral(exponential(1), bessel_j(0, 1e5), dps=30)
# ... refuses (SeriesConvergenceError) at the convergence boundary e^(-x) J0(x),
# and raises ValueError for divergent integrals such as ∫ cos(x) cos(2x) dx

# One-loop integrals, LoopTools conventions (Δ = 0, μ² = 1 by default)
B0(5, 1, 1)                 # (1.5695910590 + 1.4049629462j)   = LoopTools
C0(10, 1, 2, 3, dps=50)     # C0(0,0,s; m1², m2², m3²) to 50 digits

# Two-loop sunset: imaginary part (precision-checked)
sunset_im(100, 1, 2, 3)     # -88.1849955516
```

More in [`examples/`](https://github.com/reetanshuh1998/Ramanujan_master_theorem/tree/main/examples/):

| Example | Shows |
|---------|-------|
| `01_ramanujan_master_theorem.py` | RMT on classical cases; a dimensionally regulated radial integral |
| `02_mellin_products.py` | exp × Bessel at high frequency, log cases, three-factor products, convergence errors |
| `03_one_loop_integrals.py` | B0, C0 at double and 50-digit precision; MoB series vs closed form |
| `04_sunset_dispersion.py` | sunset Im part and twice-subtracted dispersion relation |
| `05_multiloop_graphs.py` | graph-based two- and three-loop integrals, unequal masses and UV diagnostics |
| `06_sunset_rmt.py` | exact bracket families, convergent multivariate sunset series, domain refusals |
| `07_sunset_taylor.py` | equal-mass vacuum, low momentum and overlap with the RMT chart |

### Graph-based multiloop example

```python
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_graph

# Four parallel edges give a three-loop banana graph.
graph = ScalarGraph([ScalarEdge(0, 1, mass_squared=1) for _ in range(4)])
result = integrate_graph(graph, D=2, epsrel=1e-4, seed=0)
print(result.value, result.error_estimate)  # approximately 7*zeta(3) = 8.414398...
```

The graph API uses **positive Euclidean propagators** and the loop measure
dᴰk/π^(D/2). Its `error_estimate` is statistical, not a rigorous bound.
Unmet tolerances raise `MultiloopConvergenceError`, carrying the partial result.
Read [the guide](https://reetanshuh1998.github.io/Ramanujan_master_theorem/user_guide/multiloop.html) before comparing conventions.

### Multivariate RMT example

```python
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, compile_sunset_rmt

graph = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)],
                    external_momenta={0: [10], 1: [-10]})
series = compile_sunset_rmt(graph)
print(series.bracket_system.matrix)  # exact exponent constraints
print(len(series.gamma_terms))       # 8 regulated Gamma families
result = series.evaluate(dps=30)
print(mp.nstr(result.value, 30))      # 0.629016707590614149590827253884
```

Supported charts require **p_E > m1+m2+m3** or **M > ma+mb+p_E**, where
M is the largest mass. Equal-mass vacuum and the gap between these charts
raise `RMTDomainError`. This evaluator uses no numerical integration fallback.
See [the derivation and error controls](https://reetanshuh1998.github.io/Ramanujan_master_theorem/user_guide/sunset_rmt.html).

The separate `integrate_sunset_taylor(graph, dps=30)` method now covers
equal-mass vacuum and finite Euclidean momentum. It uses an ODE/Taylor series
with a Clausen boundary value, with no automatic substitution for an RMT call.
See [its derivation](https://reetanshuh1998.github.io/Ramanujan_master_theorem/user_guide/sunset_taylor.html).

## API overview

| Module | Function | Description | Validated against |
|--------|----------|-------------|-------------------|
| `rmt` | `ramanujan_master_theorem(phi, s)` | Γ(s)·φ(−s) | numerical Mellin transforms, DLMF |
| | `mellin_numeric(f, s)` | numerical Mellin transform | — |
| | `massive_propagator_rmt(m², D)` | ∫dq² (q²)^(D/2−1)/(q²+m²) | closed form, quadrature |
| `mellin` | `product_integral(f, g, s)` | Mellin residue summation: validity check of the contour closure, existence check, cancellation-compensated precision, pole collisions | closed forms (DLMF, Gradshteyn–Ryzhik), quadrature; adversarial audit |
| | atlas: `exponential, gaussian, bessel_j, cosine, sine, inverse_power, gaussian_bessel` | Mellin data of each factor | |
| `one_loop` | `B0(p², m1², m2², mu2, delta)` | two-point function, all masses | LoopTools, independent quadrature |
| | `B0_mob(p², m²)` | equal-mass MoB ₂F₁ series, continued across threshold | `B0` to 50 digits |
| | `C0(s, m1², m2², m3²)` | C0(0,0,s; m1², m2², m3²); massless lines allowed when IR finite | LoopTools, independent quadrature |
| | `C0_mob(s, m²)` | equal-mass closed MoB form | arcsin² identity, `C0` |
| | `bubble_3d(p², m1², m2²)` | finite D=3 bubble | quadrature with −i0 |
| `sunset` | `sunset_im`, `sunset_subtracted`, `sunset_d2` | Im S, S(s)−S(0)−sS′(0), S″(s) | 2-D Feynman-parameter integrals |
| `multiloop` | `ScalarEdge`, `ScalarGraph`, `integrate_graph` | convergent massive Euclidean graphs; RMT scale + numerical Hepp sectors | independent quadrature, Clausen/zeta values, position-space integrals through four loops |
| `brackets`, `sunset_rmt` | `schwinger_brackets`, `compile_sunset_rmt`, `integrate_graph_rmt` | exact bracket algebra; justified D=2 sunset Gamma series | high-precision independent simplex quadrature; pole limits; hybrid graph backend |

The original numerical APIs take `dps=` (decimal digits). Squared masses throughout;
Minkowski metric, so p² > 0 is time-like; Feynman +i0.

**Normalisation of `one_loop` and `sunset`:** each loop is integrated with dᴰk/(iπ^(D/2)), and propagators
are 1/(q² − m² + i0), as in LoopTools and pySecDec.

The classes of version 0.1 (`FeynmanMoBSolver`, `AnalyticalConvolutionEngine`,
`RamanujanContinuationEngine`, …) are still importable. Methods that did not
compute their stated integral now raise `NotImplementedError` with an
explanation (see [CHANGELOG.md](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/CHANGELOG.md)).

## Validation

```bash
pytest -m "not slow"     # fast regressions and multiloop validation
pytest                   # also independent nested-quadrature checks; several minutes
bash benchmarks/looptools/compare_looptools.sh   # builds LoopTools (gfortran) and compares
python benchmarks/bench_release.py   # accuracy-checked 30-digit product timings
```

* B0 and C0 agree with LoopTools 2.16 to double-precision round-off at 15, 30
  and 60 working digits (`tests/data/looptools_reference.csv`).
* The MoB series for B0 agrees with the closed form to 50 digits, below and
  above threshold.
* The sunset's Im S, S″ and twice-subtracted S agree with independent
  Feynman-parameter integrations to 10⁻⁸ to 10⁻¹⁴.
* One-loop results are *precision-checked*: each is evaluated at two working precisions,
  raised until they agree within the requested tolerance. This checks for
  unresolved cancellation at extreme kinematics; it is not an interval proof.
* RACE went through three adversarial audit rounds against closed forms and
  independent quadrature: two of about 2,000–4,000 cases each, then a bounded
  785-case round. All 50 confirmed defects (19 + 28 + 3) were fixed and turned
  into regression tests (`tests/test_mellin_regressions.py`,
  `tests/test_round2_regressions.py`, `tests/test_round3_regressions.py`). In
  the recorded final sweeps, accepted values met their accuracy targets;
  these finite tests do not establish correctness for every input. Round 3 also covered the one-loop and sunset
  functions (1,820 random cases plus a 24,000-point LoopTools comparison). It
  found and fixed defects in the sunset functions and in C0 with massless
  lines. See
  [AUDIT.md](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/AUDIT.md).

## Roadmap

* Extend the D=2 sunset RMT charts into the uncovered Euclidean region, then
  add topologies with derived convergence rules. Broaden the graph backend with
  efficient sector strategies, epsilon expansions and subtraction,
  massless graphs, and causal continuation. See the staged plan in
  [the multiloop guide](https://reetanshuh1998.github.io/Ramanujan_master_theorem/user_guide/multiloop.html).
* Sunset subtraction constants S(0), S′(0) in closed form, giving the full
  finite part.
* C0 with general external momenta; D0.
* Extend `schwinger_brackets` and the sunset series compiler with justified
  family selection, pole resolution and convergence regions for other topologies.
* A larger Mellin atlas (Bessel K/Y, Struve, rational functions).

Contributions are welcome. Please add a test against an independent reference
for any new integral.

## References

* T. Amdeberhan, O. Espinosa, I. Gonzalez, M. Harrison, V. H. Moll, A. Straub,
  *Ramanujan's Master Theorem*, Ramanujan J. 29 (2012) 103.
* I. Gonzalez, V. H. Moll, I. Schmidt, *Ramanujan's Master Theorem applied to
  the evaluation of Feynman diagrams*, Adv. Appl. Math. 63 (2015) 214.
* I. Gonzalez, I. Schmidt, *Optimized negative dimensional integration method
  (NDIM) and multiloop Feynman diagram calculation*, Nucl. Phys. B 769 (2007) 124.
* T. Hahn, M. Pérez-Victoria, *Automatized one-loop calculations in four and D
  dimensions*, Comput. Phys. Commun. 118 (1999) 153 (LoopTools).
* A. Denner, *Techniques for the calculation of electroweak radiative
  corrections at the one-loop level*, Fortsch. Phys. 41 (1993) 307.
* S. Borowka et al., *pySecDec: a toolbox for the numerical evaluation of
  multi-scale integrals*, Comput. Phys. Commun. 222 (2018) 313.
* S. P. Martin, D. G. Robertson, *TSIL: a program for the calculation of
  two-loop self-energy integrals*, Comput. Phys. Commun. 174 (2006) 133.
* NIST Digital Library of Mathematical Functions, §10.22 (Mellin transforms of
  Bessel functions).

## License

MIT (see [LICENSE](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/LICENSE)).
