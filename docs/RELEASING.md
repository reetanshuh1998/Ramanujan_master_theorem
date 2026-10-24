# Research-alpha release record and checklist

Released: **[0.3.0a4](https://pypi.org/project/ramanujan-qft/0.3.0a4/)**
on 2026-10-24, correcting the six nonblocking review findings.
Numerical algorithms are unchanged from the reviewed 0.3.0a2 source. See
{doc}`SCIENTIFIC_REVIEW` for the review scope, original report and dispositions.

The [0.3.0a3 restoration](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/40006767164)
passed full validation, TestPyPI upload, hash verification and installation
outside the checkout. It remains available; the earlier a1/a2 files were deleted.

The replacement TestPyPI publisher authorizes `publish.yml`, environment `pypi`.
Production PyPI separately accepted that identity in the
[authentication preflight](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/40056000753).
The frozen `ca31a681ccd60e03883dcf16fbc13ba3dbe2bfee` candidate passed the
[final TestPyPI rehearsal](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/40056460397)
and the [production release workflow](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/40057042071),
including validation, uploads and fresh index installations outside the checkout.
Published wheel/sdist hashes were checked against each workflow's validated
artifacts. The [release assets](https://github.com/reetanshuh1998/Ramanujan_master_theorem/releases/tag/v0.3.0a4)
retain the verification records, source archive, review report and dispositions.

## Metadata correction for 0.3.0a5

Version 0.3.0a5 corrects the author credit to **Reet** and updates documentation.
The numerical algorithms are unchanged. It must pass the same validation,
TestPyPI upload and fresh-install checks before production publication.
The records above and completed checklist below refer to 0.3.0a4.

## Local preparation

- [x] Document the RMT and Taylor derivations, convergence domains and errors.
- [x] Run the fixed-seed numerical audit and record source hashes.
- [x] Prepare a runnable research notebook and contribution instructions.
- [x] Keep `pyproject.toml`, `__version__` and `CITATION.cff` consistent.
- [x] Complete the final candidate artifact checks and record their outcomes.

Local evidence for 0.3.0a4: 455 tests and 19 doctests passed; all 34 fixed-seed audit cases,
the 18-point default-budget grid, six notebook code cells and all 67
documentation examples passed. Sphinx,
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
python tools/check_release_metadata.py --tag v0.3.0a5
python -m build --outdir dist .
python -m twine check --strict dist/*
python tools/smoke_release.py --dist dist --format wheel
python tools/smoke_release.py --dist dist --format sdist
```

Use a clean output directory containing one wheel and one source distribution.
The artifact checks create fresh virtual environments outside the checkout and
verify the series APIs without SciPy. The source distribution includes tests,
reference data, audit tooling, documentation and the research notebook.

## Completed release gates for 0.3.0a4

- [x] Record the supplementary review and its limitations in {doc}`SCIENTIFIC_REVIEW`.
- [x] Address the six nonblocking review corrections. Human peer review remains welcome.
- [x] Run hosted CI on the frozen `ca31a68` candidate.
- [x] Verify its Linux, Windows and macOS artifacts and supported Python jobs.
- [x] Freeze the final candidate/version and rerun validation on that exact commit.
- [x] Review the generated documentation and notebook from the candidate.
- [x] Confirm the candidate version is unused on each target index; if needed,
  increment it consistently before rebuilding. Never replace a published artifact.
- [x] Configure the separate TestPyPI publisher (`publish.yml`, environment `pypi`) and run
  the **manual** TestPyPI rehearsal on the candidate ref.
- [x] Verify the rehearsed install-from-TestPyPI job succeeds outside the checkout.
- [x] Rehearse the final candidate on TestPyPI if its artifacts have changed.
- [x] Pass real-browser startup, example, numerical-reference and reset checks
  on the final candidate in [the documentation run](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/40056453265).
- [x] Verify the production `pypi` trusted publisher/environment through authentication.
- [x] Approve the concrete candidate, tag its matching version, and publish a prerelease
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

## Authentication and TestPyPI upload

Dispatch `publish.yml` on a frozen `v*` tag. The default operation is
`authenticate`, with `index=pypi` or `index=testpypi`. Authentication uploads no
files. PyPI can activate a pending publisher and create its empty project during
token exchange. Credentials remain in memory and are not logged or archived.

For each new release, use an unused version and freeze its matching tag.
For the 0.3.0a5 correction:

```bash
gh workflow run publish.yml --ref v0.3.0a5 -f operation=testpypi-release -f index=testpypi
```

`testpypi-release` always uploads to `https://test.pypi.org/legacy/`, regardless
of the authentication-only `index` input. It uses the protected `pypi`
environment because that is the name in the configured replacement TestPyPI
publisher. The workflow builds once, validates the resulting artifacts and
installs the uploaded version outside the checkout. The separate production
upload job runs only when a GitHub release is published, after full validation.

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
  version. The production `pip install --pre ramanujan-qft` command should be advertised
  as available only after the production upload and a fresh install succeed.
- Publish the candidate's audit, known limitations, change log and instructions
  for reporting a numerical error, including graph, conventions and precision.

## Released scope

Version 0.3.0a4 includes exact graph-polynomial and Schwinger bracket compilation,
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
open. The supplementary review and its limitations are recorded in the review packet.
