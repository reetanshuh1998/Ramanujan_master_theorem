# Inspect and export an RMT calculation

`explain_sunset_rmt` is a development interface introduced after 0.3.0a5.
It exposes the derivation for the supported massive, unit-power D=2 sunset.
It does not compile arbitrary multiloop topologies into convergent series.
The version 1 export format is provisional until release qualification.

## From graph to series

Mass inputs are squared masses. The measure is `d^D k / pi^(D/2)` per loop,
with positive Euclidean propagators. This example has Q=10 and m1=m2=m3=1,
so the momentum chart satisfies Q > m1+m2+m3.

```python
import json
from ramanujan_qft import ScalarEdge, ScalarGraph, explain_sunset_rmt

graph = ScalarGraph([ScalarEdge(0, 1, 1)] * 3, {0: [10], 1: [-10]})
trace = explain_sunset_rmt(graph, evaluate=True, dps=30)
assert trace['schema_version'] == 1
assert trace['evaluation']['status'] == 'converged'
print('U =', trace['polynomials']['U'])
print('F =', trace['polynomials']['F'])
print('Chart:', trace['convergence']['chart'])
print('Condition:', trace['convergence']['condition'])
print('Value:', trace['evaluation']['diagnostics']['value']['decimal'])
payload = json.dumps(trace, indent=2, allow_nan=False)
assert json.loads(payload) == trace
```

Omit `evaluate=True` to inspect the series without summing it. The trace includes:

- Exact U/F polynomials, exponent matrix, offsets and normalization.
- The selected bracket families, their determinants, solved indices and Gamma
  expressions. These remain **formal regulated families** individually.
- The common summation indices and finite coefficient after combining families
  and resolving the regulator limit. Never evaluate a single divergent family
  as if it were the result.
- The selected chart, edge mass ordering and exact rational upper bound on its
  convergence ratio. The proof uses this bound, not matrix invertibility.
- Optional value, tail bound, arithmetic-inclusive error estimate, work counts
  and requested/working precision. An error estimate is not an interval enclosure.
- Package/dependency versions and hashes of the implementation files used for
  the explanation. These hashes identify source, not an independent review.

The derivation is in {doc}`sunset_rmt`. Existing regression tests compare the
regulated Gamma sums with the finite coefficients and independent reference
integrals. Export tests check that the trace describes that same compiler.

## Encoding and schema

The result contains ordinary JSON objects, arrays, strings, integers, booleans
and nulls; it uses no binary floating-point JSON numbers. Exact algebraic
expressions are display strings. **Do not load them using `eval` or unrestricted
symbolic parsing.** Numeric graph input strings are rationals and can be used to
rebuild `ScalarGraph` through its normal validated inputs.

Each mpmath number has a readable `decimal` and an exact binary encoding:

`(-1)**sign * int(mantissa_hex, 16) * 2**exponent2`.

The decimal string is for display; the binary fields preserve every stored bit,
including precision above the caller's global mpmath context. Hexadecimal avoids
Python's decimal integer string-length limit. The encoding is not a statement
that the computed number equals the mathematical integral exactly.

`sunset_rmt_schema()` returns a fresh copy of the bundled JSON Schema, draft
2020-12. Install the package's `test` extra to run the optional schema validator:

```python
from jsonschema import Draft202012Validator
from ramanujan_qft import sunset_rmt_schema
Draft202012Validator(sunset_rmt_schema()).validate(trace)
```

Schema version and package version are separate. Do not assume future schema
versions preserve field layouts; reject unknown versions in downstream readers.
Vertex labels are normalized to integers; edge order and exact momentum values
are preserved. Symbolic family ordering is descriptive rather than a stable
choice of basis.

## Refusals remain visible

Unsupported graphs and domains raise the compiler's normal exceptions. There
is no numerical fallback. An evaluation budget failure is exported as
`budget_exceeded`, with an exception message and any available partial result:

```python
limited = explain_sunset_rmt(graph, evaluate=True, max_shells=1)
assert limited['evaluation']['status'] == 'budget_exceeded'
assert not limited['evaluation']['diagnostics']['converged']
print(limited['evaluation']['exception'])
```

A partial value is not an accepted result. `diagnostics` can be null when the
precision limit prevented even a first summation. `not_requested` means only
that compilation was requested; it does not claim numerical convergence.
