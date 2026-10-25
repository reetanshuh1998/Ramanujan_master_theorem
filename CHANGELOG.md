# Changelog

## 0.3.0b5 — beta prerelease

Packages the implemented engineering work from all five stable-release
objectives and the corrections rehearsed in 0.3.0rc2:

1. Proposed API compatibility contract and the `sunset_second_derivative` alias.
2. Expanded independent-reference audits, exact binary numerical evidence,
   explicit hybrid coverage alerts and reproducible reviewer packets.
3. `explain_sunset_rmt` with graph-to-series traces, provenance, diagnostics and
   a bundled provisional JSON schema.
4. Method-selection guidance, actionable refusals and shared reference-checked
   local, notebook and browser examples.
5. Bounded missing-version retries, matching-tag publication guards,
   minimum-dependency/platform/upgrade checks and complete source archives.

Numerical algorithms and mathematical domains are unchanged from rc2. This is
an explicitly requested beta label, not a rollback of the rc2 implementation.
The hybrid evaluator and compiler/export research interfaces remain experimental
or provisional. Human scientific review and outside-user/hosted-Colab feedback
remain pending before stable publication; no such approval is claimed here.

## 0.3.0rc2 — release candidate (qualification pending)

- Include root review files and workflow definitions in the source distribution;
  validate its review-support contents during every artifact build. The rc1
  rehearsal was stopped before upload; its frozen tag remains unchanged.
- Address the supplementary Claude review: include benchmark dependencies in
  reviewer packets, enforce matching tag refs for TestPyPI, display values at
  requested precision, and preserve input mass order in domain errors.
- Separate hybrid accuracy and coverage in schema-v2 audits, retain every
  coverage alert, and export exact binary evidence for numerical comparisons.
- Correct the unverified Colab claim; preserve the review and pending release
  qualifications explicitly.

- Retry only the selected index's exact missing-version response, with bounded
  attempts. Other install failures and smoke checks fail immediately.
- Add minimum-dependency CI, source-bound stability reports and clean/upgrade
  artifact checks with base and optional SciPy dependencies. The development
  version distinguishes these artifacts from the published 0.3.0a5.

- Add a method-selection guide and shared reference-checked examples for local
  Python, documentation, notebooks and the browser. Domain/precision refusals
  now include relevant inputs and explicit next steps.

- Add a source-bound stability audit covering series boundaries, budget refusals,
  independent references, scaling identities and repeated hybrid estimates.
- Add `explain_sunset_rmt` and a bundled provisional JSON schema for exact
  graph-to-series traces, source provenance and optional evaluation diagnostics.

- Track the five objectives for 0.3.0 and define a proposed compatibility
  contract separating stable candidates, experimental and legacy interfaces.
- Add `sunset_second_derivative` as an explicit spelling of `sunset_d2`.
  The existing name, arguments, numerical implementation and exceptions remain
  unchanged; neither name denotes a D=2 graph integral.

## 0.3.0a5 — author metadata and documentation

- Correct the author credit to **Reet** in package metadata, citations and the
  documentation, matching the maintainer's README correction.
- Make README links work on PyPI as well as GitHub; reconcile benchmark
  statements with the retained 0.3.0a4 measurements.
- Correct precision-setting notation, argument descriptions and grammar;
  update test counts, review status and the sunset continuation roadmap.
- Remove draft writing advice and promotional wording from user documentation.
  Keep mathematical references, limitations and original review records.
- Numerical code and algorithms are unchanged from 0.3.0a4.

## 0.3.0a4 — research alpha

- Address all six nonblocking findings in the supplementary review of 0.3.0a2;
  retain the original report and its scope with the release evidence.
- Make audit and benchmark reports work from source archives without Git,
  using source SHA-256 hashes as the binding provenance identifiers.
- Replace ambiguous numerical “certified” claims with precision checks and
  explain the dimension-independent zero in the sunset Gamma families.
- Publish measured default-budget coverage at 10, 20 and 30 digits, with
  accurate values and typed budget refusals reported separately.
- Validate product benchmarks against a separate Gaussian Fourier/angular
  representation, then regenerate the accuracy-checked measurements.
- Standardize package and citation author metadata; the name was corrected
  in 0.3.0a5.
- Numerical algorithms and documented domains are unchanged from 0.3.0a2.

## 0.3.0a3 — replacement TestPyPI release

- Restore TestPyPI availability after the earlier releases were accidentally
  deleted. A new version is required because deleted filenames cannot be reused.
- Use `publish.yml` and the protected `pypi` environment for TestPyPI uploads,
  matching the replacement trusted publisher. Manual uploads target only
  TestPyPI and require full validation and an installation check.
- Authentication diagnostics now select PyPI or TestPyPI explicitly and report
  allowlisted rejection codes without exposing credentials.
- Numerical algorithms are unchanged from 0.3.0a2. Review and production PyPI publication were pending at preparation time.

## 0.3.0a2 — historical TestPyPI rehearsal (files subsequently deleted)

- Fixed browser startup by loading Pyodide's compiled NumPy before importing
  the package, including custom dependency-wheel configurations.
- Added browser examples for graph-derived sunset RMT and equal-mass Taylor
  evaluation, and real Chromium checks for examples, references and reset.
- Added a reproducible 30-digit comparison with three mpmath quadrature
  methods, raw timings, source hashes and explicit accuracy failures.
  Historical one-loop timings are labelled separately; unsupported broad
  rankings were removed.
- Added production publisher authentication preflight without upload, plus
  an installation check outside the checkout after production publication.
- Refreshed candidate metadata and the independent-parameter audit. External
  scientific review remains pending; automated validation is not peer review.

## 0.3.0a1 — TestPyPI rehearsal (not published to production PyPI)

### Equal-mass continuation and release preparation
- Added a separate D=2 equal-mass transformed Taylor series for vacuum and
  finite Euclidean momentum, with an analytic tail bound and precision control
  for the unstable coefficient recurrence. RMT calls retain their own domains.
- Added a reproducible independent-parameter audit, capability table, scientific
  review packet, research notebook and contribution instructions.
- Publication now depends on tests, numerical audit, docs/notebook checks and
  installed wheel/sdist checks across Linux, Windows and macOS. Added a manual
  TestPyPI rehearsal. Hosted candidate checks passed; external review and
  publication remain pending.

### Repository cleanup
- Removed obsolete root scripts, superseded plots/results drafts, generated
  SecDec runs, vendored tools, binaries and downloaded PDFs from the current tree.
- Retained the supported package and compatibility APIs, current examples,
  maintained benchmarks, independent fixtures and reproducible audit report.
- Updated ignore rules and packaging so generated output stays outside version
  control and the source distribution contains the maintained reproduction files.
- Git history is preserved; this cleanup is not a history rewrite.

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
  in LoopTools conventions, checked at the requested precision (evaluation at two
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
  - explicit `error_estimate`.
- B0/C0 cancellation at extreme kinematics (precision checks), C0 ZeroDivisionError at
  regular points, massless D=3 bubble, sunset edge cases, `mellin_numeric` checks.
- Round 3:
  - sunset functions rewritten (scaling, factored Kallen functions, normalised
    and error-checked quadrature, precision checks); accurate at threshold and for
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
