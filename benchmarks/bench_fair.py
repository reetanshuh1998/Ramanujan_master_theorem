"""
Fair benchmark of ramanujan_qft.product_integral at 30 digits.

Baselines: the closed form where one exists (evaluated with mpmath), and
mpmath.quadosc (general oscillatory quadrature). For the triple product
there is no closed form (SymPy's integrate does not find one).

    python benchmarks/bench_fair.py
"""
import time

import mpmath as mp

from ramanujan_qft import bessel_j, cosine, exponential, gaussian_bessel, product_integral

DPS = 30


def best(fn, reps=3):
    t = float("inf")
    for _ in range(reps):
        t0 = time.perf_counter()
        v = fn()
        t = min(t, time.perf_counter() - t0)
    return v, t


def row(name, race, closed=None, quad=None):
    with mp.workdps(DPS + 10):
        ref = closed[0] if closed else quad[0]
        err = lambda v: mp.nstr(abs(v - ref) / abs(ref), 2)
        out = f"| {name} | {err(race[0])}, {race[1]*1e3:.1f} ms |"
        out += f" {err(closed[0])}, {closed[1]*1e3:.3f} ms |" if closed else " — |"
        out += f" {err(quad[0])}, {quad[1]*1e3:.0f} ms |" if quad else " — |"
    print(out)


mp.mp.dps = DPS
print("| integral (30 digits) | RACE | closed form (mpmath) | mpmath.quadosc |")
print("|---|---|---|---|")
for b in (3, 1e3, 1e6):
    race = best(lambda: product_integral(exponential(1), bessel_j(0, b), dps=DPS))
    closed = best(lambda: 1 / mp.sqrt(1 + mp.mpf(b)**2))
    quad = best(lambda: mp.quadosc(lambda x: mp.exp(-x) * mp.besselj(0, b * x), [0, mp.inf], omega=b), reps=1) if b < 1e4 else None
    row(f"e^-x J0({b:g} x)", race, closed, quad)
for b in (3, 1e3, 1e6):
    race = best(lambda: product_integral(exponential(1), cosine(b), dps=DPS))
    closed = best(lambda: 1 / (1 + mp.mpf(b)**2))
    row(f"e^-x cos({b:g} x)", race, closed)
for b in (1, 100, 1e4):
    race = best(lambda: product_integral(exponential(2), gaussian_bessel(0.5, b, 1), dps=DPS))
    with mp.workdps(DPS + 10):
        quad = best(lambda: mp.quadosc(lambda x: mp.exp(-2 * x - x * x / 2) * mp.besselj(1, b * x),
                                       [0, mp.inf], omega=b), reps=1) if b < 1e3 else None
    if quad is None:
        print(f"| e^-2x e^-x^2/2 J1({b:g} x) | {race[1]*1e3:.1f} ms (no independent reference at this b) | — | — |")
    else:
        row(f"e^-2x e^-x^2/2 J1({b:g} x)", race, None, quad)
