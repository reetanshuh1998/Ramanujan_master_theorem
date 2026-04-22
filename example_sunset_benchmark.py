import time
import mpmath
import numpy as np
from feynman_mob_solver import FeynmanMoBSolver
import ctypes
import os

# --- pySecDec Wrapper for Sunset ---
def psd_sunset_lib(real_parameters):
    lib_path = 'pysecdec_sunset_benchmark/pysecdec_sunset_lib/pysecdec_sunset_lib_pylink.so'
    if not os.path.exists(lib_path):
        return complex(0, 0)
    
    # Load the library using the pySecDec interface
    # (Assuming standard pylink structure)
    try:
        import sys
        sys.path.append('pysecdec_sunset_benchmark/pysecdec_sunset_lib')
        import pysecdec_sunset_lib_pylink as psd_link
        
        # requested_orders=[0] for finite part
        res = psd_link.integrate(real_parameters=real_parameters, epsrel=1e-3)
        # Returns [order0, order1, ...]
        return complex(res[0])
    except Exception as e:
        print(f"Error loading pySecDec Sunset: {e}")
        return complex(0, 0)

def run_sunset_benchmark():
    solver = FeynmanMoBSolver(precision=50)
    
    print("\n" + "="*120)
    print("  MASSIVE SUNSET BENCHMARK: 2-LOOP SELF-ENERGY S(p², m1, m2, m3)")
    print("  D = 4  |  IMAGINARY PART VALIDATION (The Global Residue Strategy)")
    print("="*120)
    
    # Test Point: p^2 = 100, m^2 = [1, 2, 3]
    psq = 100.0
    msq_list = [1.0, 2.0, 3.0]
    
    print(f"\nKinematics: p² = {psq}, m² = {msq_list}")
    
    # ── RAF / MoB ────────────────────────────────────────
    t0 = time.time()
    res_raf, raf_t = solver.massive_sunset_residue(msq_list, psq)
    raf_val = complex(res_raf)
    
    # ── pySecDec ─────────────────────────────────────────
    # psd expects [m1, m2, m3, psq] based on setup_pysecdec_sunset.py
    t0 = time.time()
    psd_val = psd_sunset_lib([msq_list[0], msq_list[1], msq_list[2], psq])
    psd_t = time.time() - t0
    
    print("\n" + "-"*120)
    print(f"{'Solver':<15} | {'Real Part':^25} | {'Imaginary Part':^25} | {'Time':^10} |")
    print("-"*120)
    print(f"{'RAF MoB':<15} | {raf_val.real:^25.10f} | {raf_val.imag:^25.10f} | {raf_t*1000:^10.2f}ms |")
    print(f"{'pySecDec':<15} | {psd_val.real:^25.10f} | {psd_val.imag:^25.10f} | {psd_t:^10.2f}s  |")
    print("-"*120)
    
    # Accuracy Check for Imaginary Part
    err_im = abs(raf_val.imag - psd_val.imag)
    if psd_val.imag != 0:
        rel_err = err_im / abs(psd_val.imag)
        print(f"\n[Validation] Imaginary Part Relative Error: {rel_err:.2e}")
        if rel_err < 0.05:
            print("✓ MATCH: The Global Residue Strategy successfully discovers the Sunset threshold cut.")
        else:
            print("✗ MISMATCH: Phase space integral parameters or prefactors need refinement.")
    else:
        print("\n[Warning] pySecDec returned zero imaginary part. Check if library was compiled correctly.")

if __name__ == "__main__":
    run_sunset_benchmark()
