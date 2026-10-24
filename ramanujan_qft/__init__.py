"""
ramanujan-qft: Ramanujan's Master Theorem, Mellin residue summation and
arbitrary-precision Feynman integrals.

Validated public API
--------------------
rmt        ramanujan_master_theorem, mellin_numeric, massive_propagator_rmt
mellin     product_integral and the Mellin atlas (exponential, gaussian, bessel_j, ...)
one_loop   B0, B0_mob, C0, C0_mob, bubble_3d   (LoopTools conventions)
sunset     sunset_im, sunset_subtracted, sunset_d2
multiloop  ScalarEdge, ScalarGraph, integrate_graph (massive Euclidean, statistical errors)
sunset_rmt compile_sunset_rmt, integrate_graph_rmt (D=2 sunset, proven series domains)

The 0.1 classes (FeynmanMoBSolver, RamanujanContinuationEngine, ...) remain importable.
"""

from .rmt import ramanujan_master_theorem, mellin_numeric, massive_propagator_rmt
from .mellin import (MellinFunction, SeriesConvergenceError, product_integral, exponential,
                     gaussian, bessel_j, cosine, sine, inverse_power, gaussian_bessel)
from .one_loop import B0, B0_mob, C0, C0_mob, bubble_3d
from .sunset import sunset_threshold, sunset_im, sunset_subtracted, sunset_d2
from .multiloop import (ScalarEdge, ScalarGraph, MultiloopResult,
                       MultiloopConvergenceError, integrate_graph)
from .brackets import BracketSystem, BracketSolution, schwinger_brackets
from .sunset_rmt import (SunsetRMTSeries, RMTSeriesResult, RMTDomainError,
                         RMTSeriesConvergenceError, compile_sunset_rmt, integrate_graph_rmt)
from .sunset_taylor import (SunsetTaylorSeries, SunsetTaylorResult, SunsetTaylorConvergenceError,
                            compile_sunset_taylor, integrate_sunset_taylor)
from .solvers.feynman_mob_solver import FeynmanMoBSolver
from .utils.ramanujan_continuation import RamanujanContinuationEngine

__version__ = "0.3.0a4"
