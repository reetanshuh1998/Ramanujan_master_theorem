# Automated Claude review: ramanujan-qft 0.3.0rc1.dev1 development snapshot

> **Automated review, not human peer review.** This report was produced by an
> automated Claude reviewer with a local shell. No human took part in the
> assessment. It may support a decision to proceed to human review or to
> candidate qualification. It does not constitute human scientific approval,
> and it does not authorize stable publication.

## 1. Identity and scope

| | |
|---|---|
| Date | 2026-10-25 |
| Reviewer | Claude Opus 5.5, model identifier `claude-opus-5-5` (Anthropic), running in Claude Code |
| Label | Automated scientific and software review |
| Brief followed | `/home/reet/Ramanujan_master_theorem/docs/CLAUDE_REVIEW_BRIEF.md` (areas A–E) |
| Tools available | Linux shell; Python 3.12.3; pip; mpmath/SymPy/NumPy/SciPy/jsonschema; `git`; read-only `gh` |
| Not available or not used | No browser, no Google Colab, no Python 3.9 interpreter, no Sphinx run, no actionlint, no index upload |

**Files examined in depth:**
- `ramanujan_qft/` modules: `multiloop.py`, `brackets.py`, `sunset_rmt.py`, `sunset_taylor.py`, `explain.py`, the schema `schemas/sunset-rmt-v1.json`, `sunset.py` (alias only), `__init__.py`.
- `tools/`: `audit_stability.py`, `audit_sunset.py`, `prepare_review_packet.py`, `install_from_index.py`, `smoke_release.py`, `check_release_metadata.py`, `check_notebook.py`.
- `tests/`: `test_index_install.py`, `test_report_reproducibility.py`.
- `.github/workflows/`: `validate.yml`, `publish.yml`, `tests.yml`.
- Examples and notebooks: `examples/08_first_calculations.py`, `notebooks/stable_walkthrough.ipynb`.
- Docs: `CAPABILITIES.md`, `API_STABILITY.md`, `STABILITY_AUDIT.md`, `SCIENTIFIC_REVIEW.md`, `RELEASING.md`, `user_guide/{conventions,sunset_rmt,sunset_taylor,explanation}.md`, `getting_started/choose_method.md`.

**Examined by execution only, not line-by-line:** `mellin.py`, `one_loop.py`, `sunset.py` beyond the alias, the legacy `core/solvers/utils` modules, and the remaining test modules.

**Omitted:**
- **Python 3.9 minimum-dependency matrix:** no 3.9 interpreter is available. Hosted CI evidence only (§5.5).
- **Sphinx build and actionlint:** not run.
- **Interactive Colab and browser (Pyodide) checks:** not run.
- **TestPyPI or production upload rehearsal:** not attempted.
- **Literature:** no primary sources were re-read during this review. Derivations are my own (§4), and statements about cited papers are not independently verified here.

**Prior context.** I previously reviewed the frozen 0.3.0a2 source (commit
e74a223). Since then the series evaluators changed only in their error
messages (verified by `git diff e74a223 d998357`). I did not carry that review's
conclusions over. All numerical checks below were re-run against this
snapshot's installed code.

## 2. Reviewed artifact

| Item | Value |
|---|---|
| Package version | `0.3.0rc1.dev1`: a development version, not a frozen rc1. The published baseline is 0.3.0a5 |
| Packet | `/home/reet/ramanujan-stable-development-review` |
| SHA-256 of `SHA256SUMS` | `3ed86502713643a27fb6a85356bf5caf56479261549b1fc265257820237ec731` |
| SHA-256 of `stability-audit.json` | `a8762dc2b836df40807f7aeb3942a64c4f5f3ff05082f12fc24090524a0077a0` |
| Manifest verification | `sha256sum -c SHA256SUMS`: exit 0, **127/127 OK**. The manifest covers every file in the packet; nothing extra, nothing missing |
| Audit source binding | All **22/22** `source_sha256` entries in `stability-audit.json` match `source/` |
| Repository context | `d998357235083d2cb83ca6175245e4ecb46680f1`. Every file in `source/` is byte-identical to that commit. The packet omits `benchmarks/`, `.gitignore`, `requirements.txt` and `setup.py` (see R1). The audit's `base_commit` is `3fed46f`, the parent commit; per the brief this is context only |
| Assessed source | Exactly the files in `source/`, copied unchanged to a separate workspace. The original packet was not modified. The manifest still verifies after the review (§5.1) |

## 3. Findings

**No critical findings.** I found no materially wrong accepted value and no
unsafe upload behaviour.

| ID | Severity | Status | Location | Finding |
|---|---|---|---|---|
| R1 | Major | Confirmed | `tools/prepare_review_packet.py:27`; `tests/test_report_reproducibility.py:7` | The review packet is not self-contained; its prescribed test command fails at collection |
| R2 | Minor | Confirmed | `tools/audit_stability.py:201,228`; `prepare_review_packet.py:17` | The hybrid audit's 100% coverage pass rule depends on which seeds are declared |
| R3 | Minor | Confirmed (static) | `.github/workflows/publish.yml:8,30,65-66`; `validate.yml:75-79`; `docs/RELEASING.md:111` | TestPyPI upload by dispatch is not restricted to a frozen `v*` tag |
| R4 | Minor | Confirmed | `ramanujan_qft/explain.py:34-37`; `examples/08_first_calculations.py:36` | Exported and printed decimals contain digits beyond the requested precision |
| R5 | Minor | Confirmed | `ramanujan_qft/sunset_rmt.py:260,275` | The domain-refusal message reports masses in sorted order, not the caller's edge order |
| R6 | Improvement | — | `tools/audit_stability.py:123`; `tools/audit_sunset.py:122` | Audit reports store values only as rounded decimal strings |
| R7 | Improvement | — | `docs/getting_started/choose_method.md:52` | The Colab statement is phrased as a fact |

### R1. The review packet is not self-contained; its prescribed test command fails

**Severity:** Major, by the brief's definition of "broken supported usage". This
is the frozen reviewer artifact's primary reproduction command. No numerical
value is affected, which is why it is not critical.

**Inputs:** the packet's `REVIEW_REQUEST.md` instructions (`cd source; python -m pip install ".[test]"; python -m pytest -q`) on Python 3.12.3.

| | |
|---|---|
| **Expected** | The suite runs. Commit d998357 is titled "Keep reviewer snapshots self-contained" |
| **Observed** | Exit **2** after 4 s: `ModuleNotFoundError: No module named 'benchmarks'` while collecting `tests/test_report_reproducibility.py`. The collection error aborts the session, so **zero tests run** (`evidence/reproduction/tests.log`) |
| **Cause** | `prepare_review_packet.py:27` copies a fixed folder list `('ramanujan_qft','tools','tests','docs','examples','notebooks','.github')` that omits `benchmarks/`. That module imports `benchmarks.bench_release` |
| **Also missing** | Docs in the packet cite `benchmarks/data/sunset_budgets.json` and other `benchmarks/` reports (`docs/user_guide/sunset_rmt.md:276`, `COMPARISON.md`, `SCIENTIFIC_REVIEW.md`). A packet-only reviewer cannot inspect them |

**Minimal reproduction:**
```bash
cp -a source /tmp/x
cd /tmp/x
python -m pip install '.[test]'
python -m pytest -q   # exit 2
```

**Impact:**
- With only that module ignored, **521 tests pass**.
- The ignored module passes **6/6** when `benchmarks/` is copied from d998357. That is a declared substitution, made outside the packet.
- So the code is fine, but a reviewer following instructions gets no test evidence.
- Hosted CI runs from a full checkout and cannot detect this.

**Proposed fix:**
- Add `benchmarks` (`.py` and `.json`) to the packet folder list.
- Make the builder fail if any test module imports a top-level package that is absent from the packet.

**Regression check:** a test that builds a packet in `tmp_path` and runs `python -m pytest --collect-only -q` inside `source/`, expecting exit 0.

### R2. The hybrid audit's pass rule depends on which seeds are declared

**Severity:** Minor. The documentation already says hybrid coverage is
"empirical fixed-grid coverage, not a confidence level", so no guarantee is
misstated. But `passed` gates packet creation, and its outcome is close to a
coin flip under other seed choices.

**Audit rule:** a hybrid sample passes only if `outcome=='value' and target_met and error_covered`. The audit passes only if all 32 samples (4 graphs × seeds 1729–1736) pass, and `prepare_review_packet.py` refuses failing audits.

**Inputs:** the audit's four graphs, plus five new ones (below). Seeds 1000–1031 (32 per graph), `epsrel=1e-3`, `max_evaluations=4e6`, `strict=False`. All 288 outcomes are retained in `evidence/hybrid_coverage.json`.

| | |
|---|---|
| **Expected, if coverage were reliable** | All samples covered |
| **Accuracy target** | Met in **288/288** samples |
| **Error-estimate coverage** | **285/288**. The three misses are all on the audit's own graphs and all `converged=True` |
| **Miss 1** | D=1 one-loop banana, seed 1011: actual/reported = **1.597** |
| **Miss 2** | Same graph, seed 1010: actual/reported = **1.046** |
| **Miss 3** | D=1 three-loop banana, seed 1004: actual/reported = **1.001** |
| **Audit rule on alternative seed blocks** | Applied to four disjoint 8-seed blocks: **FAIL** on 1000–1007 and 1008–1015, **PASS** on 1016–1023 and 1024–1031 (`evidence/hybrid_rescore.log`) |

**Why this is expected:** a miss rate near 1% per sample is consistent with
`error = max(3·stderr, change, roundoff)` computed from 8 replicates. For a
Student-t with 7 degrees of freedom, P(|t|>3) ≈ 0.02. All 32 samples would then
be covered with probability of roughly 0.5–0.7.

**New stress cases:** all five were fully covered (32/32 each):
- a mass hierarchy (1,1,30);
- high momentum (p² = 2500);
- the D=2 bubble with powers 0.55/0.55 (UV margin 0.1);
- the D=1.5 vacuum sunset;
- the D=2 vacuum sunset with powers (0.55,0.55,1) (margins 0.1).

That last case needed a corrected reference. My first position-space quadrature
disagreed between 20 and 35 digits by 8×10⁻⁵ relative. I did not count it until
re-resolved, with dense breakpoints at 30/45 digits (spread 5.5×10⁻¹⁴); see
`singular_sunset_reference.log`. The other new references were validated
against independent closed forms at unit powers and integer D
(`hybrid_reference_validation.log`).

**Proposed fix:**
- Report coverage as k/n with a Clopper–Pearson interval.
- Gate on `target_met` plus a predeclared coverage threshold, for example a lower bound ≥ 0.85 at n=32.
- Keep listing outliers.
- Optionally, widen the estimator with a t-quantile for the replicate count (t₇,0.995 ≈ 3.5).
- Keep `integrate_graph` experimental.

**Regression check:** run the audit on two disjoint seed sets. Its pass/fail
result should not change because of a single 1–2σ miss.

### R3. TestPyPI upload by dispatch is not restricted to a frozen `v*` tag

**Severity:** Minor. Confirmed by static reading only; I did not execute it. The
risk is limited to TestPyPI, and the procedure documents the right practice.

| | |
|---|---|
| **Expected** | `RELEASING.md:111` and the workflow comment say to dispatch "on a frozen `v*` tag" |
| **Observed** | No job condition checks `github.ref`. `check_release_metadata.py --tag` runs only `if: github.event_name == 'release'` (`validate.yml:75-79`) |
| **Consequence** | `gh workflow run publish.yml --ref <branch> -f operation=testpypi-release` would build and upload whatever version is on that branch, e.g. `0.3.0rc1.dev1`. TestPyPI file names are immutable, so this permanently consumes the version and "rehearses" a non-frozen source |

The rest of the release logic is sound:
- the upload index is fixed per job;
- the install-check index is chosen by event type and cannot cross over;
- production upload happens only on a `release` event, after full validation;
- retries never upload (see §5.6).

**Proposed fix:**
- Add `if: startsWith(github.ref, 'refs/tags/v')` to the `testpypi` job.
- Run `check_release_metadata.py --tag "$GITHUB_REF_NAME"` for dispatch too.

**Regression check:** a workflow-lint test asserting both conditions, plus a dispatch from a branch that is refused before the upload job.

### R4. Exported and printed decimals contain digits beyond the requested precision

**Severity:** Minor (clarity). The exact binary fields are correct; only the
human-readable string invites misreading.

**What happens:** `_diagnostics` exports `decimal=mp.nstr(value, dps+8)` for a
value already rounded to `dps` digits, so the last 8 digits are rounding noise.

**Example:** `examples/08_first_calculations.py` (dps=25):

| | Value |
|---|---|
| Printed | `RMT value: 0.62901670759061414959082725578282` |
| True value | 0.62901670759061414959082725388358… |
| Estimated error printed alongside | 5.2×10⁻²⁷ |

The difference is consistent with that error, so nothing is wrong numerically,
but readers may copy insignificant digits.

**Proposed fix:** export `decimal` at `dps` significant digits, or add an
explicit `significant_digits` field. In the example, print `mp.nstr(value, 25)`.

**Regression check:** assert that the exported decimal has at most `dps` significant digits.

### R5. The domain-refusal message reports masses in sorted order

**Severity:** Minor (diagnostic clarity).

**Input:** edges with squared masses (9,1,4) and p=5.

| | Message |
|---|---|
| `RMTDomainError` | `squared masses=(1, 4, 9)`: sorted |
| Taylor refusal | `(9, 1, 4)`: the caller's order (`evidence/refusal_message_order.log`) |

**Proposed fix:** report the caller's edge order, and the sorted chart order separately if useful.

**Regression check:** assert that the message contains `(9, 1, 4)`.

### R6. Audit reports store values only as rounded decimal strings (improvement)

The audits store `value` as a decimal string of dps+15 or dps+5 digits. When the
error estimate is dominated by the final rounding term, the margin between
actual and reported error can be far below that resolution.

**Example: the `mass_hierarchy` row** (masses² 10⁻¹⁶, 1, 10¹⁶):
- Re-checked from the report strings, it appears uncovered: actual and reported error are both 6.07×10⁻¹⁷ relative.
- Re-computed with exact mpf values, it is covered at dps 15–30. The margin equals the truncation bound, about 10⁻⁴³ absolute (`evidence/mass_hierarchy_margin.log`).

The accounting is sound by the triangle inequality, but independent
re-verification from the report alone is impossible.

**Suggestion:** store the exact binary encoding already used by `explain.py`.

### R7. The Colab statement is phrased as a fact (improvement)

`choose_method.md` says the notebook "also runs in Colab". No hosted Colab
evidence is in the packet, and the next sentence correctly calls a Colab session
"a separate user check". Reword it as "is intended to run in Colab (not yet
verified)". The install cell also pins the mutable branch `stable/01-api-contract`;
this is documented as needing a freeze before qualification.

### Unresolved concerns (not defects)

- **U1.** Analytic continuation in the propagator powers for the momentum chart is argued in the guide but not proven by me. My evidence is that the regulated family sums converge to the finite coefficient along five regulator paths (§4.3), plus agreement of the summed series with an independent reference.
- **U2.** The Python 3.9 minimum-dependency matrix was not reproduced locally. It is green in hosted CI (§5.5).
- **U3.** Browser/Pyodide and Colab behaviour were not tested.

### Earlier findings (0.3.0a2 review), checked in this snapshot

| Finding | Status in this snapshot |
|---|---|
| N1 (git required) | Fixed: `_base_commit` returns `None`, with tests |
| N2 ("certified") | Fixed: now "precision-checked"; no "certified" remains in `README.md`, `docs/index.md` or `COMPARISON.md` |
| N3 (vanishing family) | Fixed: now says the family vanishes "independently of dimension and propagator powers" |
| N4 (default-budget coverage) | Addressed: a measured default-budget table was added (consistent with my measurements) |
| N5 (`base_commit`) | Addressed: `SCIENTIFIC_REVIEW.md:50` |
| N6 (benchmark reference) | Addressed: `triple_reference` is an angular representation with no quadosc |

## 4. Derivation assessment

These are my own derivations; no literature was consulted during this review.

### 4.1 Normalization (area A)

- **Projective formula.** For positive Euclidean propagators and measure d^Dk/π^{D/2} per loop, Schwinger parameters and Gaussian integration give
  I = Γ(A−LD/2)/∏Γ(ν_e) ∫δ(1−Σx) ∏x^{ν−1} U^{A−(L+1)D/2} F^{−(A−LD/2)},
  with F = U·Σx m² + Σ_{2-forests} p_T² ∏x. `multiloop.py:287-304` implements exactly this:
  - `s = A − L·D/2`;
  - `u_power = s − D/2`;
  - the prefactor Γ(s)/∏Γ(ν) via `ramanujan_master_theorem(lambda n: 1, s)` (which is just Γ(s));
  - the F rescaling.
- **Mass inputs** are squared. External momentum vectors enter only through Σp² of each forest component, and vectors with several components work, e.g. p=(12,16).
- **D=2 sunset.** A=3, L=2: the integrand reduces to ∫_Δ 1/F. I confirmed this numerically against a bubble-insertion representation that shares no formula with the package:
  I = ∫₀^∞ dt B(t)/√((t−P)² + m₁²(2t+2P+m₁²)), with B the closed-form D=2 bubble.
  It reproduces 4Cl₂(π/3)/√3 for the equal-mass vacuum, and all committed fixtures to about 10⁻⁵⁰.
- **General-D position space**, Δ_ν(r) = 2/((4π)^{D/2}Γ(ν)) (r/2m)^{ν−D/2} K_{D/2−ν}(mr), reproduces the D=2 and D=1 results at unit powers and was used for fractional D and powers.
- **D=1 banana:** I = π^{(n−1)/2} M/(∏m (M²+p²)), from e^{−m|x|}/(2m) propagators. This matches `audit_stability.py:160` and example 08.
- **D=2 bridge:** the tadpole ∫d²k/π (k²+m²)^{−2} = 1/m² and the bridge factor (p²+m²)^{−2} give 1/(2·5·49), matching `audit_stability.py:166`.
- **Graph polynomials.** U and F from `symanzik()` equal an independent construction (matrix-tree theorem U = ∏x·det L̃(1/x), kinetic term U·pᵀL̃⁻¹p) for five topologies, including a self-loop graph, and for every exported trace (`polys_multiloop.log`, `explain_checks.log`).
- **Sunset bracket rows.** Re-derived from U^{−D/2}e^{−F/U}: ⟨ν_i + k + r_i + (U-monomials containing x_i)⟩ and ⟨D/2 + k + a+b+c⟩. The factor (−1)ⁿ/n! applies to free indices, Γ(−n_b) to bound indices, with 1/|det B| (the Jacobian of the linear change to bound indices), 1/Γ(D/2+k) and 1/∏Γ(ν).
- **Convergence is not claimed from algebra.** The compiler and docs correctly do not treat a nonsingular basis as proof of convergence. Convergence comes from the chart conditions (§4.4).
- **Layers are kept separate:**
  - graph polynomials and brackets: general;
  - formal Gamma families: general, formal;
  - the evaluable series: sunset-specific;
  - the hybrid backend: numerical.
- **Alias.** `sunset_second_derivative` equals `sunset_d2` (identical values at two points, the same refusal at and above threshold, the same signature) and is documented as the 4-D dispersive S''. It is not confusable with the D=2 graph value (`alias_check.log`).

### 4.2 Family selection (area B)

- **Momentum chart.** The Mellin–Barnes kernel ∏Γ(−z_i)Γ(D/2−ν_i−z_i)·Γ(A+Z−D)/Γ(3D/2−A−Z) closes to the right for Σm_i/Q < 1, giving 2³ pole families. These are exactly the mass-index/paired-U-index choices the compiler makes.
- **The all-U family vanishes identically.** At z_i = D/2−ν_i+n_i one has Z = 3D/2−A+N, so 1/Γ(−N) = 0 for any D and powers. I confirmed this in the generated term: the denominator is Γ(−n₀−n₁−n₂).
- **Mass chart:** 4 families. The coordinate-space argument (expand the two lighter K₀ factors and J₀; the absolute series is bounded by a polynomial-logarithmic factor times e^{(m_a+m_b+Q)r}, against K₀(Mr) ~ e^{−Mr}) justifies termwise integration by Tonelli in the strict domain.

### 4.3 Pole limits

I summed the generated regulated families numerically at fixed (n₀,n₁,n₂) and
compared them with `series.coefficient`:
- **Regulator paths:** five, with regulator size 10⁻²⁵: the common shift; distinct shifts (1,2,−3) and (0.7,−1.3,2.9); D = 2+h; and mixed D with distinct shifts.
- **Cases:** unequal masses (1,4,9); equal colliding masses; the mass chart at p=1; the mass-chart vacuum with equal light masses; mixed indices up to (3,0,4).
- **Result:** across **80 comparisons**, the maximum relative difference is **2.4×10⁻²³**, which is O(h). The finite harmonic/logarithmic coefficients are the combined limit, independent of path. Individual families are never evaluated as results.

### 4.4 Domains and tail bound

- **Domain decisions** use integer-square-root rational enclosures of Σ√r. They are rigorous, with no floats.
- **Exact boundaries** are refused. That includes Q = 3 and 2.99999999999999999999 for unit masses, the mass-chart boundary (1,4,16) at Q=1, and the momentum boundary (1,4,9) at p=6.
- **Points just inside a boundary** are accepted, then refused by the work budget with a typed error.
- **The gap and the equal-mass vacuum** raise `RMTDomainError`, with no fallback.
- **Multinomial majorant:** Σ_{|n|=N} W_n rⁿ ≤ (Σ√r_i)^{2N} = ρᴺ holds because a sum of squares is at most the square of the sum.
- **Log-factor bounds:** c(L+H_N)²+d with (3, π²/4) for momentum and (1, π²/12) for mass.
- **Tail formula:** with H_{N+k} ≤ H_N + k/(N+1), the geometric moments give exactly the implemented expression (`sunset_rmt.py:180-184`).
- **What is not rigorous:** the mathematical bound is separate from the arithmetic estimate, the two-precision difference and final rounding. None of these is an interval enclosure, as the docs state.

### 4.5 Taylor chart

- **ODE:** substituting t = −9r/(1−r), f = (1−r)G into the stated Picard–Fuchs equation gives the documented G-equation times (r−1), which is nonzero on [0,1).
- **Recurrence:** coefficient matching (SymPy) gives the stated recurrence exactly.
- **Moments:** recurrence values b₀…b₆ from the Clausen seed equal direct 2-D quadrature of ∫(1−9v)ⁿ/U. At fixed 30 digits they lose about one digit per step, confirming the (−8)ⁿ parasitic mode that the guard digits address.
- **Tail bound:** 0 ≤ I−I_K ≤ b₀rᴷ/m² follows from 0 ≤ b_n ≤ b₀.
- **Seed:** b₀ is confirmed directly as the vacuum integral, so the Laporta–Remiddi factor of 16 is not needed for correctness. I did not consult that paper.

### 4.6 Gaps

- The continuation in powers for the momentum chart (U1).
- No interval or ball arithmetic anywhere. All error estimates are numerical, apart from the analytic tail.

## 5. Execution evidence

All logs are under `/home/reet/ramanujan-stable-development-claude-review/evidence/`.

**Environment** (`reproduction/python-version.txt`, `dependencies.txt`):
- Python 3.12.3 (GCC 13.3.0), Linux 7.0.0-38-generic x86_64;
- mpmath 1.3.0, SymPy 1.14.0, NumPy 2.5.4, SciPy 1.18.1, pytest 9.1.1, jsonschema 4.26.0;
- `pip check`: exit 0.

**Workspace.** I used the session scratchpad instead of the brief's
`mktemp -d /tmp/...`. Both are isolated temporary locations; this one is
session-private.

**Interpreter difference.** The packet's audit used NumPy 1.26.4 and SciPy 1.11.4.
My regenerated audit is nonetheless **bit-identical**: 15/15 series values and
32/32 hybrid samples (`audit_regeneration_comparison.log`).

### 5.1 Reproduction commands from the brief

| Command | Exit | Time | Result |
|---|---|---|---|
| `sha256sum -c SHA256SUMS`, before | 0 | — | 127/127 OK |
| `python -m pip install '.[test]'` | 0 | — | `reproduction/pip-install.log` |
| `python -m pytest -q` | **2** | 4 s | Collection error; 0 tests run (R1). `reproduction/tests.log` |
| `python -m pytest -q --ignore=tests/test_report_reproducibility.py` | 0 | 807 s | **521 passed**, 1 known SciPy QUADPACK roundoff warning. `reproduction/tests-ignore1.log` |
| The ignored module, with `benchmarks/` added from d998357 (declared substitution) | 0 | 12 s | **6 passed**. `reproduction/tests-report-repro-with-benchmarks.log` |
| `tools/audit_sunset.py --output …` | 0 | 30 s | 34/34 PASS |
| `tools/audit_stability.py --output …` | 0 | 34 s | `passed: true`; series `{value 15, domain 4, budget 6}`; hybrid 32/32 |
| `examples/08_first_calculations.py` | 0 | 4 s | `reproduction/example08.log` |
| `tools/check_notebook.py notebooks/stable_walkthrough.ipynb` | 0 | 3 s | 2 code cells passed. The network-install cell is skipped by design; this is not a Colab test |
| `sha256sum -c SHA256SUMS`, after | 0 | — | 127/127 OK; packet unchanged |

### 5.2 Independent sunset references

**Stability-audit cross-check** (`stability_audit_crosscheck.log`):
- Every accepted value in the **packet's** `stability-audit.json`, and in my regenerated copy, agrees with my bubble-insertion reference, which uses neither package code nor the Cheng–Wu reduction.
- The audit's Cheng–Wu references agree with mine to 10⁻⁴⁵–10⁻⁴⁷ relative, and my reference's own two-precision spread is ≤ 10⁻⁵⁵.
- The one row that looked uncovered from report strings is covered with exact values (R6).

**30-digit sweep, 63 inputs** (`sweep30.log`, `sweep_30.json`). The inputs cover:
- both charts, Taylor, and the dominant-mass and equal-mass vacua;
- permutations;
- hierarchies from 10⁻³⁰ to 10¹⁶;
- 20 random unequal-mass points from `random.Random(20261024)`;
- domain and budget refusals.

Results: **40 values, 3 domain refusals, 20 budget refusals.** 36 of the 40 values meet 10⁻³⁰ and lie within the reported error against a resolved reference. The other 4 (`mom_huge_scale`, `mom_tiny_scale`, `taylor_scale_small`, `taylor_scale_big`) are flagged only because **my** reference is not scale-normalized: its own spread there is 2×10⁻⁵ to 5×10⁻⁵, so it is unresolved and is not counted as a pass or a failure. With the scale-normalized reference, all four are covered at 30 digits (`scale_check.log`, below). The 20 budget refusals are typed and expose `.result`. They lie near a chart boundary, consistent with the default-budget table.

**Extreme scales** (`scale_check.log`): squared-mass scales 10⁻¹⁰⁰…10²⁰², and a
600-decade hierarchy (10⁻³⁰⁰, 1, 10³⁰⁰). **6/6** are covered at 30 digits, with
reference spread ≤ 10⁻⁵⁶.

**Adversarial precisions** (`adversarial.log`): dps 10, 15, 60 and 100 on seven
cases, including logarithmic hierarchies of 10⁻⁴⁰ and 10⁻⁶⁰ and ρ = 0.49.
Results: **22 values, all covered**, with actual/reported between 0.035 and 0.78, and 6 typed budget refusals at dps 60/100.

### 5.3 Derivation scripts

| Script | Result |
|---|---|
| `taylor_derivation.py` | ODE transform and recurrence re-derived; moments match |
| `family_limits.py` | 80 comparisons, max relative difference 2.4×10⁻²³ |
| `polys_multiloop.py` | U/F match on 5 topologies; D=2 bubble and sunset hybrid values; `integrate_graph` coverage 10/10 at `epsrel=1e-5`; D=3 and D=4 sunsets refused by UV margins |

### 5.4 Explanation export (area D; `explain_checks.log`, 42/42 PASS)

- **JSON round trip** with global `mp.dps=5` and requested dps=80 is equal, for momentum, mass and mass-vacuum charts.
- **The binary encoding** `(-1)^sign·int(mantissa_hex,16)·2^exponent2` reproduces the evaluator's mpf **exactly**.
- **Exported values** lie within the exported error of the independent reference; e.g. the momentum chart has actual 6.4×10⁻⁸² versus reported 9.5×10⁻⁸².
- **The trace matches the compiler:** U/F equal the independent construction; the matrix, chart and condition match; there are 8 or 4 families; `rho_upper` is at least the true ρ and below 1.
- **Graphs rebuilt** from the exported rational strings reproduce the trace.
- **Schema (Draft 2020-12):**
  - valid for `not_requested`, `converged`, `budget_exceeded` with a partial result, and `budget_exceeded` with `diagnostics: null` (at `max_dps` equal to `dps`);
  - rejects schema version 2, float-valued number fields and unknown keys.
- **Domain refusals** (equal-mass vacuum, gap, exact boundary) raise `RMTDomainError` with no fallback.
- **Symbolic strings** are display strings. My script parsed U/F with `sympify` only to compare them with my own construction. The guide correctly warns against `eval`.
- **Global precision:** 14 success and refusal paths across the one-loop, dispersive, Mellin, RMT, Taylor, explain and hybrid APIs leave global mpmath precision unchanged (`global_precision_check.log`).

### 5.5 Hosted CI (read-only `gh`; context, not candidate qualification)

- `tests` run 40123303036 on d998357 (PR #10, branch `stable/01-api-contract`) succeeded.
- All 14 jobs were green: minimum dependencies (Python 3.9, `constraints-minimum.txt`); tests on 3.9, 3.11 and 3.13; audit-and-docs (including Sphinx); build; six installed-artifact jobs (Linux, macOS and Windows; wheel and sdist); upgrade-from-0.3.0a5 for base and multiloop.
- The `docs` run also succeeded.
- The action references `checkout@v7`, `setup-python@v7`, `upload-artifact@v7` and `download-artifact@v8` therefore resolve. I did not independently confirm their Node.js runtime version.

### 5.6 Release engineering (area E; `artifact_checks.log`)

**Local builds from the packet copy:**

| Check | Result |
|---|---|
| `python -m build` | exit 0 |
| `twine check --strict` | exit 0 |
| Wheel SHA-256 | `f05c5dda…b3ea` |
| sdist SHA-256 | `1cc904b7…4ad1` |

These hashes come from local builds and do not identify any uploaded artifact.

**`tools/smoke_release.py` runs** (all exit 0):
- wheel and sdist, with SciPy blocked;
- the wheel with `--with-multiloop`;
- the wheel with `--upgrade-from 0.3.0a5`, which installs the baseline from production PyPI.

The explanation schema `schemas/sunset-rmt-v1.json` is present in both artifacts.

**Retry policy, by reading** `install_from_index.py` and its tests:
- A retry happens only when the output has exactly pip's two missing-version lines for the exact requirement, with no `WARNING`, `Traceback` or `SSL` lines.
- Timeouts are not retried.
- The index is restricted to PyPI or TestPyPI and fixed for each attempt.
- Nothing is uploaded or rebuilt.
- The smoke check runs once, after installation.

**Versions** in `pyproject.toml`, `__init__.py`, `CITATION.cff` and `docs/citing.md` all read `0.3.0rc1.dev1`; the CHANGELOG labels it "Unreleased".

### 5.7 Not run, timed out or inconclusive

- **Not run:**
  - the Python 3.9 minimum-dependency suite (hosted only);
  - Sphinx and actionlint;
  - browser/Pyodide and interactive Colab;
  - TestPyPI or production upload and hash verification of uploaded files;
  - `tools/audit_sunset_budgets.py`, so the default-budget table was not regenerated. It is consistent with my 0.3.0a2 measurements.
- **Timed out:** none.
- **Inconclusive, then resolved:** the singular-power sunset reference (R2) and the mass-hierarchy string margin (R6).
- **Packet integrity after review:** `sha256sum -c SHA256SUMS` exit 0, 127/127 OK. The packet holds 128 files (the 127 entries plus `SHA256SUMS`) and no `__pycache__`; the original packet was not modified (`reproduction/manifest_check_after.txt`).

## 6. Disposition

**Changes required (R1) before this packet can serve as the reproducible basis
for human review.** I found no blockers in the scientific content within the
reviewed scope:
- all accepted values tested agree with independent references;
- the reported RMT and Taylor error estimates bounded the actual error in every
  case I evaluated with exact values;
- domain and budget refusals keep their types and expose partial results honestly.

R2 and R3 should be fixed before a frozen candidate. R4–R7 are clarity and
reproducibility improvements. "No scientific blockers" is not a guarantee of
correctness.

**API stability recommendations:**

| Status | APIs |
|---|---|
| Suitable to propose as stable, within the documented domains | `integrate_graph_rmt`, `integrate_sunset_taylor`, their result and exception types, `ScalarEdge`/`ScalarGraph`, `sunset_second_derivative`/`sunset_d2` |
| Should remain experimental | `integrate_graph`, `MultiloopResult`, `MultiloopConvergenceError` (statistical errors with about 1% observed under-coverage; R2) |
| Keep as inspectable or provisional research interfaces, as documented | `explain_sunset_rmt`/`sunset_rmt_schema` (provisional schema v1); `compile_sunset_rmt`, `schwinger_brackets`, `symanzik` and the other compiler internals |

## 7. Remaining gates

- **Qualified human scientific review:** not performed by this report.
- **Outside-user feedback** and an **interactive Colab/browser session:** not performed. I have no outside-user feedback, and none is implied.
- **Frozen release candidate:** none exists yet. It needs a freeze, a fresh audit and packet (after R1), and **a TestPyPI rehearsal of that exact candidate**, including verifying the uploaded hashes. A green PR, an older rehearsal or valid publisher configuration does not substitute for this.
- **Final release qualification and production publication** remain with the release owner. This review authorizes neither.
