# How ramanujan-qft relates to existing tools

The aim of this page is an accurate map, so you can pick the right tool for a
job. Timings are workload-specific measurements, not rankings of entire libraries.
The current product benchmark records its environment, source hashes and raw
samples; the one-loop table below is explicitly historical.

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
| **ramanujan-qft `product_integral`** | numerical Mellin residue summation with validity checks, cancellation control and explicit errors | arbitrary precision; selected high-frequency products converge quickly; handles Gaussian–Bessel products | only atlas factors; raises at the convergence boundary (e.g. e^(−x) J₀(x)); slower than closed forms |

### Accuracy-checked product benchmarks

Measured with **ramanujan-qft 0.3.0a4**, Python 3.12.3 and mpmath 1.3.0 on Linux.
These retained measurements describe 0.3.0a4; they were not rerun for the
metadata and documentation update in 0.3.0a5. The numerical algorithms are
unchanged from the reviewed 0.3.0a2 candidate.
All methods run at 30 working digits (RACE adds its own guard digits); the target
is relative error at most $10^{-30}$. Times are milliseconds, median of three
calls after one warm-up per method. Node/zero caches remain warm; setup and
reference generation are excluded. These are **product integrals**, not
one-loop B0/C0 or multiloop graph speed comparisons.

| Integral over $(0,\infty)$ | RACE | mpmath `quadosc` | mpmath tanh–sinh | mpmath Gauss–Legendre | Closed form |
|---|---:|---:|---:|---:|---:|
| $e^{-x}J_0(3x)$ | 2.12 | 372 | 220 | target missed | 0.0089 |
| $e^{-x}J_0(1000x)$ | 0.742 | 1008 | target missed | target missed | 0.0086 |
| $e^{-2x-x^2/2}J_1(x)$ | 5.08 | 97.1 | 59.7 | 13.7 | — |
| $e^{-2x-x^2/2}J_1(100x)$ | 3.92 | 1021 | target missed | target missed | — |

On the frequency-100 three-factor example, RACE was about **261× faster than
`quadosc`**, with relative errors $5.9\times10^{-33}$ and $1.5\times10^{-31}$,
respectively. On the frequency-1 example it was **2.7× faster than
Gauss–Legendre**, **11.8× faster than tanh–sinh**, and **19.1× faster than
`quadosc`**. These comparisons identify useful cases for residue summation;
they do not establish that those quadrature methods generally underperform.
The closed forms in the first two rows were about 86–239× faster than RACE.

The ordinary quadratures use intervals `[0, 1, infinity]` and `maxdegree=8`.
Their missed targets are results under that finite budget, not proof that they
cannot solve the integrals. For example, at frequency 1000 their relative errors
were 0.086 (tanh–sinh) and 0.022 (Gauss–Legendre). `quadosc` uses the known
frequency, as recommended in the [mpmath documentation](https://mpmath.org/doc/current/calculus/integration.html).
All four RACE results and all four `quadosc` results met the target.

Reproduce with `python benchmarks/bench_release.py`. The retained
[JSON report](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/benchmarks/data/release_comparison.json)
contains every sample and error, including failed targets. References use
closed forms for the two-factor cases and a Gaussian Fourier/angular
representation at 50/70 digits for the three-factor cases. It uses neither
RACE nor the oscillatory Bessel quadrature being timed. Precision agreement
is evidence, not a rigorous enclosure. No closed-form baseline is supplied for
the three-factor cases; this is not a proof that no closed form exists.

For the three-factor reference, [DLMF 10.9.2](https://dlmf.nist.gov/10.9.E2)
and completing the Gaussian square give

$$
I(\omega)=\frac2\pi\int_0^{\pi/2}\cos\theta\,
\operatorname{Im}G(\omega\cos\theta)\,d\theta,\qquad
G(b)=\sqrt{\frac\pi2}\,e^{(2-ib)^2/2}
\operatorname{erfc}\!\left(\frac{2-ib}{\sqrt2}\right).
$$

Absolute Gaussian decay justifies exchanging the original integrals.
The reference performs finite angular quadrature after evaluating the inner
Gaussian transform analytically. It shares mpmath arithmetic and tanh–sinh
quadrature machinery with a baseline, but has a different integrand and domain;
it does not reuse a timed method's result as its reference. Cross-representation
tests also compare it with high-precision oscillatory Bessel integration.
The 50/70-digit reference differences were below $5\times10^{-51}$ for both
three-factor cases.

The report's per-file SHA-256 hashes identify the evaluated source.
`base_commit` is optional checkout context, can predate the commit that stores
the report, and is `null` for the retained reports generated without `.git`.

## 2. One-loop Feynman integrals

| Tool | Language | Precision | Scope |
|------|----------|-----------|-------|
| LoopTools (Hahn, Pérez-Victoria) | Fortran/C++ | double | scalar and tensor integrals A–E, complex masses |
| COLLIER (Denner, Dittmaier, Hofer) | Fortran | double | tensor integrals, numerically stable reduction |
| OneLOop (van Hameren) | Fortran | double and higher | scalar integrals, complex masses, IR divergent cases |
| QCDLoop 2 (Carrazza, Ellis, Zanderighi) | C++ | double and quadruple | scalar integrals incl. IR divergent |
| Package-X (Patel) | Mathematica | analytic | analytic one-loop expressions |
| **ramanujan-qft `one_loop`** | Python (mpmath) | **arbitrary, precision-checked** | B0 (all masses), C0(0,0,s; m1,m2,m3) (massless lines allowed when IR finite), D=3 bubble |

### Historical one-loop measurements

These retained version-0.2 timings were not rerun for 0.3.0a2. They must not be
combined with the current product-integral table to infer a common ranking.

| | LoopTools 2.16 | ramanujan-qft 0.2 (15 / 50 digits) |
|---|---|---|
| C0(0,0,10;1,2,3) | 24 µs | 11 ms / 25 ms |
| B0(5;1,1) | 0.8 µs | 0.27 ms / 0.31 ms |

LoopTools is roughly 300–450× faster at double precision. That is expected:
compiled Fortran against interpreted Python with multiprecision arithmetic.
The reasons to use ramanujan-qft here are:

* **reference values at 30–100+ digits**, for validating other codes or for
  expressions with large cancellations. Example at an extreme mass hierarchy:
  `C0(2.1973609307495493e-11, 8.481053224196959e-10, 8.48190132951938e-10, 35.105214341025246)`
  = −0.66788699075041312… (precision-checked; an independent 90-digit quadrature agrees).
  LoopTools 2.16 in double precision returns −0.69637. More cases are in
  `tests/test_round2_regressions.py`;
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

In its four-dimensional sunset API, ramanujan-qft provides the
**scheme-independent** pieces: Im S from its exact phase-space representation,
and the twice-subtracted dispersion relation S(s) − S(0) − s·S′(0). Both are
precision-checked numerical integrations. They are validated against independent
Feynman-parameter integration and a closed form for masses (0, 0, M), at
thresholds and at scales from 10⁻¹² to 10¹². This is a small, correct building
block, **not** a replacement for the tools above. TSIL is a relevant comparison
for production two-loop self-energies. No matched TSIL timing was retained, so no speed ratio is claimed; an earlier
`sunset_subtracted` measurement took about 10 s here.

The experimental [graph backend](user_guide/multiloop.md) also handles
UV-convergent massive Euclidean scalar graphs with positive powers and real
dimension. It uses RMT for the common Schwinger scale and numerical Hepp sectors
for the remaining parameters. Results have statistical float64 error estimates;
the factorial sector count limits practical graph size. This is an independent
numerical reference for RMT-series work, without general regulator
expansions, massless domains, tensors, or physical-region continuation.
This graph evaluator has no fixed loop-count limit, and validation includes
examples through four loops. It is distinct from RACE (`mellin.product_integral`),
which sums Mellin residues for products from the documented function atlas.
General graph integration entirely through RACE/RMT residue series is still
a research objective.

The separate [D=2 sunset RMT backend](user_guide/sunset_rmt.md) now generates
exact bracket families, resolves coalescing Gamma poles analytically, and
sums a multivariate series with an analytic tail bound. It covers unit powers
in the strict regions $Q>m_1+m_2+m_3$ and $M>m_a+m_b+Q$. Equal-mass vacuum
and the gap between the charts remain unsupported by that RMT evaluator.
The separate [equal-mass Taylor backend](user_guide/sunset_taylor.md) covers
vacuum and finite Euclidean momentum, subject to work budgets. No speed
comparison with general-purpose multiloop tools is claimed.

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
* Convergent massive Euclidean scalar graphs → the experimental
  **ramanujan-qft** graph backend, within its work budgets; for supported D=2
  sunset domains, use the RMT or equal-mass Taylor series explicitly.
* Broader multiloop coverage, regulator expansions and physical regions →
  pySecDec / FIESTA / AMFlow / TSIL (self-energies).
