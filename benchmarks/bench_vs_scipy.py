"""
Mellin residue summation vs scipy.integrate.quad for oscillatory product integrals.

    python benchmarks/bench_vs_scipy.py

SciPy is used *properly* (finite range where e^-x < 1e-17, enough subintervals),
so the comparison reflects the methods rather than a misconfigured baseline.
"""
import time

import mpmath as mp
import numpy as np
from scipy import integrate, special

from ramanujan_qft import bessel_j, exponential, product_integral


def timed(fn, reps=3):
    best = float("inf")
    for _ in range(reps):
        t = time.perf_counter()
        out = fn()
        best = min(best, time.perf_counter() - t)
    return out, best


print("Int_0^oo e^(-x) J0(w x) dx = 1/sqrt(1+w^2)")
print(f"{'w':>8} | {'RMT/Mellin rel.err':>18} {'time':>9} | {'scipy.quad rel.err':>18} {'time':>9}")
for w in (2, 10, 100, 1e3, 1e4, 1e5):
    exact = 1 / np.sqrt(1 + w * w)
    with mp.workdps(16):
        v, t1 = timed(lambda: product_integral(exponential(1), bessel_j(0, w), dps=16))
    q, t2 = timed(lambda: integrate.quad(lambda x: np.exp(-x) * special.j0(w * x), 0, 40,
                                         limit=int(max(200, 15 * w)))[0], reps=1)
    print(f"{w:>8g} | {abs(float(v) - exact) / exact:>18.1e} {t1 * 1e3:>7.1f}ms | "
          f"{abs(q - exact) / exact:>18.1e} {t2 * 1e3:>7.1f}ms")
