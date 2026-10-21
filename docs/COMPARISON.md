# How ramanujan-qft relates to existing tools

The aim of this page is an accurate map, so you can pick the right tool for a
job. Measured numbers are from `benchmarks/` on one Linux machine, Python 3.13.

## 1. Product integrals over (0, ∞): Mellin residues vs the alternatives

RACE (`product_integral`) implements the classical Mellin-convolution /
Meijer-G residue method. See [PRIOR_ART.md](PRIOR_ART.md) for Marichev,
Adamchik–Marichev, Slater, Fikioris, SymPy `meijerint` and mpmath `meijerg`.

| Tool | Approach | Strength | Weakness |
|------|----------|----------|----------|
| closed form (SymPy `integrate`/`meijerint`, Mathematica, tables) | symbolic Mellin convolution of G-functions | exact; evaluation takes µs | not every product has a closed form |
| mpmath `meijerg` | Slater residue series of a G-function | arbitrary precision, both expansions | requires the G-function representation |
| SciPy `quad` (QUADPACK, QAWO/QAWF) | adaptive quadrature, Fourier weights | fast, general, double precision | loses digits on oscillatory, cancelling integrands |
| Ooura–Mori, Ogata double-exponential | DE quadrature for Fourier / Hankel integrals | fast and robust in double precision | needs node tables; slower at high precision |
| mpmath `quadosc` | oscillatory quadrature, arbitrary precision | general | slow |
| **ramanujan-qft `product_integral`** | numerical Mellin residue summation with validity check, cancellation control and honest refusal | arbitrary precision; cost nearly independent of the oscillation frequency; three-factor products without closed forms | only atlas factors; raises at the convergence boundary (e.g. e^(−x) J₀(x)); slower than closed forms |

Measured at 30 digits (`benchmarks/bench_fair.py`; relative error, best-of-3 time):

| integral | RACE | closed form (mpmath) | mpmath.quadosc |
|---|---|---|---|
| e^(−x) J₀(3x) | exact, 5.1 ms | exact, 0.010 ms | exact, 905 ms |
| e^(−x) J₀(10³x) | exact, 1.1 ms | exact, 0.012 ms | exact, 1618 ms |
| e^(−x) J₀(10⁶x) | exact, 0.8 ms | exact, 0.010 ms | — |
| e^(−x) cos(10⁶x) | exact, 0.6 ms | exact, 0.006 ms | — |
| e^(−2x) e^(−x²/2) J₁(x) (no closed form) | 7e-35, 6.5 ms | — | exact, 1.6 s |
| e^(−2x) e^(−x²/2) J₁(100x) (no closed form) | 6e-33, 6.2 ms | — | exact, 4.3 s |

A wider audit benchmark (double precision, with QUADPACK QAWO/QAWF,
Ooura–Mori, Ogata, Levin and contour rotation) found:

* RACE is **never the fastest at 15 digits**. Compiled double-precision methods
  take 5–300 µs, against RACE's milliseconds.
* Closed forms are 100–40,000× faster wherever they exist.
* At 30 digits, RACE beats every general-purpose alternative measured, by 2–30×
  over the best (Ogata DE in mpmath, after an 83 s table build). This is
  clearest for three-factor products that have no closed form.
* Fourier-weighted quadrature loses digits on e^(−x)cos(bx) at large b, where the
  value ~1/b² cancels. RACE and contour rotation do not.

**Honest positioning:** a reliable arbitrary-precision evaluator for products of
atlas functions, most useful where no closed form exists. It is not faster than
symbolic integration where a closed form exists, and the method itself is
classical.

## 2. One-loop Feynman integrals

| Tool | Language | Precision | Scope |
|------|----------|-----------|-------|
| LoopTools (Hahn, Pérez-Victoria) | Fortran/C++ | double | scalar and tensor integrals A–E, complex masses |
| COLLIER (Denner, Dittmaier, Hofer) | Fortran | double | tensor integrals, numerically stable reduction |
| OneLOop (van Hameren) | Fortran | double and higher | scalar integrals, complex masses, IR divergent cases |
| QCDLoop 2 (Carrazza, Ellis, Zanderighi) | C++ | double and quadruple | scalar integrals incl. IR divergent |
| Package-X (Patel) | Mathematica | analytic | analytic one-loop expressions |
| **ramanujan-qft `one_loop`** | Python (mpmath) | **arbitrary** | B0 (all masses), C0(0,0,s; m1,m2,m3) for non-zero masses, D=3 bubble |

Speed per call (measured):

| | LoopTools 2.16 | ramanujan-qft 0.2 (15 / 50 digits) |
|---|---|---|
| C0(0,0,10;1,2,3) | 24 µs | 11 ms / 25 ms |
| B0(5;1,1) | 0.8 µs | 0.27 ms / 0.31 ms |

LoopTools is roughly 300–450× faster at double precision. That is expected:
compiled Fortran against interpreted Python with multiprecision arithmetic.
The reasons to use ramanujan-qft here are:

* **reference values at 30–100+ digits**, for validating other codes or for
  expressions with large cancellations. Example: at extreme mass hierarchies,
  C0(0,0,2.2·10⁻¹¹; 8.48·10⁻¹⁰, 8.48·10⁻¹⁰, 35.1) is −0.66788699075 (certified;
  confirmed by an independent 90-digit quadrature). LoopTools 2.16 in double
  precision returns −0.69637. More cases are in `tests/test_round2_regressions.py`;
* **transparent derivations**: B0 is also available directly as the
  Method-of-Brackets series (2w/3)·₂F₁(1,1;5/2;w), and C0 in its MoB
  arcsin² / log² form;
* pure Python: nothing to compile.

## 3. Multi-loop integrals

| Tool | Approach |
|------|----------|
| pySecDec, FIESTA | sector decomposition + contour deformation; general, numerical |
| AMFlow | auxiliary mass flow (differential equations); high precision |
| DiffExp, SeaSyde | series solutions of differential equations along paths |
| TSIL (Martin, Robertson) | C library for all two-loop self-energy integrals (sunset included), arbitrary masses |
| MB.m, MBresolve, AMBRE | Mellin–Barnes representations, asymptotic expansions, numerics |
| MoB literature (Gonzalez, Moll, Schmidt; Ananthanarayan et al.) | Method of Brackets → multivariate hypergeometric series in convergence regions |
| Kira, FIRE, LiteRed | IBP reduction to master integrals (complementary to all of the above) |

ramanujan-qft currently provides, for the two-loop sunset, only the
**scheme-independent** pieces: the exact Im S and the twice-subtracted
dispersion relation S(s) − S(0) − s·S′(0). Both are validated against
independent Feynman-parameter integration. This is a small, correct building
block, **not** a replacement for the tools above. For production two-loop
self-energies, TSIL is the natural comparison, and it is much faster.

### Why "O(1) multi-loop via RMT" does not hold in general

The Method of Brackets maps a Feynman-parameter integral to a sum over
multivariate hypergeometric series. Each series converges only in a region of
kinematic space, and the number of series and summation indices grows with the
number of propagators. Analytic continuation between regions — physical
thresholds in particular — is the hard part. This is why the field relies on
differential equations and sector decomposition. RMT/MoB is valuable where its
series converge quickly, and as a source of exact representations. It is not a
constant-time evaluator.

## 4. When to use what (short version)

* Many digits of a one-loop scalar integral, or an independent check of a
  Fortran result → **ramanujan-qft**.
* Oscillatory product integral of exponentials, Gaussians, Bessel and
  trigonometric functions, and powers → **ramanujan-qft** `product_integral`.
* Phenomenology at one loop (speed, tensor integrals) → LoopTools / COLLIER.
* Two loops and beyond → pySecDec / FIESTA / AMFlow / TSIL (self-energies).
