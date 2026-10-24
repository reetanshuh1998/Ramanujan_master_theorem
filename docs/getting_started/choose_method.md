# Choose a method and check your first result

Start with the graph, dimension and kinematics. The choice determines the
normalization, available precision and meaning of an error estimate.
These are distinct methods; selecting RMT never silently invokes quadrature.

| Input and purpose | Method | Precision and limits |
|---|---|---|
| Named scalar one-loop B0 or the restricted C0(0,0,s) | `B0`, `C0` | mpmath, requested `dps`; LoopTools conventions; see {doc}`/user_guide/one_loop` |
| Unit-power, positive-mass D=2 sunset; Q > m1+m2+m3 or M > ma+mb+Q | `integrate_graph_rmt`, or `explain_sunset_rmt` for the derivation | Arbitrary precision, analytic series tail bound plus estimated arithmetic error |
| Unit-power, equal-positive-mass D=2 sunset at finite Euclidean Q | `integrate_sunset_taylor` | Separate transformed Taylor method, arbitrary precision within explicit budgets |
| Other connected massive Euclidean scalar graphs with positive powers and convergent UV subgraphs | `integrate_graph` | Experimental RMT scale integration plus numerical sectors; float64/statistical errors; SciPy required |
| D=4 sunset discontinuity or subtracted dispersive combinations | `sunset_im`, `sunset_subtracted`, `sunset_second_derivative` | Named quantities in their documented dispersive normalization; not the D=2 graph value |
| UV-divergent graphs, regulator expansions, general tensor numerators or physical-region multiloop continuation | No general supported evaluator | Do not reinterpret a refused or partial result as a value |

Here Q is the magnitude of the Euclidean external momentum; m and M are
masses. **API mass arguments are squared masses.** See
{doc}`/user_guide/conventions` before comparing values from different programs.
Use exact decimal strings for input precision beyond ordinary floats.

For series, `dps` requests decimal digits; work limits can still stop an otherwise
valid calculation. Read the typed exception and increase the named budget only
when you can afford the work. A larger budget cannot fix an invalid domain.
For the hybrid method, use `epsrel`/`epsabs` and inspect statistical diagnostics;
requesting tiny tolerances does not turn float64 into arbitrary precision.

## Three complete calculations

The development walkthrough uses features introduced after 0.3.0a5. From this
source checkout install `pip install '.[multiloop]'`, then run
`python examples/08_first_calculations.py`.
It checks a one-loop value against a Feynman-parameter integral, a two-loop RMT
series against a separately computed simplex reference, and a three-loop hybrid
graph against a Fourier-convolution formula. Each comparison uses the same
normalization on both sides. The frozen simplex reference is reproducible with
`tools/generate_sunset_rmt_references.py`.

```{literalinclude} ../../examples/08_first_calculations.py
:language: python
:lines: 8-
```

The RMT trace is described in {doc}`/user_guide/explanation`. An expected refusal
is included because the equal-mass vacuum is finite but outside the implemented
RMT charts; the separate Taylor method covers that point.
The hybrid assertion checks one declared seed, not a universal statistical
coverage guarantee; the wider audit is in {doc}`/STABILITY_AUDIT`.

Run the same code by selecting **Three reference-checked calculations** on
{doc}`/try_it`. That example downloads SciPy on first use.
The development [notebook](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/stable/01-api-contract/notebooks/stable_walkthrough.ipynb)
also runs in [Colab](https://colab.research.google.com/github/reetanshuh1998/Ramanujan_master_theorem/blob/stable/01-api-contract/notebooks/stable_walkthrough.ipynb).
Its installation cell selects this development branch, not the published alpha;
freeze that reference to the candidate tag before release qualification.
Notebook calculation cells are checked locally and in CI. An interactive
Google-hosted Colab session is a separate user check.
