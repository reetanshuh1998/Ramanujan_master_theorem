# API stability and compatibility

This is the **proposed contract for 0.3.0**, under development after 0.3.0a5.
The interfaces below are candidates for stability, subject to the validation
and release gates in {doc}`STABLE_RELEASE_PLAN`. No new stable release is
announced by this page.

Stability concerns how callers use a function and interpret its result.
Supported mathematical domains and error guarantees are specified separately
in {doc}`CAPABILITIES`; the contract does not broaden those domains.

## Interfaces targeted for stability

Use explicit imports from `ramanujan_qft` or the documented defining module.
These names and their existing arguments are the proposed compatibility surface:

| Group | Interfaces | Contract |
|---|---|---|
| Basic RMT | `ramanujan_master_theorem`, `mellin_numeric`, `massive_propagator_rmt` | Scalar mpmath result; theorem hypotheses remain the caller's responsibility |
| Mellin products | `product_integral`; factories `exponential`, `gaussian`, `bessel_j`, `cosine`, `sine`, `inverse_power`, `gaussian_bessel`; `SeriesConvergenceError` | Factory-created factors, scalar result or `(value, info)` when `return_info=True` |
| Scalar one-loop | `B0`, `B0_mob`, `C0`, `C0_mob`, `bubble_3d` | Existing scalar return types, LoopTools conventions and documented kinematic restrictions |
| Dispersive sunset | `sunset_threshold`, `sunset_im`, `sunset_subtracted`, `sunset_d2`, `sunset_second_derivative` | Four-dimensional sunset combinations; derivative names refer to the same calculation |
| Graph input | `ScalarEdge`, `ScalarGraph`; graph attributes `edges`, `vertices`, `external_momenta`, `loops` | Connected graphs, ordered edges, positive squared masses/powers and exactly conserved Euclidean momenta |
| D=2 sunset evaluation | `integrate_graph_rmt`, `integrate_sunset_taylor`; `RMTSeriesResult`, `SunsetTaylorResult`; `RMTDomainError`, `RMTSeriesConvergenceError`, `SunsetTaylorConvergenceError` | Explicitly chosen method, documented convergence domains, result attributes and typed refusals |

`MellinFunction` remains importable as the type returned by atlas factories.
Calling a factory-created factor as `factor(x)` is supported. Its constructor,
`build`, `tail` and internal pole data are extension machinery, outside the
stable contract. Use the factories rather than constructing private Mellin data.

`sunset_second_derivative(s, m1sq, m2sq, m3sq, dps=None)` is the clearer spelling
introduced during this development cycle. `sunset_d2` remains supported without
a deprecation warning. Both compute S''(s) below threshold in the existing
four-dimensional dispersive convention. For a D=2 integral, use one of the
explicit graph evaluators. The new spelling is not in the published 0.3.0a5.

## Experimental and legacy interfaces

The hybrid `integrate_graph`, `MultiloopResult` and
`MultiloopConvergenceError` remain experimental. Their current float64 and
statistical-error behavior is documented, but their interfaces may evolve with
validation and sector improvements. Changes must be described in release notes.

Exact graph algebra and series compilation are inspectable research interfaces:
`ScalarGraph.symanzik`, `ScalarGraph.uv_margins`, `schwinger_brackets`,
`BracketSystem`, `BracketSolution`, `compile_sunset_rmt`, `SunsetRMTSeries`,
`compile_sunset_taylor` and `SunsetTaylorSeries`. Their symbolic expressions,
family ordering and dataclass layouts are not frozen. `explain_sunset_rmt` and
`sunset_rmt_schema` provide a separate, provisional version 1 JSON export; see
{doc}`user_guide/explanation`. Its schema does not freeze compiler internals.

The version 0.1 classes and modules under `core`, `solvers` and `utils` retain
their documented compatibility behavior; see {doc}`api/legacy`. Withdrawn
methods continue to raise `NotImplementedError`. They are not the recommended
interface for new work. An importable symbol is not automatically a stable API;
underscore-prefixed helpers and incidental module imports are internal.

## Inputs and conventions

- Feynman mass parameters named `msq`, `m1sq`, etc., and edge `mass_squared`
  are **squared masses**. Atlas parameters have their own documented meaning;
  for example, `inverse_power(m, v)` means `(x + m)**(-v)`.
- One-loop and dispersive sunset functions use their documented Minkowski
  signs, branches and normalization. Graph functions use positive Euclidean
  propagators and `d^D k / pi^(D/2)` per loop. No automatic conversion is implied.
- Preserve documented positional arguments and keyword names. A `dps` request
  concerns decimal precision and numerical checks, not a proof of correctness.
  `sunset_threshold` uses the current mpmath context rather than a `dps` argument.
- Exact decimal inputs should be strings. Passing a binary float cannot restore
  decimal digits already lost before the call. Precision checks must not leave
  a changed global mpmath precision behind.
- An explicitly requested RMT or Taylor calculation never silently becomes a
  hybrid numerical calculation. Optional analytic continuation of Mellin products
  requires `continuation=True`; it need not represent a convergent integral.

## Results and diagnostics

Scalar routines retain mpmath results rather than introducing a common wrapper.
The graph series retain result objects. Read their attributes by name; their
positional constructors, textual representation and pickled form are not a
serialization contract.

| Result | Attributes callers may rely on |
|---|---|
| `product_integral(..., return_info=True)` | Tuple `(value, info)`; `info` contains `method`, `error_estimate`, `terms`, `working_dps` |
| `RMTSeriesResult` | `value`, `error_estimate`, `truncation_bound`, `terms`, `shells`, `working_dps`, `chart`, `convergence_ratio`, `converged`, `method` |
| `SunsetTaylorResult` | `value`, `error_estimate`, `truncation_bound`, `terms`, `working_dps`, `convergence_ratio`, `converged`, `method` |

`chart` identifies `momentum` or `mass` in the current RMT evaluator. `method`
is explanatory text: display it, but do not parse its wording for control flow.
Additional diagnostic keys or attributes may be added; callers should tolerate
them. Numerical values, work counts and working precision can change as accuracy
or efficiency improves. Compatibility does not promise identical floating-point
bits, identical timings or identical automatic chart selection.

`truncation_bound` bounds the mathematical series tail with the documented
working-precision qualifications. `error_estimate` also includes estimated
arithmetic effects. Neither provides a full interval-arithmetic enclosure.
The experimental hybrid diagnostics have statistical meanings described in
{doc}`user_guide/multiloop`; they must not be treated as series tail bounds.

## Exceptions

Catch documented types, not exact message strings. The following distinctions
are retained; the function-specific reference documents individual cases:

| Condition | Handling |
|---|---|
| Invalid numeric inputs or a divergent requested Mellin integral | `ValueError` |
| Wrong graph object passed to a graph series evaluator | `TypeError` |
| Unsupported series topology, dimension, propagator powers or Taylor mass pattern | `NotImplementedError` |
| Supported RMT topology outside all implemented convergence charts | `RMTDomainError`, a `ValueError` subclass |
| Mellin series cannot reach its target | `SeriesConvergenceError`, an `ArithmeticError` subclass |
| RMT/Taylor work or precision budget exhausted | `RMTSeriesConvergenceError` / `SunsetTaylorConvergenceError`, both `ArithmeticError` subclasses |
| Scalar quadrature or precision agreement fails | `ArithmeticError` |

RMT/Taylor convergence exceptions expose `.result`, which can be `None` when
no partial evaluation was possible. A partial result is not a successful return;
inspect its diagnostics and do not assume that it meets the requested tolerance.
The experimental hybrid convergence exception likewise carries its estimate.
Some invalid work-budget inputs raise `ValueError` before evaluation.

## Change policy for the stable line

Once 0.3.0 is released, compatible 0.3.x changes may add optional keyword
arguments, diagnostics or supported inputs while preserving existing calls and
meanings. Existing argument defaults are part of the contract. A bug fix may
correct a value, error estimate or previously unsafe acceptance; it must be
explained in the changelog and accompanied by a regression against a reference.
Never preserve a known wrong answer for compatibility.

An incompatible rename or removal of a stable interface requires a documented
migration path and a `DeprecationWarning` for at least two released versions
and at least 90 days, whichever is longer, before removal in a later minor or
major line. Urgent correctness restrictions may take effect immediately with
an explicit release note. No such removal is scheduled for `sunset_d2`.

The compatibility tests retain the baseline calling signatures, required result
fields and exception relationships. Existing numerical tests establish the
mathematical behavior; these contract tests do not replace them. Changes to the
baseline require a review of this policy and the migration notes.
