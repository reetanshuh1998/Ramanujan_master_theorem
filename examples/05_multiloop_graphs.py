"""
Massive Euclidean multiloop graphs
==================================

Graph construction, RMT scale integration, and numerical Hepp sectors.
Requires ``pip install '.[multiloop]'``. Errors are statistical estimates.
"""
import mpmath as mp
from ramanujan_qft import ScalarEdge, ScalarGraph, integrate_graph

# A two-loop equal-mass vacuum sunset, in D=2.
sunset = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(3)])
value = integrate_graph(sunset, D=2, epsrel=1e-4)
print("Two-loop sunset:", value.value, "+/-", value.error_estimate)
print("Independent Clausen value:", 4/mp.sqrt(3)*mp.im(mp.polylog(2, mp.exp(mp.j*mp.pi/3))))

# Add a fourth propagator: a genuine three-loop graph, without a topology dispatch.
banana = ScalarGraph([ScalarEdge(0, 1, 1) for _ in range(4)])
value = integrate_graph(banana, D=2, epsrel=1e-4)
print("Three-loop banana:", value.value, "+/-", value.error_estimate)
print("Independent exact value:", 7*mp.zeta(3))

# Unequal masses and conserved Euclidean external vectors.
moving = ScalarGraph([ScalarEdge(0, 1, mass) for mass in (1, 4, 9)],
                     external_momenta={0: [2, 1], 1: [-2, -1]})
print("U, F:", moving.symanzik()[1:])
print("UV margins:", moving.uv_margins(D=2))
print("Moving sunset:", integrate_graph(moving, D=2, epsrel=1e-3).value)
