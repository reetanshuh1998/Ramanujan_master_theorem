# API reference

Every public object is importable from the top-level package, for example
`from ramanujan_qft import B0, product_integral`. The pages below document them
by module. Masses are squared masses, `dps` is the number of decimal digits
requested, and results are mpmath numbers (see {doc}`/user_guide/precision`).

## Ramanujan's Master Theorem — `ramanujan_qft.rmt`

| | |
|---|---|
| {py:func}`~ramanujan_qft.rmt.ramanujan_master_theorem` | $\Gamma(s)\,\varphi(-s)$, the Mellin transform given by the theorem |
| {py:func}`~ramanujan_qft.rmt.mellin_numeric` | numerical Mellin transform, for cross-checks |
| {py:func}`~ramanujan_qft.rmt.massive_propagator_rmt` | radial integral of a massive propagator in $D$ dimensions |

## Product integrals — `ramanujan_qft.mellin`

| | |
|---|---|
| {py:func}`~ramanujan_qft.mellin.product_integral` | $\int_0^\infty x^{s-1} f(x)\,g(x)\,dx$ by Mellin residue summation |
| {py:func}`~ramanujan_qft.mellin.exponential` | $e^{-kx}$ |
| {py:func}`~ramanujan_qft.mellin.gaussian` | $e^{-ax^2}$ |
| {py:func}`~ramanujan_qft.mellin.bessel_j` | $J_\nu(bx)$ |
| {py:func}`~ramanujan_qft.mellin.cosine` | $\cos bx$ |
| {py:func}`~ramanujan_qft.mellin.sine` | $\sin bx$ |
| {py:func}`~ramanujan_qft.mellin.inverse_power` | $(x+m)^{-v}$ |
| {py:func}`~ramanujan_qft.mellin.gaussian_bessel` | $e^{-ax^2}J_\nu(bx)$ |
| {py:class}`~ramanujan_qft.mellin.MellinFunction` | a factor described by its Mellin data |
| {py:class}`~ramanujan_qft.mellin.SeriesConvergenceError` | no valid expansion reaches the accuracy target |

## One-loop integrals — `ramanujan_qft.one_loop`

| | |
|---|---|
| {py:func}`~ramanujan_qft.one_loop.B0` | two-point function $B_0(p^2;m_1^2,m_2^2)$ |
| {py:func}`~ramanujan_qft.one_loop.B0_mob` | equal-mass $B_0$ from its Method-of-Brackets series |
| {py:func}`~ramanujan_qft.one_loop.C0` | three-point function $C_0(0,0,s;m_1^2,m_2^2,m_3^2)$ |
| {py:func}`~ramanujan_qft.one_loop.C0_mob` | equal-mass $C_0$ in closed form |
| {py:func}`~ramanujan_qft.one_loop.bubble_3d` | the finite $D=3$ two-point function |

## Two-loop sunset — `ramanujan_qft.sunset`

| | |
|---|---|
| {py:func}`~ramanujan_qft.sunset.sunset_threshold` | $(m_1+m_2+m_3)^2$ |
| {py:func}`~ramanujan_qft.sunset.sunset_im` | $\operatorname{Im}S(s)$ |
| {py:func}`~ramanujan_qft.sunset.sunset_subtracted` | $S(s)-S(0)-s\,S'(0)$ |
| {py:func}`~ramanujan_qft.sunset.sunset_d2` | $S''(s)$ below threshold |

## Legacy (version 0.1) interface

`FeynmanMoBSolver`, `RamanujanContinuationEngine` and the modules under
`ramanujan_qft.core`, `ramanujan_qft.solvers` and `ramanujan_qft.utils` are kept
for backward compatibility; see {doc}`legacy`.

```{toctree}
:hidden:
:maxdepth: 1

rmt
mellin
one_loop
sunset
legacy
```
