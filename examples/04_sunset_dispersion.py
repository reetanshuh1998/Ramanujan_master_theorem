r"""
Two-loop sunset: imaginary part and dispersion relation
=======================================================

The imaginary part of the massive sunset from its phase-space representation, and
the twice-subtracted dispersion relation :math:`S(s) - S(0) - s S'(0)`. Both are
precision-checked numerical integrations, validated against Feynman-parameter integrals
and a closed form. Each subtracted value takes 10-20 s.
"""
import mpmath as mp

from ramanujan_qft import sunset_im, sunset_subtracted, sunset_threshold

m = (1, 2, 3)
print("threshold (m1+m2+m3)^2 =", sunset_threshold(*m))
for s in (10, 20, 50, 100):
    print(f"s = {s:>4}:  Im S = {mp.nstr(sunset_im(s, *m), 12):>16}   "
          f"S(s) - S(0) - s S'(0) = {mp.nstr(sunset_subtracted(s, *m), 12)}")
