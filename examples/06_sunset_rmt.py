"""
A graph-generated multivariate RMT series
==================================================

Exact bracket algebra, analytic pole resolution, and convergent summation.
This example uses no numerical integration backend.
"""
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, compile_sunset_rmt, RMTDomainError

graph = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)],
                    external_momenta={0: [10], 1: [-10]})
series = compile_sunset_rmt(graph)
print("Bracket matrix:", series.bracket_system.matrix)
print("Gamma families:", len(series.families))
result = series.evaluate(dps=30)
print("Chart:", result.chart)
print("Integral:", mp.nstr(result.value, 30))
print("Tail bound:", mp.nstr(result.truncation_bound, 5))

vacuum = ScalarGraph([ScalarEdge(0, 1, m2) for m2 in (1, 4, 100)])
result = compile_sunset_rmt(vacuum).evaluate(dps=30)
print("Unequal-mass vacuum:", mp.nstr(result.value, 30))

# This finite integral needs another series chart, not a forced summation.
try:
    compile_sunset_rmt(ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)]))
except RMTDomainError as error:
    print("Equal-mass vacuum correctly refused:", error)
