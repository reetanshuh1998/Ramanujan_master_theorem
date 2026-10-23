{.rq-landing}
# ramanujan-qft

```{toctree}
:hidden:
:maxdepth: 2

getting_started/index
user_guide/index
auto_examples/index
try_it
api/index
validation
CAPABILITIES
RELEASE_PLAN
SCIENTIFIC_REVIEW
RELEASING
Comparison <COMPARISON>
Prior art <PRIOR_ART>
citing
changelog
```

::::{container} rq-hero

{.rq-tagline}
Ramanujan's Master Theorem, Mellin residue summation and arbitrary-precision
Feynman integrals in pure Python.

:::{container} rq-formula
$$
\begin{gathered}
f(x) = \sum_{n=0}^{\infty}\frac{\varphi(n)}{n!}\,(-x)^n \\[4pt]
\int_0^\infty x^{s-1} f(x)\,dx \;=\; \Gamma(s)\,\varphi(-s)
\end{gathered}
$$
:::

{.rq-formula-caption}
Ramanujan's Master Theorem

:::{container} rq-buttons
```{button-ref} getting_started/quickstart
:ref-type: doc
:color: primary

Get started
```

```{button-ref} try_it
:ref-type: doc
:color: primary
:outline:

Try it in your browser
```

```{button-link} https://github.com/reetanshuh1998/Ramanujan_master_theorem
:color: secondary
:outline:

GitHub
```
:::

::::

See {doc}`CAPABILITIES` for supported domains and error guarantees, and
{doc}`RELEASE_PLAN` for the research-alpha release status.

## What is in the package

::::{grid} 1 1 2 2
:gutter: 3

:::{grid-item-card} Ramanujan's Master Theorem
:link: user_guide/rmt
:link-type: doc

`ramanujan_master_theorem(phi, s)` returns $\Gamma(s)\,\varphi(-s)$, and
`mellin_numeric` checks any use of the theorem by direct numerical integration.
:::

:::{grid-item-card} Product integrals by Mellin residues
:link: user_guide/mellin
:link-type: doc

`product_integral(f, g, s)` evaluates $\int_0^\infty x^{s-1} f(x)\,g(x)\,dx$ for
exponentials, Gaussians, Bessel $J_\nu$, sines, cosines and powers, and raises
an error when it cannot certify the result.
:::

:::{grid-item-card} One-loop integrals
:link: user_guide/one_loop
:link-type: doc

`B0`, `C0(s, m1sq, m2sq, m3sq)` $= C_0(0,0,s;m_1^2,m_2^2,m_3^2)$ and the
$D=3$ bubble in LoopTools conventions, certified to any number of digits.
:::

:::{grid-item-card} Two-loop sunset
:link: user_guide/sunset
:link-type: doc

The imaginary part of the massive sunset and its twice-subtracted dispersion
relation $S(s)-S(0)-s\,S'(0)$, from certified numerical integration.
:::

:::{grid-item-card} Experimental multiloop graphs
:link: user_guide/multiloop
:link-type: doc

`ScalarGraph` and `integrate_graph`: convergent massive Euclidean scalar
topologies, automatic graph polynomials and UV checks, RMT scale integration,
and numerical Hepp sectors with statistical errors.
:::

:::{grid-item-card} Multivariate Ramanujan sunset series
:link: user_guide/sunset_rmt
:link-type: doc

`compile_sunset_rmt` generates exact Gamma families for the massive $D=2$
sunset, resolves pole collisions, and sums in justified Euclidean convergence
charts with arbitrary precision and an analytic tail bound.
:::

::::

## A first calculation

```pycon
>>> from ramanujan_qft import product_integral, exponential, bessel_j, B0
>>> product_integral(exponential(1), bessel_j(0, 3))  # = 1/sqrt(10)
mpf('0.31622776601683794')
>>> B0(5, 1, 1)  # LoopTools 2.16: 1.56959105903599583 + 1.40496294620814521 i
mpc(real='1.5695910590359961', imag='1.4049629462081452')
>>> import mpmath as mp
>>> mp.nstr(B0(5, 1, 1, dps=30), 30)
'(1.56959105903599596111056676705 + 1.40496294620814527863127492864j)'
```

Masses are squared masses, and `dps=` is the number of decimal digits
requested. The [quickstart](getting_started/quickstart.md) explains the
conventions and the printing of high-precision results.

## When to use it

* You need **reference values** of one-loop scalar integrals to 30–100 or more
  digits, for example to validate a double-precision code or to evaluate an
  expression with large cancellations.
* You need $\int_0^\infty x^{s-1} f(x)\,g(x)\,dx$ for products of exponentials,
  Gaussians, Bessel functions, trigonometric functions and powers **at high
  precision**, in particular at high oscillation frequency or when no closed
  form exists.
* You want **explicit, readable series representations** (the Master Theorem,
  the Method of Brackets, residue sums) for teaching or for checking a
  derivation.
* You need the **scheme-independent part of the two-loop sunset**
  ($\operatorname{Im} S$, $S(s)-S(0)-s\,S'(0)$) as an independent check.

## When not to use it

* **Double-precision phenomenology.** LoopTools and COLLIER are roughly
  300–450 times faster at double precision, and provide tensor integrals and
  general kinematics.
* **Integrals with a closed form.** Symbolic integration (SymPy `meijerint`,
  Mathematica) followed by mpmath is 100–40,000 times faster where it applies.
  At 15 digits, compiled quadrature is also faster than `product_integral`.
* **Multiloop regulator expansions or physical-region integrals.** The
  experimental graph backend covers convergent massive Euclidean cases only.
  For broader coverage, use pySecDec, FIESTA or AMFlow, and TSIL for
  two-loop self-energies; a certified `sunset_subtracted` call takes about 10 s.
* **Integrals at the convergence boundary.** `product_integral` raises
  `SeriesConvergenceError` instead of returning a value it cannot certify, for
  example for $\int_0^\infty e^{-x} J_0(x)\,dx$. Use quadrature or a closed form there.

The methods are classical (Ramanujan and Hardy; Marichev and Slater;
Gonzalez, Moll and Schmidt; 't Hooft and Veltman); none of them is new.
{doc}`COMPARISON` maps the package against existing tools, with measured
timings, and {doc}`PRIOR_ART` credits the earlier work.

{.rq-dedication}
## In memory of Srinivasa Ramanujan

Srinivasa Ramanujan (1887–1920) stated the Master Theorem in his quarterly
reports to the University of Madras. G. H. Hardy made it widely known, with a
proof under explicit conditions, in *Ramanujan: Twelve Lectures on Subjects
Suggested by His Life and Work* (1940), chapter XI. This package is dedicated to
his memory.
