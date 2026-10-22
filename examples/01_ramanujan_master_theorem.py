r"""
Ramanujan's Master Theorem
==========================

If :math:`f(x) = \sum_n \varphi(n) (-x)^n / n!`, then

.. math:: \int_0^\infty x^{s-1} f(x)\,dx = \Gamma(s)\,\varphi(-s).

This example applies the theorem to :math:`(1+x)^{-3}`, checks it against the
Beta function and a numerical Mellin transform, and evaluates a dimensionally
regulated radial integral, where the theorem *is* the analytic continuation in D.
"""
import mpmath as mp

from ramanujan_qft import massive_propagator_rmt, mellin_numeric, ramanujan_master_theorem

mp.mp.dps = 30

# 1/(1+x)^a = Sum (a)_n (-x)^n / n!   ->  phi(n) = Gamma(a+n)/Gamma(a)
a, s = mp.mpf(3), mp.mpf("1.25")
rmt = ramanujan_master_theorem(lambda n: mp.gamma(a + n) / mp.gamma(a), s)
print("Int x^(s-1) (1+x)^-3 dx   RMT     :", rmt)
print("                          Beta    :", mp.beta(s, a - s))
print("                          numeric :", mellin_numeric(lambda x: (1 + x)**-a, s))

# A dimensionally regulated radial integral: the RMT result *is* the analytic continuation in D.
for D in (1, 3, mp.mpf("3.9")):
    print(f"Int dq2 q2^(D/2-1)/(q2+1),  D={mp.nstr(D, 3)}:", massive_propagator_rmt(1, D))
