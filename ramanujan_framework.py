import mpmath
from feynman_atlas import RMTAtlas

class AnalyticalConvolutionEngine:
    """
    Ramanujan Analytical Convolution Engine (RACE).
    Solves product integrals by summing residues of their Mellin components.
    """

    def __init__(self, precision=100):
        self.precision = precision
        mpmath.mp.dps = precision

    def solve_product(self, comp1, comp2, s_target=1.0):
        """
        Evaluate Integral[ f1 * f2 * x^(s-1), 0, inf ]
        Uses the Parseval-Mellin Identity with Epsilon Regularization.
        """
        M1 = RMTAtlas.get_transform(comp1['type'], comp1['params'])
        M2 = RMTAtlas.get_transform(comp2['type'], comp2['params'])
        
        if not M1 or not M2:
            return "Component not in Atlas."

        # POLE REGULARIZATION: Shift s_target slightly to avoid direct Gamma poles
        # We take the result as the real part of calculation at s + i*eps
        eps = mpmath.mpc(0, '1e-30')
        s_reg = mpmath.mpf(str(s_target)) + eps

        def residue_contribution(k_val):
            if comp1['type'] == 'exponential':
                k_param = mpmath.mpf(str(comp1['params']['k']))
                res_M1 = mpmath.power(k_param, k_val) * mpmath.power(-1, k_val) / mpmath.factorial(k_val)
                # Correct sum: Res(M1, -k) * M2(s_reg - (-k))
                val = res_M1 * M2(s_reg + k_val)
                return val
            return 0

        try:
            # Use Richardson extrapolation for the infinite sum
            result = mpmath.nsum(residue_contribution, [0, mpmath.inf])
            return result.real # The physical result is the real part
        except Exception as e:
            return f"Summation failed: {e}"
class TripleProductEngine(AnalyticalConvolutionEngine):
    """
    Advanced Engine for Triple Product Integrals (Transcendental Trio).
    Handles Integral[ exp(-kx) * exp(-ax^2) * Jv(bx) * x^(s-1), 0, inf ]
    """

    def solve_trio_benchmark(self, k, a, b, nu=1, s_target=1.0):
        """
        Evaluate the 'Transcendental Trio': exp(-kx) * exp(-ax^2) * Jv(bx).
        Uses Composite Sequential Convolution:
        I = SUM_{n} Res(M_exp, -n) * M_composite(s_target + n)
        where M_composite is the Mellin transform of Gaussian * Bessel.
        """
        eps = mpmath.mpc(0, '1e-30')
        s_reg = mpmath.mpf(str(s_target)) + eps

        def composite_mellin_gb(s):
            """Mellin transform of exp(-ax^2) * Jv(bx)"""
            # M(s) = [ (b/2)^v / (2 * a^((s+v)/2) * Gamma(v+1)) ] * Gamma((s+v)/2) * 1F1((s+v)/2, v+1, -b^2/4a)
            # Parameters
            ap = mpmath.mpf(str(a))
            bp = mpmath.mpf(str(b))
            nup = mpmath.mpf(str(nu))
            
            # Components
            prefactor = (mpmath.power(bp/2, nup)) / (2 * mpmath.power(ap, (s + nup)/2) * mpmath.gamma(nup + 1))
            g_part = mpmath.gamma((s + nup)/2)
            f11_part = mpmath.hyp1f1((s + nup)/2, nup + 1, -(bp**2)/(4*ap))
            
            return prefactor * g_part * f11_part

        def residue_contribution(n_val):
            # Poles of exp(-kx) at -n
            kp = mpmath.mpf(str(k))
            res_exp = mpmath.power(kp, n_val) * mpmath.power(-1, n_val) / mpmath.factorial(n_val)
            # Result = Res * M_composite(s_reg + n)
            return res_exp * composite_mellin_gb(s_reg + n_val)

        try:
            # Evaluate the residue series
            # For extreme scales, this series is much more stable than double-summation
            result = mpmath.nsum(residue_contribution, [0, mpmath.inf])
            return result.real
        except Exception as e:
            return f"Trio Convolution failed: {e}"

def benchmark_race():
    print("\n" + "="*70)
    print("   RAMANUJAN ANALYTICAL CONVOLUTION ENGINE (RACE) - BENCHMARK")
    print("="*70)

    engine = AnalyticalConvolutionEngine()

    # TEST RANGE
    print("\n1. Diverse Integral Test: Bessel-Exponential Product")
    print("Integrand: exp(-3x) * J0(4x)")
    
    comp1 = {'type': 'exponential', 'params': {'k': 3}}
    comp2 = {'type': 'bessel_j0',   'params': {'b': 4}}
    
    res = engine.solve_product(comp1, comp2, s_target=1.0)
    exact = 1.0 / mpmath.sqrt(3**2 + 4**2)
    
    print(f"Exact Value: {float(exact):.6f}")
    if isinstance(res, str):
        print(f"RACE Result: {res}")
    else:
        print(f"RACE Result: {float(res):.6f}")
        print(f"Error:       {float(abs(res - exact)):.2e}")
    
    print("\n2. Gaussian-Exponential Product")
    comp1b = {'type': 'exponential', 'params': {'k': 5}}
    comp2b = {'type': 'gaussian',    'params': {'a': 2}}
    
    res2 = engine.solve_product(comp1b, comp2b, s_target=1.0)
    exact2 = mpmath.quad(lambda x: mpmath.exp(-5*x) * mpmath.exp(-2*x**2), [0, mpmath.inf])
    
    print(f"Numerical Ref: {float(exact2):.6f}")
    if isinstance(res2, str):
        print(f"RACE Result:   {res2}")
    else:
        print(f"RACE Result:   {float(res2):.6f}")
        print(f"Error:         {float(abs(res2 - exact2)):.2e}")

if __name__ == "__main__":
    benchmark_race()
