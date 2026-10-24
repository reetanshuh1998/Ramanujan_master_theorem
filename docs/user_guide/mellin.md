# Product integrals by Mellin residue summation

{py:func}`~ramanujan_qft.mellin.product_integral` evaluates

$$
I(s) = \int_0^\infty x^{s-1}\, f(x)\, g(x)\, dx
$$

for two factors taken from a small *atlas* of functions with known Mellin
transforms: exponentials, Gaussians, Bessel $J_\nu$, cosines, sines, inverse
powers $(x+m)^{-v}$ and the Gaussian–Bessel product $e^{-ax^2}J_\nu(bx)$. It
sums a residue series. For some high-frequency products this requires fewer
terms than resolving the oscillations by quadrature. Cost depends on the
selected expansion, cancellation and requested precision; work budgets apply.

The method is the classical Mellin-convolution (Meijer-G / Slater) residue
expansion of Marichev, Adamchik–Marichev and others. SymPy's `meijerint` and
mpmath's `meijerg` rest on the same theory. See {doc}`/PRIOR_ART`. The module
checks the convergence strip and contour closure, raises working precision
against cancellation, and reports an error if its accuracy checks fail.

The examples on this page use these imports:

```python
import mpmath as mp
from ramanujan_qft import (product_integral, exponential, gaussian, bessel_j, cosine, sine,
                           inverse_power, gaussian_bessel, SeriesConvergenceError)
```

## A first example

$\int_0^\infty e^{-2x}\cos 5x\,dx = 2/29$:

```pycon
>>> product_integral(exponential(2), cosine(5))
mpf('0.068965517241379309')
>>> mp.mpf(2) / 29
mpf('0.068965517241379309')
```

The third argument, `s`, selects the Mellin transform of the product. Here it is
$\int_0^\infty x^{-1/2} e^{-2x}\sin x\,dx = \Gamma(\tfrac12)\,5^{-1/4}\sin(\tfrac12\arctan\tfrac12)$:

```pycon
>>> mp.nstr(product_integral(exponential(2), sine(1), s="0.5", dps=20), 20)
'0.27232873955224408453'
>>> with mp.workdps(20):
...     half = mp.mpf(1) / 2
...     mp.nstr(mp.gamma(half) * 5**(-half / 2) * mp.sin(mp.atan(half) / 2), 20)
'0.27232873955224408453'
```

A high-frequency example is $\int_0^\infty e^{-x}\cos(10^6 x)\,dx = 1/(1+10^{12})$
to 20 digits:

```pycon
>>> mp.nstr(product_integral(exponential(1), cosine(10**6), dps=20), 20)
'9.99999999999e-13'
>>> with mp.workdps(20):
...     mp.nstr(1 / (1 + mp.mpf(10)**12), 20)
'9.99999999999e-13'
```

(`mp.nstr` drops trailing zeros. Both values are $9.99999999999000000000\ldots\times 10^{-13}$.)

## The atlas

Each constructor returns a {py:class}`~ramanujan_qft.mellin.MellinFunction`. The
parameters must be real, finite and positive, except the Bessel order. Pass
decimal values as strings (`"0.1"`) to keep them exact; see
{doc}`precision`.

| Constructor | $f(x)$ | Mellin transform $M(s)=\int_0^\infty x^{s-1}f(x)\,dx$ | $L$ | $R$ | scale $c$ |
|---|---|---|---|---|---|
| `exponential(k)` | $e^{-kx}$ | $k^{-s}\,\Gamma(s)$ | 1 | 1 | $k$ |
| `gaussian(a)` | $e^{-ax^2}$ | $\tfrac12\,a^{-s/2}\,\Gamma(s/2)$ | ½ | ½ | $\sqrt{2a}$ |
| `bessel_j(nu, b)` | $J_\nu(bx)$ | $2^{s-1}\,b^{-s}\,\Gamma\!\big(\tfrac{\nu+s}{2}\big)\big/\Gamma\!\big(\tfrac{\nu-s}{2}+1\big)$ | 1 | 1 | $b$ |
| `cosine(b)` | $\cos bx$ | $b^{-s}\,\Gamma(s)\cos(\pi s/2)$ | 1 | 1 | $b$ |
| `sine(b)` | $\sin bx$ | $b^{-s}\,\Gamma(s)\sin(\pi s/2)$ | 1 | 1 | $b$ |
| `inverse_power(m, v)` | $(x+m)^{-v}$ | $m^{s-v}\,\Gamma(s)\,\Gamma(v-s)/\Gamma(v)$ | 0 | 0 | $1/m$ |
| `gaussian_bessel(a, b, nu)` | $e^{-ax^2}J_\nu(bx)$ | $\dfrac{(b/2)^\nu\,\Gamma(h)}{2\,a^{h}\,\Gamma(\nu+1)}\;{}_1F_1\!\big(h;\nu+1;-\tfrac{b^2}{4a}\big)$, $h=\tfrac{s+\nu}{2}$ | — | ½ | $\sqrt{2a}$ |

* `bessel_j` accepts a real order $\nu > -1$, or a negative integer, which it
  maps to $J_{-n} = (-1)^n J_n$. Complex orders raise `ValueError`.
* `inverse_power` also carries its expansion at large $x$,
  $(x+m)^{-v} = \sum_n \binom{-v}{n} m^n x^{-v-n}$. Its residue series therefore
  contains a second sum.
* `gaussian_bessel` has no usable Taylor expansion here ($L$ is undefined), so it
  can only be the factor that is *not* expanded. This is how three-factor
  products such as $e^{-2x}\,e^{-x^2/2}\,J_1(100x)$ are handled.
* A factor can be evaluated directly, which is useful for quick checks:
  `exponential(1)(2)` returns `mpf('0.1353352832366127')`.

$L$ and $R$ are the *Gamma orders* of the factor. They describe how fast its
Taylor coefficients decay, $|r(p)| \sim c^{p}/\Gamma(p)^{L}$, and how fast its
Mellin transform grows, $|M(w)| \sim \Gamma(w)^{R}/c^{w}$ as $w\to+\infty$.
They decide which expansions are legitimate (next section).

## How it works

By the Mellin–Parseval formula,

$$
I(s) = \frac{1}{2\pi i}\int_{c-i\infty}^{c+i\infty} M_f(z)\, M_g(s-z)\, dz .
$$

Closing the contour to the left picks up two families of poles. The poles of
$M_f$ sit at the Taylor exponents $p_n$ of $f$ at $x=0$, and their residues are
the Taylor coefficients $r_n$; this is Ramanujan's Master Theorem. If $g$ has an
expansion $g \sim \sum q_n x^{-a_n}$ at large $x$, $M_g(s-z)$ contributes poles
at $z = s - a_n$. Together,

$$
I(s) = \sum_{n\ge0} r_n\, M_g(s+p_n) \;+\; \sum_{n\ge0} q_n\, M_f(s-a_n).
$$

This is "expanding $f$ against $g$". The engine works through these steps:

1. **Existence.** It computes the strip $\sigma_- < \operatorname{Re}s < \sigma_+$
   where the integral exists. The lower edge comes from the leading powers at
   $x=0$. The upper edge comes from the decay at $\infty$; for two oscillating
   factors it includes the extra unit from oscillation. Products with equal
   frequencies are treated separately, because there a non-oscillating beat term
   survives unless the phases differ by an odd multiple of $\pi/2$. Outside the
   strip it raises `ValueError` (see `continuation` below).
2. **Validity.** Closing the contour is legitimate only if the integrand decays
   on the arc. Expanding $f$ against $g$ is valid if and only if
   $L_f > R_g$, or $L_f = R_g$ and $\rho = c_f/c_g < 1$. When $L_f > R_g$ the
   series converges factorially; when $L_f = R_g$ it converges geometrically,
   with ratio $\rho$. Both orderings are tried. An invalid ordering gives a
   divergent asymptotic series, which would return silently wrong values, so it
   is never used. $\rho = 1$ is the convergence boundary and no value is returned
   there.
3. **Summation.** The terms are summed until they are past their a-priori peak
   (which includes the shifts of the Gamma arguments by $s$, $v$ and $\nu$) and
   the estimated tail is below `tol` relative to the sum.
4. **Cancellation.** The ratio $\sum|t_n| / |\sum t_n|$ measures how many digits
   cancel. The working precision is raised until the requested digits survive
   that cancellation, up to `max_dps`.
5. **Slow series.** For $\rho > 0.85$ and alternating terms, the Wynn
   $\varepsilon$ algorithm accelerates the sum. Its error estimate compares two
   disjoint windows of partial sums.
6. **Coinciding poles.** When poles of the two families coincide, the result
   contains logarithms. The engine then evaluates at $s\pm\delta$ and
   $s\pm2\delta$ and Richardson-extrapolates. $\delta$ is scaled to the distance
   from the nearest edge of the strip.

`return_info=True` shows what happened: the expansion used, the error estimate,
the number of terms and the final working precision.

```pycon
>>> value, info = product_integral(gaussian(1), cosine(3), return_info=True)
>>> value
mpf('0.093407630728565852')
>>> info
{'method': 'expand cos(3 x)', 'error_estimate': mpf('4.1341518148592734e-17'), 'terms': 31, 'working_dps': 30}
>>> mp.sqrt(mp.pi) / 2 * mp.exp(-mp.mpf(9) / 4)          # closed form
mpf('0.093407630728565838')
```

The two values differ by $1.5\times10^{-16}$ relative, within the default 15
digits. The cosine was expanded ($L=1 > R=\tfrac12$). Expanding the Gaussian
against the cosine is invalid, and summing it anyway gives the incorrect
answer 0.

## Options

`product_integral(f, g, s=1, dps=None, tol=None, max_terms=4000, return_info=False, continuation=False, max_dps=None)`

`s`
: The Mellin variable; `s=1` is the plain integral. Complex values are allowed.
  Strings are taken as exact decimals.

`dps`
: Decimal digits requested. The default is the global `mp.mp.dps`, 15 unless you
  changed it. The result is rounded to `dps` digits.

`tol`
: Relative accuracy target. The default is $10^{-\mathrm{dps}}$. If the best
  error estimate is more than ten times `tol` relative to the value,
  `SeriesConvergenceError` is raised.

`max_terms`
: The largest number of residue terms per series (default 4000). Series that
  need more raise `SeriesConvergenceError`.

`return_info`
: Also return a dict with `method`, `error_estimate`, `terms` and `working_dps`.
  `method` names the expanded factor. It notes the Wynn acceleration or the
  symmetric evaluation at coinciding poles when they were used.

`continuation`
: Allow `s` outside the strip where the integral exists and return the analytic
  continuation of $I(s)$.

`max_dps`
: Cap on the internal working precision. The default is `max(20*dps, 1000)`.

Examples of the options:

```pycon
>>> mp.nstr(product_integral(exponential(1), bessel_j(0, 3), dps=40), 40)
'0.316227766016837933199889354443271853372'
>>> with mp.workdps(40):
...     mp.nstr(1 / mp.sqrt(10), 40)
'0.316227766016837933199889354443271853372'
>>> product_integral(exponential(2), cosine(1), s=-0.5)
Traceback (most recent call last):
  ...
ValueError: Int x^(s-1) exp(-2 x) * cos(1 x) dx diverges for Re s = -0.5; it exists for 0.0 < Re s < +inf (pass continuation=True for the analytic continuation)
>>> product_integral(exponential(2), cosine(1), s=-0.5, continuation=True)
mpf('-5.1590696909850546')
>>> mp.gamma(-0.5) * mp.mpf(5)**0.25 * mp.cos(mp.atan(0.5) / 2)   # Gamma(s) |2+i|^(-s) cos(s arg(2+i))
mpf('-5.1590696909850546')
```

## Errors and refusals

`ValueError`
: The integral does not exist for this `s`. The message gives the strip.
  `ValueError` is also raised for invalid factor parameters, such as `k <= 0` or
  a complex Bessel order, and for a non-finite `s`.

`SeriesConvergenceError` (a subclass of `ArithmeticError`)
: No valid expansion reached the accuracy target. This happens in three cases:
  the scales sit on the convergence boundary $\rho = 1$; the series needs more
  than `max_terms` terms; or the precision needed exceeds `max_dps`. The message
  says which. Use quadrature or a closed form for these integrals.

$\int_0^\infty \cos x\,\cos 2x\,dx$ diverges at infinity, since the strip is
$0 < \operatorname{Re}s < 1$:

```pycon
>>> product_integral(cosine(1), cosine(2))
Traceback (most recent call last):
  ...
ValueError: Int x^(s-1) cos(1 x) * cos(2 x) dx diverges for Re s = 1.0; it exists for 0.0 < Re s < 1.0 (pass continuation=True for the analytic continuation)
```

$\int_0^\infty e^{-x}J_0(x)\,dx = 1/\sqrt2$ exists, but it sits on the convergence
boundary $\rho=1$:

```pycon
>>> product_integral(exponential(1), bessel_j(0, 1))
Traceback (most recent call last):
  ...
ramanujan_qft.mellin.SeriesConvergenceError: neither ordering of exp(-1 x) * J_0(1 x) is a convergent residue expansion (the scales are at the convergence boundary rho = 1, or the factors cannot be expanded). Use quadrature or a closed form.
```

Close to the boundary the series converges slowly. At $\rho = 1/1.01$, the
alternating series is accelerated by Wynn's algorithm. With a low `max_terms`
the same call is refused:

```pycon
>>> product_integral(exponential(1), bessel_j(0, "1.01"), return_info=True)
(mpf('0.70358012959608052'), {'method': 'expand exp(-1 x) + Wynn-epsilon', 'error_estimate': mpf('3.40206030430895e-17'), 'terms': 239, 'working_dps': 43})
>>> 1 / mp.sqrt(1 + mp.mpf("1.01")**2)
mpf('0.70358012959608052')
>>> product_integral(exponential(1), bessel_j(0, "1.01"), max_terms=50)
Traceback (most recent call last):
  ...
ramanujan_qft.mellin.SeriesConvergenceError: valid residue expansion of exp(-1 x) * J_0(1.01 x) did not reach the target (expand exp(-1 x): not converged after 50 terms (rho = 0.9901)). Use quadrature or a closed form.
```

## More examples

**Three-factor product.** $\int_0^\infty e^{-2x}\,e^{-x^2/2}\,J_1(bx)\,dx$
is `exponential(2)` against `gaussian_bessel("0.5", b, 1)`. At $b=1$ the integrand
does not oscillate much, and mpmath's quadrature agrees:

```pycon
>>> product_integral(exponential(2), gaussian_bessel("0.5", 1, 1))
mpf('0.072735927988686319')
>>> mp.quad(lambda x: mp.exp(-2*x - x**2/2) * mp.besselj(1, x), [0, mp.inf])
mpf('0.072735927988686319')
>>> mp.nstr(product_integral(exponential(2), gaussian_bessel("0.5", 100, 1), dps=30), 30)
'0.00980001000675268801870689780916'
```

**Inverse powers.** $\int_0^\infty x\,e^{-x}(x+1)^{-1/2}dx = \Gamma(2)\,U(2, \tfrac52, 1)$,
with Tricomi's confluent hypergeometric function $U$:

```pycon
>>> product_integral(exponential(1), inverse_power(1, "0.5"), s=2)
mpf('0.6210639219293439')
>>> mp.gamma(2) * mp.hyperu(2, 2.5, 1)
mpf('0.6210639219293439')
```

**Coinciding poles (a logarithmic result).** $\int_0^\infty e^{-x}/(1+x)\,dx = e\,E_1(1)$.
Both families of poles hit the integers here:

```pycon
>>> product_integral(exponential(1), inverse_power(1, 1), return_info=True)
(mpf('0.59634736232319407'), {'method': 'expand exp(-1 x) (coinciding poles: symmetric evaluation at s +- delta)', 'error_estimate': mpf('1.4630487432904594e-18'), 'terms': 26, 'working_dps': 66})
>>> mp.e * mp.e1(1)
mpf('0.59634736232319407')
```

**Discontinuous integrals.** The Weber–Schafheitlin integral
$\int_0^\infty J_0(ax)\cos(bx)\,dx$ equals $1/\sqrt{a^2-b^2}$ for $b<a$ and $0$
for $b>a$. The engine picks the right branch from the scales:

```pycon
>>> product_integral(bessel_j(0, 2), cosine(1))
mpf('0.57735026918962573')
>>> 1 / mp.sqrt(3)
mpf('0.57735026918962584')
>>> product_integral(bessel_j(0, 1), cosine(2))
mpf('0.0')
```

The gallery example {ref}`sphx_glr_auto_examples_02_mellin_products.py` has more,
including cases at high frequency.

## Performance

The [current accuracy-checked comparison](../COMPARISON.md) measures RACE,
`mpmath.quadosc`, tanh–sinh, Gauss–Legendre and closed-form evaluation at 30
digits. RACE takes about 0.7–5.1 ms on those four inputs and outperforms the
successful quadrature baselines. Closed forms remain faster where available.
The report records missed accuracy targets separately and supports no general
speed claim for other integrals or precisions.

## Defining new factors

{py:class}`~ramanujan_qft.mellin.MellinFunction` is a dataclass. It holds the
Gamma orders $L$ and $R$, the leading power at $x=0$, the behaviour at
$\infty$ and a builder for the Mellin data. The builder returns an internal
structure, which is not yet a stable public interface. To add a factor to the
atlas (Bessel $K_\nu$ or $Y_\nu$, Struve functions, rational functions, …),
follow the constructors in `ramanujan_qft/mellin.py`. Please include a test
against an independent closed form or quadrature, as the existing tests in
`tests/test_mellin.py` do.

## See also

* {doc}`rmt`: the one-factor theorem that the residues come from.
* {doc}`precision`: exact inputs, printing and error estimates.
* API: {py:func}`~ramanujan_qft.mellin.product_integral`,
  {py:class}`~ramanujan_qft.mellin.MellinFunction`,
  {py:class}`~ramanujan_qft.mellin.SeriesConvergenceError`.
* {doc}`/PRIOR_ART`: Marichev, Adamchik–Marichev, Slater, Fikioris,
  Bleistein–Handelsman; SymPy `meijerint`; mpmath `meijerg`.
* {doc}`/validation`: the audit rounds that tested this engine.
