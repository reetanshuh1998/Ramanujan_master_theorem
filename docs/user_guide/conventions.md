# Conventions

The Feynman-integral functions follow the conventions of LoopTools, so that
values can be compared one to one with LoopTools, FF and pySecDec output.

## Kinematics

* **Squared masses.** Every mass argument (`m1sq`, `m2sq`, `m3sq`, `msq`) is a
  squared mass $m^2 \ge 0$. Thresholds are written with the masses themselves,
  for example $(m_1+m_2)^2$.
* **Metric.** Minkowski, $p^2 = p_0^2 - \vec p^{\,2}$. $p^2 > 0$ is time-like,
  and physical thresholds lie at positive $p^2$ or $s$. Euclidean
  (space-like) momenta are $p^2 < 0$.
* **Feynman prescription.** Every propagator is $1/(q^2 - m^2 + i0)$. The $+i0$
  is implemented exactly: imaginary parts come from the analytic structure, not
  from a small numerical width. The resulting signs are listed
  [below](#signs-of-imaginary-parts).

## Loop measure and dimension

Each loop is integrated with

$$
\frac{\mu^{4-D}}{r_\Gamma}\int\frac{d^Dq}{i\pi^{D/2}}, \qquad D = 4-2\epsilon,
\qquad r_\Gamma = \frac{\Gamma^2(1-\epsilon)\,\Gamma(1+\epsilon)}{\Gamma(1-2\epsilon)} .
$$

The factor $1/(i\pi^{D/2})$ makes one-loop integrals real and of order one
below threshold. For UV-finite integrals ($C_0$, the $D=3$ bubble, the sunset
combinations) the factor $r_\Gamma$ and the scale $\mu$ drop out, and the measure is
$d^4q/(i\pi^2)$ (or $d^3q/(i\pi^{3/2})$ for `bubble_3d`).

## The UV pole of B0

$B_0$ is UV divergent. As in LoopTools, the divergence is returned through
the constant

$$
\Delta = \frac{1}{\epsilon} - \gamma_E + \log 4\pi ,
$$

so that

$$
B_0(p^2;m_1^2,m_2^2) = \Delta - \int_0^1 dx\,\log\frac{x m_1^2 + (1-x) m_2^2 - x(1-x)p^2 - i0}{\mu^2} + O(\epsilon).
$$

The parameter `delta` is the value assigned to $\Delta$, and `mu2` is $\mu^2$.
The defaults `delta=0`, `mu2=1` reproduce LoopTools' default output, which is
the $\overline{\rm MS}$ finite part at $\mu^2 = 1$. To obtain the finite part at
another scale, pass `mu2`; to keep track of the pole, pass a symbolic stand-in
value for `delta`, for example `delta=1`, and subtract.

```pycon
>>> import mpmath as mp
>>> from ramanujan_qft import B0
>>> B0(10, 1, 2)
mpc(real='0.62259207309054199', imag='2.0116008064341786')
>>> mp.nstr(B0(10, 1, 2, mu2=4) - B0(10, 1, 2), 12), mp.nstr(mp.log(4), 12)
('(1.38629436112 + 0.0j)', '1.38629436112')
>>> mp.nstr(B0(10, 1, 2, delta=1) - B0(10, 1, 2), 12)
'(1.0 + 0.0j)'
```

## The three-point function

`C0(s, m1sq, m2sq, m3sq)` is $C_0(0,0,s;m_1^2,m_2^2,m_3^2)$, LoopTools'
`C0(0, 0, s, m1sq, m2sq, m3sq)`:

$$
C_0 = \int\frac{d^4q}{i\pi^2}\,
\frac{1}{(q^2-m_1^2)\,((q+k_1)^2-m_2^2)\,((q+k_2)^2-m_3^2)},
\qquad k_1^2 = (k_2-k_1)^2 = 0,\quad k_2^2 = s .
$$

$m_2$ is the line between the two light-like legs, so $m_1 = m_2 = 0$ or
$m_2 = m_3 = 0$ gives a collinear divergence. $C_0$ is symmetric under
$m_1\leftrightarrow m_3$, and its $s$-channel cut opens at $s = (m_1+m_3)^2$.

## The two-loop sunset

$$
S(s) = \int\frac{d^Dk}{i\pi^{D/2}}\,\frac{d^Dl}{i\pi^{D/2}}\;
\frac{1}{(k^2-m_1^2)\,(l^2-m_2^2)\,((p-k-l)^2-m_3^2)}, \qquad s = p^2 ,
$$

with the same per-loop measure. The package provides only UV-finite
combinations ($\operatorname{Im}S$, $S - S(0) - sS'(0)$, $S''$), which do not depend on
the scheme or on $\mu$. See {doc}`sunset`.

## Signs of imaginary parts

With the $+i0$ prescription and the measure above, imaginary parts above
threshold have these signs:

| function | sign of the imaginary part above threshold |
|---|---|
| `B0` | positive, $\operatorname{Im}B_0 = \pi\,\lambda^{1/2}(p^2,m_1^2,m_2^2)/p^2$ |
| `C0` | from the cut formula on the {doc}`one_loop` page; negative in all its examples |
| `bubble_3d` | positive, $\pi^{3/2}/\sqrt{p^2}$ |
| `sunset_im` | negative |

```pycon
>>> p2, m1, m2 = 10, 1, 2
>>> mp.pi * mp.sqrt(p2**2 + m1**2 + m2**2 - 2*p2*m1 - 2*p2*m2 - 2*m1*m2) / p2
mpf('2.0116008064341786')
```

## Converting to other normalisations

* A measure $\int d^Dq/(2\pi)^D$ instead of $\int d^Dq/(i\pi^{D/2})$ multiplies each
  one-loop integral by $i/(16\pi^2)$ in $D = 4$ (and each loop of the sunset by the
  same factor), up to the $\epsilon$-dependent factors that only matter for the
  pole terms.
* Euclidean conventions ($p_E^2 = -p^2$, propagators $1/(q_E^2 + m^2)$): evaluate
  at $p^2 = -p_E^2$.

## Units and numbers

* All quantities are in arbitrary but consistent units: only ratios such as
  $p^2/m^2$ matter, apart from the $\log\mu^2$ of `B0`. Results scale exactly under
  $p^2, m^2, \mu^2 \to \lambda p^2, \lambda m^2, \lambda\mu^2$ ($B_0$ is invariant, $C_0$
  scales as $1/\lambda$, $\operatorname{Im}S$ as $\lambda$).
* Inputs may be ints, floats, strings or mpmath numbers. Floats are exact binary
  numbers; pass strings for exact decimals ({doc}`precision`).
* `dps` is the number of decimal digits requested. Results are `mpmath.mpc` for the
  one-loop functions and `sunset_subtracted`, and `mpmath.mpf` for `sunset_im`,
  `sunset_d2` and `sunset_threshold`.
