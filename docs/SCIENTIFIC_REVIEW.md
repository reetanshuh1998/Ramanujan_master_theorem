# Scientific review packet

Status: a supplementary automated review of the frozen 0.3.0a2 source
recommended approval within the documented scope and found no release blockers.
Its six nonblocking corrections are addressed in 0.3.0a4 below. This is not
human peer review or a proof of correctness.

## Review scope

Review the unit-power massive D=2 sunset in the positive Euclidean normalization
$d^2k\,d^2\ell/\pi^2$. The reusable bracket compiler produces formal candidates;
the proven series selection and collision limits are specific to the sunset.

| Component | Derivation | Implementation | Independent evidence |
|---|---|---|---|
| Bracket constraints and Gamma families | [RMT guide](user_guide/sunset_rmt.md) | `ramanujan_qft/brackets.py` | exact constraints, nonsingularity refusals, regulated pole-limit tests |
| Momentum and dominant-mass RMT charts | [RMT guide](user_guide/sunset_rmt.md) | `ramanujan_qft/sunset_rmt.py` | 40/55-digit nested parameter references, sector comparisons |
| Equal-mass Euclidean continuation | [Taylor guide](user_guide/sunset_taylor.md) | `ramanujan_qft/sunset_taylor.py` | Clausen vacuum, independent parameter integral, overlap with RMT |

## Questions for the reviewer

1. Are the loop normalization, Euclidean signs and squared-mass conventions
   consistent between graph polynomials, Mellin-Barnes formulas and references?
2. Does the momentum-chart contour argument justify the selected pole families
   and the continuation in propagator powers? Check the reciprocal Gamma zero.
3. Do the coalesced harmonic coefficients follow from the complete regulated
   family sum, including mixed-index terms and unequal masses?
4. Are the stated convergence regions sufficient, and are the tail bounds valid
   for all accepted inputs, including near-boundary cases?
5. Does the transformed Taylor recurrence follow from the stated ODE and seed?
   Check the factor of 16 relative to Laporta–Remiddi's D=2 normalization.
6. Are the arithmetic estimates conservative enough in practice? Neither backend
   provides rigorous interval enclosures. Check error propagation and budget
   refusals under cancellation and extreme scaling.

## Reproduce the numerical audit

```bash
python -m pip install ".[test]"
python -m pytest -q tests/test_sunset_rmt.py tests/test_sunset_taylor.py tests/test_sunset_audit.py
python tools/audit_sunset.py --output benchmarks/data/sunset_audit.json
```

The audit uses fixed random seed 1729, records package-source SHA-256 hashes,
numerical-library versions and actual versus estimated error. The per-file
SHA-256 hashes are the binding identifiers for the evaluated sources.
`base_commit` is optional checkout context: it can predate the commit containing
the report and is `null` in a source archive or when Git is unavailable. It does
not identify uncommitted changes; the source hashes do.
Timings are descriptive measurements on the executing machine, not promises.

The reference is obtained from the projective parameter integral by setting
$x+y=1$, $a=x(1-x)$, $A=m_1^2x+m_2^2(1-x)$ and integrating $z$ analytically:

$$F=m_3^2z^2+Bz+C,\quad B=A+m_3^2a+p_E^2a,\quad C=aA.$$

With $\Delta=B^2-4m_3^2C\ge0$, the remaining integrand is

$$\int_0^\infty\frac{dz}{F}
=\frac{2\operatorname{asinh}(\sqrt\Delta/(2\sqrt{m_3^2C}))}{\sqrt\Delta},$$

with limit $2/B$ at $\Delta=0$. A one-dimensional quadrature at two precisions
provides the reference. Separate tests compare this reference with the existing
nested two-dimensional simplex fixtures. These checks share the underlying
integral but do not share the series formulas, recurrence or Clausen seed.

Precision agreement is evidence, not a rigorous reference enclosure. The report
includes the measured difference and a numerical allowance. Domain refusals
and budget exhaustion are counted separately from successful evaluations.

## Findings from the local audit

The refreshed 0.3.0a4 report records 34 passing cases: 27 evaluations, three expected
domain refusals and four expected budget refusals. Its source hashes match the
candidate numerical code. This is a bounded local audit, not a claim of
exhaustive domain coverage.

- The first fixed-precision run failed the reference check for squared masses
  `(1e-16, 1, 1e16)`. The 35- and 50-digit quadratures disagreed; this was not
  accepted as evidence of a backend error or as a valid reference.
- The reference driver now increases precision within a bounded schedule,
  records both working precisions, and requires eight more relative digits
  than the requested result. An unresolved reference still fails the audit.
- The equal-mass forward recurrence is unstable at fixed low precision. Its
  growing mode is covered by extra guard digits, propagated arithmetic error,
  two-precision agreement, and an explicit precision-budget regression test.

## Review record and corrections

The original [automated review report](https://github.com/reetanshuh1998/Ramanujan_master_theorem/releases/download/v0.3.0a4/INDEPENDENT_REVIEW_REPORT.md)
is retained unchanged with the release evidence. It identifies its reviewer,
methods and limitations. It reviewed commit
`e74a2233913f4e0c9f6a319e305c0cfc908fe251` (0.3.0a2), dated 2026-10-24,
and recommended **approval within the documented scope**, with no blockers.
Report SHA-256: `fb1a1fe3014341ecce48c474fd39ace2976aa20dcc7dec3103ed2f2e8ea8e8cf`.

Numerical calculations are unchanged since that reviewed candidate; public
API docstrings now describe precision checks without implying interval proofs.
The later release tooling and documentation have separate regression and
artifact checks; the report does not constitute review of those later edits.
A qualified human scientific review remains welcome. No human peer-review
claim is made for this research alpha.

| Finding | Correction in 0.3.0a4 | Evidence |
|---|---|---|
| N1: reports fail outside Git | Optional `base_commit`, including absent Git | Regression tests and complete report generation from an archive without `.git` |
| N2: ambiguous numerical guarantees | Use “precision-checked”; explain precision agreement and its limits | README, API and user guides |
| N3: vanishing family | Explain the dimension-independent reciprocal Gamma zero | Sunset RMT derivation |
| N4: practical budget coverage | Measured 10/20/30-digit grid at default budgets; report refusals separately | `benchmarks/data/sunset_budgets.json` and RMT guide |
| N5: report provenance | Source hashes bind the evaluated files; commit is optional context | This page and comparison guide |
| N6: benchmark reference independence | Gaussian Fourier/angular representation replaces the timed oscillatory method as reference | Two-precision reference agreement, cross-representation tests and refreshed raw timings |

The product benchmark is separate from the sunset audit. Its new reference
uses a different integral representation; it shares mpmath arithmetic with the
evaluators, so agreement still does not establish a rigorous interval enclosure.
