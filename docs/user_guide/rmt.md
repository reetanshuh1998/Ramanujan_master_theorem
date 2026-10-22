# Ramanujan's Master Theorem

The module `ramanujan_qft.rmt` implements Ramanujan's Master Theorem (RMT), which
turns a Mellin transform into the evaluation of a Taylor coefficient. It has three
functions:

| Function | Computes |
|---|---|
| {py:func}`ramanujan_master_theorem(phi, s, dps=None) <ramanujan_qft.rmt.ramanujan_master_theorem>` | $\Gamma(s)\,\varphi(-s)$, the right-hand side of the theorem |
| {py:func}`mellin_numeric(f, s, dps=None) <ramanujan_qft.rmt.mellin_numeric>` | $\int_0^\infty x^{s-1} f(x)\,dx$ by quadrature, to check a use of the theorem |
| {py:func}`massive_propagator_rmt(msq, D, dps=None) <ramanujan_qft.rmt.massive_propagator_rmt>` | the radial integral of a massive propagator in $D$ dimensions |

The theorem is classical: Ramanujan used it as a formal identity, and Hardy proved
it under the growth condition below. See [Prior art](../PRIOR_ART.md).

## The theorem

If $f$ has an expansion

$$
f(x) = \sum_{n=0}^{\infty} \varphi(n)\,\frac{(-x)^n}{n!},
$$

then its Mellin transform is

$$
\int_0^\infty x^{s-1} f(x)\,dx = \Gamma(s)\,\varphi(-s).
$$

The right-hand side needs $\varphi$ at the non-integer point $-s$, so the identity
is a statement about one particular analytic continuation of the coefficients.

**Hardy's conditions.** Write $\lambda(v) = \varphi(v)/\Gamma(1+v)$ for the
coefficient of $(-x)^n$. Suppose $\lambda$ is analytic in a half-plane
$\operatorname{Re} v \ge -\delta$ with $0 < \delta < 1$, and that it satisfies the
growth condition

$$
|\lambda(v + i w)| < C\, e^{P v + A |w|} \qquad \text{for some } A < \pi .
$$

Then the theorem holds for $0 < \operatorname{Re} s < \delta$. Analytic
continuation in $s$ extends it to the whole strip in which the integral converges
(Hardy, *Ramanujan: Twelve Lectures*, Ch. XI; Amdeberhan et al. 2012, Sec. 3).

The condition $A < \pi$ is what selects the continuation. A function that
agrees with $\varphi$ on the integers but has an extra term such as
$\sin(\pi v)$ grows like $e^{\pi |w|}$, so it violates the condition and gives a
different, wrong value. A black-box callable cannot be tested for this, so the
library does not try. Checking the result is your job; use
[`mellin_numeric`](#checking-a-result-with-mellin_numeric) for that.

## Using `ramanujan_master_theorem`

`ramanujan_master_theorem(phi, s, dps=None)` returns `Gamma(s) * phi(-s)` as an
mpmath number:

* `phi` is a callable. It is called once, with the mpmath number `-s`, inside
  `mpmath.workdps(dps)`. Write it with mpmath functions (`mp.gamma`, `mp.rgamma`,
  `mp.rf`, ...), so that it accepts non-integer arguments and runs at the working
  precision.
* `s` is any number that `mpmath.mpmathify` accepts: an int, float, complex,
  mpmath number or string. Pass decimal values as strings (`"0.1"`) to keep them
  exact (see [Precision](precision.md)).
* `dps` is the number of decimal digits (default: the global `mp.dps`).

The function does not know the strip of convergence of your integral. Outside it,
it returns the analytic continuation without a warning (see
[Pitfalls](#pitfalls-when-the-theorem-does-not-apply)).

The examples on this page use these imports:

```python
import mpmath as mp
from ramanujan_qft import ramanujan_master_theorem, mellin_numeric, massive_propagator_rmt

mp.mp.dps = 15      # mpmath's default; the printed outputs below use it
```

$e^{-x}$ has $\varphi(n) = 1$, so its Mellin transform is $\Gamma(s)$:

```pycon
>>> ramanujan_master_theorem(lambda n: 1, 2.5)
mpf('1.329340388179137')
>>> mp.gamma(2.5)
mpf('1.329340388179137')
```

$(1+x)^{-a} = \sum_n (a)_n (-x)^n/n!$, so $\varphi(n) = \Gamma(a+n)/\Gamma(a)$, and
RMT gives the Beta function $\Gamma(s)\Gamma(a-s)/\Gamma(a) = B(s, a-s)$ for
$0 < \operatorname{Re} s < a$:

```pycon
>>> phi = lambda n: mp.gamma(3 + n) / mp.gamma(3)      # a = 3
>>> ramanujan_master_theorem(phi, 1.25)
mpf('0.41652027545234682')
>>> mp.beta(1.25, 1.75)
mpf('0.41652027545234682')
>>> mellin_numeric(lambda x: (1 + x)**-3, 1.25)        # independent quadrature
mpf('0.41652027545234682')
```

$J_0(2\sqrt{x}) = \sum_n (-x)^n/(n!)^2$, so $\varphi(n) = 1/\Gamma(n+1)$ and the
transform is $\Gamma(s)/\Gamma(1-s)$ for $0 < s < 3/4$ (DLMF 10.22.43 after the
substitution $x = t^2/4$):

```pycon
>>> print(ramanujan_master_theorem(lambda n: mp.rgamma(n + 1), 0.25))
2.95867511918864
>>> print(mp.gamma(0.25) / mp.gamma(0.75))
2.95867511918864
```

With `dps=` the result carries the requested precision, but `print` and `str`
show digits at the global `mp.dps`. Use `mp.nstr(x, n)` (or `mp.workdps`) to see
them all:

```pycon
>>> phi = lambda n: mp.gamma(3 + n) / mp.gamma(3)
>>> v = ramanujan_master_theorem(phi, "1.25", dps=40)
>>> print(v)
0.416520275452347
>>> mp.nstr(v, 40)
'0.4165202754523468356577388428181900342451'
>>> with mp.workdps(40):
...     print(mp.beta(mp.mpf("1.25"), mp.mpf("1.75")))
0.4165202754523468356577388428181900342451
```

## Checking a result with `mellin_numeric`

`mellin_numeric(f, s, dps=None)` computes $\int_0^\infty x^{s-1} f(x)\,dx$ by
tanh-sinh quadrature (`mpmath.quad`). It is meant for cross-checks of
**non-oscillatory** `f` that behave like a power $x^{p_0}$ at $x \to 0$ and decay
like a power (or faster) at $x \to \infty$. `f` is called with mpmath numbers.

How it works:

1. It requires $\operatorname{Re} s > 0$.
2. It estimates $p_0$ from samples of `f` at $x = 10^{-4}, \dots, 10^{-12}$
   (rounded to the nearest $10^{-3}$), and the decay $f \sim x^{-a}$ from samples
   at $x = 10^{4}, \dots, 10^{12}$. A decay faster than $x^{-20}$ over that range
   counts as faster than any power.
3. It removes the algebraic endpoint behaviour by substitution, $x = y^{1/\sigma}$
   on $[0, 1]$ with $\sigma = \operatorname{Re} s + p_0$, and $x = y^{-1/c}$ on
   $[1, \infty)$ with $c = a - \operatorname{Re} s$, then integrates both pieces.
4. It accepts the result only if the quadrature error estimate is below
   $10^{-\lfloor dps/2 \rfloor}$ relative to the value.

It raises instead of guessing:

| Exception | When |
|---|---|
| `ValueError` | $\operatorname{Re} s \le 0$ |
| `ValueError` | `f` is zero at a sample point near 0, or at some (not all) sample points near $\infty$ |
| `ValueError` | `f` is not in its power-law regime on $[10^{-12}, 10^{-4}]$ or $[10^{4}, 10^{12}]$ (oscillating, logarithmic, ...) |
| `ValueError` | the integral diverges, or nearly so ($\sigma \le 0.01$ or $c \le 0.01$), at $x = 0$ or at $\infty$ |
| `ArithmeticError` | the quadrature error estimate does not reach about half of the working digits |

The tolerance in step 4 means you should ask for more digits than you want to
compare. The tests compare RMT and `mellin_numeric` to $10^{-12}$ at `dps=25`.

```pycon
>>> mellin_numeric(lambda x: mp.exp(-x), 2.5)
mpf('1.329340388179137')
>>> mellin_numeric(lambda x: 1 / (1 + x), 1)           # ~ 1/x at infinity: diverges
Traceback (most recent call last):
...
ValueError: the Mellin integral diverges (or nearly so) at infinity for this s
>>> mellin_numeric(lambda x: mp.besselj(0, 2 * mp.sqrt(x)), 0.25)   # oscillates
Traceback (most recent call last):
...
ValueError: f is not in its power-law regime for x in [1e4, 1e12]; decay estimate unreliable
>>> mellin_numeric(lambda x: mp.exp(-x) * mp.cos(10 * x), 1)
Traceback (most recent call last):
...
ArithmeticError: quadrature did not converge (error estimate 0.0001)
```

For oscillatory integrands use `mpmath.quadosc`, a closed form, or
[`product_integral`](mellin.md) if `f` is a product of atlas functions.

## Dimensional regularisation: `massive_propagator_rmt`

The radial integral of a massive propagator is

$$
\int_0^\infty dq^2\, (q^2)^{D/2-1}\, \frac{1}{q^2 + m^2}
= (m^2)^{D/2-1}\, \Gamma(D/2)\, \Gamma(1 - D/2).
$$

`massive_propagator_rmt(msq, D, dps=None)` obtains it from RMT. The expansion
$1/(q^2 + m^2) = \sum_n \Gamma(n+1)\,(m^2)^{-n-1}\,(-q^2)^n/n!$ gives
$\varphi(n) = \Gamma(n+1)/(m^2)^{n+1}$, and the theorem is applied at $s = D/2$.

* `msq` is the squared mass $m^2$. It must be positive (`ValueError` otherwise).
* `D` may be any number. The integral converges only for $0 < D < 2$. Elsewhere
  the function returns the analytic continuation in $D$, which is exactly
  dimensional regularisation. At $D = 2, 4, 6, \dots$ the continuation has a
  pole, and mpmath raises `ValueError: gamma function pole`.
* Dividing by $\Gamma(D/2)$ gives the Euclidean tadpole
  $\int d^D q_E/\pi^{D/2}\; 1/(q_E^2 + m^2) = \Gamma(1-D/2)\,(m^2)^{D/2-1}$, because
  $d^D q_E = \pi^{D/2}/\Gamma(D/2)\; dq^2\,(q^2)^{D/2-1}$ after the angular
  integration. For the Minkowski conventions of the one-loop functions see
  [Conventions](conventions.md).

```pycon
>>> massive_propagator_rmt(2.5, 1.5)                   # inside the strip 0 < D < 2
mpf('3.533294752055899')
>>> mellin_numeric(lambda q2: 1 / (q2 + 2.5), 0.75)
mpf('3.533294752055899')
>>> print(massive_propagator_rmt(4, 3))                # D = 3 by continuation: -2 pi
-6.28318530717959
>>> print(-2 * mp.pi)
-6.28318530717959
>>> massive_propagator_rmt(1, 4)
Traceback (most recent call last):
...
ValueError: gamma function pole
```

## Pitfalls: when the theorem does not apply

**`s` outside the strip.** `ramanujan_master_theorem` returns $\Gamma(s)\varphi(-s)$
for every `s`. For $e^{-x}$ at $s = -1/2$ that is $\Gamma(-1/2)$, although the
integral diverges at $x = 0$. Decide the strip from the behaviour of `f` at 0 and
at $\infty$, or let `mellin_numeric` check it:

```pycon
>>> ramanujan_master_theorem(lambda n: 1, -0.5)        # a continuation, not an integral
mpf('-3.5449077018110322')
>>> mellin_numeric(lambda x: mp.exp(-x), -0.5)
Traceback (most recent call last):
...
ValueError: mellin_numeric requires Re(s) > 0
```

**The wrong continuation of $\varphi$.** $\varphi(n) = 1 + \sin(\pi n)$ equals 1 on
every integer, so it describes the same $e^{-x}$. It breaks Hardy's condition,
and the result is wrong:

```pycon
>>> ramanujan_master_theorem(lambda n: 1 + mp.sinpi(n), 0.5)   # should be Gamma(1/2)
mpf('0.0')
>>> mellin_numeric(lambda x: mp.exp(-x), 0.5)
mpf('1.7724538509055168')
```

**No expansion of the required form.** The theorem needs a power series in $x$ at
$x = 0$. Half-integer powers or logarithms (for example $e^{-\sqrt{x}}$ or the
Bessel function $K_0$) do not fit directly. Even functions fit after the
substitution $t = x^2$:
$\int_0^\infty x^{s-1} f(x^2)\,dx = \tfrac12 \int_0^\infty t^{s/2-1} f(t)\,dt$.
For $e^{-x^2}$ at $s = 1$:

```pycon
>>> print(ramanujan_master_theorem(lambda n: 1, 0.5) / 2)      # Gamma(1/2) / 2
0.886226925452758
>>> print(mellin_numeric(lambda x: mp.exp(-x * x), 1))
0.886226925452758
```

**`phi` must accept non-integer arguments.** It is called at $-s$, not at an
integer:

```pycon
>>> import math
>>> ramanujan_master_theorem(lambda n: 1 / math.factorial(n), 0.3)
Traceback (most recent call last):
...
TypeError: 'mpf' object cannot be interpreted as an integer
>>> print(ramanujan_master_theorem(lambda n: mp.rgamma(n + 1), 0.3))   # use Gamma instead
2.30465444149125
```

## Products of functions

For $\int_0^\infty x^{s-1} f(x)\, g(x)\, dx$, expand one factor by its Taylor series
and apply the Mellin transform of the other term by term. This is RMT combined
with the Mellin-Parseval formula, and it is what
[`product_integral`](mellin.md) does, with a check that the expansion is
legitimate.

## See also

* API reference: {py:func}`ramanujan_qft.rmt.ramanujan_master_theorem`,
  {py:func}`ramanujan_qft.rmt.mellin_numeric`,
  {py:func}`ramanujan_qft.rmt.massive_propagator_rmt` ([API index](../api/index.md)).
* Gallery example {ref}`sphx_glr_auto_examples_01_ramanujan_master_theorem.py`.
* T. Amdeberhan, O. Espinosa, I. Gonzalez, M. Harrison, V. H. Moll, A. Straub,
  *Ramanujan's Master Theorem*, Ramanujan J. 29 (2012) 103.
* G. H. Hardy, *Ramanujan: Twelve Lectures on Subjects Suggested by His Life and
  Work*, Cambridge University Press (1940), Chapter XI.
* I. Gonzalez, V. H. Moll, I. Schmidt, *Ramanujan's Master Theorem applied to the
  evaluation of Feynman diagrams*, Adv. Appl. Math. 63 (2015) 214.
