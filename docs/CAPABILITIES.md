# Supported calculations and error guarantees

The beta prerelease scope is explicit below. General multiloop RMT
evaluation remains a research objective. Inputs are squared masses; the graph
APIs use positive Euclidean propagators and $d^Dk/\pi^{D/2}$ per loop.
The proposed stable-versus-experimental interface classification is in
{doc}`API_STABILITY`; work toward the next release is in {doc}`STABLE_RELEASE_PLAN`.

| API | Supported calculation | Method | Error information |
|---|---|---|---|
| `ramanujan_master_theorem` | User-supplied coefficient continuation; theorem hypotheses are the caller's responsibility | $\Gamma(s)\varphi(-s)$ | Arithmetic precision; no automatic proof of theorem hypotheses |
| `product_integral` | Products from the documented Mellin atlas in accepted domains | Mellin residue summation | Convergence checks, tail/error estimates and cancellation control |
| `B0`, `C0`, `bubble_3d` | Named scalar one-loop functions; `C0` has two lightlike external legs | Analytic functions and numerical evaluation | Working-precision agreement; independent regression data |
| `sunset_im`, `sunset_subtracted`, `sunset_d2` | Specified scheme-independent four-dimensional sunset combinations | Phase-space and dispersion integration | Precision and quadrature checks |
| `integrate_graph` | UV-convergent massive Euclidean scalar graphs, positive powers and dimension, bounded enumeration | RMT for the common scale; numerical Hepp sectors | Float64 statistical diagnostics; no deterministic error enclosure |
| `schwinger_brackets` | Exact Schwinger bracket algebra for `ScalarGraph` | Formal exponent matrices and Gamma-family candidates | Exact linear algebra; no convergence certificate or generic evaluator |
| `integrate_graph_rmt` | Massive unit-power D=2 sunset; $Q>m_1+m_2+m_3$ or $M>m_a+m_b+Q$ | Generated multivariate Gamma series with analytic pole limits | Analytic truncation bound, arithmetic estimates and precision agreement |
| `integrate_sunset_taylor` | Equal-mass unit-power D=2 sunset at finite Euclidean momentum, subject to budgets | Transformed Taylor series from an ODE and a Clausen boundary value | Analytic truncation bound, recurrence-error estimates and precision agreement |

The original `one_loop` and `sunset` APIs use LoopTools-style Minkowski
conventions, unlike the graph APIs. See {doc}`user_guide/conventions` before
comparing signs or normalizations. `sunset_d2` means a second derivative in
the existing four-dimensional API; it does **not** mean dimension D=2.

## Selecting a sunset evaluator

- Equal masses at zero or low Euclidean momentum: `integrate_sunset_taylor`.
- A justified RMT chart: `compile_sunset_rmt` exposes the matrix and Gamma
  families; `integrate_graph_rmt` evaluates them.
- Unequal masses outside both RMT charts: the hybrid `integrate_graph` may
  supply a statistical numerical reference. There is no automatic fallback.

An RMT boundary is a series boundary, not necessarily a singularity of the
Euclidean integral. The equal-mass Taylor method crosses the RMT boundary
$Q=3m$ and overlaps the momentum chart. Large momenta may make its Taylor
series too expensive; choose the RMT chart explicitly in that case.

## What each error quantity means

| Quantity | Meaning | What it does not establish |
|---|---|---|
| `truncation_bound` in the series APIs | Analytic bound on the omitted mathematical series, evaluated with guard precision | A rigorous interval enclosure including all floating-point operations |
| `error_estimate` in the series APIs | Tail plus estimated arithmetic loss, precision disagreement and final rounding | A formal proof of every reported digit |
| `error_estimate` in `integrate_graph` | Statistical diagnostics, refinement changes and a roundoff floor | A guaranteed bound or fixed confidence level after adaptive stopping |
| Agreement at two precisions | Evidence against unresolved arithmetic cancellation | Evidence that the underlying formula, branch or normalization is correct |

`RMTDomainError` refuses an unsupported RMT chart. `RMTSeriesConvergenceError`,
`SunsetTaylorConvergenceError` and `MultiloopConvergenceError` report unmet
budgets or tolerances and carry partial results when available. Refusals are
part of the contract. A small sequence of terms is not a convergence proof.

## Coverage still open

The series backends do not implement unequal-mass continuation between the
RMT charts, non-unit powers, epsilon expansions, overlapping-divergence
subtraction, massless limits, tensor numerators or physical-region continuation.
Topology-independent family selection and convergence proofs are also open.

The sunset backends have numerical audit evidence and a supplementary
automated review with its findings addressed; see {doc}`SCIENTIFIC_REVIEW`.
This is not human peer review. Historical audits of other APIs do not transfer
automatically to these methods.
