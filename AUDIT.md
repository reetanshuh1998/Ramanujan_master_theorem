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
| 13 | Speed claims ("O(1)", faster than LoopTools) | LoopTools: C0 ≈ 24 µs, B0 ≈ 0.8 µs per call. RAF 0.1: C0 ≈ 22 ms, B0 up to 4.5 ms. 0.2: C0 ≈ 2.5 ms, B0 ≈ 0.12 ms. Evaluation is not O(1) in any meaningful sense: it calls special functions and series of growing length. | `benchmarks/looptools/compare_looptools.sh` | **Claims removed** from README |
| 14 | pySecDec "fails at the branch cut" (C0 table) | The value -0.1474950302 is not a pySecDec limitation. LoopTools and the independent integration both give -0.4219-0.3367i, and pySecDec handles this case with contour deformation. The run was most likely misconfigured (parameter order or missing contour deformation). | — | **Claim removed** |
| 15 | Tests | The `test_*.py` files in the root contained no assertions. Some printed hard-coded "Target" values for competitors. | Source | **New suite** in `tests/`: 164 tests |
| 16 | Benchmark scripts in the root | Require pySecDec libraries that are not in the repository (`RECREATION/`, `pysecdec_*`). Several print fixed reference numbers and labels such as "Competitor Killer". | Source | **Left untouched;** listed below for you to decide |

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
