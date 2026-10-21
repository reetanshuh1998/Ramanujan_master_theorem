"""
Product integrals by Mellin residue summation (accuracy and timing against exact values).

Int_0^oo e^(-x) J0(w x) dx = 1/sqrt(1 + w^2). For large w the integrand oscillates
w/(2 pi) times per unit length, so adaptive quadrature needs ~w subintervals,
while the residue series converges like (1/w)^n.
"""
import time

import mpmath as mp

from ramanujan_qft import (SeriesConvergenceError, bessel_j, exponential, gaussian_bessel,
                           inverse_power, product_integral)

mp.mp.dps = 30
for w in (10, 1e3, 1e5):
    t = time.perf_counter()
    v, info = product_integral(exponential(1), bessel_j(0, w), return_info=True)
    dt = time.perf_counter() - t
    err = abs(v - 1 / mp.sqrt(1 + mp.mpf(w)**2)) / v
    print(f"w = {w:>8}: rel. error {mp.nstr(err, 2):>8}  {dt * 1e3:6.1f} ms  ({info['terms']} terms, {info['method']})")

# Logarithmic case (coinciding poles), exact: e^6 E1(6)
print("Int e^(-2x)/(x+3) dx =", product_integral(exponential(2), inverse_power(3, 1)), " exact:", mp.exp(6) * mp.e1(6))

# Three-factor product e^(-2x) e^(-x^2/2) J1(100 x)
print("Int e^(-2x) e^(-x^2/2) J1(100x) dx =", product_integral(exponential(2), gaussian_bessel(0.5, 100, 1)))

# Where the expansion parameter is ~1 the engine refuses instead of guessing:
try:
    product_integral(exponential(1), bessel_j(0, 1), max_terms=300)
except SeriesConvergenceError as e:
    print("k = b:", str(e)[:90], "...")
