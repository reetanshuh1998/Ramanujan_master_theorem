# Pre-release audit (October 2026)

This file records what was checked before making the repository public, how it
was checked, what was found, and what was changed. Every number below can be
reproduced with the scripts in `tests/` and `benchmarks/`.

## How the code was checked

* **LoopTools 2.16** (the vendored copy, built with gfortran) as the reference
  for one-loop integrals: values in `tests/data/looptools_reference.csv`.
* **Independent integrations** written from first principles: Feynman-parameter
  integrals with the inner integration done analytically (mpmath), and 2-D
  Feynman-parameter integrals for the two-loop sunset (SciPy).
* **Several working precisions** (15, 30, 50/60 digits). A correct method must
  give the same answer at every precision.
* **A clean install** of the package outside the repository, in a fresh venv.

## Findings in version 0.1 and their status

| # | Component | Finding | Evidence | Status in 0.2 |
|---|-----------|---------|----------|---------------|
| 1 | Packaging | `import ramanujan_qft` failed after installation: `core/ramanujan_framework.py` imported `feynman_atlas`, a file in the repository root that is not part of the package. | `ModuleNotFoundError: feynman_atlas` in a clean environment | **Fixed.** `pyproject.toml` added; clean venv install tested |
| 2 | `solve_B0_standard`, equal-mass `solve_C0_standard` above threshold | A hard-coded regulator `delta = 1e-30` combined with the precision setting gave correct values only for `precision >= 50`. At 30 digits B0(1;1,1) returned -0.375 instead of -0.391, and C0(0,0,5;1,1,1) was off by 0.11. At 15 digits it crashed with "gamma function pole". | `tests/test_legacy_api.py`, `tests/test_one_loop.py` | **Fixed.** Exact closed forms, correct at every precision |
| 3 | `solve_B0_standard` convention | The finite part differs from LoopTools by exactly -γ_E (RAF -0.39102 vs LoopTools +0.18620 at p²=1). The README stated a perfect match with LoopTools. | LoopTools run | **Documented.** The legacy method keeps its convention; the new `one_loop.B0` uses LoopTools conventions |
| 4 | Unequal-mass C0 | **Correct.** Matches LoopTools and the independent integration to working precision, including degenerate masses. | `tests/test_one_loop.py` | Kept (moved to `one_loop.C0`) |
| 5 | `massive_sunset_residue`, Euclidean branch | Integrated `F/U^3` over the simplex. That is not the sunset finite part: it is linear in p² by construction and jumps from 466 to 1.4 across threshold. | Discontinuity test | **Withdrawn** (raises `NotImplementedError`) |
| 6 | Sunset Im part (`phase_space_3body`) | Correct shape, but the prefactor was π/(16s) instead of π/s, and the sign was flipped. This is the "16× normalisation discovery" in `global_sunset_benchmark.py`: it is a bug, not a new effect. | Ratio is exactly 16.000000 against the Feynman-parameter Im part | **Fixed** in `sunset.sunset_im` |
| 7 | Sunset real part (`sunset_real_dispersion`) | Fixed placeholder subtraction constants `s0 = -0.5`, `s1 = 0.1`. The dispersion integral ran straight through the pole at t = s (no principal value). | Source | **Replaced** by `sunset.sunset_subtracted`, validated to 1e-11 to 1e-14 against Feynman parameters |
| 8 | `solve_P126` | Hard-coded log coefficients and a fixed +iπ phase, which gives a spurious imaginary part in the Euclidean region. Does not reproduce the target -1.039367 printed by the module itself (returns 0.5617+0.1401i). | Run | **Withdrawn** |
| 9 | `solve_graph_polynomials`, `solve_elliptic_kite`, `solve_double_box_inv`, `solve_triangle3L` | The "topology parser" classifies by polynomial degree. The kite and double box were routed to the sunset with masses (1,2,3) regardless of input: changing s,t from (-3,-2) to (-30,-99) changed the "double box" only through the sunset quadrature. The 3-loop triangle and any user polynomial returned exactly 0. The "elliptic" series was an ad hoc expression. | `PolynomialStructuralParser.identify` output | **Withdrawn** |
| 10 | `MoBDynamicEngine` | Analyses the bracket matrix, then returns `complex(0)`. | Source | **Raises** `NotImplementedError` |
| 11 | `solve_bessel_exp_product` | Returned 0 for every input (the residue formula evaluated Γ at its poles, and a bare `except` returned 0). | `(3,4) -> 0.0` instead of 0.2 | **Fixed** via `mellin.product_integral` |
| 12 | RACE (`solve_product`) | Correct for exp × J0 / Gaussian away from the convergence boundary. Near it, accuracy degraded silently: exp(-3x)J0(4x) gave 0.2000042 instead of 0.2. Errors were returned as strings. Poles from the large-x expansion of a factor were ignored, so factors such as 1/(x+m) gave wrong results. | Closed forms | **Rewritten:** both expansions, convergence control, pole collisions, exceptions |
| 13 | Speed claims ("O(1)", faster than LoopTools) | LoopTools: C0 ≈ 24 µs, B0 ≈ 0.8 µs per call. RAF 0.1: C0 ≈ 22 ms, B0 up to 4.5 ms. 0.2 (certified): C0 ≈ 11 ms, B0 ≈ 0.27 ms. Evaluation is not O(1) in any meaningful sense: it calls special functions and series of growing length. | `benchmarks/looptools/compare_looptools.sh` | **Claims removed** from README |
| 14 | pySecDec "fails at the branch cut" (C0 table) | The value -0.1474950302 is not a pySecDec limitation. LoopTools and the independent integration both give -0.4219-0.3367i, and pySecDec handles this case with contour deformation. The run was most likely misconfigured (parameter order or missing contour deformation). | — | **Claim removed** |
| 15 | Tests | The `test_*.py` files in the root contained no assertions. Some printed hard-coded "Target" values for competitors. | Source | **New suite** in `tests/`: 311 tests |
| 16 | Benchmark scripts in the root | Require pySecDec libraries that are not in the repository (`RECREATION/`, `pysecdec_*`). Several print fixed reference numbers and labels such as "Competitor Killer". | Source | **Left untouched;** listed below for you to decide |

## Originality review

A literature review (references checked online or against local copies) found
that RACE and the other methods in the package are **classical**. Credit goes
to Hardy, Marichev and Adamchik–Marichev, Slater, Fikioris, SymPy
`meijerint`, mpmath `meijerg`, Gonzalez–Moll–Schmidt, Prausa,
Ananthanarayan–Banik–Friot–Ghosh and others. No copied code was found. The
contribution is the implementation. See [docs/PRIOR_ART.md](docs/PRIOR_ART.md).

## RACE (Mellin residue engine): two adversarial audits

Each round used independent hunters that tried to break the engine with
about 2,000–4,000 cases checked against closed forms (DLMF, Gradshteyn–Ryzhik,
SymPy) and independent quadratures (contour rotation, Gauss–Legendre,
QUADPACK). Separate agents then reproduced every claimed defect with a
different method.

**Round 1 (19 confirmed defects in the first rewrite), all fixed:**

* Invalid contour closures: the asymptotic "expand the Gaussian" series
  returned silent zeros, e.g. ∫e^(−x²)cos x dx = 0.
* Wrong branch of the Weber–Schafheitlin discontinuous integrals.
* Divergent integrals returned as finite numbers.
* Uncompensated cancellation, losing 7–10 digits.
* Near pole collisions accepted with errors up to 10¹³.
* Tiny results accepted with only absolute accuracy.
* Parameters frozen at 15 digits.
* A dead `nsum` fallback.
* A leaked private exception.
* Quadratic-time summation.

**Round 2 (28 confirmed defects after the fixes), all fixed:**

*RACE:*

* Inputs within 10⁻¹⁶ of a lattice point (e.g. s = 10⁻⁴⁰, ν = 10⁻²⁵) were rounded,
  returning 0. Inputs are now represented exactly.
* A late peak of the terms (`gaussian_bessel`) stopped the summation early. An
  a-priori peak estimate now guards the stopping rule.
* An over-optimistic Wynn-ε error estimate. Wynn is now used only for
  alternating series, with disjoint-window checks.
* Collisions near a singularity of I(s). The step δ is now scaled to the
  distance from the singularity, with Richardson extrapolation.
* Equal-frequency integrals with a vanishing beat term were called divergent.
  The strip check now uses the asymptotic phases.
* The precision cap gave up too early, with a misleading message.
* A raw mpmath `NoConvergence` leaked out.
* `error_estimate` ignored the final rounding.

*One-loop and sunset:*

* Catastrophic cancellation in B0 and C0 at extreme kinematics: B0(10⁻¹²; 1, 10⁶)
  was 330% off. All one-loop functions are now certified by two-precision agreement.
* C0 raised ZeroDivisionError at regular points.
* The all-massless sunset returned an undefined quantity.
* A quadrature node landing on t = s caused a crash.
* The massless D=3 bubble crashed.

*Helpers and tests:*

* `mellin_numeric` accepted integrals divergent at x = 0.
* A complex-z misuse of the 2F1 continuation gave the wrong branch.
* The legacy HCF series summation was inaccurate.
* Missing input validation.
* Test-suite flaws: a vacuous symmetry test, a wrong reference constant, a wrong
  closed form in a comment.

Final random sweeps: every result was either correct to the requested
accuracy or a raised `SeriesConvergenceError` / `ValueError`. **No silent wrong
result remained.** Known, documented refusals: the convergence boundary ρ = 1
(e.g. e^(−x) J₀(x), equal-scale products), fixed-sign series with ρ very close
to 1, and cases needing more than `max_terms` terms. All 47 cases are
regression tests (`tests/test_mellin_regressions.py`,
`tests/test_round2_regressions.py`).

## Round 3: one-loop and sunset

A third round targeted silent wrong results only.

**One-loop functions: no silent wrong result.**

* 1,820 random B0 / C0 / bubble_3d / B0_mob / C0_mob cases were checked at 15, 30
  and 50 digits, with masses from 10⁻¹² to 10¹², thresholds and pseudo-thresholds
  included.
* 1,740 cases at s = 0 were checked.
* A 24,000-point comparison against LoopTools was run.
* At the extreme hierarchies where the two disagreed, LoopTools (double precision)
  was the one in error. The package agreed with 90-digit independent quadrature.

**Defects found, all fixed:**

* **`sunset_im`.** It suffered catastrophic cancellation near threshold and
  could return 0 there. It also gave precision-independent errors at small
  scales, because mpmath's quadrature tolerance is absolute. It now uses exact
  homogeneity scaling, factored Källén functions with an endpoint-free
  substitution, error-checked quadrature and two-precision certification.
* **`sunset_subtracted` / `sunset_d2`.** These were up to 22% wrong at scales
  around 10¹², and wrong at small scales and large |s|/th. They are now scaled
  to the threshold, use a 1/t tail map, normalise each integrand, and are
  certified. They are validated against a closed form for masses (0, 0, M).
* **C0 with a massless internal line.** It was refused with a false "IR
  divergent" message. IR-finite configurations are now supported through a
  general imaginary part with clipped roots. Only the truly divergent cases
  (m1 = m2 = 0 or m2 = m3 = 0) raise.
* **C0 at s = 0.** An unchecked quadrature fooled the certification for masses
  ≳ 2¹⁴⁰. It is replaced by the exact divided-difference closed form.
* **Non-finite inputs.** These are now rejected with `ValueError`. Previously one
  call ran for more than 14 minutes.
* **Docs.** The "exact" wording for numerical sunset values, a mis-rounded
  LoopTools example and stale test counts were corrected.

**Cost.** Certified `sunset_subtracted` / `sunset_d2` take about 10 s per value
(up to ~40 s for |s| ≫ threshold).

## Round 3: RACE

The first two RACE hunters were stopped by usage limits, so the round was
completed by a smaller, bounded run: one hunter and one independent reproducer.

**Defect from the interrupted hunter (fixed).** For (x+m)^(−v) with v ≫ k·m, the
residue terms dip and then peak again near n ≈ v. The stopping rule fired in the
dip, so wrong values were returned silently: relative errors up to 10²¹ while
claiming 10⁻¹⁶. The a-priori peak estimate now includes the Gamma-argument
offsets |s|, v and |ν|. The hunter's lead maps now pass:

| Map | Before | After |
|---|---|---|
| exp × inverse_power, large v | 34 + 21 bad | 0 bad of 288 |
| hump / inverse-power-pair scans | 18 + 2 bad | 0 bad |
| exp × ip and ip × ip at 15/30/50 digits | 60 bad (at 50 digits) | 0 bad of 2,880 |

**Bounded hunter: 785 cases.** 700 correct and 31 honest refusals. No silent
error for large Bessel orders (up to 200), large or complex s (|Im s| up to 400),
inverse-power pairs with large v, `gaussian_bessel` with large ν, Wynn on growing
alternating series, `continuation=True`, exact and near collisions, or the
legacy engines. It found two defects, both confirmed by the reproducer with
independent closed forms, and both fixed:

1. **Long decimal-string s next to a pole of I(s).** Up to 1.4% error at dps 15.
   String inputs are now sized by their digits and the requested precision.
2. **Strip edges frozen at construction precision.** For string ν or v, some
   divergent integrals returned values, and one existing integral was reported
   divergent. The strip is now computed from the raw parameters at
   input-sized precision.

Regression tests for all of these are in `tests/test_round3_regressions.py`.

## Repository hygiene: actions for the owner before going public

These were **not** done automatically because they delete files or rewrite
history:

1. **Third-party code** (`third_party/`, 25 MB: LoopTools, SecDec 3, FIESTA 4/5
   sources and tarballs, plus a compiled `lt_driver`). It is GPL/LGPL/academic
   code inside an MIT repository. Remove it; `benchmarks/looptools/compare_looptools.sh`
   downloads LoopTools when needed.
2. **Generated SecDec output** (`HEAD_TO_HEAD/`, including four `intfile1.exe`
   binaries) and `secdec3_local`. Remove.
3. **Third-party PDFs**: `rmt1.pdf` (Elsevier journal article), `loop_tool.pdf`
   (LoopTools manual), `benchmark_paper.pdf` (pySecDec paper), `rmt.pdf`,
   `rmt2.pdf`, `2408.08725v1.pdf`. Redistribution is generally not permitted;
   cite them instead (README "References"). `RMT_mynotes.pdf` is your own work
   (13 MB): keep it only if you want it public.
4. **Images** with superseded claims: `rmt_superiority_plot.png`, `RACE.png`
   (4.4 MB), `rmt_vs_scipy_stress_test.png`.
5. **LICENSE copyright holder** reads "Antigravity AI", and the README said
   "Developed by Antigravity AI". Put your own name there.
6. **Git history** is 136 MB and contains all of the above, plus two author
   e-mail addresses. Removing files does not remove them from history. Either
   publish a fresh repository from a clean tree (simplest), or use
   `git filter-repo` before pushing the repository public.
7. **Root scripts** (`example*.py`, `*benchmark*.py`, `ultimate_*.py`, `test1.py`,
   `test2.py`, `test_c0.py`, `test_p126_dl_mob.py`, `test_sunset_suite.py`,
   `generate_bubble.py`, `ramanujan_integrator.py`, `ramanujan_user_api.py`,
   `recreate_table_5.py`, `feynman_*.py`, `plot_rmt_superiority.py`,
   `local_qft_benchmark.py`, `runners/`, `scratch/`): move them to a
   `research/` folder with a note, or delete them. The supported examples are
   in `examples/`.
8. `PAPER_DRAFT.md` and `perfect_table_results.md` repeat claims from
   findings 3, 5–9, 13 and 14. Revise them before circulating.
