# Research-alpha release checklist

Current candidate: **0.3.0a2**. External scientific review remains pending.

Previously rehearsed version: **0.3.0a1**, uploaded to TestPyPI from commit `3b00bd6`.
The [rehearsal](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/39924746748)
passed validation, trusted-publisher upload and installation outside the checkout.
Both published file hashes matched the validated distribution artifacts.
This is a TestPyPI rehearsal; production PyPI publication and external scientific
review remain pending. The code remains a scoped research tool.

The 0.3.0a2 candidate includes the browser fix, current comparison report and
publishing checks. Rehearse its frozen commit on TestPyPI before production
publication; the existing `0.3.0a1` files are immutable. Candidate-specific hosted
results and artifact hashes are recorded in the GitHub candidate release notes.

## Local preparation

- [x] Document the RMT and Taylor derivations, convergence domains and errors.
- [x] Run the fixed-seed numerical audit and record source hashes.
- [x] Prepare a runnable research notebook and contribution instructions.
- [x] Keep `pyproject.toml`, `__version__` and `CITATION.cff` consistent.
- [x] Complete the final candidate artifact checks and record their outcomes.

Local evidence for 0.3.0a2: 443 tests and 19 doctests passed; all 34 fixed-seed audit cases,
six notebook code cells and all 67 documentation examples passed. Sphinx,
actionlint, strict Twine checks, and fresh-environment wheel/sdist installs
passed. The full tests emitted one existing SciPy reference-quadrature roundoff
warning. These local results do not substitute for the hosted and external
steps below.

```bash
python -m pip install ".[test]" build twine
python -m pytest -q
python tools/audit_sunset.py --output benchmarks/data/sunset_audit.json
python tools/check_notebook.py notebooks/research_alpha.ipynb
python tools/check_doc_snippets.py docs
python tools/check_release_metadata.py --tag v0.3.0a2
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
- [x] Run hosted CI on the rehearsed `3b00bd6` candidate.
- [x] Verify its Linux, Windows and macOS artifacts and supported Python jobs.
- [ ] Freeze the final candidate/version and rerun validation on that exact commit.
- [ ] Review the generated documentation and notebook from the candidate.
- [ ] Confirm the candidate version is unused on each target index; if needed,
  increment it consistently before rebuilding. Never replace a published artifact.
- [x] Configure the separate `testpypi` trusted publisher/environment and run
  the **manual** TestPyPI rehearsal on the candidate ref.
- [x] Verify the rehearsed install-from-TestPyPI job succeeds outside the checkout.
- [ ] Rehearse the final candidate on TestPyPI if its artifacts have changed.
- [x] Pass real-browser startup, example, numerical-reference and reset checks
  on merged browser-fix commit `73ee2b7`; CI repeats these for the new candidate.
- [ ] Configure the `pypi` trusted publisher/environment, with maintainer review.
- [ ] Approve the concrete candidate, tag its matching version, and publish a prerelease
  with the reviewed notes. This triggers PyPI publication only after validation.

The TestPyPI and PyPI services require separate configuration. Trusted
Publishing setup follows [PyPI's documentation](https://docs.pypi.org/trusted-publishers/using-a-publisher/).
The rehearsal installs dependencies from PyPI and this package with `--no-deps`
from TestPyPI, following the [TestPyPI guide](https://packaging.python.org/en/latest/guides/using-testpypi/).

The reusable `.github/workflows/validate.yml` runs tests, the numerical audit,
notebook and documentation checks, builds the artifacts once, and tests those
artifacts on three operating systems. `publish.yml` depends on all these jobs
and publishes the same artifact bundle. Release tags must match the metadata.
JavaScript actions use Node.js 24 runtimes, including the nested artifact
upload in the Pages composite action. When updating action versions, inspect
their `action.yml` runtime and nested actions as well as their release notes.
Hosted jobs, account configuration, independent review and uploads cannot be
verified by a local build alone.

## Production authentication preflight

After merging and freezing the candidate, dispatch `publish.yml` on its `v*` tag.
The `publisher-preflight` job uses the existing protected `pypi` environment and
checks whether PyPI accepts that workflow identity. The manual-dispatch path
cannot upload a distribution. PyPI can activate a pending publisher and create
its empty project during token exchange; this is publishing setup, not a release.
A release publication is a separate trigger.
Credentials stay in memory and are not logged or stored as artifacts.

For a new project, the account owner must configure a
[pending publisher](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/)
on **production** PyPI with these exact values:

| Field | Value |
|---|---|
| Project | `ramanujan-qft` |
| Owner | `reetanshuh1998` |
| Repository | `Ramanujan_master_theorem` |
| Workflow | `publish.yml` |
| Environment | `pypi` |

GitHub environment configuration and TestPyPI authentication do not establish
production PyPI trust. The preflight uses the documented
[OIDC exchange](https://docs.pypi.org/trusted-publishers/using-a-publisher/), an
implementation-specific interface; actual uploads still use the supported
PyPA publishing action. After publication, the production workflow installs
that exact version from PyPI and runs the smoke check outside the checkout.

## Trust and first-use checks

- An independent reviewer should examine normalization, convergence regions,
  collision limits and error estimates, with findings tied to a source commit.
  Automated tests do not substitute for this review.
- Keep the method visible in examples: RACE for Mellin products, RMT scale plus
  numerical sectors for general graph input, and the specific sunset RMT/Taylor
  series. Do not describe statistical or arithmetic estimates as interval proofs.
- Demonstrate graph input, a justified method, the result/error diagnostics and
  an independent reference. Exercise both successful calculations and useful
  domain/budget refusals in the notebook and browser console.
- Keep installation and scope documentation consistent with the released
  version. The production `pip install ramanujan-qft` command should be advertised
  as available only after the production upload and a fresh install succeed.
- Publish the candidate's audit, known limitations, change log and instructions
  for reporting a numerical error, including graph, conventions and precision.

## Draft release notes

Version 0.3.0a2 includes exact graph-polynomial and Schwinger bracket compilation,
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
