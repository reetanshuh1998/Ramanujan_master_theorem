# Legacy interface (version 0.1)

The classes of version 0.1 are still importable, so that existing scripts keep
running. New code should use the functions documented in the other API pages.

Methods that compute a validated integral now delegate to those functions.
Methods whose 0.1 implementation did not compute the integral they named
(placeholder constants, misclassified diagrams, silent zeros) now raise
`NotImplementedError` with an explanation. `AUDIT.md` in the repository lists
each case, and the {doc}`changelog </changelog>` gives the history.

## `FeynmanMoBSolver`

`from ramanujan_qft import FeynmanMoBSolver` (module
`ramanujan_qft.solvers.feynman_mob_solver`); `FeynmanMoBSolver(precision=30)`.

| method | now |
|---|---|
| `solve_B0_standard(psq, msq, return_pole=True)` | equal-mass `B0` with `delta = -gamma_E` (the 0.1 convention: LoopTools' value shifted by $-\gamma_E$); returns `(1, finite)` when `return_pole` |
| `solve_C0_standard(psq, msq)` | `C0` (if `msq` is a list of three masses) or `C0_mob` |
| `solve_massive_bubble(v1=1, v2=1, s=None, m1_sq=None, m2_sq=None)` | `bubble_3d`; other propagator powers raise |
| `solve_massive_propagator(m2, D=3)` | `massive_propagator_rmt` |
| `solve_bessel_exp_product(a, b)` | `product_integral(exponential(a), bessel_j(0, b))` |
| `solve_bracket_integral(a_matrix, c_vector, phi_funcs)` | Method-of-Brackets rule E2 for a square bracket system |
| `massive_sunset_residue`, `solve_massive_sunset`, `solve_graph_polynomials`, `solve_P126`, `solve_triangle3L`, `solve_elliptic_kite`, `solve_double_box_inv` | raise `NotImplementedError` |

## `RamanujanContinuationEngine`

`from ramanujan_qft import RamanujanContinuationEngine` (module
`ramanujan_qft.utils.ramanujan_continuation`); `RamanujanContinuationEngine(precision=30)`.

| method | now |
|---|---|
| `hypergeom_continuation_2F1(a, b, c, z)` | ${}_2F_1(a,b;c;z+i0)$ for real $z>1$ by the $1/z$ transformation ($a-b$ not an integer) |
| `algebraic_continuation_Li2(z)` | $\mathrm{Li}_2(z+i0)$ |
| `phase_space_3body(s, m1sq, m2sq, m3sq)` | `sunset_im` (version 0.1 had the prefactor $\pi/(16s)$ with the wrong sign, 16 times too small) |
| `sunset_real_dispersion`, `evaluate_minkowski_residues` | raise `NotImplementedError`; use `sunset_subtracted` |

## Other modules

`ramanujan_qft.core.ramanujan_framework`
: `AnalyticalConvolutionEngine.solve_product(comp1, comp2, s_target=1.0)` takes
  dictionaries such as `{"type": "exponential", "params": {"k": 3}}` and calls
  `product_integral`. `TripleProductEngine.solve_trio_benchmark(k, a, b, nu=1)` is
  `product_integral(exponential(k), gaussian_bessel(a, b, nu))`. Failures raise
  exceptions instead of returning error strings.

`ramanujan_qft.core.dispersion_mob`
: `DispersionMoBEngine`, a generic subtracted dispersion relation for a
  user-supplied imaginary part and subtraction constants.

`ramanujan_qft.core.mob_dynamic_engine`
: `MoBDynamicEngine` analyses the bracket system of a Feynman-parameter
  integral (stages A to C). The multi-series summation (stage D) is not
  implemented, so it raises `NotImplementedError` instead of returning a value.

`ramanujan_qft.utils.mob_convergence_filter`
: `HypergeometricConvergenceFilter`, convergence tests and sums of
  hypergeometric-type series. Its `compute_p126_*` methods raise
  `NotImplementedError`.
