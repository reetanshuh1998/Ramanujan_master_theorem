import sympy as sp
import mpmath
from ramanujan_integrator import RamanujanIntegrator
from ramanujan_qft.core.ramanujan_framework import AnalyticalConvolutionEngine
from scipy.integrate import quad
import numpy as np

class RamanujanUserAPI:
    """
    User-friendly Interface for the Ramanujan Algorithm Framework.
    Supports symbolic function input and automated transformation.
    """

    def __init__(self, precision=50):
        self.precision = precision
        mpmath.mp.dps = precision
        # Use the upgraded RamanujanIntegrator
        self.struct_integrator = RamanujanIntegrator(func=None, precision=precision)

    def integrate(self, func_expr, var_name='x'):
        """
        Calculates the integral of func_expr from 0 to infinity.
        Automatically detects power-transformations (e.g., sin(x^4)).
        """
        x = sp.Symbol(var_name)
        
        print(f"\nTarget: {func_expr}")
        
        # 1. Structural RMT Calculation
        # The RamanujanIntegrator handles the variable change and coefficient extraction
        res_rmt = self.struct_integrator.integrate(func_expr=func_expr, var_name=var_name)
        
        # 2. SciPy Baseline
        try:
            # We lambdify for SciPy
            f_np = sp.lambdify(x, func_expr, modules=['numpy', 'mpmath'])
            res_sp, err_sp = quad(f_np, 0, np.inf)
        except Exception as e:
            res_sp = "Failed"
            err_sp = str(e)

        # 3. Reporting
        print("-" * 50)
        print(f"RMT Result:   {float(res_rmt):.6f}")
        
        if isinstance(res_sp, (float, int)):
            print(f"SciPy Result: {float(res_sp):.6f}")
            error = abs(float(res_rmt) - float(res_sp))
            print(f"Difference:   {error:.2e}")
        else:
            print(f"SciPy Result: {res_sp}")
        print("-" * 50)
        
        return res_rmt

def demo_user_request():
    print("="*60)
    print("   RAMANUJAN INTEGRATOR - USER CUSTOM TEST")
    print("="*60)
    
    api = RamanujanUserAPI()
    
    # User's suggested integral: x^2 * sin(x^4)
    x = sp.Symbol('x')
    api.integrate(x**6 * sp.sin(x**8))

if __name__ == "__main__":
    demo_user_request()
