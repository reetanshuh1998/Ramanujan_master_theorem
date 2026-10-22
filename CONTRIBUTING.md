# Contributing

The aim is a reproducible scientific package built around Ramanujan and Mellin
methods. Read [the capability table](docs/CAPABILITIES.md) and
[the release plan](docs/RELEASE_PLAN.md) before proposing extensions.

## Development

```bash
python -m pip install -e ".[test]"
python -m pytest -q -m "not slow"
python -m pytest -q                  # includes slow independent quadrature
python tools/audit_sunset.py --output /tmp/sunset_audit.json
```

On Windows, choose a writable output path instead of `/tmp/sunset_audit.json`.
Release tooling and documentation builds use Python 3.12; the numerical
package supports Python 3.9 and later.

## Scientific changes

Include the integral's normalization and domain, a derivation with primary
references, and an independent numerical or analytic reference. A nonsingular
exponent matrix alone does not establish convergence. Document pole collisions,
error controls and resource limits. Keep distinct evaluation methods visible
in the API and returned diagnostics; do not add silent quadrature fallbacks.

For a bug, provide the smallest reproducing graph or function call, exact input
strings, requested precision, installed version, actual result and independent
expected value with its provenance. Add a regression test when fixing it.

Tests should establish scientific behavior, numerical robustness or public API
contracts. Timing measurements should include hardware/software versions,
precision and a matched accuracy target. Avoid unconditional speed claims.

## Pull requests and releases

Describe the mathematical or numerical problem, resulting behavior, limitations
and validation. The [scientific review packet](docs/SCIENTIFIC_REVIEW.md) lists
open review questions for the new backends. Keep the fixed audit seed and record
source hashes when regenerating benchmark data.

Only maintainers publish releases. The [release checklist](docs/RELEASING.md)
separates local preparation, hosted CI, external scientific review and public
publication. Cite both the software version and the original methods.
