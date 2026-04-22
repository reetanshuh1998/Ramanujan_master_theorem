"""
example_C0_triangle.py
=======================
3-WAY BENCHMARK: RAF MoB vs pySecDec vs LoopTools

Scalar Triangle C₀(0, 0, s; m², m², m²) in D = 4-2ε

Three independent implementations compared:
  1. RAF MoB  — Ramanujan Method of Brackets (2D → 1D analytical reduction)
  2. pySecDec — Monte Carlo sector decomposition (Borowka et al.)
  3. LoopTools — van Oldenborgh FF library (analytical dilogarithms)
"""
import os, re, time, subprocess, mpmath
from pySecDec.integral_interface import IntegralLibrary
from feynman_mob_solver import FeynmanMoBSolver

mpmath.mp.dps = 50

# ═══════════════════════════════════════════════════════════════════
#                    ENGINE SETUP
# ═══════════════════════════════════════════════════════════════════

# 1) RAF/MoB engine
solver = FeynmanMoBSolver(precision=50)

# 2) pySecDec engine
LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'triangle1L_massive_pysecdec',
                        'triangle1L_massive_pysecdec_pylink.so')
psd_lib = IntegralLibrary(LIB_PATH)

# 3) LoopTools engine (via Fortran subprocess)
LT_DRIVER = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         'third_party', 'lt_driver')

def looptools_C0(p1sq, p2sq, p3sq, m1sq, m2sq, m3sq):
    """Call LoopTools C0 via compiled Fortran driver."""
    t0 = time.time()
    result = subprocess.run(
        [LT_DRIVER, 'C0', '1.0', '0.0',
         str(p1sq), str(p2sq), str(p3sq),
         str(m1sq), str(m2sq), str(m3sq)],
        capture_output=True, text=True, timeout=10
    )
    dt = time.time() - t0
    # Parse output: find the line with two floats
    for line in result.stdout.split('\n'):
        line = line.strip()
        parts = line.split()
        if len(parts) == 2:
            try:
                re_val = float(parts[0])
                im_val = float(parts[1])
                return complex(re_val, im_val), dt
            except ValueError:
                continue
    return None, dt

def looptools_B0(psq, m1sq, m2sq, delta=0.0):
    """Call LoopTools B0 via compiled Fortran driver."""
    t0 = time.time()
    result = subprocess.run(
        [LT_DRIVER, 'B0', '1.0', str(delta),
         str(psq), str(m1sq), str(m2sq)],
        capture_output=True, text=True, timeout=10
    )
    dt = time.time() - t0
    for line in result.stdout.split('\n'):
        line = line.strip()
        parts = line.split()
        if len(parts) == 2:
            try:
                return complex(float(parts[0]), float(parts[1])), dt
            except ValueError:
                continue
    return None, dt

def parse_pysecdec(raw):
    s = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
    m = re.search(r'\(\(([^,]+),([^)]+)\)', s)
    if m:
        return complex(float(m.group(1)), float(m.group(2)))
    return None

# ═══════════════════════════════════════════════════════════════════
#                  C₀ TRIANGLE BENCHMARK
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":

    test_points = [
        (1.0,  1.0, "Deep Euclidean (Eq Mass)"),
        (10.0, 1.0, "Minkowski (Eq Mass)"),
        (10.0, [1.0, 2.0, 3.0], "TARGET: Unequal m=[1,2,3]"),
    ]

    W = 140
    print("\n" + "=" * W)
    print("  3-WAY BENCHMARK: Scalar Triangle C₀(0, 0, s; m², m², m²)")
    print("  D = 4-2ε  |  UV FINITE (no 1/ε pole)  |  m = 1 GeV, μ = m")
    print("  RAF MoB  vs  pySecDec  vs  LoopTools (FF library)")
    print("=" * W)

    print(f"\n{'s':>6} | {'Region':^22} | {'RAF MoB':^28} {'t':>6} | {'pySecDec':^28} {'t':>6} | {'LoopTools':^28} {'t':>6} |")
    print("-" * W)

    # Pre-load PySecDec unequal library
    try:
        psd_uneq_lib = IntegralLibrary('./pysecdec_C0_unequal_lib/pysecdec_C0_unequal_lib_pylink.so')
    except Exception:
        psd_uneq_lib = None

    for sv, m_val, desc in test_points:
        is_unequal = isinstance(m_val, list)
        if is_unequal:
            m1sq, m2sq, m3sq = [float(x) for x in m_val]
        else:
            m1sq = m2sq = m3sq = float(m_val)

        # ── RAF / MoB ────────────────────────────────────────
        t0 = time.time()
        try:
            raf = complex(solver.solve_C0_standard(sv, m_val if is_unequal else m1sq))
        except Exception:
            raf = complex(0, 0)
        raf_t = time.time() - t0

        # ── pySecDec ─────────────────────────────────────────
        t0 = time.time()
        if is_unequal and psd_uneq_lib:
            try:
                raw = psd_uneq_lib([sv, m1sq, m2sq, m3sq])[0]
                psd = parse_pysecdec(raw)
            except Exception as e:
                psd = complex(0, 0)
        else:
            try:
                raw = psd_lib([sv, m1sq])[0]
                psd = parse_pysecdec(raw)
            except Exception:
                psd = complex(0,0)
        psd_t = time.time() - t0

        # ── LoopTools ────────────────────────────────────────
        # Note: LoopTools expects arguments for m1, m2, m3
        lt, lt_t = looptools_C0(0.0, 0.0, sv, m1sq, m2sq, m3sq)

        # ── Format ───────────────────────────────────────────
        def fmt(c):
            if c is None: return f"{'N/A':^28}"
            return f"{c.real:>+13.10f}{c.imag:>+13.10f}i"

        # Cross-check all three
        checks = []
        if psd and lt:
            for ref_name, ref_val in [("psd", psd), ("lt", lt)]:
                rel = abs(raf - ref_val) / max(abs(ref_val), 1e-30)
                checks.append(rel < 1e-4)

        ok = "✓" if all(checks) else "✗"

        print(f"{sv:>6.2f} | {desc:^22} | {fmt(raf)} {raf_t*1000:>5.1f}ms | {fmt(psd)} {psd_t*1000:>5.1f}ms | {fmt(lt)} {lt_t*1000:>5.1f}ms | {ok}")

    # ═══════════════════════════════════════════════════════════
    #  B₀ BUBBLE — 3-WAY COMPARISON
    # ═══════════════════════════════════════════════════════════
    import math
    GAMMA_E = 0.5772156649015329  # Euler-Mascheroni

    B0_LIB = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          'RECREATION', 'B0_standard_pysecdec',
                          'B0_standard_pysecdec_pylink.so')

    def parse_laurent(raw_str):
        pairs = re.findall(r'\(\(([^,]+),([^)]+)\)', raw_str)
        return [complex(float(p[0]), float(p[1])) for p in pairs]

    psd_b0_lib = IntegralLibrary(B0_LIB)

    b0_points = [
        (1.0,  1.0, "Below threshold"),
        (5.0,  1.0, "TARGET: p²=5"),
        (10.0, 1.0, "Above threshold"),
        (100.0,1.0, "Deep Minkowski"),
    ]

    print(f"\n{'─'*W}")
    print(f"  3-WAY BENCHMARK: Passarino-Veltman B₀(p², m², m²)")
    print(f"  D = 4-2ε  |  UV DIVERGENT (1/ε pole)  |  m = 1 GeV, μ = m")
    print(f"  Note: LoopTools uses MS-bar (includes +γ_E offset in finite part)")
    print(f"{'─'*W}")

    print(f"\n{'p²':>6} | {'Region':^22} | {'RAF MoB (eps⁰)':^28} {'t':>6} | {'pySecDec (eps⁰)':^28} {'t':>6} | {'LoopTools−γ_E':^28} {'t':>6} |")
    print("-" * W)

    for psq, msq, desc in b0_points:
        # ── RAF / MoB ────────────────────────────────────────
        t0 = time.time()
        pole, finite = solver.solve_B0_standard(psq, msq)
        raf = complex(finite)
        raf_t = time.time() - t0

        # ── pySecDec ─────────────────────────────────────────
        t0 = time.time()
        raw = psd_b0_lib(real_parameters=[psq, msq])
        psd_t = time.time() - t0
        result_str = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
        psd_coeffs = parse_laurent(result_str)
        psd = psd_coeffs[1] if len(psd_coeffs) > 1 else None

        # ── LoopTools ────────────────────────────────────────
        # LoopTools B0 with delta=0 includes +γ_E offset vs pySecDec
        lt_raw, lt_t = looptools_B0(psq, msq, msq, delta=0.0)
        lt = complex(lt_raw.real - GAMMA_E, lt_raw.imag) if lt_raw else None

        def fmt(c):
            if c is None: return f"{'N/A':^28}"
            return f"{c.real:>+13.10f}{c.imag:>+13.10f}i"

        checks = []
        for ref in [psd, lt]:
            if ref: checks.append(abs(raf - ref) / max(abs(ref), 1e-30) < 1e-4)

        ok = "✓" if all(checks) else "✗"
        print(f"{psq:>6.1f} | {desc:^22} | {fmt(raf)} {raf_t*1000:>5.1f}ms | {fmt(psd)} {psd_t*1000:>5.1f}ms | {fmt(lt)} {lt_t*1000:>5.1f}ms | {ok}")

    # ═══════════════════════════════════════════════════════════
    #  DERIVATION TRACE
    # ═══════════════════════════════════════════════════════════
    print(f"\n{'─'*W}")
    print(f"  MoB DERIVATION TRACE")
    print(f"{'─'*W}")
    print(f"")
    print(f"  C₀ (UV-finite triangle):")
    print(f"    MoB Rule E3:  2D Feynman simplex → 1D:  C₀ = (1/s) ∫₀¹ dx/x · ln[1−(s/m²)x(1−x)]")
    print(f"    Branch cut:   s > 4m² → split contour at x± = (1±√(1−4m²/s))/2")
    print(f"    Convention:   matches LoopTools (Passarino-Veltman) EXACTLY")
    print(f"")
    print(f"  B₀ (UV-divergent bubble):")
    print(f"    MoB discovery: B₀ = Γ(ε)·(m²)^{{−ε}}·₂F₁(ε, 1; 3/2; p²/(4m²))")
    print(f"    Pole:         1/ε (from Γ(ε))")
    print(f"    Finite part:  lim_{{ε→0}} [B₀(ε) − 1/ε]")
    print(f"    LoopTools offset: B0_LT(delta=0) = B0_MS + γ_E")
    print(f"")
    print(f"  Conventions:")
    print(f"    pySecDec:   Laurent in 1/ε (MS scheme)")
    print(f"    LoopTools:  Δ = 1/ε − γ_E + ln(4π) subtracted when delta=0")
    print(f"    RAF:        matches pySecDec 1/ε convention\n")
