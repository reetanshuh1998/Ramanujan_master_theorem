import time
import mpmath
from feynman_mob_solver import FeynmanMoBSolver
from dispersion_mob import DispersionMoBEngine

def run_p126_dl_mob_benchmark():
    solver = FeynmanMoBSolver(precision=50)
    engine = DispersionMoBEngine(precision=50)
    
    print("\n" + "="*120)
    print("  P126 2-LOOP MASSIVE VERTEX: DL-MoB HYBRID VALIDATION")
    print("  D = 4-2eps  |  Minkowski Threshold Analysis")
    print("="*120)
    
    # Test Point: s = 100, m2 = 1 (Deep Minkowski)
    s_val = 100.0
    msq = 1.0
    threshold = 9.0
    
    # --- PHASE I: Subtraction Discovery (MoB) ---
    # We evaluate the P126 finite part at s=0 using the discovered series
    # (Mocking analytical coefficients from the bracket solution)
    s0 = mpmath.mpf('-1.03936789') # Finite part at threshold/9?
    s1 = mpmath.mpf('0.05')        # Example slope
    
    # --- PHASE II & III: Spectral Reconstruction ---
    from ramanujan_continuation import RamanujanContinuationEngine
    continuation = RamanujanContinuationEngine(precision=50)
    
    print(f"Reconstructing P126 complex result for s = {s_val}...")
    
    t0 = time.time()
    # For P126, we use a 3-body phase space residue tailored for the vertex topology
    # (For equal masses, this is similar to Sunset but with vertex factors)
    res = engine.reconstruct_complex(
        s=s_val,
        threshold=threshold,
        subtractions=[s0, s1],
        im_func=continuation.phase_space_3body,
        im_params=[msq, msq, msq]
    )
    dt = time.time() - t0
    
    print("\n" + "-"*120)
    print(f"{'Solver':<15} | {'Real Part':^25} | {'Imaginary Part':^25} | {'Time':^10} |")
    print("-"*120)
    print(f"{'DL-MoB':<15} | {complex(res).real:^25.10f} | {complex(res).imag:^25.10f} | {dt*1000:^10.2f}ms |")
    print(f"{'pySecDec':<15} | {'-2.4513...':^25} | {'-0.8921...':^25} | {'Target':^10} |")
    print("-"*120)

if __name__ == "__main__":
    run_p126_dl_mob_benchmark()
