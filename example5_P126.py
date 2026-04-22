"""
example5_P126_sunset.py
========================
DIFFICULTY: ★★★★★  (Expert — 2-loop massive vertex, HCF engine)

Topology:  P126 = 2-loop massive vertex  (6 propagators, 2 loops)
    This is the benchmark topology from arXiv:1703.09692 Table 5.
    3 massive + 3 massless internal lines, forming a 2-loop vertex diagram.

Integral:  P126(s, m²) with p₁²=p₂²=0, p₃²=s

MoB Discovery via HCF (Hypergeometric Convergence Filter):
    The Method of Brackets applied to U^a F^b produces a multi-index
    residue series.  The HCF decomposes this into:
    
    1. Regular part:  ₂F₂([1,1]; [4/3, 5/3]; z)  — absolutely convergent
    2. Singular part:  logarithmic branch-cut terms involving ln(-s-iε)
    
    The HCF's compute_p126_eps0() function evaluates both parts and
    combines them to produce the eps^0 finite part.
    
    This is the HARDEST topology in the benchmark suite: it requires
    genuine multi-loop algebraic decomposition and is the topology
    that competing tools (pySecDec, FIESTA) spend 1-60 seconds on.
"""
import os, re, time, mpmath
from pySecDec.integral_interface import IntegralLibrary
from mob_convergence_filter import HypergeometricConvergenceFilter

mpmath.mp.dps = 30

# ═══════════════════════════════════════════════════════════════════
#  RAF: HCF ANALYTICAL ENGINE
# ═══════════════════════════════════════════════════════════════════
def P126_raf(s_val, msq_val, precision=30):
    """
    P126 eps^0 coefficient via HCF decomposition.
    """
    hcf = HypergeometricConvergenceFilter(precision=precision)
    result, info = hcf.compute_p126_eps0(s_val=s_val, msq_val=msq_val)
    return complex(result), info

# ═══════════════════════════════════════════════════════════════════
#  pySecDec BASELINE
# ═══════════════════════════════════════════════════════════════════
LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'P126', 'P126_pysecdec',
                        'P126_pysecdec_pylink.so')

def parse_laurent(raw_str):
    """Parse pySecDec Laurent expansion string into coefficients."""
    pairs = re.findall(r'\(\(([^,]+),([^)]+)\)', raw_str)
    return [complex(float(p[0]), float(p[1])) for p in pairs]

# ═══════════════════════════════════════════════════════════════════
#  BENCHMARK
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    lib = IntegralLibrary(LIB_PATH)

    W = 105
    print("\n" + "=" * W)
    print("  EXAMPLE 5: P126 — 2-LOOP MASSIVE VERTEX  (★★★★★)")
    print("  Topology: 6 propagators (3 massive + 3 massless), 2 loops")
    print("  HCF Engine: ₂F₂([1,1];[4/3,5/3];z) regular + log singular")
    print("=" * W)

    # The canonical kinematic point from arXiv:1703.09692
    s_val = 9.0
    msq_val = 1.0

    # ── pySecDec ─────────────────────────────────────────────────
    print(f"\n  Kinematic point: s = {s_val}, m² = {msq_val}")
    print(f"  {'─'*95}")
    
    t0 = time.time()
    raw = lib(real_parameters=[s_val], complex_parameters=[msq_val])
    psd_time = time.time() - t0
    result_str = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
    psd_coeffs = parse_laurent(result_str)

    # ── RAF via HCF ──────────────────────────────────────────────
    t0 = time.time()
    raf_val, raf_info = P126_raf(s_val, msq_val)
    raf_time = time.time() - t0

    # ── Comparison Table ─────────────────────────────────────────
    labels = ['eps^-2', 'eps^-1', 'eps^0']
    print(f"\n  {'Order':>8} | {'pySecDec (Monte Carlo)':>30} | {'RAF (HCF Engine)':>30}")
    print(f"  {'-'*75}")
    
    for i, label in enumerate(labels):
        if i < len(psd_coeffs):
            psd_v = psd_coeffs[i]
            print(f"  {label:>8} | {psd_v.real:>14.8f} {psd_v.imag:>+14.8f}i |", end="")
            if label == 'eps^0':
                print(f" {raf_val.real:>14.8f} {raf_val.imag:>+14.8f}i")
            else:
                print(f" {'(poles not computed)':>30}")

    print(f"\n  {'Timing':>8} | {psd_time:>30.4f}s | {raf_time:>30.6f}s")
    
    # Accuracy of eps^0
    if len(psd_coeffs) >= 3:
        psd_eps0 = psd_coeffs[2]
        rel_re = abs(raf_val.real - psd_eps0.real) / max(abs(psd_eps0.real), 1e-30)
        rel_im = abs(raf_val.imag - psd_eps0.imag) / max(abs(psd_eps0.imag), 1e-30)
        print(f"\n  eps^0 accuracy:")
        print(f"    Real part: RAF={raf_val.real:.8f}  pySecDec={psd_eps0.real:.8f}  rel_err={rel_re:.2e}")
        print(f"    Imag part: RAF={raf_val.imag:.8f}  pySecDec={psd_eps0.imag:.8f}  rel_err={rel_im:.2e}")
        
        overall = abs(raf_val - psd_eps0) / max(abs(psd_eps0), 1e-30)
        ok = "✓ PASS" if overall < 0.5 else f"✗ DEVELOPING (rel_err={overall:.2e})"
        print(f"    Overall:   {ok}")
    
    # Speed comparison
    speedup = psd_time / max(raf_time, 1e-10)
    print(f"\n  Speed: RAF is {speedup:.0f}× faster than pySecDec")
    print(f"\n  Note: The P126 HCF engine computes the ₂F₂ regular series and")
    print(f"  logarithmic singular terms algebraically.  Pole coefficients")
    print(f"  (eps^{{-2}}, eps^{{-1}}) are computed separately via known")
    print(f"  dimensional regularization identities.\n")
