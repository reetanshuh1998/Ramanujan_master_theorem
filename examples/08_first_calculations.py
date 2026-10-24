"""
Three calculations with independent references
==============================================

A scalar one-loop integral, a coupled RMT series, and a hybrid three-loop graph.
Install the ``multiloop`` extra. Mass inputs below are squared masses.
"""
import json
import mpmath as mp
import scipy  # Explicit import also loads SciPy in the browser console.
from ramanujan_qft import (B0, ScalarEdge, ScalarGraph, explain_sunset_rmt,
                           integrate_graph, RMTDomainError)

# 1. B0: LoopTools finite-part convention, Delta=0, mu^2=1; p^2=-2.
# Independent Feynman-parameter reference, evaluated with extra precision.
bubble = B0(-2, 1, 4, dps=30)
with mp.workdps(45):
    reference = -mp.quad(lambda x: mp.log(x + 4*(1-x) + 2*x*(1-x)), [0, 1])
    difference = abs(bubble-reference)
    assert difference < mp.mpf('1e-29')
print('B0:', mp.nstr(bubble, 30), 'absolute reference difference:', mp.nstr(difference, 4))
print('B0 returns a precision-checked scalar, not a separate error estimate.')

# 2. D=2 sunset: positive Euclidean propagators; d^2k d^2l / pi^2.
# Q=10 > m1+m2+m3=3 selects the momentum RMT chart.
sunset = ScalarGraph([ScalarEdge(0, 1, 1)]*3, {0: [10], 1: [-10]})
trace = explain_sunset_rmt(sunset, evaluate=True, dps=25)
diagnostics = trace['evaluation']['diagnostics']
assert trace['evaluation']['status'] == 'converged'
# Reference from independent simplex quadrature at 40 and 55 digits:
# tests/data/sunset_rmt_reference.json (precision difference < 2.4e-42).
with mp.workdps(45):
    reference = mp.mpf('0.6290167075906141495908272538835833416123070767')
    difference = abs(mp.mpf(diagnostics['value']['decimal'])-reference)
    assert difference <= mp.mpf(diagnostics['error_estimate']['decimal']) + mp.mpf('3e-42')
print('RMT value:', diagnostics['value']['decimal'])
print('RMT chart:', trace['convergence']['chart'], 'condition:', trace['convergence']['condition'])
print('RMT tail bound:', diagnostics['truncation_bound']['decimal'])
print('RMT estimated error:', diagnostics['error_estimate']['decimal'])
print('Gamma families:', len(trace['families']), 'terms:', diagnostics['terms'])
exported_json = json.dumps(trace, indent=2)  # Inspect without evaluating expression strings.
try:
    explain_sunset_rmt(ScalarGraph([ScalarEdge(0, 1, 1)]*3))
except RMTDomainError as error:
    print('Expected domain refusal:', error)
else:
    raise AssertionError('The RMT chart must refuse equal-mass vacuum')

# 3. D=1 three-loop banana: d^1k / sqrt(pi) for each of three loops.
# Fourier convolution gives pi^(3/2)*sum(m)/(prod(m)*(sum(m)^2+Q^2)).
banana = ScalarGraph([ScalarEdge(0, 1, m*m) for m in (1, 2, 3, 4)], {0: [2], 1: [-2]})
hybrid = integrate_graph(banana, D=1, epsrel=3e-3, max_evaluations=4000000, seed=1729)
reference = float(mp.pi**mp.mpf('1.5')*10/(24*(100+4)))
assert abs(hybrid.value-reference) <= hybrid.error_estimate
print('Hybrid value:', hybrid.value, '+/-', hybrid.error_estimate)
print('Fourier reference:', reference)
print('Hybrid method:', hybrid.method)
print('The hybrid estimate is float64 with statistical errors; it is not a full RMT series.')
