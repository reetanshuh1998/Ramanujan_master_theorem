"""Convergent multivariate Gamma/Ramanujan series for the D=2 massive sunset.

Two analytically justified charts are implemented: p_E > m1+m2+m3 and
M > m_a+m_b+p_E. Coalescing Gamma poles are resolved symbolically into
harmonic numbers and logarithms. Evaluation uses no quadrature, QMC, numerical
regulator, or analytic-continuation fallback. See docs/user_guide/sunset_rmt.md.
"""
from dataclasses import dataclass
from itertools import product
from math import comb, isqrt

import mpmath as mp
import sympy as sp

from .brackets import schwinger_brackets
from .multiloop import ScalarGraph, _integer, _real

__all__ = ["SunsetRMTSeries", "RMTSeriesResult", "RMTDomainError",
           "RMTSeriesConvergenceError", "compile_sunset_rmt", "integrate_graph_rmt"]


class RMTDomainError(ValueError):
    """No implemented series chart has a certified convergence domain here."""


class RMTSeriesConvergenceError(ArithmeticError):
    """A valid chart exceeded its work/precision budget; result may be partial."""
    def __init__(self, message, result=None):
        self.result = result
        super().__init__(message)


@dataclass(frozen=True)
class RMTSeriesResult:
    """An arbitrary-precision series value and convergence diagnostics.

    truncation_bound bounds the mathematical series tail (evaluated at working
    precision). error_estimate also includes estimated arithmetic error,
    agreement between two precisions, and final rounding. It is not an interval
    arithmetic certificate. terms/shells refer to the final summation, not the
    cumulative cost of precision checks.
    """
    value: object
    error_estimate: object
    truncation_bound: object
    terms: int
    shells: int
    working_dps: int
    chart: str
    convergence_ratio: object
    converged: bool = True
    method: str = "multivariate RMT / coalesced Gamma series"


def _mp(q):
    return mp.mpf(int(q.p)) / mp.mpf(int(q.q))


def _root_bounds(ratios, digits):
    """Rational enclosures of sum(sqrt(r)): no floating-point domain decisions."""
    lower = upper = sp.S.Zero
    scale = 10**digits
    for ratio in ratios:
        numerator, denominator = int(ratio.p), int(ratio.q)
        radicand = numerator * denominator * scale**2
        root = isqrt(radicand)
        lower += sp.Rational(root, denominator * scale)
        upper += sp.Rational(root if root * root == radicand else root + 1, denominator * scale)
    return lower, upper


def _domain(ratios):
    for digits in (24, 48, 96, 192, 384, 768):
        lo, hi = _root_bounds(ratios, digits)
        if hi < 1:
            rho = hi**2
            gap = 1-rho
            # Perfect rational roots can resolve an arbitrarily small gap even
            # at the first enclosure level. Preserve it in numerical arithmetic.
            needed = len(str(gap.q))-len(str(gap.p))+12
            return rho, max(digits, needed)
        if lo >= 1:
            return None
    return None  # Unresolved is a refusal, never assumed convergence.


@dataclass(frozen=True)
class SunsetRMTSeries:
    """Graph-compiled sunset chart, exact bracket families, and finite pole limit.

    bracket_system and families expose the formal regulated Gamma expressions.
    gamma_terms uses common summation_indices and the symbolic regulator eta.
    coefficient_expression is their finite, coalesced D=2 limit. The numerical
    evaluator uses that limit directly, avoiding subtraction of divergent poles.
    """
    graph: object
    bracket_system: object
    families: tuple
    gamma_terms: tuple
    summation_indices: tuple
    regulator: object
    chart: str
    scale: object
    ratios: tuple
    mass_order: tuple
    rho_upper: object
    domain_digits: int
    coefficient_expression: object

    def coefficient(self, indices, *, dps=30):
        """One finite summand, including the overall normalization 4/scale."""
        if len(indices) != 3:
            raise ValueError("three nonnegative summation indices are required")
        indices = tuple(_integer(n, "summation index", 0) for n in indices)
        dps = _integer(dps, "dps", 10)
        with mp.workdps(dps + 15):
            N = sum(indices)
            H = [mp.mpf(0)]
            H2 = [mp.mpf(0)]
            for n in range(1, N + 1):
                H.append(H[-1] + mp.mpf(1) / n)
                H2.append(H2[-1] + mp.mpf(1) / n**2)
            ratios = tuple(_mp(r) for r in self.ratios)
            logs = tuple(-mp.log(r) / 2 for r in ratios[:3 if self.chart == "momentum" else 2])
            i, j, k = indices
            weight = mp.mpf(comb(N, i) * comb(N-i, j))**2
            weight *= mp.fprod(r**n for r, n in zip(ratios, indices))
            value = 4 / _mp(self.scale) * weight * self._log_factor(indices, H, H2, logs)
        with mp.workdps(dps):
            return +value

    def _log_factor(self, indices, H, H2, logs):
        i, j, k = indices
        N = i+j+k
        b = [log + H[n] - H[N] for log, n in zip(logs, indices)]
        if self.chart == "momentum":
            return (-1)**N * (b[0]*b[1] + b[0]*b[2] + b[1]*b[2] - mp.mpf(3)/2 * H2[N])
        return (-1)**k * (b[0]*b[1] + (mp.zeta(2) - H2[N])/2)

    def _sum(self, dps, wp, max_shells, max_terms):
        with mp.workdps(wp):
            ratios = tuple(_mp(r) for r in self.ratios)
            # Inflate the rational upper bound against working-precision rounding.
            rho = _mp(self.rho_upper) * (1 + 16*mp.eps) + 16*mp.eps
            if rho >= 1:
                raise RMTSeriesConvergenceError("working precision cannot resolve the convergence boundary")
            scale = 4 / _mp(self.scale)
            logs = tuple(-mp.log(r) / 2 for r in ratios[:3 if self.chart == "momentum" else 2])
            L = max(logs)
            H, H2 = [mp.mpf(0)], [mp.mpf(0)]
            powers = [[mp.mpf(1)] for _ in range(3)]
            total = absolute = mp.mpf(0)
            terms = shells = 0
            tail = mp.inf
            tolerance = mp.mpf(10)**(-dps)
            for N in range(max_shells):
                count = (N+1) if ratios[2] == 0 else (N+1)*(N+2)//2
                if terms + count > max_terms:
                    break
                if N:
                    H.append(H[-1] + mp.mpf(1)/N)
                    H2.append(H2[-1] + mp.mpf(1)/N**2)
                    for values, r in zip(powers, ratios):
                        values.append(values[-1]*r)
                shell = []
                for i in range(N+1):
                    js = (N-i,) if ratios[2] == 0 else range(N-i+1)
                    for j in js:
                        k = N-i-j
                        weight = mp.mpf(comb(N, i)*comb(N-i, j))**2
                        weight *= powers[0][i]*powers[1][j]*powers[2][k]
                        term = weight * self._log_factor((i, j, k), H, H2, logs)
                        shell.append(term)
                        absolute += abs(term)
                total += mp.fsum(shell)
                terms += count
                shells = N+1
                # sum multinomial(N;n)^2 * r^n <= (sum sqrt(r))^(2N).
                # H_(N+k) <= H_N + k/(N+1); sum the resulting geometric moments.
                C, a, gap = L + H[N], mp.mpf(1)/(N+1), 1-rho
                factor = 3 if self.chart == "momentum" else 1
                constant = mp.pi**2/4 if self.chart == "momentum" else mp.pi**2/12
                tail = rho**(N+1) * ((factor*C*C + constant)/gap
                       + 2*factor*C*a/gap**2 + factor*a*a*(1+rho)/gap**3)
                rounding = mp.eps * absolute * (100 + 10*terms)
                result = RMTSeriesResult(scale*total, scale*(tail+rounding), scale*tail,
                                         terms, shells, wp, self.chart, rho, False)
                if tail <= tolerance*abs(total)/16:
                    # The caller increases precision if cancellation dominates.
                    return result, scale*rounding
            if shells == 0:
                result = RMTSeriesResult(mp.mpf(0), mp.inf, mp.inf, 0, 0,
                                         wp, self.chart, rho, False)
            raise RMTSeriesConvergenceError(
                f"{self.chart} RMT series did not reach {dps} digits within "
                f"max_shells={max_shells}, max_terms={max_terms}; "
                "increase the budget or use an independent integral representation", result)

    def evaluate(self, *, dps=30, max_shells=128, max_terms=250000, max_dps=None):
        """Sum complete total-degree shells with an analytic tail bound.

        Working precision is raised against cancellation. Acceptance requires
        agreement at two working precisions and an error estimate below 10^-dps
        relative to the result. All budgets are per summation/precision pass.
        The result is rounded to dps decimal digits; no quadrature is used.
        """
        dps = _integer(dps, "dps", 10)
        max_shells = _integer(max_shells, "max_shells", 1)
        max_terms = _integer(max_terms, "max_terms", 1)
        max_dps = max(1000, 5*dps) if max_dps is None else _integer(max_dps, "max_dps", dps)
        wp = max(dps+20, self.domain_digits+10)
        previous = None
        while wp <= max_dps:
            result, arithmetic = self._sum(dps, wp, max_shells, max_terms)
            with mp.workdps(wp):
                tolerance = mp.mpf(10)**(-dps) * abs(result.value)
                if result.value <= 0:
                    wp *= 2
                    continue
                if arithmetic > tolerance/16:
                    wp += max(15, int(mp.ceil(mp.log10(arithmetic/(tolerance/16)))))
                    previous = None
                    continue
                if previous is not None:
                    with mp.workdps(dps):
                        rounded = +result.value
                    error = (result.truncation_bound + arithmetic + abs(result.value-previous.value)
                             + abs(result.value-rounded))
                    if error <= tolerance:
                        return RMTSeriesResult(rounded, error, result.truncation_bound,
                                               result.terms, result.shells, wp, self.chart,
                                               result.convergence_ratio)
                previous = result
            wp += 15
        raise RMTSeriesConvergenceError(
            f"RMT series needs more than max_dps={max_dps} working digits; "
            f"requested dps={dps}, chart={self.chart}. Increase max_dps or reduce dps", previous)


def compile_sunset_rmt(graph, D=2, *, chart="auto"):
    """Compile a unit-power, massive D=2 sunset into a justified Gamma series.

    ``chart='momentum'`` requires p_E > m1+m2+m3. ``chart='mass'`` requires
    the largest mass M > the other two masses + p_E. ``auto`` selects a valid
    chart. Boundaries and the intervening domain are explicitly refused.
    In particular, the equal-mass vacuum point is outside these charts.
    """
    if not isinstance(graph, ScalarGraph):
        raise TypeError("graph must be a ScalarGraph")
    if _real(D, "D", True) != 2:
        raise NotImplementedError("the RMT sunset backend currently requires D=2")
    if (len(graph.edges) != 3 or len(graph.vertices) != 2 or graph.loops != 2
            or any(e.source == e.target for e in graph.edges)):
        raise NotImplementedError("the RMT backend requires a sunset: three parallel edges between two vertices")
    if any(e.power != 1 for e in graph.edges):
        raise NotImplementedError("the RMT sunset backend currently requires unit propagator powers")
    if chart not in ("auto", "momentum", "mass"):
        raise ValueError("chart must be 'auto', 'momentum', or 'mass'")
    order = tuple(sorted(range(3), key=lambda i: graph.edges[i].mass_squared))
    masses = tuple(graph.edges[i].mass_squared for i in order)
    p = graph.external_momenta[graph.vertices[0]]
    q2 = sum((c*c for c in p), sp.S.Zero)
    candidates = []
    if q2 > 0 and chart in ("auto", "momentum"):
        candidates.append(("momentum", q2, tuple(m/q2 for m in masses)))
    if chart in ("auto", "mass"):
        candidates.append(("mass", masses[2], (masses[0]/masses[2], masses[1]/masses[2], q2/masses[2])))
    for chosen, scale, ratios in candidates:
        proof = _domain(ratios)
        if proof is not None:
            break
    else:
        raise RMTDomainError("no certified RMT chart: require p_E > m1+m2+m3, or "
                             "M > m_a+m_b+p_E; boundaries and equal-mass vacuum are not covered. "
                             f"Received squared masses={tuple(e.mass_squared for e in graph.edges)}, "
                             f"p_E^2={q2}, chart={chart!r}. "
                             "For equal masses use integrate_sunset_taylor; otherwise consider "
                             "integrate_graph with the multiloop extra as a numerical reference")
    rho, digits = proof
    eta = sp.Symbol("eta", real=True)
    system = schwinger_brackets(graph, D=2, propagator_shifts=(eta,)*3)
    # In the sunset U, each monomial omits precisely one edge. Its index pairs
    # with that edge's mass-expansion index; the choices generate 8 or 4 families.
    paired = {}
    for column, powers in zip(system.u_columns, system.u_exponents):
        missing = [i for i, power in enumerate(powers) if power == 0]
        if len(missing) != 1 or sum(powers) != 2:
            raise ArithmeticError("unexpected sunset U polynomial")
        paired[missing[0]] = column
    ns = sp.symbols("n0:3")  # No integer assumptions: gamma(-n) must remain formal.
    active_edges = order if chosen == "momentum" else order[:2]
    choices = tuple((system.mass_columns[i], paired[i]) for i in active_edges)
    families, gamma_terms = [], []
    for selection in product(*choices):
        free_to_n = {column: ns[j] for j, column in enumerate(selection)}
        if chosen == "mass" and system.kinetic_columns:
            free_to_n[system.kinetic_columns[0]] = ns[2]
        bound = tuple(i for i in range(system.matrix.cols) if i not in free_to_n)
        solution = system.solve(bound)
        substitutions = {system.indices[column]: n for column, n in free_to_n.items()}
        gamma_terms.append(solution.term.subs(substitutions, simultaneous=True))
        families.append(solution)
        if len(families) == 1:
            # Match the generated scale constraint to the analytically resolved
            # Mellin kernel. This ties the coefficient generator to the graph algebra.
            scale_column = system.kinetic_columns[0] if chosen == "momentum" else system.mass_columns[order[2]]
            degree = -solution.values[scale_column].subs(substitutions, simultaneous=True).subs(eta, 0) - 1
            expected = sum(ns) if q2 else ns[0]+ns[1]
            if sp.expand(degree-expected) != 0:
                raise ArithmeticError("generated bracket constraint does not match the sunset Mellin kernel")
    N = sum(ns)
    b = [sp.harmonic(n)-sp.harmonic(N)-sp.log(r)/2
         for n, r in zip(ns, ratios[:3 if chosen == "momentum" else 2])]
    weight = sp.gamma(N+1)**2 / sp.prod(sp.gamma(n+1)**2 for n in ns)
    weight *= sp.prod(r**n for r, n in zip(ratios, ns))
    if chosen == "momentum":
        finite = (-1)**N * (b[0]*b[1]+b[0]*b[2]+b[1]*b[2]-sp.Rational(3, 2)*sp.harmonic(N, 2))
    else:
        finite = (-1)**ns[2] * (b[0]*b[1]+sp.zeta(2)/2-sp.harmonic(N, 2)/2)
    expression = 4/scale * weight * finite
    return SunsetRMTSeries(graph, system, tuple(families), tuple(gamma_terms), ns,
                           eta, chosen, scale, ratios, order, rho, digits, expression)


def integrate_graph_rmt(graph, D=2, *, chart="auto", dps=30, max_shells=128,
                        max_terms=250000, max_dps=None):
    """Compile and evaluate the supported sunset RMT chart; no numerical fallback.

    Returns :class:`RMTSeriesResult`. For inspection or repeated precision
    requests, use :func:`compile_sunset_rmt` and its evaluate method instead.
    """
    return compile_sunset_rmt(graph, D=D, chart=chart).evaluate(
        dps=dps, max_shells=max_shells, max_terms=max_terms, max_dps=max_dps)
