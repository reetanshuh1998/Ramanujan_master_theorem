# Massive Euclidean multiloop graphs

`integrate_graph` accepts a connected scalar graph instead of a named topology.
It constructs the Symanzik polynomials, checks UV subgraphs, applies Ramanujan's
Master Theorem to the common Schwinger scale, and numerically integrates the
remaining parameters in Hepp sectors. This is an experimental **hybrid**
evaluator: the remaining integration uses scrambled Sobol quadrature, not a
multivariate Ramanujan/Method-of-Brackets residue sum.

For a genuine multivariate series, the separate {doc}`sunset_rmt` backend now
supports the unit-power massive $D=2$ sunset in two explicitly justified
convergence charts. This hybrid evaluator remains an independent reference.

## Installation and first calculation

```bash
pip install ".[multiloop]"    # from the repository; adds SciPy
```

```python
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_graph

# Three parallel propagators between two vertices: a two-loop sunset.
# mass_squared and power may be integers, decimal strings, or rationals.
graph = ScalarGraph([
    ScalarEdge("a", "b", mass_squared=1),
    ScalarEdge("a", "b", mass_squared=1),
    ScalarEdge("a", "b", mass_squared=1),
])
result = integrate_graph(graph, D=2, epsrel=1e-4, seed=0)
print(graph.loops)
print(round(result.value, 4))
print(result.converged)
```

```text
2
2.3439
True
```

`result` also contains `error_estimate`, `standard_error`, `evaluations`,
`sectors`, `samples_per_replicate`, `replicates`, `seed`, and `method`.

For nonzero external momenta, specify vectors entering each vertex. Missing
vertices have zero momentum, and the supplied components must sum to zero
exactly. For example:

```python
moving = ScalarGraph([
    ScalarEdge(0, 1, 1), ScalarEdge(0, 1, 4), ScalarEdge(0, 1, 9),
], external_momenta={0: [2, 1], 1: [-2, -1]})
parameters, U, F = moving.symanzik()
assert moving.loops == 2
x0, x1, x2 = parameters
assert U == x0*x1 + x0*x2 + x1*x2
# The external Euclidean invariant is p_E^2 = 2^2 + 1^2 = 5.
```

External vectors specify dot products independently of the real integration
dimension `D`. Their component count does not constrain `D`; this permits
analytic continuation in dimension inside the convergence domain. Decimal
strings and rational numbers are stored exactly for graph algebra and power
counting. Other numeric inputs are interpreted through their decimal string
representation. Use explicit strings for reproducible decimal inputs.

## Conventions and supported domain

The returned integral is

$$
I_G=\int\prod_{\ell=1}^{L}\frac{d^Dk_\ell}{\pi^{D/2}}
       \prod_{e=1}^{E}(q_e^2+m_e^2)^{-\nu_e}.
$$

All masses squared, propagator powers, and `D` must be finite and strictly
positive real numbers. The graph must be connected; parallel edges, self-loops,
bridges, and tree graphs are supported. No tensor numerator is included.

This **Euclidean positive-propagator convention differs from the existing
LoopTools-style functions**. For integer powers and spacelike invariants, the
corresponding Minkowski scalar integral in the package's convention has an
additional factor $(-1)^{\sum_e\nu_e}$. There is no automatic conversion or
physical-region analytic continuation.

Every cyclic edge subset $H$ is checked for

$$
\sum_{e\in H}\nu_e-\frac D2 L_H>0.
$$

The check includes overlapping and disconnected subsets, and uses exact
rational arithmetic. Testing only the whole graph would miss subdivergences.
`graph.uv_margins(D)` exposes these margins with zero-based edge indices.
Positive masses eliminate infrared singularities in this Euclidean domain.
An integral failing a UV check raises `ValueError`; its analytic continuation
or renormalized finite part is not substituted for the divergent integral.

## Where Ramanujan's theorem enters

After Gaussian loop integration, write Schwinger parameters as
$\alpha_e=\rho x_e$. Define $A=\sum_e\nu_e$ and $s=A-LD/2$.
The scale dependence is $\rho^{s-1}\exp(-\rho F/U)$. Its Taylor coefficient
continuation is $\varphi(n)=(F/U)^n$, so RMT gives

$$
\int_0^\infty \rho^{s-1}e^{-\rho F/U}\,d\rho
=\Gamma(s)(U/F)^s.
$$

The code evaluates the equivalent unit-scale RMT factor with $\varphi(n)=1$
and applies the scale power separately. This leaves the standard projective
parameter integral

$$
I_G=\frac{\Gamma(s)}{\prod_e\Gamma(\nu_e)}
\int_{x_e\geq0}\delta\left(1-\sum_e x_e\right)
\prod_e x_e^{\nu_e-1}\frac{U^{s-D/2}}{F^s}\,d^Ex.
$$

Graph construction follows spanning-tree and spanning-two-forest formulas:
$U=\sum_T\prod_{e\notin T}x_e$ and
$F=U\sum_e m_e^2x_e+\sum_{T_1\cup T_2}p_{T_1}^2\prod_{e\notin T_1\cup T_2}x_e$.
See [Bogner and Weinzierl, *Feynman graph polynomials*](https://arxiv.org/abs/1002.3458).
The generalized RMT treatment of Feynman diagrams is described by
[González, Moll and Schmidt](https://arxiv.org/abs/1103.0588). The separate
{doc}`sunset_rmt` implementation generates exact bracket families and justifies
their summation for a restricted sunset domain.

## Sector integration and errors

For each ordering $\pi$, projective invariance allows the largest parameter
to be set to one. Set $x_{\pi(0)}=1$ and
$x_{\pi(j)}=t_1\cdots t_j$. Common monomials are factored out of $U$ and $F$.
Their exponents agree because every internal mass is positive. The remaining
polynomials are bounded away from zero on the closed cube.

For the suffix $H_j=\{\pi(j),\ldots,\pi(E-1)\}$, the endpoint weight is
$t_j^{\beta_j-1}$, with $\beta_j=\sum_{e\in H_j}\nu_e-DL_{H_j}/2>0$.
The map $t_j=z_j^{\lceil\beta_j\rceil/\beta_j}$ replaces this with a
nonnegative integer power of $z_j$, including its Jacobian. This avoids
introducing endpoint cusps when $\beta_j>1$.

Each Sobol replicate estimates the **sum over all sectors**. Standard errors
are computed across independently scrambled replicates, so sector correlations
are included. Sample counts double until the diagnostic

```
max(3 * standard_error, change_since_previous_level, roundoff_floor)
```

is at most `max(epsabs, epsrel * abs(value))`. At least two levels are required.
Single-edge integrals need no sampling and are evaluated directly.

These are **statistical diagnostics, not rigorous error bounds or certified
digits**. Adaptive stopping does not provide a fixed confidence level.
Extremely localized features or large hierarchies can fool sampling estimates;
use independent methods and additional seeds for important results. The
backend uses float64; `dps` is not an option, and `epsrel < 1e-12` is refused.
Common mass scales are factored out, but hierarchies exceeding the floating-point
coefficient range are rejected. This does not limit the arbitrary-precision
APIs elsewhere in the package.

If tolerance is not reached, `MultiloopConvergenceError.result` contains the
partial estimate. For exploratory calculations, `strict=False` returns the
same result with `converged=False`:

```python
estimate = integrate_graph(moving, D=2, epsrel=1e-12,
                           min_power=3, max_power=4, replicates=4, strict=False)
assert not estimate.converged
assert estimate.evaluations == 6 * 4 * 16
```

Work is bounded by `max_power`, `max_evaluations`, `max_sectors`, and
`max_forests`. UV enumeration is also capped at 65,535 edge subsets. There are
$E!$ sectors and $2^E-1$ subsets: this initial implementation targets small
graphs. Defaults permit at most 5,040 sectors (seven edges), but the default
two-million-evaluation budget only permits the required initial refinement
through six edges. Larger graphs need explicit budget increases; they can
become impractical quickly. No scalability or speed superiority is claimed.

## Validation and path to broader coverage

`tests/test_multiloop.py` checks exact graph polynomials against a weighted
Laplacian, numerical bubbles and a general triangle against independent
simplex quadrature, the equal-mass two-loop vacuum sunset against a Clausen
value, and the three-loop banana against $7\zeta(3)$. One-dimensional two-,
three-, and four-loop bananas and a kite are checked against independent
position-space integrals. Other checks cover normalization, fractional powers
and dimension, UV subdivergences, mass scaling, permutations, reproducibility,
and resource exhaustion. These checks validate those examples, not every
graph in the accepted domain.

The next steps toward a general multiloop package are:

1. Extend the {doc}`sunset_rmt` charts across the uncovered Euclidean region,
   including equal-mass vacuum, then add topologies with independently derived
   convergence and pole-collision rules. Exact bracket algebra alone does not
   establish convergence.
2. More efficient sector strategies and graph factorization to replace
   factorial enumeration; benchmark nontrivial five- to seven-edge graphs.
3. Endpoint subtraction and Laurent expansion in $D=D_0-2\epsilon$, including
   overlapping UV/IR divergences and a clearly defined renormalization scheme.
4. Massless domains, causal continuation and contour deformation for physical
   thresholds, plus independent pySecDec/FIESTA reference data.
5. Tensor numerators and integration-by-parts reduction, followed by a broader
   external validation campaign.

The legacy `MoBDynamicEngine` remains an incomplete bracket-analysis tool.
Its unsupported evaluations still raise; this backend does not silently
replace them with different conventions or a different method.
