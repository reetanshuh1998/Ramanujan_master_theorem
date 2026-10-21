# Changelog

## 0.2.0

### Added
- `ramanujan_qft.rmt`: `ramanujan_master_theorem`, `mellin_numeric`, `massive_propagator_rmt`.
- `ramanujan_qft.mellin`: `product_integral` with both residue expansions, the
  large-x poles of each factor, convergence control (`SeriesConvergenceError`)
  and pole collisions (logarithmic results). Atlas: exponential, gaussian,
  bessel_j, cosine, sine, inverse_power, gaussian_bessel.
- `ramanujan_qft.one_loop`: `B0` (all masses), `B0_mob`, `C0`, `C0_mob`, `bubble_3d`
  in LoopTools conventions, exact at any precision.
- `ramanujan_qft.sunset`: `sunset_im`, `sunset_subtracted`, `sunset_d2`.
- Test suite (164 tests) with LoopTools 2.16 reference values and independent
  integrations; GitHub Actions workflow; `pyproject.toml`; examples; benchmarks.

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

### Withdrawn (raise `NotImplementedError`; see AUDIT.md)
- `FeynmanMoBSolver.massive_sunset_residue`, `solve_massive_sunset`,
  `solve_graph_polynomials`, `solve_P126`, `solve_triangle3L`,
  `solve_elliptic_kite`, `solve_double_box_inv`.
- `RamanujanContinuationEngine.sunset_real_dispersion`, `evaluate_minkowski_residues`.
- `HypergeometricConvergenceFilter.compute_p126_*`.
- `MoBDynamicEngine.stage_D_dynamic_evaluation` (it returned 0).

### Changed
- Default `precision` of the legacy classes is now 30 (was 100). Results no
  longer depend on it beyond round-off.
- RACE methods raise exceptions instead of returning error strings.
- `matplotlib`, `scipy` and `pySecDec` are no longer runtime dependencies.
