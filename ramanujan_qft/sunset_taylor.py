"""Equal-mass D=2 sunset by a convergent transformed Taylor series.

This is a differential-equation series with a Clausen boundary value, not a
Ramanujan/Gamma-family evaluator. It complements the strictly separate RMT API.
The parameter-integral majorant proves convergence for finite Euclidean p^2.
See docs/user_guide/sunset_taylor.md for normalization, recurrence and bounds.
"""
from dataclasses import dataclass

import mpmath as mp

from .multiloop import ScalarGraph, _integer, _real
from .sunset_rmt import _mp

__all__ = ["SunsetTaylorSeries", "SunsetTaylorResult", "SunsetTaylorConvergenceError",
           "compile_sunset_taylor", "integrate_sunset_taylor"]


class SunsetTaylorConvergenceError(ArithmeticError):
    """A Taylor evaluation exceeded its work or precision budget."""
    def __init__(self, message, result=None):
        self.result = result
        super().__init__(message)


@dataclass(frozen=True)
class SunsetTaylorResult:
    """Series value with mathematical tail and estimated arithmetic errors.

    The bound is evaluated at working precision, not with interval arithmetic.
    terms counts coefficients in the final pass, not both precision passes.
    """
    value: object
    error_estimate: object
    truncation_bound: object
    terms: int
    working_dps: int
    convergence_ratio: object
    converged: bool = True
    method: str = "equal-mass sunset / transformed Taylor series"


@dataclass(frozen=True)
class SunsetTaylorSeries:
    """Graph-validated equal-mass series in y = p_E^2/(9*m^2+p_E^2).

    Every finite nonnegative Euclidean invariant gives 0 <= y < 1. Close to
    one, the work budget may be insufficient. The recurrence has a growing
    parasitic solution: guard precision scales with the coefficient count.
    """
    graph: object
    mass_squared: object
    p_e_squared: object
    ratio: object

    def _sum(self, count, wp):
        with mp.workdps(wp):
            y = _mp(self.ratio)
            gap = _mp(1-self.ratio)  # retain tiny gaps independently of 1-y
            scale = 1/_mp(self.mass_squared)
            seed = 4*mp.clsin(2, mp.pi/3)/mp.sqrt(3)
            previous, current = mp.mpf(0), seed
            old_error, coefficient_error = mp.mpf(0), 64*mp.eps*abs(seed)
            power, total, arithmetic, absolute = mp.mpf(1), mp.mpf(0), mp.mpf(0), mp.mpf(0)
            for n in range(count):
                term = current*power
                total += term
                absolute += abs(term)
                arithmetic += coefficient_error*power
                if n+1 < count:
                    A, B, denominator = 7*n*n+7*n+2, 8*n*n, (n+1)**2
                    following = (6-A*current+B*previous)/denominator
                    next_error = (A*coefficient_error+B*old_error
                                  + 64*mp.eps*(6+A*abs(current)+B*abs(previous)))/denominator
                    previous, current = current, following
                    old_error, coefficient_error = coefficient_error, next_error
                power *= y
            # b_n = integral (1-9xyz/U)^n / U lies in [0, seed].
            # (1-y) sum_{n=count}^infinity b_n*y^n <= seed*y^count.
            upper_y = y*(1+8*mp.eps) if y else y
            tail = scale*seed*(1+64*mp.eps)*upper_y**count
            arithmetic = scale*gap*(arithmetic+64*mp.eps*(count+1)*absolute)
            return SunsetTaylorResult(scale*gap*total, tail+arithmetic, tail,
                                       count, wp, y, False), arithmetic

    def evaluate(self, *, dps=30, max_terms=512, max_dps=2000):
        """Evaluate with a positive-integrand tail bound and two precision passes.

        max_terms bounds each pass. max_dps bounds working decimal precision.
        Unmet targets raise SunsetTaylorConvergenceError; no quadrature or RMT
        fallback is invoked. The returned value is rounded to dps digits.
        """
        dps = _integer(dps, "dps", 10)
        max_terms = _integer(max_terms, "max_terms", 1)
        max_dps = _integer(max_dps, "max_dps", dps)
        gap = 1-self.ratio
        gap_digits = max(0, len(str(gap.q))-len(str(gap.p)))
        planning_dps = max(dps+25, gap_digits+25)
        if planning_dps > max_dps:
            raise SunsetTaylorConvergenceError("max_dps cannot resolve the series convergence ratio")
        with mp.workdps(planning_dps):
            if self.ratio == 0:
                needed = 1
            else:
                # Physical lower bound I >= seed*(1-y)/m^2 means this
                # coefficient count suffices independently of computed sums.
                threshold = mp.mpf(10)**(-dps)*_mp(gap)/32
                needed = max(1, int(mp.ceil(mp.log(threshold)/mp.log(_mp(self.ratio)))))
            count = min(needed, max_terms)
            # The unwanted recurrence solution grows as (-8)^n. Round upward
            # using one extra digit per coefficient, then measure propagation.
            wp = max(planning_dps, dps+count+25)
        previous = None
        while wp+15 <= max_dps:
            result, arithmetic = self._sum(count, wp)
            with mp.workdps(wp):
                tolerance = mp.mpf(10)**(-dps)*abs(result.value)
                if arithmetic <= tolerance/32 and result.value > 0:
                    higher, higher_arithmetic = self._sum(count, wp+15)
                    with mp.workdps(wp+15):
                        with mp.workdps(dps):
                            rounded = +higher.value
                        error = (higher.truncation_bound+higher_arithmetic
                                 + abs(higher.value-result.value)+abs(higher.value-rounded))
                        if needed <= max_terms and error <= mp.mpf(10)**(-dps)*abs(higher.value):
                            return SunsetTaylorResult(rounded, error, higher.truncation_bound,
                                                      count, wp+15, higher.convergence_ratio)
                    if needed > max_terms:
                        raise SunsetTaylorConvergenceError(
                            f"Taylor series needs {needed} terms, exceeding max_terms={max_terms}", higher)
                previous = result
            wp += max(25, wp//2)
        raise SunsetTaylorConvergenceError(
            f"Taylor series needs more than max_dps={max_dps} working digits", previous)


def compile_sunset_taylor(graph, D=2):
    """Compile the equal-mass, unit-power D=2 Euclidean sunset Taylor chart.

    This API deliberately identifies a different method from compile_sunset_rmt.
    Unequal masses and other topologies/dimensions are not implemented.
    """
    if not isinstance(graph, ScalarGraph):
        raise TypeError("graph must be a ScalarGraph")
    if _real(D, "D", True) != 2:
        raise NotImplementedError("the Taylor sunset backend requires D=2")
    if (len(graph.edges) != 3 or len(graph.vertices) != 2 or graph.loops != 2
            or any(e.source == e.target for e in graph.edges)):
        raise NotImplementedError("the Taylor backend requires three parallel sunset edges")
    if any(e.power != 1 for e in graph.edges):
        raise NotImplementedError("the Taylor sunset backend requires unit propagator powers")
    mass = graph.edges[0].mass_squared
    if any(e.mass_squared != mass for e in graph.edges):
        raise NotImplementedError("the Taylor sunset backend requires exactly equal masses")
    momentum = graph.external_momenta[graph.vertices[0]]
    q2 = sum(c*c for c in momentum)
    return SunsetTaylorSeries(graph, mass, q2, q2/(9*mass+q2))


def integrate_sunset_taylor(graph, D=2, *, dps=30, max_terms=512, max_dps=2000):
    """Compile and evaluate the separate equal-mass Taylor series backend."""
    return compile_sunset_taylor(graph, D=D).evaluate(dps=dps, max_terms=max_terms, max_dps=max_dps)
