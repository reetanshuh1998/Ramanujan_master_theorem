# Changelog

## Unreleased

## 0.3.0a1 — prepared research-alpha candidate (not published)

### Equal-mass continuation and release preparation
- Added a separate D=2 equal-mass transformed Taylor series for vacuum and
  finite Euclidean momentum, with an analytic tail bound and precision control
  for the unstable coefficient recurrence. RMT calls retain their own domains.
- Added a reproducible independent-parameter audit, capability table, scientific
  review packet, research notebook and contribution instructions.
- Publication now depends on tests, numerical audit, docs/notebook checks and
  installed wheel/sdist checks across Linux, Windows and macOS. Added a manual
  TestPyPI rehearsal. Hosted checks, external review and publication are pending.

### Multivariate Ramanujan sunset series
- Added exact Schwinger bracket matrices and basis solving with inspectable
  Gamma-function summands; nonsingularity makes no convergence claim.
- Added `compile_sunset_rmt` and `integrate_graph_rmt` for the massive,
  unit-power two-loop sunset in D=2. The momentum-dominant and mass-dominant
  Euclidean charts have explicit sufficient convergence domains.
- Resolved coalescing poles analytically into logarithms and harmonic numbers.
  Evaluation uses arbitrary-precision series summation, an analytic tail bound,
  precision checks and bounded work, with no numerical integration fallback.
- Added independent 40/55-digit simplex references, regulated Gamma-family
  checks, boundary/budget tests, and comparisons with the hybrid graph backend.
  Equal-mass vacuum and the gap between charts remain explicitly unsupported.

### Multiloop graphs
- Added immutable `ScalarEdge` and `ScalarGraph` objects with exact Symanzik
  polynomials, conserved Euclidean external vectors, graph-derived loop counts,
  and UV power counting over all cyclic edge subsets.
- Added experimental `integrate_graph`: RMT integration of the Schwinger scale,
  factored Hepp sectors with smooth boundary maps, and replicated scrambled
  Sobol integration. Supports convergent massive scalar graphs and positive
  fractional powers/dimension, subject to explicit work budgets.
- Added `MultiloopResult` statistical diagnostics and strict convergence failure
  via `MultiloopConvergenceError`; SciPy is an optional `multiloop` extra.
- Added independent one- through four-loop checks, a graph example, and a guide
  documenting Euclidean normalization and the remaining path to general
  multivariate RMT, regulator expansions, and physical-region coverage.

### Documentation
- Documentation website (Sphinx, pydata-sphinx-theme), deployed to GitHub Pages by
  `.github/workflows/docs.yml`: landing page, installation, quickstart, user guide
  (Master Theorem, product integrals, one-loop, sunset, precision, conventions),
  API reference, example gallery, validation, comparison, prior art, citing.
- "Try it in your browser": an in-browser console (Pyodide in a Web Worker) that
  runs the package without installation; a Colab quickstart notebook
  (`notebooks/quickstart.ipynb`).
- NumPy-style docstrings with examples for every public function; the examples run
  as doctests in CI, and `tools/check_doc_snippets.py` runs the examples on the
  documentation pages.
- `CITATION.cff`; `publish.yml` for PyPI trusted publishing on a GitHub release.
- LICENSE: the copyright line reads "In memory of Ramanujan".

## 0.2.0

### Added
- `ramanujan_qft.rmt`: `ramanujan_master_theorem`, `mellin_numeric`, `massive_propagator_rmt`.
- `ramanujan_qft.mellin`: `product_integral` with both residue expansions, the
  large-x poles of each factor, convergence control (`SeriesConvergenceError`)
  and pole collisions (logarithmic results). Atlas: exponential, gaussian,
  bessel_j, cosine, sine, inverse_power, gaussian_bessel.
- `ramanujan_qft.one_loop`: `B0` (all masses), `B0_mob`, `C0`, `C0_mob`, `bubble_3d`
  in LoopTools conventions, certified to the requested digits (evaluation at two
  working precisions, raised until they agree).
- `ramanujan_qft.sunset`: `sunset_im`, `sunset_subtracted`, `sunset_d2`.
- Test suite (311 tests) with LoopTools 2.16 reference values, independent
  integrations and regression tests from two adversarial audits; GitHub Actions workflow; `pyproject.toml`; examples; benchmarks.

### Fixed
- The package can now be imported after installation (it no longer depends on
  `feynman_atlas.py` in the repository root).
- `solve_B0_standard` / `solve_C0_standard` are correct at every precision
  (previously correct only for `precision >= 50`, and crashing at 15).
- Sunset imaginary part: prefactor π/s instead of π/(16s), and the correct sign.
- `solve_bessel_exp_product` returned 0.
- `DispersionMoBEngine.reconstruct_complex`: principal value above threshold.
- `HypergeometricConvergenceFilter.check_convergence`: a divergent series with
  p − q − 1 = 0 was labelled "conditional".
- Constructors no longer change the global `mpmath.mp.dps`.

- RACE (`product_integral`), after two adversarial audits (47 confirmed defects,
  all regression-tested):
  - a-priori validity check of the contour closure (Gamma orders and scale ratio);
  - existence check of the integral, with asymptotic phases for equal frequencies;
  - exact representation of inputs near lattice points;
  - a stopping rule guarded by the terms' a-priori peak;
  - cancellation-compensated precision;
  - Wynn epsilon only for alternating series;
  - Richardson-extrapolated pole collisions;
  - honest `error_estimate`.
- B0/C0 cancellation at extreme kinematics (certification), C0 ZeroDivisionError at
  regular points, massless D=3 bubble, sunset edge cases, `mellin_numeric` checks.
- Round 3:
  - sunset functions rewritten (scaling, factored Kallen functions, normalised
    and error-checked quadrature, certification); accurate at threshold and for
    scales 1e-12..1e12;
  - C0 with IR-finite massless internal lines;
  - exact C0 at s = 0;
  - non-finite inputs rejected;
  - RACE: Gamma-argument offsets in the peak estimate (second peak for large v),
    exact sizing of decimal-string inputs, strip edges from raw parameters.

### Withdrawn (raise `NotImplementedError`; see AUDIT.md)
- `FeynmanMoBSolver.massive_sunset_residue`, `solve_massive_sunset`,
  `solve_graph_polynomials`, `solve_P126`, `solve_triangle3L`,
  `solve_elliptic_kite`, `solve_double_box_inv`.
- `RamanujanContinuationEngine.sunset_real_dispersion`, `evaluate_minkowski_residues`.
- `HypergeometricConvergenceFilter.compute_p126_*`.
- `MoBDynamicEngine.stage_D_dynamic_evaluation` (it returned 0).

### Changed
- Default `precision` of the legacy classes is now 30 (was 100). Results no
  longer depend on it.
- RACE methods raise exceptions instead of returning error strings.
- `matplotlib`, `scipy` and `pySecDec` are no longer runtime dependencies.
