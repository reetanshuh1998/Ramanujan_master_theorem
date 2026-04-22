"""
feynman_benchmark_vs_traditional.py
====================================
Head-to-head comparison of the Ramanujan Algorithm Framework (RAF)
against pySecDec for the 1-loop massive bubble integral.

Topology:   1-loop self-energy with two massive propagators
Dimension:  D = 3 - 2*eps  (eps = 0)
Parameters: m1^2 = m2^2 = 1,  p^2 scanned over 4 decades

RAF uses a closed-form 2F1 discovered via MoB residue analysis:
    B(s, m, m) = [sqrt(pi)/sqrt(m)] * 2F1(1/2, 1; 3/2; s/(4m))

pySecDec uses compiled Monte-Carlo sector decomposition (C++).
"""

import time
import os
import re
import mpmath
from feynman_mob_solver import FeynmanMoBSolver

def parse_pysecdec_result(raw_str):
    """
    Extract the central value (real, imag) from pySecDec output format:
    ' + ((real,imag) +/- (err_real,err_imag)) + O(eps)'
    """
    m = re.search(r'\(\(([^,]+),([^)]+)\)', raw_str)
    if m:
        return complex(float(m.group(1)), float(m.group(2)))
    return None

def benchmark_loop_integrals():
    """
    Benchmark: pySecDec (sector decomposition) vs RAF (analytical 2F1).
    """
    solver = FeynmanMoBSolver(precision=50)

    p2_vals = [1.0, 100.0, 10000.0, 1000000.0]
    m1_sq = 1.0
    m2_sq = 1.0

    # Load the compiled pySecDec library once
    psd_lib_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        'RECREATION', 'bubble1L_pysecdec', 'bubble1L_pysecdec_pylink.so'
    )
    from pySecDec.integral_interface import IntegralLibrary
    lib = IntegralLibrary(psd_lib_path)

    W = 100  # column width
    print("\n" + "=" * W)
    print("   FEYNMAN 1-LOOP BUBBLE: RAF (Analytical 2F1) vs. pySecDec (Monte Carlo)")
    print("   Topology: B(p^2; m1^2=1, m2^2=1)  in D = 3 - 2*eps,  eps^0 coefficient")
    print("=" * W)
    print(f"{'p^2':>12} | {'Method':^16} | {'Re':>14} {'Im':>14} | {'Time (s)':>10} | {'Match?'}")
    print("-" * W)

    for p2 in p2_vals:
        # ── pySecDec (compiled C++ Monte-Carlo) ──────────────────────
        t0 = time.time()
        res_tuple = lib(real_parameters=[p2, m1_sq, m2_sq])
        psd_time = time.time() - t0
        raw_str = res_tuple[0] if isinstance(res_tuple, (list, tuple)) else str(res_tuple)
        psd_val = parse_pysecdec_result(raw_str)

        # ── Ramanujan Framework (analytical 2F1) ─────────────────────
        t0 = time.time()
        raf_val = solver.solve_massive_bubble(1, 1, s=p2, m1_sq=m1_sq, m2_sq=m2_sq)
        raf_time = time.time() - t0
        raf_val = complex(raf_val)

        # ── Accuracy comparison ──────────────────────────────────────
        if psd_val is not None:
            rel_err = abs(raf_val - psd_val) / max(abs(psd_val), 1e-30)
            match = "✓" if rel_err < 1e-4 else f"✗ ({rel_err:.1e})"
        else:
            match = "N/A"

        # Print pySecDec row
        if psd_val is not None:
            print(f"{p2:>12.1f} | {'pySecDec':^16} | {psd_val.real:>14.6f} {psd_val.imag:>14.6f} | {psd_time:>10.5f} |")
        else:
            print(f"{p2:>12.1f} | {'pySecDec':^16} | {'FAIL':>14} {'':>14} | {psd_time:>10.5f} |")

        # Print RAF row
        print(f"{'':>12} | {'RAF (2F1)':^16} | {raf_val.real:>14.6f} {raf_val.imag:>14.6f} | {raf_time:>10.5f} | {match}")
        print("-" * W)

    print(f"\n{'Legend:'}")
    print(f"  pySecDec : Compiled C++ Monte-Carlo sector decomposition (pySecDec library)")
    print(f"  RAF (2F1): Analytical MoB residue → closed-form ₂F₁(½,1;³⁄₂;s/4m²) via mpmath")
    print(f"  Match?   : Relative error |RAF - pySecDec| / |pySecDec| < 1e-4\n")

if __name__ == "__main__":
    benchmark_loop_integrals()
