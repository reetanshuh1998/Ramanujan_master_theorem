# Validation

A numerical library is only useful if its numbers can be trusted. This page
lists what each part of ramanujan-qft is checked against, how to rerun the
checks, and what the adversarial audits found before release.

## The test suite

The repository has **311 tests** (`tests/`). The 288 fast tests take about 20 s.
The 23 tests marked `slow` run independent nested quadratures and take about six
minutes. In addition, the examples in the docstrings and on these documentation
pages are executed in CI.

| file | tests | what is checked | against |
|---|---|---|---|
| `test_one_loop.py` | 126 | `B0`, `C0`, `B0_mob`, `C0_mob`, `bubble_3d`: values, symmetries, limits, refusals | LoopTools 2.16; independent Feynman-parameter quadrature; closed forms |
| `test_round2_regressions.py` | 51 | RACE defects of the second audit round; extreme one-loop hierarchies | closed forms; independent quadrature (up to 90 digits) |
| `test_mellin_regressions.py` | 39 | RACE defects of the first audit round | closed forms (DLMF, Gradshteyn–Ryzhik, SymPy); quadrature |
| `test_round3_regressions.py` | 39 | sunset at threshold and extreme scales; RACE second-peak and string-input defects | the closed form for masses $(0,0,M)$; exact homogeneity |
| `test_mellin.py` | 20 | `product_integral` and the atlas | closed forms; `mpmath.quad` / `quadosc` |
| `test_legacy_api.py` | 17 | the 0.1 interface delegates correctly, withdrawn methods raise | the new functions |
| `test_sunset.py` | 11 | `sunset_im`, `sunset_subtracted`, `sunset_d2` | two-dimensional Feynman-parameter integrals (SciPy) |
| `test_rmt.py` | 8 | Ramanujan's Master Theorem on classical cases | `mellin_numeric`; closed forms (Amdeberhan et al. 2012) |

## LoopTools comparison

`tests/data/looptools_reference.csv` holds 21 values from LoopTools 2.16 (T. Hahn)
in double precision, with its default settings ($\Delta = 0$, $\mu^2 = 1$). The
tests compare them at 15, 30 and 60 working digits. The differences below are
LoopTools' double-precision rounding, of order $10^{-16}$:

| call | LoopTools 2.16 (double precision) | ramanujan-qft, `dps=30`, first 18 digits | relative difference |
|---|---|---|---|
| `B0(1, 1, 1)` | 0.186200635765782163 | 0.186200635765782149 | 7.4e-17 |
| `B0(5, 1, 1)` | 1.56959105903599583 + 1.40496294620814521 i | 1.56959105903599596 + 1.40496294620814528 i | 7.0e-17 |
| `B0(100, 1, 1)` | -2.49223028849713657 + 3.07811959238847344 i | -2.49223028849713653 + 3.07811959238847383 i | 1.0e-16 |
| `B0(-3, 1, 1)` | -0.393325367408375648 | -0.393325367408375517 | 3.3e-16 |
| `B0(10, 1, 2)` | 0.622592073090541875 + 2.0116008064341786 i | 0.622592073090541958 + 2.01160080643417844 i | 8.6e-17 |
| `B0(0.5, 1, 2)` | -0.327394586317521274 | -0.327394586317521182 | 2.8e-16 |
| `B0(-3, 0, 1)` | 0.151607518506812533 | 0.151607518506812508 | 1.6e-16 |
| `B0(3, 0, 1)` | 1.53790187962670299 + 2.09439510239319526 i | 1.53790187962670313 + 2.09439510239319549 i | 1.0e-16 |
| `B0(0, 1, 2)` | -0.386294361119890572 | -0.386294361119890619 | 1.2e-16 |
| `B0(50, 9, 0.25)` | -1.40173926998769427 + 2.55345009887987784 i | -1.40173926998769411 + 2.55345009887987777 i | 6.0e-17 |
| `C0(5, 1, 1, 1)` | -0.894334511878058125 − 0.604708613771114734 i | -0.894334511878058105 − 0.604708613771114783 i | 5.0e-17 |
| `C0(10, 1, 1, 1)` | -0.280591593189852884 − 0.648247873678714837 i | -0.280591593189852817 − 0.648247873678714907 i | 1.4e-16 |
| `C0(1, 1, 1, 1)` | -0.548311355616076135 | -0.548311355616075479 | 1.2e-15 |
| `C0(-4, 1, 1, 1)` | -0.388409699947848075 | -0.388409699947847991 | 2.2e-16 |
| `C0(10, 1, 2, 3)` | -0.421932531674735434 − 0.336732268033680282 i | -0.421932531674735454 − 0.336732268033680194 i | 1.7e-16 |
| `C0(30, 1, 2, 3)` | -0.0491375764366192708 − 0.270027819272811553 i | -0.0491375764366193056 − 0.270027819272811554 i | 1.3e-16 |
| `C0(1, 1, 2, 3)` | -0.274155677808037845 | -0.274155677808037739 | 3.9e-16 |
| `C0(-5, 1, 2, 3)` | -0.218140010232987736 | -0.218140010232987873 | 6.3e-16 |
| `C0(20, 1, 4, 2)` | -0.0969557610032571321 − 0.255000329658827796 i | -0.0969557610032571624 − 0.255000329658827849 i | 2.3e-16 |
| `C0(7, 0.5, 1, 2)` | -0.588992213918281715 − 0.651016319444228997 i | -0.588992213918281793 − 0.651016319444229138 i | 1.8e-16 |
| `C0(1000, 1, 2, 3)` | 0.0144879629437208342 − 0.0195127404190650298 i | 0.0144879629437208358 − 0.0195127404190650301 i | 6.7e-17 |

`benchmarks/looptools/compare_looptools.sh` downloads and builds LoopTools 2.16
(gfortran is needed) and compares values and timings.

A further 24,000-point comparison with LoopTools was run during the third audit
round. At extreme mass hierarchies, where the two disagreed, LoopTools (double
precision) was the one in error: an independent 90-digit quadrature agreed with
ramanujan-qft. One such case is shown on the {doc}`/user_guide/one_loop` page.

## Independent references

* **Closed forms.** DLMF, Gradshteyn–Ryzhik and SymPy closed forms for the
  product integrals; the equal-mass closed forms of $B_0$ and $C_0$; the closed
  form of the sunset for masses $(0, 0, M)$.
* **Quadrature.** `mpmath.quad` and `quadosc`, contour rotation, Gauss–Legendre
  and QUADPACK for the product integrals. Feynman-parameter integrals at 30 to
  90 digits for $B_0$ and $C_0$. Two-dimensional Feynman-parameter integrals with
  SciPy for the sunset.
* **Internal consistency.** $B_0$ against its Method-of-Brackets series to 50
  digits; $C_0$ under $m_1 \leftrightarrow m_3$ and at the equal-mass limit; the
  sunset under exact homogeneity ($\lambda = 2^{-60}$ to $2^{40}$) and with
  different masses integrated outside.

## Audit history

Before release, the package went through adversarial audits. Independent
"hunter" agents tried to break the code with thousands of cases. Every claimed
defect was then reproduced by a separate agent with a different method. All
confirmed defects were fixed and turned into regression tests. The full record
is in [AUDIT.md](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/AUDIT.md).

| round | scope | cases | confirmed defects | examples of what was fixed |
|---|---|---|---|---|
| 1 | RACE (first rewrite) | about 2,000–4,000 | 19 | invalid contour closures giving silent zeros ($\int e^{-x^2}\cos x\,dx = 0$); the wrong branch of Weber–Schafheitlin integrals; divergent integrals returned as numbers; uncompensated cancellation |
| 2 | RACE (after the fixes) | about 2,000–4,000 | 28 | near pole collisions; tiny results accepted with absolute accuracy only; parameters frozen at 15 digits |
| 3 | one-loop and sunset | 1,820 random cases + 1,740 at $s = 0$ + 24,000 vs LoopTools | 6 groups | `sunset_im` cancellation near threshold; `sunset_subtracted` / `sunset_d2` up to 22% wrong at scales near $10^{12}$; C0 with a massless line wrongly refused; non-finite inputs |
| 3 | RACE (bounded run) | 785 | 3 | a second peak of the residue terms for $(x+m)^{-v}$ with large $v$; long decimal-string inputs next to a pole; strip edges at construction precision |

In the final sweeps, every result was either correct to the requested accuracy or
an explicit error. No silent wrong result remained. This is evidence, not a proof:
please report any case where a function returns a wrong value without raising.

## Reproducing the checks

```bash
pip install ".[test]"
python -m pytest -q -m "not slow" tests        # 288 tests, about 20 s
python -m pytest -q tests                      # all 311 tests, about 6 minutes
python -m pytest -q --doctest-modules ramanujan_qft/rmt.py ramanujan_qft/mellin.py \
       ramanujan_qft/one_loop.py ramanujan_qft/sunset.py   # docstring examples
python tools/check_doc_snippets.py docs        # examples on the documentation pages
bash benchmarks/looptools/compare_looptools.sh # LoopTools values and timings
python benchmarks/bench_fair.py                # RACE vs closed forms and quadosc
```

## Known limitations

* `product_integral` refuses at the convergence boundary $\rho = 1$ (for example
  $e^{-x}J_0(x)$), for fixed-sign series with $\rho$ very close to 1, and when more
  than `max_terms` terms are needed. Only atlas factors are supported.
* `C0` covers only $C_0(0,0,s;m_1^2,m_2^2,m_3^2)$, two light-like legs and real
  masses. There is no `D0`, no tensor integrals and no complex masses.
* The sunset functions give only the scheme-independent parts, and the
  dispersion-based ones take about 10–20 s per value.
* `mellin_numeric` is meant for non-oscillatory integrands with power-law ends.
* The legacy 0.1 interface keeps only the methods that compute what they claim;
  the others raise `NotImplementedError` ({doc}`/api/legacy`).
