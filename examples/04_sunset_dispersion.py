"""
Two-loop sunset: imaginary part and the twice-subtracted dispersion relation
(certified; validated against Feynman-parameter integrals and a closed form in
tests/test_sunset.py and tests/test_round3_regressions.py). Each subtracted value
takes about 10-20 s (the whole example about a minute).
"""
import mpmath as mp

from ramanujan_qft import sunset_im, sunset_subtracted, sunset_threshold

m = (1, 2, 3)
print("threshold (m1+m2+m3)^2 =", sunset_threshold(*m))
for s in (10, 20, 50, 100):
    print(f"s = {s:>4}:  Im S = {mp.nstr(sunset_im(s, *m), 12):>16}   "
          f"S(s) - S(0) - s S'(0) = {mp.nstr(sunset_subtracted(s, *m), 12)}")
