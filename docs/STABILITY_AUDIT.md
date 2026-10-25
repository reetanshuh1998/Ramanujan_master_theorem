# Stability audit and scientific review

The expanded audit supplements the released 34-case sunset audit. It is an
explicit finite grid, not a proof of correctness over an entire domain.
The original review and released reports remain unchanged.

## Reproduce

```bash
python -m pip install ".[test]"
python tools/audit_stability.py --output /tmp/stability-audit.json
python tools/prepare_review_packet.py --audit /tmp/stability-audit.json --output /tmp/stability-review
```

Choose writable paths on your platform. The review directory must not already
exist. Packet creation rejects failed audits and source hashes that no longer
match; rerun the audit after numerical source changes. The packet copies the
source and tests, records hashes and supplies review questions. It does not
perform or claim a human review.

## Declared grid

`tools/audit_stability.py` declares exact string inputs and fixed budgets:

- All six mass permutations of an unequal-mass momentum-chart sunset.
- A nearer-boundary momentum point, a dominant-mass point and vacuum,
  and a squared-mass hierarchy from 1e-16 to 1e16.
- Equal-mass vacuum by Taylor, RMT/Taylor overlap at Euclidean Q=6, and
  homogeneity under squared-mass scales 1e-40 and 1e40.
- Exact boundaries, points just outside and just inside them, the chart gap,
  and separate term/shell and precision-budget refusals.

The unit propagator powers exercise the analytically coalesced Gamma families;
the existing RMT tests additionally compare coefficients with regulated pole
limits. This grid does not test arbitrary powers or claim new convergence charts.

Eight separate invariant comparisons check permutations, scaling and method
overlap. These are useful checks but share evaluators; they are not independent
reference methods.

The hybrid grid contains D=1 banana graphs at one, two and three loops and a
factorized D=2 two-loop bridge graph, each with seeds 1729–1736. References
come from Fourier convolution or factorization, not the sampled Hepp sectors.
The requested relative tolerance is 0.001, with a four-million-evaluation cap.
For D=1, physical masses m_i and momentum Q give

`pi**((n-1)/2) * sum(m_i) / (prod(m_i) * (sum(m_i)**2 + Q**2))`.

The bridge reference is the product of two convergent tadpoles and its squared
bridge propagator. The formulas also appear in independent regression tests.

## Acceptance and limitations

Every successful series value is compared with the independent Cheng–Wu
parameter integral at increased precision. The reference search is bounded,
and requires agreement eight decimal digits beyond the requested precision.
Unresolved references fail the audit. Reference agreement is not a rigorous
interval enclosure.

Reports distinguish absolute error, relative error (undefined at zero),
reference uncertainty, reported error, error-estimate coverage and requested
accuracy. Budget and domain refusals have separate outcomes. Unexpected
exceptions and uncovered errors fail rather than disappearing from the report.

In schema version 2, hybrid accuracy and coverage are separate: `passed` requires
resolved references, accepted evaluations and the accuracy target, while
`hybrid_coverage_requires_review` records any coverage miss or failed evaluation.
Every outlier remains in `hybrid_outliers`, with its graph, seed and error ratio;
failed evaluations appear separately in `hybrid_failures`. Packet creation does
not resolve coverage alerts or promote the experimental hybrid API.

Hybrid coverage is reported as covered/assessed counts, both overall and per
graph. A single statistical miss does not become a series-accuracy failure.
No arbitrary coverage threshold or nominal binomial confidence interval is used
for this heterogeneous, fixed-graph grid. The evaluator's estimate is unchanged.
The supplementary Claude review observed three coverage misses across 288
samples while all accuracy targets passed; see {doc}`REVIEW_DISPOSITION`.

For a reproducible additional seed block, run:

```bash
python tools/audit_stability.py --seed-start 1000 --seed-count 32 --output /tmp/extended-stability-audit.json
```

Hybrid coverage is reported for all declared samples, with named outliers.
It is not a confidence level for adaptive stopping or a guarantee for arbitrary
graphs. No outlier is removed by choosing a favorable seed. The hybrid interface
remains experimental even if this grid passes.

## Review status

Human scientific review remains pending. The existing supplementary review is
recorded in {doc}`SCIENTIFIC_REVIEW`. The frozen packet is ready for a reviewer
after the final development audit passes. Findings must identify the audited
source, and any blocker must be resolved or keep the affected API experimental.

For a Claude-assisted review of the prepared development snapshot, use
{doc}`CLAUDE_REVIEW_BRIEF`. It defines the evidence and report requirements and
keeps automated assessment separate from the pending human review.

## Exact audit numbers

Schema version 2 of both sunset audit reports adds `exact` fields containing
`sign`, hexadecimal `mantissa_hex` and integer `exponent2`. Reconstruct each
finite value as `(-1)**sign * int(mantissa_hex, 16) * 2**exponent2`, using exact
rational arithmetic or sufficient precision. These fields preserve the stored
value, reference, uncertainty, errors and comparison allowance. Display decimals
alone can obscure a small positive coverage margin. Exact storage does not make
the underlying reference or arithmetic estimates rigorous enclosures.
