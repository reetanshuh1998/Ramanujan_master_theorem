import mpmath
mpmath.mp.dps = 30
# Let's test a simple 1D MB integral
def mb_integrand(s, z):
    # Integral of Gamma(-s) Gamma(1+s) (-z)^s / (2pi i)
    return mpmath.gamma(-s) * mpmath.gamma(1+s) * mpmath.power(-z, s)

def eval_mb(z, c=-0.5):
    # integrate along c - i*inf to c + i*inf
    def integrand(t):
        s = mpmath.mpc(c, t)
        return mb_integrand(s, z) * mpmath.mpc(0, 1) / (2 * mpmath.pi * mpmath.mpc(0, 1))
    
    # We truncate the infinite integral
    res = mpmath.quad(integrand, [-20, 20])
    return res

z = mpmath.mpf('-0.5') # Test z < 0
print(eval_mb(z))
print(1 / (1 - z)) # Expected result
