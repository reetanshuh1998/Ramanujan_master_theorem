"""
Two-loop sunset: exact imaginary part and the twice-subtracted dispersion relation
(validated against Feynman-parameter integrals in tests/test_sunset.py).
"""
import mpmath as mp

from ramanujan_qft import sunset_im, sunset_subtracted, sunset_threshold

m = (1, 2, 3)
print("threshold (m1+m2+m3)^2 =", sunset_threshold(*m))
for s in (10, 20, 50, 100):
    print(f"s = {s:>4}:  Im S = {mp.nstr(sunset_im(s, *m), 12):>16}   "
          f"S(s) - S(0) - s S'(0) = {mp.nstr(sunset_subtracted(s, *m), 12)}")
