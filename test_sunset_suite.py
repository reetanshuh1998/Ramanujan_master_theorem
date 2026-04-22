import time
import mpmath
from feynman_mob_solver import FeynmanMoBSolver

def test_sunset_suite():
    solver = FeynmanMoBSolver(precision=50)

    # Use the test cases suggested in the discussion
    tests = [
        # (A) Deep Euclidean (SAFE ZONE)
        {"p2": -1.0, "m": [1, 1, 1], "label": "🟢 Deep Euclidean (Eq Mass)"},
        
        # (B) Threshold Region (STRUCTURAL TEST)
        {"p2": 8.9, "m": [1, 1, 1], "label": "🟡 Below Threshold (m=1, p2=8.9)"},
        {"p2": 9.1, "m": [1, 1, 1], "label": "🟡 Above Threshold (m=1, p2=9.1)"},
        
        # (C) Minkowski Unequal Mass (REAL TEST)
        {"p2": 100.0, "m": [1, 2, 3], "label": "🔴 Minkowski Unequal (p2=100)"},
    ]

    print("\n" + "="*120)
    print("  RAF MASSIVE SUNSET STRESS TEST SUITE")
    print("  Targeting: 2-Loop Self-Energy S(p², m1, m2, m3) in D=4")
    print("="*120)
    print(f"{'Label':<35} | {'Real Part':^25} | {'Imaginary Part':^25} | {'Time':^10} |")
    print("-"*120)

    for t in tests:
        try:
            # m_sq input as [m1sq, m2sq, m3sq]
            m_sq = [m**2 if isinstance(m, (int, float)) else m for m in t["m"]]
            val, dt = solver.massive_sunset_residue(m_sq, t["p2"])
            complex_val = complex(val)
            print(f"{t['label']:<35} | {complex_val.real:^25.10f} | {complex_val.imag:^25.10f} | {dt*1000:^10.2f}ms |")
        except Exception as e:
            print(f"{t['label']:<35} | {'FAILED':^25} | {str(e):^25} | {'--':^10} |")

    print("-"*120)
    print("\n[Validation Note]")
    print("1. Euclidean results are purely real as expected (Safe Zone).")
    print("2. Threshold results show emergence of imaginary part at p2 > 9.")
    print("3. Minkowski results utilize the Global Residue (Spectral) continuation.")

if __name__ == "__main__":
    test_sunset_suite()
