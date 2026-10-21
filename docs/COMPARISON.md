# How ramanujan-qft relates to existing tools

The aim of this page is an accurate map, so you can pick the right tool for a
job. Measured numbers are from `benchmarks/` on one Linux machine, Python 3.13.

## 1. Product integrals over (0, ∞): RMT / Mellin residues vs quadrature

| Tool | Approach | Strength | Weakness |
|------|----------|----------|----------|
| SciPy `quad` (QUADPACK) | adaptive Gauss–Kronrod, double precision | fast, general | cost grows with the number of oscillations; tolerance-limited |
| mpmath `quad` / `quadosc` | tanh-sinh / Gauss–Legendre, arbitrary precision | general, high precision | slow for oscillatory or slowly decaying integrands |
| Mathematica `NIntegrate` / `Integrate`, Wolfram Alpha | numeric strategies + symbolic closed forms | broad coverage | proprietary; closed forms not always available |
| **ramanujan-qft `product_integral`** | Mellin–Parseval, residues = Taylor / asymptotic coefficients (RMT) | converges *faster* as oscillation increases; arbitrary precision; handles log-producing pole collisions | only for factors in the Mellin atlas; fails (with an exception) near the convergence boundary k ≈ b |

Measured on ∫ e^(-x) J₀(w x) dx (exact 1/√(1+w²)):

| w | ramanujan-qft | SciPy quad (properly configured) |
|---|---------------|----------------------------------|
| 10 | exact, 2.0 ms | 4e-10, 0.3 ms |
| 10³ | exact, 1.6 ms | 2e-6, 17 ms |
| 10⁵ | exact, 1.7 ms | 2e-5, 2.7 s |

This regime (large oscillation parameter, or many digits) is where the
Ramanujan approach gives a real advantage. For smooth, non-oscillatory
integrands, use SciPy.

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
| C0(0,0,10;1,2,3) | 24 µs | 2.5 ms / 6.9 ms |
| B0(5;1,1) | 0.8 µs | 0.12 ms / 0.13 ms |

LoopTools is roughly 100–150× faster at double precision. That is expected:
compiled Fortran against interpreted Python with multiprecision arithmetic.
The reasons to use ramanujan-qft here are:

* **reference values at 30–100+ digits**, for validating other codes or for
  expressions with large cancellations;
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
