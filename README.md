# ramanujan-qft

[![tests](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/tests.yml/badge.svg)](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/tests.yml)
[![docs](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/workflows/docs.yml/badge.svg)](https://reetanshuh1998.github.io/Ramanujan_master_theorem/)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/reetanshuh1998/Ramanujan_master_theorem/blob/main/notebooks/quickstart.ipynb)

**Documentation:** <https://reetanshuh1998.github.io/Ramanujan_master_theorem/>. It includes a user guide, an API reference, examples, and an in-browser console
([Try it](https://reetanshuh1998.github.io/Ramanujan_master_theorem/try_it.html)) that needs no installation.

**Ramanujan's Master Theorem, Mellin residue summation and arbitrary-precision
Feynman integrals in pure Python.**

```
f(x) = Σ φ(n) (-x)ⁿ / n!     ⟹     ∫₀^∞ x^(s-1) f(x) dx = Γ(s) φ(-s)
```

Ramanujan's Master Theorem (RMT) turns an integral into an evaluation of
Taylor coefficients. This library implements **classical** methods built on
it, in pure Python, at arbitrary precision, and with explicit convergence
control:

1. **`rmt`**: the theorem itself, with a numerical Mellin transform to check
   every use.
2. **`mellin.product_integral`**: ∫ x^(s-1) f(x) g(x) dx as a residue series,
   using the Mellin-convolution (Meijer-G / Slater) method of Marichev and others.
   Before summing, it checks which expansion legitimately closes the contour.
   It compensates cancellation by raising the working precision, and it raises
   an error rather than return a number it cannot certify.
3. **Feynman integrals** with known hypergeometric or dispersive
   representations: one-loop B0 and C0, the D=3 bubble, and the
   scheme-independent part of the two-loop sunset. Results are certified to the requested precision,
   and checked against LoopTools.

**Originality.** The methods are not new. [docs/PRIOR_ART.md](docs/PRIOR_ART.md)
credits the earlier work (Hardy, Marichev, Adamchik–Marichev, Slater,
Gonzalez–Moll–Schmidt, Prausa, Ananthanarayan–Banik–Friot–Ghosh, SymPy,
mpmath, …). The contribution here is a careful, tested, open implementation.

*Dedicated to the memory of Srinivasa Ramanujan.*

## Why it can be useful

* **Precision.** Standard one-loop libraries work in double (sometimes
  quadruple) precision. Validating them, or evaluating expressions with large
  cancellations, needs reference values with 30–100 digits.
* **Transparency.** Each integral is an explicit hypergeometric series, for
  example B0 = Δ − log(m²/μ²) + (2w/3)·₂F₁(1,1;5/2;w) with w = p²/4m². The
  analytic structure, thresholds included, is visible and testable.
* **Oscillatory products without closed forms, at high precision.** At 30
  digits, ∫ e^(−2x) e^(−x²/2) J₁(100x) dx takes 6 ms. `mpmath.quadosc` takes
  4.3 s. See [docs/COMPARISON.md](docs/COMPARISON.md) for the fair benchmark;
  where a closed form exists, SymPy/Mathematica plus mpmath is faster.

## What it is not

It is **not** a faster replacement for LoopTools, COLLIER, pySecDec, FIESTA,
AMFlow or TSIL. Compiled one-loop libraries are several hundred times faster at double
precision. Closed-form symbolic integration (SymPy `meijerint`, Mathematica) is
faster wherever it applies, and general multi-loop integrals are beyond the
current scope. See [docs/COMPARISON.md](docs/COMPARISON.md) and
[AUDIT.md](AUDIT.md).

## Install

```bash
pip install "git+https://github.com/reetanshuh1998/Ramanujan_master_theorem"   # latest version, requires Python >= 3.9
pip install .            # from a clone
pip install ".[test]"    # + pytest, scipy for the test suite
```

## Quick start

```python
import mpmath as mp
from ramanujan_qft import (ramanujan_master_theorem, product_integral, exponential,
                           bessel_j, B0, C0, sunset_im)

# Ramanujan's Master Theorem: ∫ x^(s-1)(1+x)^-3 dx = Γ(s) φ(-s),  φ(n) = Γ(3+n)/Γ(3)
ramanujan_master_theorem(lambda n: mp.gamma(3 + n) / 2, 1.25)     # = B(1.25, 1.75)

# Oscillatory product integral by Mellin residues: ∫ e^(-x) J0(1e5 x) dx
product_integral(exponential(1), bessel_j(0, 1e5), dps=30)
# ... refuses (SeriesConvergenceError) at the convergence boundary e^(-x) J0(x),
# and raises ValueError for divergent integrals such as ∫ cos(x) cos(2x) dx

# One-loop integrals, LoopTools conventions (Δ = 0, μ² = 1 by default)
B0(5, 1, 1)                 # (1.5695910590 + 1.4049629462j)   = LoopTools
C0(10, 1, 2, 3, dps=50)     # C0(0,0,s; m1², m2², m3²) to 50 digits

# Two-loop sunset: imaginary part (certified)
sunset_im(100, 1, 2, 3)     # -88.1849955516
```

More in [`examples/`](examples/):

| Example | Shows |
|---------|-------|
| `01_ramanujan_master_theorem.py` | RMT on classical cases; a dimensionally regulated radial integral |
| `02_mellin_products.py` | exp × Bessel at high frequency, log cases, three-factor products, convergence errors |
| `03_one_loop_integrals.py` | B0, C0 at double and 50-digit precision; MoB series vs closed form |
| `04_sunset_dispersion.py` | sunset Im part and twice-subtracted dispersion relation |

## API overview

| Module | Function | Description | Validated against |
|--------|----------|-------------|-------------------|
| `rmt` | `ramanujan_master_theorem(phi, s)` | Γ(s)·φ(−s) | numerical Mellin transforms, DLMF |
| | `mellin_numeric(f, s)` | numerical Mellin transform | — |
| | `massive_propagator_rmt(m², D)` | ∫dq² (q²)^(D/2−1)/(q²+m²) | closed form, quadrature |
| `mellin` | `product_integral(f, g, s)` | Mellin residue summation: validity check of the contour closure, existence check, cancellation-compensated precision, pole collisions | closed forms (DLMF, Gradshteyn–Ryzhik), quadrature; adversarial audit |
| | atlas: `exponential, gaussian, bessel_j, cosine, sine, inverse_power, gaussian_bessel` | Mellin data of each factor | |
| `one_loop` | `B0(p², m1², m2², mu2, delta)` | two-point function, all masses | LoopTools, independent quadrature |
| | `B0_mob(p², m²)` | equal-mass MoB ₂F₁ series, continued across threshold | `B0` to 50 digits |
| | `C0(s, m1², m2², m3²)` | C0(0,0,s; m1², m2², m3²); massless lines allowed when IR finite | LoopTools, independent quadrature |
| | `C0_mob(s, m²)` | equal-mass closed MoB form | arcsin² identity, `C0` |
| | `bubble_3d(p², m1², m2²)` | finite D=3 bubble | quadrature with −i0 |
| `sunset` | `sunset_im`, `sunset_subtracted`, `sunset_d2` | Im S, S(s)−S(0)−sS′(0), S″(s) | 2-D Feynman-parameter integrals |

All functions take `dps=` (decimal digits). Squared masses throughout;
Minkowski metric, so p² > 0 is time-like; Feynman +i0.

**Normalisation:** each loop is integrated with dᴰk/(iπ^(D/2)), and propagators
are 1/(q² − m² + i0), as in LoopTools and pySecDec.

The classes of version 0.1 (`FeynmanMoBSolver`, `AnalyticalConvolutionEngine`,
`RamanujanContinuationEngine`, …) are still importable. Methods that did not
compute their stated integral now raise `NotImplementedError` with an
explanation (see [CHANGELOG.md](CHANGELOG.md)).

## Validation

```bash
pytest -m "not slow"     # 288 tests, ~20 s
pytest                   # 311 tests, + independent Feynman-parameter / closed-form checks, ~6 min
bash benchmarks/looptools/compare_looptools.sh   # builds LoopTools (gfortran) and compares
python benchmarks/bench_fair.py      # RACE vs closed forms and mpmath.quadosc at 30 digits
```

* B0 and C0 agree with LoopTools 2.16 to double-precision round-off at 15, 30
  and 60 working digits (`tests/data/looptools_reference.csv`).
* The MoB series for B0 agrees with the closed form to 50 digits, below and
  above threshold.
* The sunset's Im S, S″ and twice-subtracted S agree with independent
  Feynman-parameter integrations to 10⁻⁸ to 10⁻¹⁴.
* One-loop results are *certified*: each is evaluated at two working precisions,
  raised until they agree, which removes cancellation at extreme kinematics
  (p² ≪ m², mass hierarchies, s ≫ m²).
* RACE went through three adversarial audit rounds against closed forms and
  independent quadrature: two of about 2,000–4,000 cases each, then a bounded
  785-case round. All 50 confirmed defects (19 + 28 + 3) were fixed and turned
  into regression tests (`tests/test_mellin_regressions.py`,
  `tests/test_round2_regressions.py`, `tests/test_round3_regressions.py`). In
  the final sweeps it either returned the correct value or raised; no silent
  wrong result remained. Round 3 also covered the one-loop and sunset
  functions (1,820 random cases plus a 24,000-point LoopTools comparison). It
  found and fixed defects in the sunset functions and in C0 with massless
  lines. See
  [AUDIT.md](AUDIT.md).

## Roadmap

* Sunset subtraction constants S(0), S′(0) in closed form, giving the full
  finite part.
* C0 with general external momenta; D0.
* An automated MoB pipeline (`core/mob_dynamic_engine.py` currently analyses the
  bracket system only), restricted to kinematic regions where the resulting
  series provably converge.
* A larger Mellin atlas (Bessel K/Y, Struve, rational functions).

Contributions are welcome. Please add a test against an independent reference
for any new integral.

## References

* T. Amdeberhan, O. Espinosa, I. Gonzalez, M. Harrison, V. H. Moll, A. Straub,
  *Ramanujan's Master Theorem*, Ramanujan J. 29 (2012) 103.
* I. Gonzalez, V. H. Moll, I. Schmidt, *Ramanujan's Master Theorem applied to
  the evaluation of Feynman diagrams*, Adv. Appl. Math. 63 (2015) 214.
* I. Gonzalez, I. Schmidt, *Optimized negative dimensional integration method
  (NDIM) and multiloop Feynman diagram calculation*, Nucl. Phys. B 769 (2007) 124.
* T. Hahn, M. Pérez-Victoria, *Automatized one-loop calculations in four and D
  dimensions*, Comput. Phys. Commun. 118 (1999) 153 (LoopTools).
* A. Denner, *Techniques for the calculation of electroweak radiative
  corrections at the one-loop level*, Fortsch. Phys. 41 (1993) 307.
* S. Borowka et al., *pySecDec: a toolbox for the numerical evaluation of
  multi-scale integrals*, Comput. Phys. Commun. 222 (2018) 313.
* S. P. Martin, D. G. Robertson, *TSIL: a program for the calculation of
  two-loop self-energy integrals*, Comput. Phys. Commun. 174 (2006) 133.
* NIST Digital Library of Mathematical Functions, §10.22 (Mellin transforms of
  Bessel functions).

## License

MIT (see [LICENSE](LICENSE)).
