import mpmath
import numpy as np
import matplotlib.pyplot as plt
from ramanujan_qft.core.ramanujan_framework import AnalyticalConvolutionEngine
from scipy.integrate import quad
import time

def generate_comparison_plot():
    engine = AnalyticalConvolutionEngine(precision=50)
    
    # Target: Integral[ exp(-x) * J0(w*x) ] = 1 / sqrt(1 + w^2)
    # Range of frequencies
    ws = np.logspace(0, 5, 20)  # From 1 to 100,000
    
    scipy_errors = []
    rmt_errors = []
    
    print("\nScaling Test: Error vs Frequency (w)")
    print(f"{'Freq (w)':<10} | {'SciPy Err':<12} | {'RMT Err':<12}")
    print("-" * 40)
    
    for w in ws:
        w_float = float(w)
        exact = 1.0 / np.sqrt(1.0 + w_float**2)
        
        # 1. SciPy Quad (Traditional)
        try:
            # We use standard quad. Oscillatory weights could be used but 
            # for a general 'black box' traditional quad is the baseline.
            res_sp, err_sp = quad(lambda x: np.exp(-x) * mpmath.j0(w_float * x), 0, np.inf, limit=100)
            sp_error = abs(res_sp - exact) / (exact + 1e-20)
        except:
            sp_error = 1.0 # Failure
        scipy_errors.append(sp_error)
        
        # 2. Ramanujan RACE
        comp1 = {'type': 'exponential', 'params': {'k': 1}}
        comp2 = {'type': 'bessel_j0',   'params': {'b': w_float}}
        res_rmt = engine.solve_product(comp1, comp2)
        
        if isinstance(res_rmt, str):
            rmt_error = 1.0
        else:
            rmt_error = float(abs(res_rmt - exact)) / (exact + 1e-20)
        
        rmt_errors.append(rmt_error)
        
        print(f"{w_float:<10.1f} | {sp_error:<12.2e} | {rmt_error:<12.2e}")

    # Plotting
    plt.figure(figsize=(10, 6))
    plt.loglog(ws, scipy_errors, 'ro-', linewidth=2, label='SciPy Quad (Numerical Sampling)')
    plt.loglog(ws, rmt_errors, 'b*--', markersize=8, label='Ramanujan RACE (Analytical Discovery)')
    
    # Aesthetics
    plt.axhline(y=1e-15, color='gray', linestyle=':', label='Double Precision Floor')
    plt.xlabel('Oscillation Frequency (w)', fontsize=12)
    plt.ylabel('Relative Error', fontsize=12)
    plt.title('The Ramanujan Advantage: Precision Stability at High Frequencies\nIntegrand: exp(-x) * J₀(wx)', fontsize=14)
    plt.grid(True, which="both", ls="-", alpha=0.5)
    plt.legend(loc='lower left')
    
    # Save
    plot_file = 'rmt_superiority_plot.png'
    plt.savefig(plot_file, dpi=300)
    print(f"\nSuperiority plot saved to {plot_file}")

if __name__ == "__main__":
    generate_comparison_plot()
