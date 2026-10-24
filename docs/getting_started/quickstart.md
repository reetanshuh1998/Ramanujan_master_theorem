# Quickstart

A ten-minute tour of the four parts of the package. Every example on this page
was run against the current version, and the outputs shown are the real ones.
The whole page runs in a few seconds.

To follow along, {doc}`install the package <installation>`, or run the same
calls without installing anything on the {doc}`/try_it` page.

The functions introduced here take `dps=`, the number of **decimal digits** requested, and
return [mpmath](https://mpmath.org) numbers (`mpf` for real, `mpc` for complex
results).

For graph-based calculations beyond the named topologies, see
{doc}`/user_guide/multiloop`. That experimental backend returns float64
estimates with statistical errors and uses `epsrel`/`epsabs` instead of `dps`.
For a graph-generated multivariate Gamma series with arbitrary precision,
see {doc}`/user_guide/sunset_rmt`, currently restricted to two justified
convergence charts of the massive, unit-power D=2 sunset.

## 1. Ramanujan's Master Theorem

If $f(x) = \sum_{n\ge 0} \varphi(n)\,(-x)^n/n!$, then, under Hardy's growth
condition on $\varphi$,

$$
\int_0^\infty x^{s-1} f(x)\,dx = \Gamma(s)\,\varphi(-s).
$$

For $f(x) = (1+x)^{-3}$ the Taylor coefficients give
$\varphi(n) = \Gamma(3+n)/\Gamma(3)$, so the theorem predicts the Beta function
$B(s, 3-s)$:

```pycon
>>> import mpmath as mp
>>> from ramanujan_qft import ramanujan_master_theorem, mellin_numeric
>>> phi = lambda n: mp.gamma(3 + n) / 2
>>> ramanujan_master_theorem(phi, 1.25)
mpf('0.41652027545234682')
>>> mp.beta(1.25, 1.75)
mpf('0.41652027545234682')
>>> mellin_numeric(lambda x: (1 + x)**-3, 1.25)   # direct quadrature, as a check
mpf('0.41652027545234682')
```

`ramanujan_master_theorem` evaluates $\Gamma(s)\,\varphi(-s)$ exactly as
given. It cannot tell whether the function you pass is the continuation of
$\varphi$ that the theorem requires, so check new uses with `mellin_numeric`.
See {doc}`/user_guide/rmt`.

## 2. Product integrals by Mellin residues

`product_integral(f, g, s=1)` evaluates
$\int_0^\infty x^{s-1} f(x)\,g(x)\,dx$, where `f` and `g` come from a small
atlas of functions with known Mellin transforms: `exponential(k)`
$= e^{-kx}$, `gaussian(a)` $= e^{-ax^2}$, `bessel_j(nu, b)` $= J_\nu(bx)$,
`cosine(b)`, `sine(b)`, `inverse_power(m, v)` $= (x+m)^{-v}$ and
`gaussian_bessel(a, b, nu)` $= e^{-ax^2} J_\nu(bx)$.

```pycon
>>> from ramanujan_qft import product_integral, exponential, bessel_j
>>> product_integral(exponential(1), bessel_j(0, 3))
mpf('0.31622776601683794')
>>> 1 / mp.sqrt(10)                                 # closed form
mpf('0.31622776601683794')
```

The cost hardly depends on the oscillation frequency. Here is
$\int_0^\infty e^{-x} J_0(10^5 x)\,dx = 1/\sqrt{1+10^{10}}$ to 30 digits:

```pycon
>>> v = product_integral(exponential(1), bessel_j(0, 1e5), dps=30)
>>> mp.nstr(v, 30)
'0.0000099999999995000000000375'
>>> with mp.workdps(30):
...     mp.nstr(1 / mp.sqrt(1 + mp.mpf(10)**10), 30)
'0.0000099999999995000000000375'
```

Pass `return_info=True` to see which factor was expanded, the error estimate,
the number of terms and the working precision:

```pycon
>>> product_integral(exponential(1), bessel_j(0, 3), dps=30, return_info=True)[1]
{'method': 'expand exp(-1 x)', 'error_estimate': mpf('1.3611704260536571e-31'), 'terms': 73, 'working_dps': 45}
```

**Refusals.** The residue series converge only when the scales of the two
factors are far enough apart. $\int_0^\infty e^{-x} J_0(x)\,dx = 1/\sqrt{2}$
exists, but both of its residue series sit on the convergence boundary
($\rho = 1$), so `product_integral` raises an error instead of returning a
number it cannot verify:

```pycon
>>> product_integral(exponential(1), bessel_j(0, 1))
Traceback (most recent call last):
  ...
ramanujan_qft.mellin.SeriesConvergenceError: neither ordering of exp(-1 x) * J_0(1 x) is a convergent residue expansion (the scales are at the convergence boundary rho = 1, or the factors cannot be expanded). Use quadrature or a closed form.
```

An integral that does not exist for the given `s`, such as
$\int_0^\infty \cos x \cos 2x\,dx$, raises `ValueError` with the range of
`Re s` where it does exist. See {doc}`/user_guide/mellin`.

## 3. One-loop integrals

`B0` and `C0` follow the LoopTools conventions: arguments are **squared**
masses, the metric is Minkowski ($p^2 > 0$ is time-like), propagators carry
$+i0$, and `B0` returns the finite part with $\Delta = 0$ and $\mu^2 = 1$ by
default (parameters `delta` and `mu2`). `C0(s, m1sq, m2sq, m3sq)` is
$C_0(0, 0, s; m_1^2, m_2^2, m_3^2)$.

```pycon
>>> from ramanujan_qft import B0, C0
>>> B0(10, 1, 2)
mpc(real='0.62259207309054199', imag='2.0116008064341786')
>>> C0(10, 1, 2, 3)
mpc(real='-0.42193253167473543', imag='-0.33673226803368017')
```

LoopTools 2.16 gives `0.622592073090541875 + 2.01160080643417860 i` and
`-0.421932531674735434 - 0.336732268033680282 i` for these two calls
(`tests/data/looptools_reference.csv`): the results agree to double-precision
round-off. Unlike LoopTools, the same functions go to any precision:

```pycon
>>> mp.nstr(C0(10, 1, 2, 3, dps=50), 50)
'(-0.42193253167473545355940149447302777724030318471005 - 0.33673226803368019435750959172486639656816178457921j)'
```

Also available: `B0_mob` and `C0_mob` (the equal-mass Method-of-Brackets
forms) and `bubble_3d` (the finite $D=3$ bubble). See
{doc}`/user_guide/one_loop` and {doc}`/user_guide/conventions`.

## 4. The two-loop sunset

`sunset_im(s, m1sq, m2sq, m3sq)` is the imaginary part of the massive sunset.
It vanishes below the three-particle threshold $s = (m_1+m_2+m_3)^2$:

```pycon
>>> from ramanujan_qft import sunset_im, sunset_threshold
>>> sunset_threshold(1, 2, 3)
mpf('17.191508225450303')
>>> sunset_im(100, 1, 2, 3)
mpf('-88.184995551555915')
>>> sunset_im(5, 1, 2, 3)
mpf('0.0')
```

`sunset_im` takes a fraction of a second. The other two sunset functions,
`sunset_subtracted` ($S(s)-S(0)-s\,S'(0)$) and `sunset_d2` ($S''(s)$), run
nested quadratures at two working precisions and take 10–30 s per call, so
they are not run on this page. See {doc}`/user_guide/sunset`.

## 5. Precision and printing

A result carries the precision you requested, but `print` and `repr` show it
at mpmath's *global* precision, `mp.dps`, which is 15 by default. Use
`mp.nstr(x, n)` or a `with mp.workdps(n):` block to see all the digits:

```pycon
>>> x = B0(10, 1, 2, dps=40)
>>> print(x)
(0.622592073090542 + 2.01160080643418j)
>>> mp.nstr(x, 40)
'(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)'
>>> with mp.workdps(40):
...     print(x)
(0.6225920730905419577001843621004278217297 + 2.01160080643417843946062487127894859004j)
```

Inputs are taken as exact numbers. A Python float such as `0.1` is the
binary number nearest to 0.1. To mean the decimal value, pass a string. (An
`mpf` is binary too: `mp.mpf("0.1")` made at the default 15 digits is the same
number as the float.)

```pycon
>>> mp.nstr(B0(0.1, 1, 2, dps=30), 30)
'(-0.374845190552788401789865766787 + 0.0j)'
>>> mp.nstr(B0('0.1', 1, 2, dps=30), 30)
'(-0.374845190552788402429829239118 + 0.0j)'
```

The one-loop and sunset functions are *precision-checked*: each is evaluated at two
working precisions, which are raised until the results agree to the requested
number of digits. {doc}`/user_guide/precision` explains what this does and does
not guarantee.

## Next steps

* {doc}`/user_guide/index`: each part of the package in detail, with its
  conventions, limitations and refusals.
* {doc}`/auto_examples/index`: complete example scripts with their output.
* {doc}`/api/index`: every function and its parameters.
* {doc}`/validation`: what the results are checked against.
* {doc}`/COMPARISON`: when another tool is the better choice.
