"""
example_B0_standard.py
=======================
THE STANDARD QFT BENCHMARK: Passarino-Veltman B₀

┌──────────────────────────────────────────────────────────┐
│                   (2πμ)^{4-d}      ∫ d^d k              │
│  B₀(p², m², m²) = ─────────── × ─────────────────────── │
│                      iπ²        [k²-m²+iε][(k+p)²-m²+iε]│
│                                                          │
│  Parameters:  m = 1 GeV,  p² = 5 GeV²,  μ = m           │
│  Above threshold (p² > 4m² = 4) → imaginary part ✓      │
└──────────────────────────────────────────────────────────┘

Why this is a perfect test:
  • Has UV divergence        → tests regularization (1/ε pole)
  • Has branch cuts          → tests complex structure (Im ≠ 0)
  • Has known analytic result → exact verification possible
  • Used in real SM physics  → self-energy, vacuum polarisation

RAF/MoB Analytical Solution:
═════════════════════════════
  The Method of Brackets applied to the Feynman parameter representation
  discovers a UNIFIED hypergeometric structure:

    D = 3-2ε:  B₀ = Γ(½) · (m²)^{-½} · ₂F₁(½, 1; 3/2; p²/(4m²))
    D = 4-2ε:  B₀ = Γ(ε)  · (m²)^{-ε}  · ₂F₁(ε, 1; 3/2; p²/(4m²))

  SAME ₂F₁(·, 1; 3/2; w) family — same MoB bracket structure —
  the only difference is the first parameter (½ vs ε).

  The +iε Feynman prescription is handled by conjugating the
  ₂F₁ above threshold (p² > 4m²), since mpmath's default analytic
  continuation lands on the opposite Riemann sheet.
"""
import os, re, time, mpmath
from pySecDec.integral_interface import IntegralLibrary
from feynman_mob_solver import FeynmanMoBSolver   # ← THE RAF ENGINE

mpmath.mp.dps = 50

# ═══════════════════════════════════════════════════════════════════
#                    pySecDec REFERENCE
# ═══════════════════════════════════════════════════════════════════

LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'B0_standard_pysecdec',
                        'B0_standard_pysecdec_pylink.so')

def parse_laurent(raw_str):
    pairs = re.findall(r'\(\(([^,]+),([^)]+)\)', raw_str)
    return [complex(float(p[0]), float(p[1])) for p in pairs]


# ═══════════════════════════════════════════════════════════════════
#                        BENCHMARK
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # ── Initialize both engines ──────────────────────────────
    solver = FeynmanMoBSolver(precision=50)   # RAF/MoB engine
    lib    = IntegralLibrary(LIB_PATH)        # pySecDec engine

    W = 115
    print("\n" + "=" * W)
    print("  STANDARD QFT BENCHMARK: Passarino-Veltman B₀(p², m², m²)")
    print("  D = 4-2ε,  m = 1 GeV,  μ = m")
    print("  RAF MoB Formula: B₀ = Γ(ε) · (m²)^{−ε} · ₂F₁(ε, 1; 3/2; p²/(4m²))")
    print("=" * W)

    test_points = [
        (1.0,  1.0, "Below threshold"),
        (3.99, 1.0, "Just below threshold"),
        (4.01, 1.0, "Just above threshold"),
        (5.0,  1.0, "TARGET: p²=5, m²=1"),
        (10.0, 1.0, "Well above threshold"),
        (100.0,1.0, "Deep Minkowski"),
    ]

    print(f"\n{'p²':>8} | {'Region':^22} | {'Order':>7} | {'pySecDec':>26} | {'RAF ₂F₁(ε,1;3/2;w)':>26} | {'Rel Err':>10} | {'Match'}")
    print("-" * W)

    for psq, msq, desc in test_points:
        # ── pySecDec (Monte Carlo sector decomposition) ──────
        t0 = time.time()
        raw = lib(real_parameters=[psq, msq])
        psd_time = time.time() - t0
        result_str = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
        psd_coeffs = parse_laurent(result_str)

        # ── RAF / MoB (analytical ₂F₁ evaluation) ────────────
        t0 = time.time()
        raf_pole, raf_finite = solver.solve_B0_standard(psq, msq)
        raf_time = time.time() - t0
        raf_coeffs = [complex(float(raf_pole), 0), complex(raf_finite)]

        # ── Print comparison ─────────────────────────────────
        labels = ['eps^-1', 'eps^0']
        for i, label in enumerate(labels):
            psd_v = psd_coeffs[i] if i < len(psd_coeffs) else None
            raf_v = raf_coeffs[i]

            if psd_v:
                rel = abs(raf_v - psd_v) / max(abs(psd_v), 1e-30)
                ok = "✓" if rel < 1e-4 else f"✗ ({rel:.1e})"
                psd_str = f"{psd_v.real:>+12.8f}{psd_v.imag:>+12.8f}i"
            else:
                ok = "N/A"
                psd_str = f"{'N/A':>26}"
                rel = 0

            raf_str = f"{raf_v.real:>+12.8f}{raf_v.imag:>+12.8f}i"
            r = desc if i == 0 else ""

            print(f"{psq if i==0 else '':>8} | {r:^22} | {label:>7} | {psd_str:>26} | {raf_str:>26} | {rel:>10.1e} | {ok}")

        # Speed line
        speedup = psd_time / max(raf_time, 1e-10)
        print(f"{'':>8} | {'':^22} | {'Time':>7} | {psd_time:>22.5f}s    | {raf_time:>22.6f}s    | {'':>10} | {speedup:.0f}×")
        print("-" * W)

    # ═══════════════════════════════════════════════════════════
    #  DETAILED MoB DERIVATION AT THE TARGET POINT: p²=5, m²=1
    # ═══════════════════════════════════════════════════════════
    psq_target, msq_target = 5.0, 1.0
    w = psq_target / (4 * msq_target)
    raf_pole, raf_fin = solver.solve_B0_standard(psq_target, msq_target)

    # Branch point locations
    disc = mpmath.sqrt(1 - 4*msq_target/psq_target)
    xm = float((1 - disc)/2)
    xp = float((1 + disc)/2)

    # Exact imaginary part: ±π·√(1 - 4m²/p²)
    im_exact = float(mpmath.pi * mpmath.sqrt(1 - 4*msq_target/psq_target))

    print(f"\n{'─'*W}")
    print(f"  MoB DERIVATION TRACE  (p² = {psq_target} GeV², m² = {msq_target} GeV², μ = m)")
    print(f"{'─'*W}")
    print(f"")
    print(f"  Step 1  Feynman parametrize:")
    print(f"          Δ(x) = m² − x(1−x)p² = 1 − 5x(1−x)")
    print(f"")
    print(f"  Step 2  MoB bracket expansion [Rule E2]:")
    print(f"          [1 − (p²/m²)·x(1−x)]^{{−ε}} = Σ (ε)_n/n! · z^n · [x(1−x)]^n")
    print(f"          z = p²/m² = {psq_target/msq_target}")
    print(f"")
    print(f"  Step 3  HCF moment integral:")
    print(f"          ∫₀¹ [x(1−x)]^n dx = (n!)² / (2n+1)! = n! / [4^n · (3/2)_n]")
    print(f"")
    print(f"  Step 4  Series collapses to hypergeometric:")
    print(f"          ₂F₁(ε, 1; 3/2; w)  where  w = p²/(4m²) = {w}")
    print(f"")
    print(f"  Step 5  Complete result:")
    print(f"          B₀ = Γ(ε) · (m²)^{{−ε}} · ₂F₁(ε, 1; 3/2; {w})")
    print(f"          eps^{{-1}} = {float(raf_pole):.10f}  [UV pole from Γ(ε)]")
    print(f"          eps^{{0}}  = ({float(raf_fin.real):+.10f}, {float(raf_fin.imag):+.10f}i)")
    print(f"")
    print(f"  Physical analysis:")
    print(f"          Threshold:     p² = 4m² = {4*msq_target:.1f} GeV²")
    print(f"          Status:        ABOVE threshold (p² = {psq_target} > {4*msq_target})")
    print(f"          Branch points: x₋ = {xm:.6f},  x₊ = {xp:.6f}")
    print(f"          Unitarity cut: Im(B₀) = +π·√(1−4m²/p²) = π/√5 = {im_exact:.10f}")
    print(f"          RAF Im(B₀)  = {float(raf_fin.imag):.10f}")
    print(f"          Match:         |Δ| = {abs(float(raf_fin.imag) - im_exact):.2e}")
    print(f"")

    # ── The unified D=3 vs D=4 connection ─────────────────────
    print(f"  ── UNIFIED MoB HYPERGEOMETRIC STRUCTURE ──")
    print(f"")
    # D=3 result at same kinematic point
    B0_D3 = solver.solve_massive_bubble(1, 1, s=psq_target, m1_sq=msq_target, m2_sq=msq_target)
    print(f"  D = 3-2ε:  B₀ = Γ(½)·(m²)^{{-½}}·₂F₁(½, 1; 3/2; {w})")
    print(f"             = √π / √m · ₂F₁(½, 1; 3/2; {w})")
    print(f"             = {complex(B0_D3)}")
    print(f"")
    print(f"  D = 4-2ε:  B₀ = Γ(ε)·(m²)^{{-ε}}·₂F₁(ε, 1; 3/2; {w})")
    print(f"             eps^0 = {complex(raf_fin)}")
    print(f"")
    print(f"  SAME ₂F₁(·, 1; 3/2; w) — the MoB discovers this")
    print(f"  unified structure across ALL spacetime dimensions.\n")
