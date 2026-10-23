# Equal-mass sunset: vacuum and Euclidean continuation

`integrate_sunset_taylor` complements the multivariate {doc}`sunset_rmt`
backend. It evaluates the unit-power, equal-mass D=2 sunset with a transformed
Taylor series, a Clausen boundary value, and a differential-equation recurrence.
It uses no quadrature. This is a separate analytic method; it does not generate
new RMT Gamma families or silently change the method of an RMT call.

```python
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_sunset_taylor
g = ScalarGraph([ScalarEdge(0, 1, 1)]*3)
result = integrate_sunset_taylor(g, dps=30)
print(mp.nstr(result.value, 25))
```

```text
2.343907238689458890601562
```

The graph must have exactly equal positive squared masses, three parallel
edges, unit powers and D=2. Finite Euclidean external momenta are supported
subject to `max_terms` and `max_dps`. Unequal masses are explicitly refused.
`compile_sunset_taylor(graph)` returns an inspectable `SunsetTaylorSeries`;
`evaluate(dps=30, max_terms=512, max_dps=2000)` returns `SunsetTaylorResult`.
Unmet work/precision targets raise `SunsetTaylorConvergenceError`, with a
partial result when available. The RMT API retains its own strict domains.

## Derivation and normalization

Use the positive Euclidean loop measure $d^2k\,d^2\ell/\pi^2$. For equal
masses, write $s=p_E^2/m^2$ and $I=m^{-2}f(-s)$. On the unit simplex,

$$f(-s)=\int_\Delta\frac{dx\,dy}{U+sxyz},\qquad
U=xy+xz+yz,\quad z=1-x-y.$$

Since $U/(xyz)=1/x+1/y+1/z\ge9$, set
$v=xyz/U\in[0,1/9]$, $r=s/(9+s)\in[0,1)$, and obtain

$$f(-s)=(1-r)\sum_{n=0}^\infty b_n r^n,\qquad
b_n=\int_\Delta\frac{(1-9v)^n}{U}\,dx\,dy.$$

The coefficients obey $0\le b_n\le b_0$ and decrease with $n$.
The integrable dominating function $1/U$ proves the interchange and
convergence for every finite $s\ge0$. After **K coefficients**, the tail obeys

$$0\le I-I_K\le \frac{b_0}{m^2}r^K.$$

The known boundary value is
$b_0=4\operatorname{Cl}_2(\pi/3)/\sqrt3$.
The equal-mass Picard-Fuchs equation in $t=-s$ is

$$t(t-1)(t-9)f''+(3t^2-20t+9)f'+(t-3)f=-6.$$

The equation and normalization follow
[Müller-Stach, Weinzierl and Zayadeh](https://arxiv.org/abs/1112.4360);
the boundary value and series methods are treated by
[Laporta and Remiddi](https://arxiv.org/abs/hep-ph/0406160).
Their D=2 loop measure gives a value smaller by a factor of 16; multiplying
their $\sqrt3\operatorname{Cl}_2(\pi/3)/12$ by 16 gives our $b_0$.
Substitute $t=-9r/(1-r)$ and $f=(1-r)G(r)$. The transformed equation is

$$r(1-r)(8r+1)G''+(1+14r-24r^2)G'+(2-8r)G=\frac6{1-r}.$$

Matching coefficients gives, with $b_{-1}=0$,

$$b_{n+1}=\frac{6-(7n^2+7n+2)b_n+8n^2b_{n-1}}{(n+1)^2}.$$

This recurrence computes the integral moments above, starting from the
Clausen boundary value. The apparent singularity at $r=-1/8$ in the ODE
does not limit this particular solution; the integral argument establishes
its power series on $|r|<1$.

## Arithmetic stability and validation

Forward recurrence excites an unwanted solution growing approximately as
$(-8)^n$. Requested decimal precision alone is insufficient. The evaluator
allocates at least one guard digit per coefficient, propagates an arithmetic
error estimate through the recurrence, and compares two working precisions.
The analytic tail and final rounding are included in `error_estimate`.
This remains a numerical diagnostic, not an interval-arithmetic certificate.

The term count follows the mathematical lower bound
$I\ge b_0(1-r)/m^2$ and does not depend on potentially corrupted partial sums.
Large Euclidean momentum makes $r$ close to one and may exhaust the budget;
the high-momentum RMT chart is then usually more practical. There is no
automatic fallback.

Tests cover the vacuum Clausen value, independent one-dimensional parameter
quadrature after analytic elimination of one parameter, exact common scaling,
the RMT boundary $p_E=3m$, overlap with the RMT chart at $p_E=6m$, partial-tail
bounds, precision exhaustion, and forbidden numerical fallbacks.
