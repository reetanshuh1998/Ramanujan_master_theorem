# One-loop integrals

The module `ramanujan_qft.one_loop` provides scalar one-loop integrals at any
precision, in the conventions of LoopTools, so that results can be compared one
to one:

| Function | Integral |
|---|---|
| {py:func}`B0(p2, m1sq, m2sq, mu2=1, delta=0, dps=None) <ramanujan_qft.one_loop.B0>` | two-point function, any masses |
| {py:func}`B0_mob(p2, msq, mu2=1, delta=0, dps=None) <ramanujan_qft.one_loop.B0_mob>` | equal-mass two-point function from its Method-of-Brackets series |
| {py:func}`C0(s, m1sq, m2sq, m3sq, dps=None) <ramanujan_qft.one_loop.C0>` | three-point function $C_0(0,0,s;m_1^2,m_2^2,m_3^2)$ |
| {py:func}`C0_mob(s, msq, dps=None) <ramanujan_qft.one_loop.C0_mob>` | equal-mass $C_0(0,0,s;m^2,m^2,m^2)$ from its closed MoB form |
| {py:func}`bubble_3d(p2, m1sq, m2sq, dps=None) <ramanujan_qft.one_loop.bubble_3d>` | the finite two-point function in $D=3$ |

All masses are **squared** masses. The metric is Minkowski, so $p^2>0$ is
time-like, and propagators carry the Feynman $+i0$. {doc}`conventions` gives the
normalisation in full. Every function returns an `mpmath.mpc` and is
*certified* to `dps` digits (see {doc}`precision`).

The examples use:

```python
import mpmath as mp
from ramanujan_qft import B0, B0_mob, C0, C0_mob, bubble_3d
```

## B0

$$
B_0(p^2; m_1^2, m_2^2) = \frac{\mu^{4-D}}{i\pi^{D/2}\,r_\Gamma}\int d^Dq\,
\frac{1}{(q^2-m_1^2+i0)\,((q+p)^2-m_2^2+i0)}
= \Delta - \int_0^1 dx\,\log\frac{x m_1^2 + (1-x) m_2^2 - x(1-x)p^2 - i0}{\mu^2}
$$

with $D = 4-2\epsilon$ and $\Delta = 1/\epsilon - \gamma_E + \log 4\pi$. As in
LoopTools, `delta` is the value given to $\Delta$ (default 0) and `mu2` is
$\mu^2$ (default 1). The Feynman-parameter integral is done in closed form from
the roots of the quadratic. The $-i0$ fixes the imaginary part exactly, as
$-\pi$ times the length of the interval where the argument is negative.

```pycon
>>> B0(10, 1, 2)
mpc(real='0.62259207309054199', imag='2.0116008064341786')
>>> B0(10, 1, 2, mu2=4)            # adds log 4 to the real part
mpc(real='2.0088864342104324', imag='2.0116008064341786')
>>> B0(10, 1, 2, delta=1)          # adds delta
mpc(real='1.6225920730905419', imag='2.0116008064341786')
>>> mp.nstr(B0(10, 1, 2, dps=40), 40)
'(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)'
```

LoopTools 2.16 gives `0.622592073090541875 + 2.01160080643417860 i` for the first
call. Massless lines and $p^2 = 0$ are allowed. The only excluded case is
$B_0(0;0,0)$, which is scaleless and vanishes in dimensional regularisation:

```pycon
>>> B0(3, 0, 1)
mpc(real='1.5379018796267032', imag='2.0943951023931957')
>>> B0(0, 1, 2)
mpc(real='-0.38629436111989063', imag='0.0')
>>> B0(0, 0, 0)
Traceback (most recent call last):
  ...
ValueError: B0(0; 0, 0) is scaleless (zero in dimensional regularisation)
```

## B0_mob: the Method-of-Brackets series

For equal masses, the Method of Brackets (Ramanujan's Master Theorem applied to
the Feynman-parameter integral) gives
$B_0(\epsilon) = \Gamma(\epsilon)\,(m^2)^{-\epsilon}\,{}_2F_1(\epsilon,1;\tfrac32;w)$.
Expanding in $\epsilon$ gives the exact series

$$
B_0 = \Delta - \log\frac{m^2}{\mu^2} + \sum_{n\ge1}\frac{\Gamma(n)}{(3/2)_n}\,w^n
= \Delta - \log\frac{m^2}{\mu^2} + \frac{2w}{3}\,{}_2F_1\!\left(1,1;\tfrac52;w\right),
\qquad w = \frac{p^2}{4m^2}.
$$

The series converges below the threshold $w = 1$. Above it, the code continues
${}_2F_1$ with $w \to w + i0$. `B0_mob(p2, msq)` takes a single positive squared
mass. It agrees with `B0` below and above threshold:

```pycon
>>> B0_mob(2, 1), B0(2, 1, 1)                  # below threshold, w = 1/2
(mpc(real='0.42920367320510339', imag='0.0'), mpc(real='0.42920367320510339', imag='0.0'))
>>> B0_mob(8, 1), B0(8, 1, 1)                  # above threshold, w = 2
(mpc(real='0.75354951971953898', imag='2.2214414690791831'), mpc(real='0.75354951971953898', imag='2.2214414690791831'))
```

## C0

$$
C_0(0,0,s;m_1^2,m_2^2,m_3^2) = \int\frac{d^4q}{i\pi^2}\,
\frac{1}{(q^2-m_1^2)\,((q+k_1)^2-m_2^2)\,((q+k_2)^2-m_3^2)},
\qquad k_1^2 = 0,\ (k_2-k_1)^2 = 0,\ k_2^2 = s,
$$

each propagator with $+i0$. This is LoopTools' `C0(0, 0, s, m1sq, m2sq, m3sq)`.
The integral is finite in four dimensions, symmetric under $m_1 \leftrightarrow m_3$,
and develops an imaginary part above the threshold $s = (m_1+m_3)^2$.

The code evaluates:

* for equal masses, the closed form of `C0_mob` (below);
* for unequal masses, the 't Hooft–Veltman dilogarithm reduction for the real
  part, and the exact Feynman-parameter result for the imaginary part
  ($-\tfrac{\pi}{s}\log|\alpha(b_+)/\alpha(b_-)|$ between the clipped roots
  $b_\pm$ of the cut);
* at $s = 0$, the exact divided-difference form $-f[m_1^2,m_2^2,m_3^2]$, with
  $f(m) = m\log m$.

```pycon
>>> C0(10, 1, 2, 3)
mpc(real='-0.42193253167473543', imag='-0.33673226803368017')
>>> C0(1, 1, 2, 3)                               # below threshold: real
mpc(real='-0.27415567780803773', imag='0.0')
>>> C0(10, 1, 2, 3) == C0(10, 3, 2, 1)           # m1 <-> m3 symmetry
True
>>> C0(0, 1, 2, 3)
mpc(real='-0.26162407188227393', imag='0.0')
```

LoopTools 2.16 gives `-0.421932531674735434 - 0.336732268033680282 i` and
`-0.274155677808037845` for the first two calls.

**Massless lines.** A massless internal line is allowed when the integral is
infrared finite. $m_1 = m_2 = 0$ or $m_2 = m_3 = 0$ gives a collinear
divergence, which is refused. (At $s = 0$, two vanishing masses are refused as
well.)

```pycon
>>> C0(10, 0, 1, 2)
mpc(real='-0.1584077038516892', imag='-0.69027845904464058')
>>> C0(10, 0, 0, 1)
Traceback (most recent call last):
  ...
ValueError: C0(0,0,s) with m1 = m2 = 0 or m2 = m3 = 0 is IR (collinear) divergent
```

**Extreme kinematics.** The results are certified, so mass hierarchies and
$s \ll m^2$ or $s \gg m^2$ do not lose digits. An example from
{doc}`/COMPARISON`, where LoopTools 2.16 in double precision returns −0.69637 and
an independent 90-digit quadrature agrees with the value below:

```pycon
>>> mp.nstr(C0(2.1973609307495493e-11, 8.481053224196959e-10, 8.48190132951938e-10, 35.105214341025246, dps=30), 30)
'(-0.667886990750413124461885162239 + 0.0j)'
```

The inputs are the binary floats as written; see {doc}`precision` for decimal
inputs.

## C0_mob: the equal-mass closed form

For equal masses the Method of Brackets gives
$C_0 = -\frac{1}{2m^2}\big[{}_2F_1(\tfrac12,\tfrac12;\tfrac32;\tfrac{s}{4m^2})\big]^2
= -\frac{2}{s}\arcsin^2\!\sqrt{s/4m^2}$. Its continuation to all real $s$ is

$$
C_0 = \frac{1}{2s}\log^2\frac{\beta-1}{\beta+1}, \qquad \beta = \sqrt{1 - \frac{4m^2}{s+i0}} .
$$

```pycon
>>> C0_mob(2, 1), C0(2, 1, 1, 1)
(mpc(real='-0.61685027506808487', imag='0.0'), mpc(real='-0.61685027506808487', imag='0.0'))
>>> -(mp.pi / 4)**2          # -(2/s) arcsin^2(sqrt(s/4m^2)) at s = 2, m^2 = 1, where arcsin(sqrt(1/2)) = pi/4
mpf('-0.61685027506808487')
```

## bubble_3d: the D = 3 bubble

The two-point function is finite in three dimensions. With the measure
$d^3q/(i\pi^{3/2})$ it equals
$\Gamma(\tfrac12)\int_0^1 dx\,(\Delta(x) - i0)^{-1/2}$, with $\Delta(x)$ as for
`B0`. With $M = m_1 + m_2$ (the masses, not squared) the closed form is:

* $p^2<0$: $\sqrt\pi\,\frac{2}{Q}\arctan\frac{Q}{M}$, where $Q=\sqrt{-p^2}$;
* $0<p^2<M^2$: $\sqrt\pi\,\frac{2}{k}\operatorname{artanh}\frac{k}{M}$, where $k=\sqrt{p^2}$;
* $p^2>M^2$: $\sqrt\pi\,\frac{2}{k}\big[\tfrac12\log\frac{k+M}{k-M} + \tfrac{i\pi}{2}\big]$.

Exactly at threshold, $p^2 = M^2$, the integral diverges and `ValueError` is
raised. The scaleless case $p^2 = 0$ with $M = 0$ raises too.

```pycon
>>> bubble_3d(10, 1, 2)
mpc(real='1.1259454203297292', imag='1.7608599228871051')
>>> bubble_3d(-5, 1, 1)
mpc(real='1.3333721684892301', imag='0.0')
```

## Errors

| Exception | When |
|---|---|
| `ValueError` | a negative squared mass, a non-finite input, `mu2 <= 0`, a scaleless or IR-divergent configuration, `bubble_3d` exactly at threshold, `B0_mob`/`C0_mob` with a zero mass |
| `ArithmeticError` | certification failed: two working precisions did not agree within the precision cap (not observed in the tests; it would signal a numerical problem rather than return a wrong value) |

## Cost

Measured on one machine (Python 3.13):

| call | 15 digits | 50 digits | 100 digits | LoopTools 2.16 (double) |
|---|---|---|---|---|
| `C0(10, 1, 2, 3)` | ~10 ms | ~21 ms | ~40 ms | 24 µs |
| `B0(5, 1, 1)` | ~0.3 ms | ~0.3 ms | ~0.9 ms | 0.8 µs |

LoopTools is several hundred times faster at double precision, as expected for
compiled Fortran against multiprecision Python. Use ramanujan-qft for reference
values at 30–100 or more digits, to validate a double-precision code, or for
kinematics with severe cancellation. See {doc}`/COMPARISON`.

## Validation

* LoopTools 2.16: 21 reference values (`tests/data/looptools_reference.csv`)
  agree to double-precision round-off at 15, 30 and 60 working digits. The full
  table is on the {doc}`/validation` page.
* Independent quadrature of the Feynman-parameter integrals, at 30 digits.
* `B0_mob` against `B0` to 50 digits below and above threshold; `C0_mob` against
  the arcsin form; continuity of `C0` at the equal-mass limit.
* An audit round of 1,820 random cases at 15, 30 and 50 digits, with masses from
  $10^{-12}$ to $10^{12}$, thresholds and pseudo-thresholds included. Where the
  package and LoopTools disagreed at extreme hierarchies, a 90-digit quadrature
  sided with the package.

## See also

* Gallery: {ref}`sphx_glr_auto_examples_03_one_loop_integrals.py`.
* {doc}`conventions`, {doc}`precision`, {doc}`sunset`.
* T. Hahn, M. Pérez-Victoria, *Automatized one-loop calculations in four and D
  dimensions*, Comput. Phys. Commun. 118 (1999) 153 (LoopTools).
* G. 't Hooft, M. Veltman, *Scalar one-loop integrals*, Nucl. Phys. B 153 (1979) 365.
* A. Denner, *Techniques for the calculation of electroweak radiative corrections
  at the one-loop level*, Fortsch. Phys. 41 (1993) 307.
