# Multivariate Ramanujan series for the D=2 sunset

This backend reaches the first graph-to-series milestone for a **massive,
unit-power, two-loop sunset in D=2**. It generates exact Schwinger bracket
matrices and Gamma families from the graph, resolves coalescing poles
analytically, selects a justified convergence region, and sums the finite
multivariate series at arbitrary precision. Evaluation performs no quadrature,
QMC, numerical regulator extrapolation, or fallback to the sector backend.

The symbolic compiler is reusable for other graphs. Numerical family selection,
pole resolution, and convergence proofs are currently specific to this sunset.

## Use it

The base package dependencies suffice; SciPy is needed only for optional
comparisons with the {doc}`multiloop` numerical backend.

```python
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, compile_sunset_rmt

graph = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)],
                    external_momenta={0: [10], 1: [-10]})
series = compile_sunset_rmt(graph)
result = series.evaluate(dps=30)
print(series.chart)
print(mp.nstr(result.value, 25))
print(result.converged)
```

```text
momentum
0.6290167075906141495908273
True
```

The invariant is $p_E^2=100$, not 10. The normalization is the positive
Euclidean integral

$$
I=\int\frac{d^2k\,d^2\ell}{\pi^2}
\frac{1}{(k^2+m_1^2)(\ell^2+m_2^2)((p-k-\ell)^2+m_3^2)}.
$$

`integrate_graph_rmt(graph, dps=30)` is the compile-and-evaluate convenience
function. It and `series.evaluate` return `RMTSeriesResult`, whose value is an mpmath
number. `truncation_bound`, `error_estimate`, `terms`, `shells`, `working_dps`,
`chart`, and `convergence_ratio` expose the summation diagnostics.

A dominant mass also permits zero momentum:

```python
from ramanujan_qft import integrate_graph_rmt
vacuum = ScalarGraph([ScalarEdge(0, 1, m2) for m2 in (1, 4, 100)])
value = integrate_graph_rmt(vacuum, dps=30)
print(value.chart)
print(mp.nstr(value.value, 25))
```

```text
mass
0.185949303854726222708126
```

## Exact graph-to-bracket compilation

For any supported `ScalarGraph`, `schwinger_brackets` obtains $U$ and
$K=F-U\sum_i m_i^2\alpha_i$ from the graph. It expands the mass exponentials,
$\exp(-K/U)$, and the remaining power of $U$. Each monomial contributes an
exact integer exponent column. The integration weights and the power of $U$
provide the bracket offsets. A basis is solved by exact linear algebra and
converted into a formal Gamma-function summand.

For the nonzero-momentum sunset, use indices
$(k,r_1,r_2,r_3,a,b,c)$ for the momentum exponential, the three mass
exponentials, and the three monomials of $U$. The brackets are

$$
\begin{pmatrix}
1&1&0&0&1&1&0\\
1&0&1&0&1&0&1\\
1&0&0&1&0&1&1\\
1&0&0&0&1&1&1
\end{pmatrix}
\begin{pmatrix}k\\r_1\\r_2\\r_3\\a\\b\\c\end{pmatrix}
+\begin{pmatrix}\nu_1\\\nu_2\\\nu_3\\D/2\end{pmatrix}=0.
$$

This matrix is constructed from the polynomials; it is not stored as a
hard-coded matrix. In a square bound-index basis $B$, with free indices $n_f$,
the compiler solves $n_b=-B^{-1}(c+A_f n_f)$ and applies the Gamma/bracket rule
with determinant factor $1/|\det B|$. Free factorial indicators, monomial
coefficients, $1/\Gamma(D/2+k)$, and $1/\prod_i\Gamma(\nu_i)$ are retained.
No dependent rows are silently discarded, and determinant tests use no
floating-point threshold. A nonsingular basis is **not** a convergence proof.

```python
from ramanujan_qft import schwinger_brackets
import sympy as sp
eta = sp.Symbol("eta", real=True)
brackets = schwinger_brackets(graph, propagator_shifts=(eta, eta, eta))
assert brackets.matrix.shape == (4, 7)
basis = brackets.solve((0, 4, 5, 6))
assert abs(basis.determinant) == 1
# Inspect basis.values and basis.term for the exact solved indices and Gamma term.
assert len(series.gamma_terms) == 8
```

`eta` shifts the propagator powers solely to expose the removable pole
collisions. It is not a dimensional regulator or an epsilon-expansion feature.
The compiled object retains `bracket_system`, `families`, `gamma_terms`,
`summation_indices`, `regulator`, and the finite `coefficient_expression`.
The evaluator checks that the generated scale constraint matches the sunset
Mellin kernel before using the optimized coefficient formula below.

The bracket rule follows the generalized RMT framework of
[González, Moll and Schmidt](https://arxiv.org/abs/1103.0588). Only candidate
algebra is produced for arbitrary topologies; the current numerical compiler
recognizes the sunset by connectivity, not polynomial degree.

## Proven series regions

Write $Q=\sqrt{p_E^2}$ and use positive masses $m_i=\sqrt{m_i^2}$.

| Chart | Required strict inequality | Squared expansion ratios |
|---|---|---|
| `momentum` | $Q>m_1+m_2+m_3$ | $z_i=m_i^2/Q^2$ |
| `mass` | $M>m_a+m_b+Q$, with $M$ the largest mass | $(z_a,z_b,w)=(m_a^2/M^2,m_b^2/M^2,Q^2/M^2)$ |

`chart="auto"` selects a covered region; an explicit chart may also be
requested. These are sufficient domains, not a claim of maximal convergence.
The equal-mass vacuum, the intervening region, and the boundaries are refused
with `RMTDomainError`, even when the integral itself is finite. For example,
the known vacuum value $4\operatorname{Cl}_2(\pi/3)/\sqrt3$ is an independent
benchmark for the existing numerical backend, **not a value supplied by these
RMT charts**.

The separate {doc}`sunset_taylor` API now covers equal-mass vacuum and finite
Euclidean momenta by a differential-equation Taylor series. An RMT call never
silently switches to this method. Unequal-mass gaps remain open.

Domain decisions use rational lower and upper enclosures of sums of square
roots, constructed using integer square roots. A positive gap is required;
there is no floating-point tolerance that turns a boundary into an interior
point. Inconclusive enclosures are refused. Very small exact gaps also increase
the required working precision.

The momentum expansion is the coalesced form of a Lauricella $F_C^{(3)}$
representation. The general sunset series and these convergence conditions
are discussed by [Ananthanarayan, Friot and Ghosh](https://arxiv.org/abs/1911.10096).
Here is a separate outline connecting the generated brackets to that expansion.
For general powers, set $A=\sum_i\nu_i$ and $Z=\sum_i z_i$. In a common
initial Mellin-Barnes strip the Schwinger integral gives

$$
\frac{(Q^2)^{2-A}}{\prod_i\Gamma(\nu_i)}
\int_{\cal C}\frac{d^3z}{(2\pi i)^3}
\frac{\Gamma(A+Z-2)}{\Gamma(3-A-Z)}
\prod_i\Gamma(-z_i)\Gamma(1-\nu_i-z_i)
\left(\frac{m_i^2}{Q^2}\right)^{z_i}.
$$

The two right-pole choices for each mass generate eight families, exactly the
choices between a mass index and the complementary $U$ index in the bracket
matrix. The standard Lauricella contour closure applies when
$\sum_i m_i/Q<1$. Analytic continuation in the powers then permits
$\nu_i\to1$ inside this region. One of the eight regulated families vanishes
identically: the all-$U$-index family contains $1/\Gamma(-N)=0$ for $N=n_1+n_2+n_3\ge0$, independently
of dimension and propagator powers. The sum of the remaining regulated
families has a finite limit at $D=2$, $\nu_i=1$.
The resulting series has the absolute majorant given below.

For the mass chart, there are four small-mass pole families. It can also be
justified by the coordinate-space identity
$I=4\int_0^\infty rJ_0(Qr)\prod_iK_0(m_i r)\,dr$: expand the two lighter
$K_0$ factors and $J_0$, retaining $K_0(Mr)$. The absolute expanded integrand
is bounded at infinity by a polynomial/logarithmic factor times
$e^{-(M-m_a-m_b-Q)r}$; it is integrable at zero. Thus termwise integration is
justified in the stated strict domain.

## Pole collisions and finite coefficients

Let $N=n_1+n_2+n_3$, $H_n=\sum_{j=1}^n1/j$ and
$H_n^{(2)}=\sum_{j=1}^n1/j^2$, with both zero at $n=0$. Define

$$
W_n=\frac{\Gamma(N+1)^2}{\prod_i\Gamma(n_i+1)^2}.
$$

In the momentum chart, $b_i=H_{n_i}-H_N-\tfrac12\log z_i$ and

$$
I=\frac4{Q^2}\sum_{n_1,n_2,n_3\ge0}(-1)^N W_n\prod_i z_i^{n_i}
\left(\sum_{i<j}b_i b_j-\frac32H_N^{(2)}\right).
$$

In the mass chart, the first two indices describe the lighter masses and the
third the momentum. With $b_a=H_{n_1}-H_N-\tfrac12\log z_a$ and
$b_b=H_{n_2}-H_N-\tfrac12\log z_b$,

$$
I=\frac4{M^2}\sum_{n_1,n_2,n_3\ge0}(-1)^{n_3}W_n z_a^{n_1}z_b^{n_2}w^{n_3}
\left(b_a b_b+\frac{\zeta(2)-H_N^{(2)}}2\right).
$$

At $Q=0$, only $n_3=0$ remains, so evaluation is a double series. These are
finite limits of the generated Gamma families, not fitted expressions.
`series.coefficient((n1,n2,n3), dps=...)` evaluates an individual summand.

One way to derive the limits uses the logarithmic
[$K_0$ series](https://dlmf.nist.gov/10.31.E2). The relevant Mellin kernels are
$\Gamma(N+1)^2$ for the retained $K_0$ factor and
$\Gamma(N+1)/\Gamma(-N)$ for $J_0$.
The [Bessel Mellin transforms](https://dlmf.nist.gov/10.22.E43) and
[modified Bessel Mellin transform](https://dlmf.nist.gov/10.43.E19) give these
kernels. Reflection writes the second as
$-\sin(\pi N)\Gamma(N+1)^2/\pi$. Taking the log-coefficient derivatives before
setting $N$ to an integer yields the finite harmonic expressions above.
The momentum derivation uses the continued Mellin kernel: integrating the
expanded growing powers against $J_0$ as ordinary convergent integrals would
be invalid. Its integral identity is justified by the Mellin-Barnes chart,
not by that invalid interchange.

## Tail bounds and numerical checks

For either chart let $r$ denote its three nonnegative squared ratios and
$\rho=(\sqrt{r_1}+\sqrt{r_2}+\sqrt{r_3})^2<1$. The multinomial theorem gives

$$
\sum_{|n|=N}W_n r^n\le\rho^N.
$$

If $L$ is the largest $-\tfrac12\log r_i$ among the mass variables, the
logarithmic bracket has absolute value at most $c(L+H_N)^2+d$, where
$(c,d)=(3,\pi^2/4)$ for momentum and $(1,\pi^2/12)$ for mass.
Using $H_{N+k}\le H_N+k/(N+1)$, the omitted tail after shell $N$ is bounded by

$$
\frac4{S}\rho^{N+1}\left[
\frac{cC^2+d}{1-\rho}
+\frac{2cCa}{(1-\rho)^2}
+\frac{ca^2(1+\rho)}{(1-\rho)^3}
\right],\quad C=L+H_N,\quad a=\frac1{N+1},
$$

with $S=Q^2$ or $M^2$. The implementation uses a conservative rational upper
bound on $\rho$, slightly inflated against arithmetic rounding. It sums
complete total-degree shells and uses this tail bound for stopping; a short
run of small terms is never treated as convergence.

The mathematical truncation bound is evaluated with mpmath guard digits.
Estimated arithmetic error, agreement at two working precisions, and final
rounding contribute to `error_estimate`. This is not a rigorous interval
arithmetic certificate. Work is bounded by `max_shells`, `max_terms`, and
`max_dps`; an unmet target raises `RMTSeriesConvergenceError`. A partial result
is attached when available. Close to the boundary the series may be impractical.

### Measured default-budget coverage

These measurements use `max_shells=128`, `max_terms=250000` and the default
precision cap. “Pass” means the returned value met the requested relative
accuracy and its reported error against a separate 45/60-digit parameter
reference. “Budget” means a typed `RMTSeriesConvergenceError`, not a divergent
integral or an inaccurate accepted result. All rows are inside a justified chart.
Mass inputs below are squared masses; $Q$ is Euclidean momentum.

| $(m_1^2,m_2^2,m_3^2)$ | $Q$ | Chart | $\rho$ | 10 digits | 20 digits | 30 digits |
|---|---:|---|---:|---|---|---|
| $(1,1,1)$ | 10 | momentum | 0.09 | Pass | Pass | Pass |
| $(1,1,1)$ | 6 | momentum | 0.25 | Pass | Pass | Pass |
| $(1,1,1)$ | $30/7$ | momentum | 0.49 | Pass | Pass | Pass |
| $(1,1,1)$ | 4 | momentum | 0.5625 | Pass | Pass | Budget |
| $(1,1,4)$ | 5 | momentum | 0.64 | Pass | Budget | Budget |
| $(1,1,16)$ | 1 | mass | 0.5625 | Pass | Pass | Budget |

Reproduce with `python tools/audit_sunset_budgets.py`; raw outcomes, source
hashes, shell counts and timings are in `benchmarks/data/sunset_budgets.json`.
This finite grid is not a universal cutoff in $\rho$: logarithms, cancellation,
scale, precision and zero ratios also affect cost. With three nonzero ratios,
shell $N$ has $(N+1)(N+2)/2$ terms. The default term cap can therefore stop a
run before the shell cap; the measured refusals stopped after 113 shells and
246,905 terms per precision pass.

Increase the budgets explicitly for an interior point, reduce the requested
digits when appropriate, or use the separately named equal-mass Taylor backend.
For unequal masses, `integrate_graph` offers a float64 statistical estimate
within its supported domain. An RMT call does not silently select a fallback.

## Validation and remaining work

Tests compare against independently generated 40/55-digit parameter
quadratures, a live nested quadrature, and the existing Hepp-sector backend.
They also test the regulated Gamma-family limits, exact exponent algebra,
truncation bounds, equal and unequal masses, both charts, mass rescaling,
permutations, and strict boundary refusal. The reference generator is
`tools/generate_sunset_rmt_references.py`; it imports no package evaluator.
The numerical pole-limit calculation is used only in tests.

The next extension is justified continuation into the gap between these
charts, particularly the equal-mass vacuum and low-momentum region. Further
topologies need their own family selection, collision resolution and
convergence proof. Non-unit powers, epsilon expansions, massless graphs,
tensors and physical-region continuation are not implemented by this API.
