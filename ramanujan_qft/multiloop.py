"""Massive Euclidean scalar graphs: RMT scale integration and Hepp-sector QMC.

This is a hybrid numerical method, not a general Method-of-Brackets residue
solver. The loop measure is d^D k / pi^(D/2), with positive Euclidean
propagators. See docs/user_guide/multiloop.md for the derivation and limits.
"""

from dataclasses import dataclass
from itertools import combinations, permutations
import math
from types import MappingProxyType

import mpmath as mp
import numpy as np
import sympy as sp

from .rmt import ramanujan_master_theorem

__all__ = ["ScalarEdge", "ScalarGraph", "MultiloopResult",
           "MultiloopConvergenceError", "integrate_graph"]


def _real(value, name, positive=False):
    """Keep numeric decimal/fraction inputs exact until numerical evaluation."""
    try:
        result = sp.Rational(str(value))
    except (TypeError, ValueError, ZeroDivisionError) as exc:
        raise ValueError(f"{name} must be a finite real number") from exc
    if not result.is_finite or (positive and result <= 0):
        raise ValueError(f"{name} must be finite" + (" and positive" if positive else ""))
    return result


def _integer(value, name, minimum):
    if isinstance(value, (bool, np.bool_)) or not isinstance(value, (int, np.integer)) or value < minimum:
        raise ValueError(f"{name} must be an integer >= {minimum}")
    return int(value)


@dataclass(frozen=True)
class ScalarEdge:
    """An internal edge (parallel edges and self-loops are allowed).

    ``source`` and ``target`` are hashable vertex labels; ``mass_squared`` and
    ``power`` must be finite and strictly positive. Decimal strings are exact.
    """

    source: object
    target: object
    mass_squared: object
    power: object = 1

    def __post_init__(self):
        try:
            hash(self.source)
            hash(self.target)
        except TypeError as exc:
            raise ValueError("vertex labels must be hashable") from exc
        if self.source != self.source or self.target != self.target:
            raise ValueError("vertex labels must compare equal to themselves (no NaN labels)")
        object.__setattr__(self, "mass_squared", _real(self.mass_squared, "mass_squared", True))
        object.__setattr__(self, "power", _real(self.power, "power", True))


@dataclass(frozen=True, init=False)
class ScalarGraph:
    """A connected scalar graph with conserved external Euclidean momenta.

    Parameters
    ----------
    edges : iterable of ScalarEdge
        Edge order fixes the order of parameters x0, x1, ... .
    external_momenta : mapping, optional
        Vertex -> real component sequence, all entering the graph. Missing
        vertices carry zero momentum. Components must sum to zero exactly;
        use decimal strings or rational numbers to avoid floating-point sums.
        These vectors specify invariants, independently of integration D.
    """

    edges: tuple
    vertices: tuple
    external_momenta: object

    def __init__(self, edges, external_momenta=None):
        edges = tuple(edges)
        if not edges or any(not isinstance(e, ScalarEdge) for e in edges):
            raise ValueError("edges must be a nonempty iterable of ScalarEdge objects")
        vertices = tuple(dict.fromkeys(v for e in edges for v in (e.source, e.target)))
        object.__setattr__(self, "edges", edges)
        object.__setattr__(self, "vertices", vertices)
        if len(self._components(range(len(edges)))[0]) != 1:
            raise ValueError("the graph must be connected")
        momenta = dict(external_momenta or {})
        if any(v not in vertices for v in momenta):
            raise ValueError("external momentum assigned to an unknown vertex")
        try:
            momenta = {v: tuple(_real(c, "momentum component") for c in p)
                       for v, p in momenta.items()}
        except TypeError as exc:
            raise ValueError("each external momentum must be a component sequence") from exc
        sizes = {len(p) for p in momenta.values()}
        if sizes and (len(sizes) != 1 or 0 in sizes):
            raise ValueError("external momentum vectors must have the same nonzero length")
        dimension = next(iter(sizes), 0)
        if any(sum(p[j] for p in momenta.values()) != 0 for j in range(dimension)):
            raise ValueError("external momenta must sum to zero exactly")
        zero = (sp.S.Zero,) * dimension
        object.__setattr__(self, "external_momenta", MappingProxyType(
            {v: momenta.get(v, zero) for v in vertices}))

    @property
    def loops(self):
        """Cycle rank E - V + 1 (including self-loops)."""
        return len(self.edges) - len(self.vertices) + 1

    def _components(self, indices):
        parent = {v: v for v in self.vertices}

        def root(v):
            while parent[v] != v:
                v = parent[v]
            return v

        cycles = 0
        for i in indices:
            edge = self.edges[i]
            a, b = root(edge.source), root(edge.target)
            if a == b:
                cycles += 1
            else:
                parent[a] = b
        groups = {}
        for v in self.vertices:
            groups.setdefault(root(v), []).append(v)
        return tuple(tuple(g) for g in groups.values()), cycles

    def symanzik(self, *, max_forests=100000):
        """Return ``(parameters, U, F)`` as exact SymPy expressions.

        U is a sum over complements of spanning trees. The momentum part of F
        sums squared momentum through each spanning two-forest cut; the mass
        part is U * sum(x_i*m_i^2). Enumeration is budgeted by max_forests.
        """
        max_forests = _integer(max_forests, "max_forests", 1)
        n, v = len(self.edges), len(self.vertices)
        count = sum(math.comb(n, k) for k in (v - 1, v - 2) if 0 <= k <= n)
        if count > max_forests:
            raise ValueError(f"forest enumeration requires {count} candidates; max_forests={max_forests}")
        x = sp.symbols(f"x0:{n}")
        U, kinetic = sp.S.Zero, sp.S.Zero
        for size in (v - 1, v - 2):
            if size < 0:
                continue
            for chosen in combinations(range(n), size):
                components, cycles = self._components(chosen)
                if cycles:
                    continue
                complement = set(range(n)).difference(chosen)
                monomial = sp.prod(x[i] for i in sorted(complement))
                if len(components) == 1:
                    U += monomial
                elif len(components) == 2:
                    vectors = [self.external_momenta[w] for w in components[0]]
                    q2 = sum(sum(c)**2 for c in zip(*vectors))
                    kinetic += q2 * monomial
        F = U * sum(x[i] * e.mass_squared for i, e in enumerate(self.edges)) + kinetic
        return x, sp.expand(U), sp.expand(F)

    def uv_margins(self, D, *, max_subgraphs=65535):
        """Return ``{edge_index_tuple: sum(nu) - D*loops/2}`` for cyclic subsets.

        Every margin must be positive for UV convergence. This includes the
        whole graph and all disconnected or overlapping loop subgraphs.
        Positive masses exclude infrared divergences in the supported domain.
        """
        dimension = _real(D, "D", True)
        max_subgraphs = _integer(max_subgraphs, "max_subgraphs", 1)
        n = len(self.edges)
        if (1 << n) - 1 > max_subgraphs:
            raise ValueError("UV subset enumeration exceeds max_subgraphs")
        margins = {}
        for size in range(1, n + 1):
            for indices in combinations(range(n), size):
                _, loops = self._components(indices)
                if loops:
                    margins[indices] = sum(self.edges[i].power for i in indices) - dimension * loops / 2
        return margins


@dataclass(frozen=True)
class MultiloopResult:
    """Double-precision estimate with statistical, not certified, uncertainty.

    ``error_estimate`` is the maximum of three standard errors across independent
    Sobol scrambles, the change at the last refinement, and a roundoff floor.
    ``converged`` means this diagnostic met max(epsabs, epsrel*abs(value)).
    ``evaluations`` counts sector integrand evaluations across all refinements.
    """

    value: float
    error_estimate: float
    standard_error: float
    converged: bool
    evaluations: int
    sectors: int
    samples_per_replicate: int
    replicates: int
    seed: int
    method: str = "RMT scale + Hepp sectors + scrambled Sobol"


class MultiloopConvergenceError(ArithmeticError):
    """Requested accuracy was not reached; ``result`` contains the estimate."""

    def __init__(self, result):
        self.result = result
        super().__init__(f"multiloop integration did not meet tolerance after {result.evaluations} "
                         f"evaluations (estimated error {result.error_estimate:.3g}); "
                         "increase max_power/max_evaluations or relax the tolerance")


def _sector_terms(terms, order):
    """Factor the common boundary monomial after x[order[j]]=t1*...*tj."""
    exponents = np.array([powers for powers, _ in terms], dtype=np.int64)
    transformed = np.cumsum(exponents[:, order][:, ::-1], axis=1)[:, ::-1][:, 1:]
    minimum = np.min(transformed, axis=0)
    return transformed - minimum, minimum


def _polynomial(points, exponents, coefficients):
    result = np.zeros(len(points))
    for powers, coefficient in zip(exponents, coefficients):
        term = np.full(len(points), coefficient)
        for j, power in enumerate(powers):
            if power:
                term *= points[:, j]**int(power)
        result += term
    return result


def integrate_graph(graph, D=2, *, epsrel=1e-4, epsabs=0.0, min_power=6,
                    max_power=16, replicates=8, seed=0, max_sectors=5040,
                    max_evaluations=2000000, max_forests=100000, strict=True):
    r"""Evaluate a convergent massive Euclidean scalar graph.

    Computes :math:`\int\prod_{l=1}^L d^Dk_l/\pi^{D/2}
    \prod_e(q_e^2+m_e^2)^{-\nu_e}`. Fractional positive D and powers are allowed.
    No dimensional-regulator expansion, counterterms, tensors, massless lines,
    or Minkowski continuation is performed.

    Requires the optional ``multiloop`` extra (SciPy). Independent scrambled
    Sobol estimates are refined from 2**min_power to at most 2**max_power
    samples per replicate, with at least two levels before acceptance.
    All E! Hepp sectors are summed at each sample; explicit sector, forest and
    evaluation budgets prevent unbounded work. Increasing loop count has no
    special hard-coded restriction, but factorial sector growth is expensive.

    Returns a :class:`MultiloopResult`. With strict=True (default), a missed
    tolerance raises :class:`MultiloopConvergenceError`, carrying the result.
    Statistical error diagnostics are not rigorous bounds or decimal-digit
    certification. ``epsrel`` must be >= 1e-12; this backend uses float64.
    """
    if not isinstance(graph, ScalarGraph):
        raise TypeError("graph must be a ScalarGraph")
    dimension = _real(D, "D", True)
    epsrel = float(_real(epsrel, "epsrel"))
    epsabs = float(_real(epsabs, "epsabs"))
    if not math.isfinite(epsrel) or not math.isfinite(epsabs) or epsrel < 1e-12 or epsabs < 0:
        raise ValueError("epsrel must be finite and >= 1e-12; epsabs must be finite and >= 0")
    min_power = _integer(min_power, "min_power", 1)
    max_power = _integer(max_power, "max_power", min_power + 1)
    if max_power > 30:
        raise ValueError("max_power must be <= 30 (Sobol bit depth)")
    replicates = _integer(replicates, "replicates", 4)
    seed = _integer(seed, "seed", 0)
    max_sectors = _integer(max_sectors, "max_sectors", 1)
    max_evaluations = _integer(max_evaluations, "max_evaluations", 1)
    n = len(graph.edges)
    sector_count = math.factorial(n)
    if sector_count > max_sectors:
        raise ValueError(f"graph requires {sector_count} Hepp sectors; max_sectors={max_sectors}")
    margins = graph.uv_margins(dimension)
    for indices, margin in margins.items():
        if margin <= 0:
            raise ValueError(f"UV divergent edge subset {indices}: sum(nu)-D*loops/2 = {margin}; "
                             "renormalization/epsilon expansion is not implemented")
    A = sum(e.power for e in graph.edges)
    s = A - graph.loops * dimension / 2
    u_power = s - dimension / 2
    x, U, F = graph.symanzik(max_forests=max_forests)
    u_terms, f_terms = sp.Poly(U, *x).terms(), sp.Poly(F, *x).terms()
    scale = max(c for _, c in f_terms)
    f_coeff = np.array([float(c / scale) for _, c in f_terms])
    u_coeff = np.array([float(c) for _, c in u_terms])
    if np.any(f_coeff <= 0) or not np.all(np.isfinite(f_coeff)):
        raise ArithmeticError("mass/kinematic hierarchy exceeds float64 coefficient range")
    # RMT on exp(-rho): phi(n)=1 gives Gamma(s). Scaling rho by F/U
    # supplies U**s/F**s. Compute the normalization before rounding to float64.
    with mp.workdps(50):
        mm = lambda q: mp.mpf(str(q.p)) / mp.mpf(str(q.q))
        log_prefactor = mp.log(ramanujan_master_theorem(lambda index: 1, mm(s)))
        log_prefactor -= sum(mp.loggamma(mm(e.power)) for e in graph.edges)
        log_prefactor -= mm(s) * mp.log(mm(scale))
        log_prefactor = float(log_prefactor)
    s, u_power = float(s), float(u_power)
    if not all(math.isfinite(v) for v in (s, u_power, log_prefactor)):
        raise ArithmeticError("parameters exceed float64 range")

    sectors = []
    for order in permutations(range(n)):
        ue, um = _sector_terms(u_terms, order)
        fe, fm = _sector_terms(f_terms, order)
        if not np.array_equal(um, fm):
            raise ArithmeticError("massive Hepp-sector factorization failed")
        # The t_j exponent is beta_j - 1. Set t_j=z_j**(ceil(beta_j)/beta_j).
        # The remaining weight has nonnegative integer exponents. Unlike
        # z**(1/beta), this does not create endpoint cusps when beta > 1.
        beta = np.array([float(sum(graph.edges[i].power for i in order[j:])
                               - dimension * int(um[j - 1]) / 2)
                         for j in range(1, n)])
        if np.any(beta <= 0) or not np.all(np.isfinite(1 / beta)):
            raise ArithmeticError("sector boundary powers exceed float64 range")
        integer_power = np.ceil(beta)
        mapping_power = integer_power / beta
        sectors.append((ue, fe, mapping_power, integer_power - 1,
                        log_prefactor + float(np.log(mapping_power).sum())))

    def integrand(points):
        result = np.zeros(len(points))
        with np.errstate(over="raise", invalid="raise", divide="raise"):
            for ue, fe, mapping_power, weight_power, log_weight in sectors:
                t = points**mapping_power
                ub = _polynomial(t, ue, u_coeff)
                fb = _polynomial(t, fe, f_coeff)
                weight = np.prod(points**weight_power, axis=1)
                result += weight * np.exp(log_weight + u_power * np.log(ub) - s * np.log(fb))
        if not np.all(np.isfinite(result)) or np.any(result < 0):
            raise ArithmeticError("integrand overflow/underflow; rescale the problem")
        return result

    if n == 1:
        value = float(integrand(np.empty((1, 0)))[0])
        if value <= 0:
            raise ArithmeticError("integrand underflow; rescale the problem")
        error = 64 * np.finfo(float).eps * abs(value)
        return MultiloopResult(value, error, 0.0, True, 1, 1, 1, 0, seed,
                              "RMT scale (single edge; no quadrature)")
    if sector_count * replicates * 2**(min_power + 1) > max_evaluations:
        raise ValueError("max_evaluations must allow at least two refinement levels")
    try:
        from scipy.stats import qmc
    except ImportError as exc:
        raise ImportError('integrate_graph requires SciPy: pip install "ramanujan-qft[multiloop]"') from exc
    random = np.random.default_rng(seed)
    engines = [qmc.Sobol(n - 1, scramble=True, seed=int(random.integers(0, 2**32)))
               for _ in range(replicates)]
    estimates = np.zeros(replicates)
    samples = evaluations = 0
    previous = None
    for power in range(min_power, max_power + 1):
        added = 2**power - samples
        cost = added * replicates * sector_count
        if evaluations + cost > max_evaluations:
            break
        for i, engine in enumerate(engines):
            # Keep batches bounded, even when the user permits a large budget.
            remaining = added
            seen = samples
            while remaining:
                batch = min(remaining, 4096)
                values = integrand(engine.random(batch))
                # Divide before summing to avoid overflow for large finite integrals.
                average = (values / batch).sum()
                estimates[i] = estimates[i] * (seen / (seen + batch)) + average * (batch / (seen + batch))
                seen += batch
                remaining -= batch
        samples += added
        evaluations += cost
        value = float((estimates / replicates).sum())
        magnitude = float(estimates.max())
        stderr = float((estimates / magnitude).std(ddof=1) / math.sqrt(replicates) * magnitude)
        if not math.isfinite(value) or not math.isfinite(stderr) or value <= 0:
            raise ArithmeticError("estimate overflow/underflow; rescale the problem")
        change = math.inf if previous is None else abs(value - previous)
        error = max(3 * stderr, change, 64 * np.finfo(float).eps * abs(value))
        converged = error <= max(epsabs, epsrel * abs(value))
        result = MultiloopResult(value, error, stderr, converged, evaluations,
                                sector_count, samples, replicates, seed)
        if converged:
            return result
        previous = value
    if strict:
        raise MultiloopConvergenceError(result)
    return result
