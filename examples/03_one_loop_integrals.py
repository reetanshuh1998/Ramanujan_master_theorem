r"""
One-loop integrals at any precision
===================================

Scalar :math:`B_0` and :math:`C_0` in LoopTools conventions, to double precision
and to 50 digits, and the Method-of-Brackets series for :math:`B_0` compared with
its closed form.
"""
import mpmath as mp

from ramanujan_qft import B0, B0_mob, C0

# Double precision: identical to LoopTools 2.16
print("B0(5; 1, 1)          =", B0(5, 1, 1))            # LoopTools: 1.5695910590 + 1.4049629462i
print("C0(0,0,10; 1, 2, 3)  =", C0(10, 1, 2, 3))         # LoopTools: -0.4219325317 - 0.3367322680i

# 50 digits, e.g. to validate another code or for cancellations in large expressions
print("C0(0,0,10; 1, 2, 3)  =", mp.nstr(C0(10, 1, 2, 3, dps=50), 45))

# The Method-of-Brackets series gives the same B0, continued across threshold:
print("B0 closed form       =", mp.nstr(B0(5, 1, 1, dps=40), 35))
print("B0 MoB 2F1 series    =", mp.nstr(B0_mob(5, 1, dps=40), 35))

# UV pole and scale: B0 = delta + log(mu^2) + ...
print("B0(5;1,2), mu2=91.19^2, delta=1/eps:", B0(5, 1, 2, mu2=91.19**2, delta=1))
