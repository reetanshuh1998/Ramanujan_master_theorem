# Precision and certification

The original numerical APIs take `dps=`, the number of **decimal digits**
requested, and returns an mpmath number (`mpf` or `mpc`). This page explains
what that number of digits means, how it is guaranteed, and the two pitfalls to
know: printing, and decimal inputs.

The experimental {doc}`multiloop` graph evaluator instead uses float64,
`epsrel`/`epsabs`, and statistical error diagnostics. It does not accept `dps`
or certify decimal digits; the guarantees below do not apply to that backend.

The separate {doc}`sunset_rmt` evaluator accepts `dps=30` by default and
returns an `RMTSeriesResult` containing an mpmath value. Its analytic tail bound
and precision checks are described in that guide. Graph inputs use exact
rationals obtained from decimal representations; use strings for reproducible
decimal input. These input and default-precision rules differ from the
original APIs described below.

```python
import mpmath as mp
from ramanujan_qft import B0, C0, product_integral, exponential, sine, gaussian, cosine
```

## Requesting digits

`dps=None`, the default, means the global `mp.dps` (15 unless you changed it).
The result is rounded to `dps` digits, so it carries about that much precision.

```pycon
>>> x = B0(10, 1, 2, dps=40)
>>> mp.nstr(x, 40)
'(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)'
```

## Printing high-precision results

`print(x)`, `str(x)` and `repr(x)` format the number at the *global* `mp.dps`, not
at the precision it carries. A 40-digit result therefore prints with 15 digits
unless you ask for more:

```pycon
>>> print(x)
(0.622592073090542 + 2.01160080643418j)
>>> print(mp.nstr(x, 40))
(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)
>>> with mp.workdps(40):
...     print(x)
(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)
```

Setting `mp.mp.dps = 40` globally works too. It also changes the default `dps` of
every later call.

## Inputs are exact numbers

Each input is taken as the exact number it represents. A Python float is a binary
number: `0.1` is $0.1000000000000000055511\ldots$. Computed to 30 digits, the
result is the exact value *at that binary input*, which differs from the value
at $1/10$ after about 17 digits. Pass a **string** to mean a decimal number:

```pycon
>>> mp.nstr(B0(0.1, 1, 2, dps=30), 30)
'(-0.374845190552788401789865766787 + 0.0j)'
>>> mp.nstr(B0("0.1", 1, 2, dps=30), 30)
'(-0.374845190552788402429829239118 + 0.0j)'
```

An `mpf` is binary as well. `mp.mpf("0.1")` created at the default 15 digits is
the same 53-bit number as the float. Create it at a higher precision, or pass the
string, when the decimal value matters:

```pycon
>>> mp.nstr(B0(mp.mpf("0.1"), 1, 2, dps=30), 30)     # made at 15 digits: same as the float
'(-0.374845190552788401789865766787 + 0.0j)'
>>> with mp.workdps(40):
...     tenth = mp.mpf("0.1")
>>> mp.nstr(B0(tenth, 1, 2, dps=30), 30)
'(-0.374845190552788402429829239118 + 0.0j)'
```

The same holds for `s` and the factor parameters of `product_integral`:

```pycon
>>> mp.nstr(product_integral(exponential(2), sine(1), s=0.1, dps=30), 30)
'0.406840882099111377456292924264'
>>> mp.nstr(product_integral(exponential(2), sine(1), s="0.1", dps=30), 30)
'0.406840882099111380246888987582'
```

Decimal strings are sized exactly: `product_integral` reads the number of digits
in each string, so a long decimal input next to a pole of the integrand is formed
without rounding.

## Certification of the Feynman integrals

The one-loop functions (`B0`, `B0_mob`, `C0`, `C0_mob`, `bubble_3d`) and the sunset
functions (`sunset_im`, `sunset_subtracted`, `sunset_d2`) are *certified*:

1. The formula is evaluated at a working precision of `dps + 10` digits.
2. It is evaluated again at a higher working precision, `max(step, wp/2)` digits
   more; the step is 20 digits for the one-loop functions and `sunset_im`, and 12
   for the two dispersion integrals.
3. If the two results agree to $10^{-(\mathrm{dps}+2)}$ relative, the higher one is
   rounded to `dps` digits and returned. Otherwise the precision is raised again,
   up to 14 times, and then `ArithmeticError` is raised.

Because the inputs are exact, the only thing that changes between the two
evaluations is the rounding of the intermediate steps. Certification therefore
detects and removes **loss of digits to cancellation and rounding**. This is what
makes closed forms trustworthy at $p^2 \ll m^2$, at strong mass hierarchies,
near thresholds and at $s \gg m^2$, where double-precision codes lose many
digits.

It is not a proof of correctness. An error that does not depend on the working
precision, such as a wrong formula or a wrong branch, would pass the check. The
{doc}`/validation` page covers those: comparisons with LoopTools, with
independent quadratures and with closed forms, and the audit rounds. The
quadratures inside the sunset functions use tolerances tied to the working
precision, so their truncation errors also shrink between the two evaluations.

## Error control in `product_integral`

`product_integral` is not evaluated twice. It controls its error directly, as
described in {doc}`mellin`:

* the series is summed until the estimated tail is below `tol` (default
  $10^{-\mathrm{dps}}$) relative to the sum;
* the ratio $\sum|t_n| / |\sum t_n|$ measures cancellation, and the working
  precision is raised until the requested digits survive it (up to `max_dps`);
* the call raises `SeriesConvergenceError` if the final error estimate is more
  than ten times `tol` relative to the value.

`return_info=True` reports the estimate and the working precision that was
needed. Here the value is $\tfrac{\sqrt\pi}{2}e^{-225} \approx 1.7\times10^{-98}$,
while the residue terms are of order one. The engine raised the working
precision to 220 digits by itself:

```pycon
>>> value, info = product_integral(gaussian(1), cosine(30), return_info=True)
>>> value
mpf('1.7032818257102441e-98')
>>> info
{'method': 'expand cos(30 x)', 'error_estimate': mpf('9.4242890246314583e-114'), 'terms': 838, 'working_dps': 220}
>>> mp.sqrt(mp.pi) / 2 * mp.exp(-mp.mpf(900) / 4)
mpf('1.7032818257102438e-98')
```

## What the errors mean

| Exception | Meaning | What to do |
|---|---|---|
| `ValueError` | the input is outside the domain: a divergent integral (the message gives the strip), a negative squared mass, a non-finite number, an IR-divergent or scaleless configuration | change the input, or pass `continuation=True` to `product_integral` for the analytic continuation |
| `SeriesConvergenceError` (from `ramanujan_qft.mellin`, a subclass of `ArithmeticError`) | `product_integral` found no expansion that reaches the accuracy target: the convergence boundary $\rho=1$, too many terms, or too much precision needed | use quadrature or a closed form; or raise `max_terms` / `max_dps` if the message names them |
| `ArithmeticError` | a certification or a quadrature did not reach the requested digits | report it: it means the function refused rather than return an uncertain value |

## Cost and precision

Measured on one machine (Python 3.13, mean of repeated calls):

| call | 15 digits | 30 | 50 | 100 | 200 |
|---|---|---|---|---|---|
| `B0(5, 1, 1)` | 0.3 ms | 0.3 ms | 0.4 ms | 0.5 ms | 0.7 ms |
| `C0(10, 1, 2, 3)` | 10 ms | 17 ms | 29 ms | 49 ms | 98 ms |
| `product_integral(exponential(1), bessel_j(0, 3))` | 1.9 ms | 3.4 ms | 5.4 ms | 11 ms | 24 ms |
| `product_integral(exponential(2), gaussian_bessel("0.5", 100, 1))` | 5.2 ms | 6.5 ms | 8.8 ms | 20 ms | 56 ms |
| `sunset_im(100, 1, 2, 3)` | 39 ms | 54 ms | 0.14 s | 0.33 s | 1.0 s |

The cost grows slowly with the number of digits. `sunset_subtracted` and
`sunset_d2` take about 10–20 s at 15 digits; see {doc}`sunset`.
