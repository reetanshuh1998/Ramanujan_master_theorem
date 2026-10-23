"""
Equal-mass vacuum and Euclidean continuation
============================================================

A separate Taylor method fills the equal-mass gap in the RMT charts.
"""
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_sunset_taylor, integrate_graph_rmt

for momentum in (0, 1, 3, 6):
    graph = ScalarGraph([ScalarEdge(0, 1, 1)]*3,
                        {0: [momentum], 1: [-momentum]})
    result = integrate_sunset_taylor(graph, dps=25)
    print(momentum, mp.nstr(result.value, 25), result.method)
    if momentum == 6:
        rmt = integrate_graph_rmt(graph, dps=25)
        with mp.workdps(40):
            assert abs(result.value-rmt.value) <= result.error_estimate+rmt.error_estimate
