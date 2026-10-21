"""
Backward-compatible front end of the Mellin-convolution engine (RACE).

The implementation lives in :mod:`ramanujan_qft.mellin`; this module keeps the
original ``AnalyticalConvolutionEngine`` / ``TripleProductEngine`` API.
Failures now raise exceptions instead of returning error strings.
"""

import mpmath

from ramanujan_qft import mellin

__all__ = ["AnalyticalConvolutionEngine", "TripleProductEngine"]


def _component(comp):
    t, p = comp["type"], comp.get("params", {})
    if t == "exponential":
        return mellin.exponential(p["k"])
    if t == "gaussian":
        return mellin.gaussian(p["a"])
    if t == "bessel_j0":
        return mellin.bessel_j(0, p["b"])
    if t == "bessel_j":
        return mellin.bessel_j(p["nu"], p["b"])
    if t == "cosine":
        return mellin.cosine(p["b"])
    if t == "sine":
        return mellin.sine(p["b"])
    if t == "inverse_power":
        return mellin.inverse_power(p["m"], p["v"])
    raise ValueError(f"component type {t!r} is not in the Mellin atlas")


class AnalyticalConvolutionEngine:
    """
    Ramanujan Analytical Convolution Engine (RACE).
    Evaluates Int_0^oo x^(s-1) f1(x) f2(x) dx by summing Mellin residues.
    """

    def __init__(self, precision=30):
        self.precision = precision

    def solve_product(self, comp1, comp2, s_target=1.0):
        """
        comp = {'type': 'exponential'|'gaussian'|'bessel_j0'|'bessel_j'|'cosine'|'sine'|
                        'inverse_power', 'params': {...}}
        Raises mellin.SeriesConvergenceError when no residue expansion converges.
        """
        return mellin.product_integral(_component(comp1), _component(comp2),
                                       s=s_target, dps=self.precision)


class TripleProductEngine(AnalyticalConvolutionEngine):
    """Int_0^oo x^(s-1) exp(-k x) exp(-a x^2) J_nu(b x) dx."""

    def solve_trio_benchmark(self, k, a, b, nu=1, s_target=1.0):
        return mellin.product_integral(mellin.exponential(k), mellin.gaussian_bessel(a, b, nu),
                                       s=s_target, dps=self.precision)

    def solve_triple_bessel(self, k, a, b, nu=0, s=1.0):
        """Alias of :meth:`solve_trio_benchmark`."""
        return self.solve_trio_benchmark(k, a, b, nu=nu, s_target=s)


if __name__ == "__main__":
    eng = AnalyticalConvolutionEngine()
    r = eng.solve_product({"type": "exponential", "params": {"k": 3}},
                          {"type": "bessel_j0", "params": {"b": 4}})
    print("Int exp(-3x) J0(4x) dx =", r, " exact = 1/5")
