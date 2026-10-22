# Two-loop sunset

The module `ramanujan_qft.sunset` provides the **scheme-independent** parts of the
massive two-loop sunset (sunrise) self-energy

$$
S(s; m_1^2, m_2^2, m_3^2) = \int \frac{d^Dk}{i\pi^{D/2}}\,\frac{d^Dl}{i\pi^{D/2}}\;
\frac{1}{(k^2-m_1^2)\,(l^2-m_2^2)\,((p-k-l)^2-m_3^2)}, \qquad s = p^2,
$$

with $+i0$ on every propagator and $D = 4-2\epsilon$. This is the same per-loop
measure as LoopTools and pySecDec.

| Function | Returns |
|---|---|
| {py:func}`sunset_threshold(m1sq, m2sq, m3sq) <ramanujan_qft.sunset.sunset_threshold>` | the three-particle threshold $(m_1+m_2+m_3)^2$ |
| {py:func}`sunset_im(s, m1sq, m2sq, m3sq, dps=None) <ramanujan_qft.sunset.sunset_im>` | $\operatorname{Im} S(s)$, zero below threshold |
| {py:func}`sunset_subtracted(s, m1sq, m2sq, m3sq, dps=None) <ramanujan_qft.sunset.sunset_subtracted>` | $S(s) - S(0) - s\,S'(0)$, complex above threshold |
| {py:func}`sunset_d2(s, m1sq, m2sq, m3sq, dps=None) <ramanujan_qft.sunset.sunset_d2>` | $S''(s)$, below threshold |

**What is not provided.** The sunset is UV divergent. Its divergences, and hence
its scheme dependence, sit in a polynomial of first degree in $s$. The
combinations above are finite and the same in every scheme. The full finite part
also needs the constants $S(0)$ and $S'(0)$. They are known in closed form
(Davydychev and Tausk, Nucl. Phys. B 397 (1993) 123) but are **not implemented**
here. For complete two-loop self-energies, use TSIL.

As in the rest of the package, masses are **squared** masses and `dps` is the
number of decimal digits. The results are certified (see {doc}`precision`). The
examples use:

```python
import mpmath as mp
from ramanujan_qft import sunset_threshold, sunset_im, sunset_subtracted, sunset_d2
```

## The imaginary part

Above the threshold $s > (m_1+m_2+m_3)^2$, the imaginary part is an exact
one-dimensional phase-space integral over the invariant mass $t$ of one pair of
lines:

$$
\operatorname{Im} S(s) = -\frac{\pi}{s}\int_{(m_2+m_3)^2}^{(\sqrt s-m_1)^2} dt\;
\frac{\lambda^{1/2}(s,t,m_1^2)\,\lambda^{1/2}(t,m_2^2,m_3^2)}{t},
$$

where $\lambda(a,b,c) = a^2+b^2+c^2-2ab-2bc-2ca$ is the Källén function.

```pycon
>>> sunset_threshold(1, 2, 3)
mpf('17.191508225450303')
>>> sunset_im(100, 1, 2, 3)
mpf('-88.184995551555915')
>>> sunset_im(10, 1, 2, 3)                   # below threshold
mpf('0.0')
>>> mp.nstr(sunset_im(100, 1, 2, 3, dps=50), 50)
'-88.184995551555914710284131980016002689913916914772'
```

`sunset_im` takes a fraction of a second, even at 50 digits.

For masses $(0, 0, M)$ there is a closed form,
$\operatorname{Im} S = -\pi\big[(s^2-M^2)/(2s) - M\log(s/M)\big]$ for $s > M$
(with $M$ the squared mass):

```pycon
>>> sunset_im(10, 0, 0, 1)
mpf('-8.3170992228540115')
>>> -mp.pi * ((10**2 - 1) / (2 * 10) - mp.log(10))
mpf('-8.3170992228540115')
```

**How it is computed.** The problem is first scaled to unit threshold by the exact
homogeneity $\operatorname{Im}S(\lambda s;\lambda m^2) = \lambda\,\operatorname{Im}S(s;m^2)$.
The Källén functions are used in factored form, with the substitution
$t = t_- + w\sin^2(u/2)$, so that the width $w$ of the integration range is formed
without cancellation, even very close to threshold. Every quadrature checks its
error estimate against a relative tolerance. The result is certified by
evaluation at two working precisions.

## The subtracted sunset

$S(s) - S(0) - s\,S'(0)$ follows from the twice-subtracted dispersion relation

$$
S(s) - S(0) - s\,S'(0) = \frac{s^2}{\pi}\int_{s_{\rm th}}^\infty dt\;
\frac{\operatorname{Im}S(t)}{t^2\,(t - s - i0)} ,
$$

which needs `sunset_im` inside an outer integral. Above threshold the principal
value is taken by subtracting the integrand at $t = s$; the $-i0$ gives the
imaginary part, $\operatorname{Im}S(s)$. The infinite tail is mapped to a finite
interval with $t = 1/v$.

```pycon
>>> sunset_subtracted(20, 1, 2, 3)
mpc(real='-5.1100935200526116', imag='-0.37584965333842213')
>>> sunset_im(20, 1, 2, 3)                   # the imaginary part above
mpf('-0.37584965333842213')
```

Checked against the closed form for masses $(0,0,M)$,
$S(s)-S(0)-sS'(0) = G(s) - M/2 - \tfrac54 s$ with
$G(s) = \frac{s^2-M^2}{2s}\log(1-s/M) + M\,\mathrm{Li}_2(s/M)$ at $s\to s+i0$:

```pycon
>>> v = sunset_subtracted(10, 0, 0, 1)
>>> with mp.workdps(30):
...     s, M = mp.mpf(10), mp.mpf(1)
...     G = (s**2 - M**2) / (2 * s) * mp.mpc(mp.log(s / M - 1), -mp.pi) \
...         + M * mp.mpc(mp.polylog(2, s / M).real, mp.pi * mp.log(s / M))
...     exact = G - M / 2 - 5 * s / 4
>>> mp.nstr(v, 15), mp.nstr(exact, 15)
('(-1.58743705482785 - 8.31709922285401j)', '(-1.58743705482785 - 8.31709922285401j)')
```

## The second derivative

Below threshold, $S''(s) = \frac{2}{\pi}\int_{s_{\rm th}}^\infty dt\,
\operatorname{Im}S(t)/(t-s)^3$ is finite and real:

```pycon
>>> sunset_d2(10, 1, 2, 3)
mpf('-0.027076472707398637')
>>> sunset_d2(20, 1, 2, 3)
Traceback (most recent call last):
  ...
ValueError: sunset_d2 is implemented below threshold only
```

## Cost

| call | time (15 digits) |
|---|---|
| `sunset_im` | 0.02–0.1 s (0.2 s at 50 digits) |
| `sunset_subtracted`, `sunset_d2` | about 10–20 s; up to about 40 s far above threshold |

`sunset_subtracted` and `sunset_d2` run a nested quadrature twice, at two working
precisions, and each inner point is a full `sunset_im` evaluation. TSIL, a
compiled C library for all two-loop self-energies, is much faster. Use these
functions for independent high-precision checks, not for scans over many points.

## Errors and limitations

* `ValueError`: a negative squared mass, a non-finite input, `sunset_d2` at or
  above threshold, or `sunset_subtracted` with all three masses zero (then
  $S'(0)$ does not exist).
* Exactly at threshold, the dispersion integral of `sunset_subtracted` is not
  evaluated. Depending on how the threshold value rounds, you get a `ValueError`
  or an `ArithmeticError` ("quadrature did not converge"), never a value. Points
  close to threshold are fine.
* `ArithmeticError` signals that a quadrature or the two-precision certification
  failed, instead of returning an uncertified value.
* Only $\operatorname{Im}S$, $S - S(0) - sS'(0)$ and $S''$ are provided; see
  above.

## Validation

* Independent two-dimensional Feynman-parameter integrations (SciPy `dblquad`)
  of $\operatorname{Im}S$, $S''$ and the subtracted $S$ agree to $10^{-8}$ to
  $10^{-14}$, at points below, near and above threshold.
* The closed form for masses $(0,0,M)$, at scales from $10^{-12}$ to $10^{12}$
  and within $10^{-12}$ of threshold, agrees to the requested digits.
* Exact homogeneity under $s, m^2 \to \lambda s, \lambda m^2$ for
  $\lambda = 2^{-60}$ to $2^{40}$, and independence of which mass is integrated
  outside.
* The audit that hardened these functions is summarised on the
  {doc}`/validation` page.

## See also

* Gallery: {ref}`sphx_glr_auto_examples_04_sunset_dispersion.py`.
* {doc}`one_loop`, {doc}`conventions`, {doc}`precision`.
* A. I. Davydychev, J. B. Tausk, *Two-loop self-energy diagrams with different
  masses and the momentum expansion*, Nucl. Phys. B 397 (1993) 123.
* S. P. Martin, D. G. Robertson, *TSIL: a program for the calculation of
  two-loop self-energy integrals*, Comput. Phys. Commun. 174 (2006) 133.
