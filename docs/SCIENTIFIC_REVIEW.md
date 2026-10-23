# Scientific review packet

Status: implementation checks are automated; external scientific review is
pending. This document does not claim peer review or an independent human audit.

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
the base git commit and numerical-library versions, and reports actual versus
estimated error. Source hashes identify uncommitted implementation changes too.
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

The refreshed 0.3.0a2 report records 34 passing cases: 27 evaluations, three expected
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

## External review record

The release preparation also adds an accuracy-checked product benchmark against
three quadrature methods. This comparison is separate from the sunset scientific
audit and does not extend its domain or establish scientific independence.
The candidate remains unsuitable for a claim of completed external review until
an identified reviewer supplies findings on the frozen source below.

- Reviewer: pending.
- Reviewed source hashes/release commit: pending.
- Findings and resolutions: pending.
- Recommendation for public research-alpha release: pending.
