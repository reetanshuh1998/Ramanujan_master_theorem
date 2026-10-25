# Claude review brief for the stable-release development snapshot

Use this brief for an additional **automated scientific and software review**.
Claude's report can identify errors and help a human reviewer, but it does not
complete the qualified human scientific review, outside-user feedback or release
rehearsal required by the stable-release plan.

The target is development version **0.3.0rc1.dev1**, not a frozen 0.3.0rc1 release
candidate. The published baseline remains 0.3.0a5. No release is authorized by
this review request.

## Material to give Claude

For Claude with local file access, provide this document and the packet path:

`/home/reet/ramanujan-stable-development-review`

The packet contains `source/`, `stability-audit.json`, `REVIEW_REQUEST.md` and
`SHA256SUMS`. Source preparation was completed on repository commit
`d998357235083d2cb83ca6175245e4ecb46680f1`. The packet's manifest and audit source
hashes identify the actual reviewed files; a commit name alone is insufficient.
The audit's `base_commit` is context, not a substitute for those hashes.

If Claude cannot access local files, supply the packet through the file interface
available in your Claude session. If only selected files fit, require the report
to list the omitted material and narrow its conclusions accordingly. Do not
claim execution of tests in a chat session without an execution environment.

Use the actual model name/version shown by the service in the report. Do not
invent a model version or describe the assessment as human peer review.

## Prompt to paste into Claude

Copy the following text as the review request:

```text
Review the ramanujan-qft development snapshot independently and critically.
Your task is to find reproducible scientific, numerical, API or release-engineering
faults before a stable release. Do not assume the existing tests or earlier
review establish correctness. Do not merely summarize the documentation.

Target package version: 0.3.0rc1.dev1.
Snapshot: /home/reet/ramanujan-stable-development-review
Repository context: d998357235083d2cb83ca6175245e4ecb46680f1

First read this brief, the packet's REVIEW_REQUEST.md and SHA256SUMS, and verify
the manifest. Record the SHA-256 of the manifest itself and of stability-audit.json.
Check that every source hash in the audit matches the corresponding source file.
If files are missing or hashes disagree, report the mismatch and stop treating
this as a review of the named snapshot. Never silently substitute current main,
an installed PyPI package or an older review packet.

Preserve the packet and original reports. Work in a separate copy. Write findings,
new reproduction scripts and logs outside the original packet. Do not modify the
library or tests to make checks pass. Propose fixes in the report; implementation
and re-review are separate steps. Do not publish, tag, merge, upload packages,
change publisher settings or request credentials.

Review the five areas A–E below. Prioritize scientific correctness and reproducible
counterexamples over style. Distinguish mathematical derivations, numerical
agreement and empirical statistical coverage. State which claims you could not
verify and why. Existing tests passing is evidence, not a proof.

Reproduce the provided evidence where your tools permit, then design additional
checks that could falsify the claims. Use independent representations where
possible, state shared dependencies, and verify reference precision separately.
Do not use the evaluator's own coefficient formula as its independent reference.
For new random experiments, declare seeds and budgets and retain all outcomes.

Return a complete report using the format below. Record actual commands, exit
codes, versions, logs and inputs. Never invent execution results, literature
citations, human participation, Colab use or an index rehearsal. If you cannot
execute code, label the report a static review and leave execution unverified.

Save the report as:
/home/reet/ramanujan-stable-development-claude-review/CLAUDE_REVIEW_REPORT.md
Use a new sibling directory if that directory already contains an earlier report.
If filesystem access is unavailable, return the Markdown report in the chat.

Identify yourself accurately as an automated Claude reviewer. A favorable result
may support proceeding to human review or candidate qualification; it is not
human scientific approval and does not by itself authorize stable publication.
```

## A. Normalization, graph algebra and scope

Read `docs/CAPABILITIES.md`, `docs/API_STABILITY.md`,
`docs/user_guide/conventions.md`, `ramanujan_qft/multiloop.py` and
`ramanujan_qft/brackets.py`.

- Derive the Schwinger/projective normalization from positive Euclidean
  propagators with measure `d^D k / pi^(D/2)` per loop. Check squared-mass
  inputs, conserved external vectors, propagator powers and Gamma factors.
- Independently reconstruct sunset U/F polynomials and exponent constraints.
  Check exact basis solutions and the meaning of the determinant factor.
- Separate general graph-polynomial/bracket construction, formal Gamma families,
  the topology-specific evaluable sunset series and hybrid sector integration.
  An invertible matrix must not be presented as proof of convergence.
- Check that the four-dimensional dispersive `sunset_second_derivative` alias
  retains `sunset_d2` behavior and cannot be mistaken for the D=2 graph integral.

## B. Sunset series, pole collisions and error estimates

Read `docs/user_guide/sunset_rmt.md`, `docs/user_guide/sunset_taylor.md`,
`ramanujan_qft/sunset_rmt.py`, `ramanujan_qft/sunset_taylor.py` and their tests.

- Reconstruct the contour/family-selection argument, including reciprocal Gamma
  zeros. Verify the combined regulator limit, mixed-index coefficients and
  unequal-mass terms. Individual divergent families are not evaluable results.
- Check the sufficient RMT domains `Q > m1+m2+m3` and `M > ma+mb+Q`, with Q a
  Euclidean momentum magnitude and m/M physical masses. Verify exact rational
  domain decisions, strict boundaries and refusal of the intervening gap.
- Check the analytic shell-tail majorant and its implementation. Distinguish the
  mathematical tail bound from floating-point arithmetic estimates and from a
  rigorous interval enclosure. Test cancellation, extreme scales and precision
  limits without interpreting an unresolved reference as a pass.
- Derive the equal-mass Taylor recurrence and seed normalization independently.
  Check the growing recurrence mode, guard digits, truncation estimate and
  precision/term-budget failures. Keep Taylor continuation distinct from RMT.
- Cover both RMT charts, dominant-mass vacuum, equal-mass vacuum via Taylor,
  mass permutations, overlap, scaling, near-boundary inputs and colliding poles.
  Verify that refusals preserve their types and expose partial values honestly.

## C. Independent references and hybrid statistics

Read `docs/STABILITY_AUDIT.md`, `docs/SCIENTIFIC_REVIEW.md`,
`tools/audit_stability.py`, `tools/audit_sunset.py`,
`tests/data/sunset_rmt_reference.json` and the associated audit tests.

- Re-derive the Cheng–Wu reference reduction and compare at least selected
  values with a separate simplex representation or another justified reference.
  Record precision changes and reference uncertainty; agreement at two
  precisions is not a rigorous error bound.
- Verify accepted values, domain refusals, budget failures and unresolved
  references remain distinct. Examine whether the audit can falsely pass when
  an estimate is too small or a reference is unreliable.
- Check the D=1 Fourier-convolution banana formulas and factorized D=2 bridge
  normalization against the hybrid implementation's conventions.
- Inspect repeated-seed coverage, adaptive stopping and evaluation caps. Retain
  outliers. The supplied 32/32 coverage result is only a finite-grid observation,
  not a universal confidence guarantee. Keep the hybrid API experimental.

## D. Explanation export and first-use experience

Read `ramanujan_qft/explain.py`, its bundled JSON schema,
`tests/test_explain.py`, `docs/user_guide/explanation.md`,
`docs/getting_started/choose_method.md` and `examples/08_first_calculations.py`.

- Verify that the trace matches the compiler's polynomials, constraints, selected
  families, pole limit, normalization and convergence condition.
- Check JSON round trips at high precision with a low global mpmath precision.
  Confirm the exact binary number encoding and explicit provenance. Exported
  symbolic strings must not be treated as safe executable input.
- Check compile-only, converged and budget-exceeded states, including a missing
  partial result. Ensure domain failures never silently invoke another method.
- Run the shared notebook/example code and examine installation instructions,
  optional SciPy use and actionable refusals. Check every comparison uses the
  same normalization and reports the appropriate diagnostics.
- Local notebook execution is not an interactive Google Colab test. Report
  actual browser/Colab use separately; do not fabricate outside-user feedback.

## E. Release engineering and remaining gates

Read `.github/workflows/validate.yml`, `.github/workflows/publish.yml`,
`tools/install_from_index.py`, `tools/smoke_release.py`, their tests,
`docs/RELEASING.md` and `docs/STABLE_RELEASE_PLAN.md`.

- Examine bounded retries: only the requested missing version may be retried.
  Other install errors and smoke failures must remain visible; no retry should
  upload or replace artifacts or switch between PyPI and TestPyPI.
- Check the minimum-dependency matrix, clean wheel/sdist installation, baseline
  upgrade and optional-dependency coverage. Check legacy imports and inclusion
  of the explanation schema in installed packages.
- Check version/citation consistency, the distinction between this development
  version and a frozen candidate, and continued use of Node.js 24 actions.
- Review workflow logic statically. A successful older release, a green PR or
  valid publisher configuration does not establish a new candidate rehearsal.
  Leave final TestPyPI upload/hash verification and production publication
  pending unless separately performed and documented by the release owner.

## Reproduction workspace

These commands are for Claude with a local shell. They preserve the original
packet and keep installations, generated reports and logs in a separate directory.
The full scientific suite includes slow quadratures; record timeouts rather than
weakening tests or reporting unfinished checks as passed.

```bash
PACKET=/home/reet/ramanujan-stable-development-review
cd "$PACKET"
sha256sum -c SHA256SUMS
sha256sum SHA256SUMS stability-audit.json

REVIEW_WORK=$(mktemp -d /tmp/ramanujan-claude-review.XXXXXX)
cp -a "$PACKET/source" "$REVIEW_WORK/source"
python3 -m venv "$REVIEW_WORK/venv"
. "$REVIEW_WORK/venv/bin/activate"
cd "$REVIEW_WORK/source"
python -m pip install '.[test]'
python -VV > "$REVIEW_WORK/python-version.txt" 2>&1
python -m pip freeze > "$REVIEW_WORK/dependencies.txt"
python -m pip check
python -m pytest -q > "$REVIEW_WORK/tests.log" 2>&1
python tools/audit_sunset.py --output "$REVIEW_WORK/sunset-audit.json"
python tools/audit_stability.py --output "$REVIEW_WORK/stability-audit.json"
python examples/08_first_calculations.py
python tools/check_notebook.py notebooks/stable_walkthrough.ipynb
```

Use Python 3.12 for the documented reproduction environment, or record any
interpreter difference explicitly. Check each command's exit status; a later
successful command does not erase an earlier failure. The notebook checker skips
its network installation branch; artifact installation and hosted Colab require
separate evidence. New numerical reproduction scripts should use this same
isolated environment and retain their exact inputs and outputs.

The original manifest must still verify after the review. Do not overwrite
`stability-audit.json` in the supplied packet with a newly generated report.

## Required report format

Use these sections in `CLAUDE_REVIEW_REPORT.md`:

1. **Identity and scope:** date, actual model identifier, automated-review label,
   available tools, files examined, omitted areas and execution limitations.
2. **Reviewed artifact:** package version, repository context, manifest/report
   SHA-256 values, verification result and the precise source under assessment.
3. **Findings first:** one entry per issue with a stable ID, severity, file/line
   or equation, exact inputs, expected versus observed behavior, minimal
   reproduction, scientific impact, proposed correction and regression check.
   Distinguish confirmed defects, unresolved concerns and improvements.
4. **Derivation assessment:** normalization, family selection, pole limits,
   convergence and tail bounds. Explain the reasoning and any independent
   sources actually consulted; identify gaps even if numerical tests pass.
5. **Execution evidence:** commands, environment, exit codes, runtime, log paths,
   reference precision, requested tolerance, observed differences, estimates and
   refusal outcomes. List not-run, timed-out and inconclusive checks explicitly.
6. **Disposition:** recommend changes required, no blockers found within the
   reviewed scope, or inconclusive. “No blockers found” is not a correctness
   guarantee. Identify which APIs should remain experimental.
7. **Remaining gates:** human scientific review, actual outside-user/Colab
   feedback, frozen-candidate TestPyPI rehearsal and final release qualification.

Severity should reflect impact: critical for materially wrong accepted values or
unsafe release behavior; major for unsupported scientific guarantees, incorrect
domain acceptance or broken supported usage; minor for nonblocking clarity and
usability problems. Explain each severity instead of inferring it from a label.

## After the report

Keep the original report and evidence unchanged. Record each finding's disposition
and implement corrections in a separate change. Re-run affected checks, generate
fresh source-bound evidence after numerical changes, and obtain follow-up review
on the corrected snapshot. Do not carry approval from the old source to changed
files without identifying the delta.

A Claude report is one input to qualification. The release owner still needs the
human assessment and user feedback specified in the plan, followed by a rehearsal
of the actual frozen candidate. See {doc}`STABLE_RELEASE_PLAN` for the gate status.
