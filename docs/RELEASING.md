# Research-alpha release checklist

Candidate version: **0.3.0a1**. This is a prepared candidate, not a claim that a
release or upload has occurred. The code remains a scoped research tool.

## Local preparation

- [x] Document the RMT and Taylor derivations, convergence domains and errors.
- [x] Run the fixed-seed numerical audit and record source hashes.
- [x] Prepare a runnable research notebook and contribution instructions.
- [x] Keep `pyproject.toml`, `__version__` and `CITATION.cff` consistent.
- [x] Complete the final candidate artifact checks and record their outcomes.

Local evidence: 440 tests and 19 doctests passed; all 34 fixed-seed audit cases,
six notebook code cells and seven graph/series guide snippets passed. Sphinx,
actionlint, strict Twine checks, and fresh-environment wheel/sdist installs
passed. The full tests emitted one existing SciPy reference-quadrature roundoff
warning. These local results do not substitute for the hosted and external
steps below.

```bash
python -m pip install ".[test]" build twine
python -m pytest -q
python tools/audit_sunset.py --output benchmarks/data/sunset_audit.json
python tools/check_notebook.py notebooks/research_alpha.ipynb
python tools/check_release_metadata.py --tag v0.3.0a1
python -m build --outdir dist .
python -m twine check --strict dist/*
python tools/smoke_release.py --dist dist --format wheel
python tools/smoke_release.py --dist dist --format sdist
```

Use a clean output directory containing one wheel and one source distribution.
The artifact checks create fresh virtual environments outside the checkout and
verify the series APIs without SciPy. The source distribution includes tests,
reference data, audit tooling, documentation and the research notebook.

## Before a public announcement

- [ ] Obtain and record external scientific review in {doc}`SCIENTIFIC_REVIEW`.
- [ ] Commit the candidate and run hosted CI on that exact commit.
- [ ] Verify the Linux, Windows and macOS artifact jobs and supported Python jobs.
- [ ] Review the generated documentation and notebook from the candidate.
- [ ] Confirm the candidate version is unused on each target index; if needed,
  increment it consistently before rebuilding. Never replace a published artifact.
- [ ] Configure the separate `testpypi` trusted publisher/environment and run
  the **manual** TestPyPI rehearsal on the candidate ref.
- [ ] Verify the install-from-TestPyPI job succeeds outside the checkout.
- [ ] Configure the `pypi` trusted publisher/environment, with maintainer review.
- [ ] Approve the concrete candidate, tag `v0.3.0a1`, and publish a prerelease
  with the reviewed notes. This triggers PyPI publication only after validation.

The TestPyPI and PyPI services require separate configuration. Trusted
Publishing setup follows [PyPI's documentation](https://docs.pypi.org/trusted-publishers/using-a-publisher/).
The rehearsal installs dependencies from PyPI and this package with `--no-deps`
from TestPyPI, following the [TestPyPI guide](https://packaging.python.org/en/latest/guides/using-testpypi/).

The reusable `.github/workflows/validate.yml` runs tests, the numerical audit,
notebook and documentation checks, builds the artifacts once, and tests those
artifacts on three operating systems. `publish.yml` depends on all these jobs
and publishes the same artifact bundle. Release tags must match the metadata.
Hosted jobs, account configuration, independent review and uploads cannot be
verified by a local build alone.

## Draft release notes

Version 0.3.0a1 adds exact graph-polynomial and Schwinger bracket compilation,
a hybrid numerical graph evaluator, and justified multivariate Gamma series
for two massive D=2 sunset charts. A separately named equal-mass Taylor backend
adds vacuum and finite Euclidean momentum coverage with an analytic tail bound.

Both series backends return explicit method and error diagnostics and refuse
unmet work budgets. The source includes independent references, a reproducible
audit grid and a notebook demonstrating the overlap between methods.

The mathematical methods are established in the cited literature. The software
contribution is their implementation, graph interface, validation and error
controls. This release does not claim general multiloop RMT evaluation,
epsilon expansions, massless or physical-region series coverage, or rigorous
interval certification. Unequal-mass continuation between the RMT charts remains
open. External-review status must be reported honestly in the announcement.
