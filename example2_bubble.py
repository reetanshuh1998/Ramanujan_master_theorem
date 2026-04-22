"""
example2_bubble.py
===================
DIFFICULTY: ★★☆☆☆  (Moderate — requires ₂F₁ hypergeometric)

Topology:  1-loop Bubble / Self-energy  (2 propagators, 1 loop)
    ○═══○
    ╲   ╱
     ╲_╱
      
Integral:  B₀(p²; m², m²) = ∫ dᴰk / [(k²+m²)((k-p)²+m²)]

MoB Discovery:
    Rule E2 on the Feynman-parameter representation yields a single
    free-index residue series.  HCF identifies this as a convergent
    ₂F₁ for |s/(4m²)| < 1 (Euclidean) and analytically continues
    it through the branch cut at s = 4m² via mpmath.

    B₀(s, m, m) = [√π / √m] · ₂F₁(½, 1; ³⁄₂; s/(4m²))

    This closed form is evaluated in O(1) time (~0.001s) and matches
    pySecDec across Euclidean and Minkowski regimes to < 10⁻⁴.
"""
import os, re, time, mpmath
from pySecDec.integral_interface import IntegralLibrary
from ramanujan_qft.solvers.feynman_mob_solver import FeynmanMoBSolver

mpmath.mp.dps = 30

# ═══════════════════════════════════════════════════════════════════
#  pySecDec BASELINE
# ═══════════════════════════════════════════════════════════════════
LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'bubble1L_pysecdec',
                        'bubble1L_pysecdec_pylink.so')

def parse_pysecdec(raw):
    s = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
    m = re.search(r'\(\(([^,]+),([^)]+)\)', s)
    if m:
        return complex(float(m.group(1)), float(m.group(2)))
    return None

# ═══════════════════════════════════════════════════════════════════
#  BENCHMARK
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    solver = FeynmanMoBSolver(precision=30)
    lib = IntegralLibrary(LIB_PATH)

    p2_vals = [0.5, 1.0, 3.99, 5.0, 100.0, 10000.0]
    m_sq = 1.0

    W = 105
    print("\n" + "=" * W)
    print("  EXAMPLE 2: 1-LOOP MASSIVE BUBBLE  (★★☆☆☆)")
    print("  MoB Formula: B₀ = [√π/√m] · ₂F₁(½, 1; ³⁄₂; s/4m²)")
    print("  D = 3-2ε (eps=0),  m₁²=m₂²=1")
    print("=" * W)
    print(f"{'s':>10} | {'Method':^16} | {'Re':>14} {'Im':>14} | {'Time (s)':>10} | {'Match'}")
    print("-" * W)

    for p2 in p2_vals:
        # pySecDec
        t0 = time.time()
        psd_val = parse_pysecdec(lib(real_parameters=[p2, m_sq, m_sq]))
        psd_time = time.time() - t0

        # RAF
        t0 = time.time()
        raf_val = complex(solver.solve_massive_bubble(1, 1, s=p2, m1_sq=m_sq, m2_sq=m_sq))
        raf_time = time.time() - t0

        # Accuracy
        if psd_val:
            rel = abs(raf_val - psd_val) / max(abs(psd_val), 1e-30)
            ok = "✓" if rel < 1e-4 else f"✗ ({rel:.1e})"
        else:
            ok = "N/A"

        if psd_val:
            print(f"{p2:>10.2f} | {'pySecDec':^16} | {psd_val.real:>14.8f} {psd_val.imag:>14.8f} | {psd_time:>10.5f} |")
        print(f"{'':>10} | {'RAF (₂F₁)':^16} | {raf_val.real:>14.8f} {raf_val.imag:>14.8f} | {raf_time:>10.5f} | {ok}")
        print("-" * W)

    print(f"\n  Key: Threshold at s = 4m² = 4.0")
    print(f"  Below threshold: purely real (Euclidean)")
    print(f"  Above threshold: complex (Minkowski, +iε prescription)\n")
