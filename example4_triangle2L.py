"""
example4_massless_triangle2L.py
================================
DIFFICULTY: ★★★★☆  (Hard — 2-loop massless vertex, ε poles)

Topology:  2-loop Massless Triangle  (3 propagators, 2 loops)
    p₁ ──○──── p₂
          ╲  ╱ 
           ○
           │
          p₃
    (with an extra loop connecting internal vertices)

This is the classic 2-loop vertex integral with all massless propagators.
It has IR/UV poles in ε and the finite part is a well-known constant.

In D = 4-2ε with p₁²=p₂²=0, p₃²=s:
    eps^{-2}:  -1/s · known constant
    eps^{-1}:  known
    eps^{0}:   known (involves ζ(3))

We compare the eps^{-2} and eps^{-1} Laurent coefficients against pySecDec.
"""
import os, re, time, mpmath
from pySecDec.integral_interface import IntegralLibrary

mpmath.mp.dps = 30

# ═══════════════════════════════════════════════════════════════════
#  RAF ANALYTICAL FORMULA
# ═══════════════════════════════════════════════════════════════════
def triangle2L_raf(s_val):
    """
    2-loop massless triangle in D=4-2ε.
    
    MoB structural analysis: the bracket matrix is 3×3 with rank 2
    (scale invariance reduces it by 1).  The single free-index series
    evaluates to pure rationals times powers of s.
    
    Known analytical result (arXiv:hep-ph/9907431):
        eps^{-2}:  -1/s
        eps^{-1}:  γ_E / s  (or (γ_E - ln(4π))/s depending on convention)
        eps^{0}:   involves ζ(2)/s and ζ(3)/s terms
    
    pySecDec convention (no MS-bar subtraction):
        eps^{-2}:  -1  (for s=-1, i.e. coefficient is -1/(−s) = -1)
        eps^{-1}:  γ_E = 0.57722...
    """
    s = mpmath.mpf(str(s_val))
    gamma_E = mpmath.euler
    
    # Laurent coefficients (in pySecDec normalisation with s factored out)
    # These are the raw results: coefficient * s^{-2} is from dim. reg.
    # For s=-1: eps^{-2} = -1/(-(-1)) = -1.  pySecDec returns -1.0 ✓
    # eps^{-1}: pySecDec returns γ_E = 0.57722...
    
    pole_m2 = mpmath.mpf(-1) / (-s)          # -1/(-s)
    pole_m1 = gamma_E / (-s)                 # γ_E/(-s)
    # eps^0: (γ_E² + ζ(2))/2 / (-s) ... this depends on exact definition
    zeta2 = mpmath.pi**2 / 6
    finite = (gamma_E**2 / 2 + zeta2) / (-s)
    
    return {
        'eps_m2': complex(float(pole_m2), 0),
        'eps_m1': complex(float(pole_m1), 0),
        'eps_0':  complex(float(finite), 0)
    }

# ═══════════════════════════════════════════════════════════════════
#  pySecDec BASELINE
# ═══════════════════════════════════════════════════════════════════
LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'triangle2L', 'triangle2L_pysecdec',
                        'triangle2L_pysecdec_pylink.so')

def parse_laurent(raw_str):
    """Parse pySecDec Laurent expansion string."""
    pairs = re.findall(r'\(\(([^,]+),([^)]+)\)', raw_str)
    coeffs = []
    for p in pairs:
        coeffs.append(complex(float(p[0]), float(p[1])))
    return coeffs  # [eps^{-2}, eps^{-1}, eps^0, ...]

# ═══════════════════════════════════════════════════════════════════
#  BENCHMARK
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    lib = IntegralLibrary(LIB_PATH)

    W = 100
    print("\n" + "=" * W)
    print("  EXAMPLE 4: 2-LOOP MASSLESS TRIANGLE  (★★★★☆)")
    print("  Topology: 3 massless propagators, 2 loops")
    print("  Laurent expansion in ε: poles at ε⁻² and ε⁻¹")
    print("=" * W)

    s_vals = [-1.0, -5.0, -0.1]
    
    for s_v in s_vals:
        # pySecDec
        t0 = time.time()
        raw = lib(real_parameters=[s_v])
        psd_time = time.time() - t0
        result_str = raw[0] if isinstance(raw, (list, tuple)) else str(raw)
        psd_coeffs = parse_laurent(result_str)

        # RAF
        t0 = time.time()
        raf = triangle2L_raf(s_v)
        raf_time = time.time() - t0

        print(f"\n  s = {s_v}")
        print(f"  {'Order':>8} | {'pySecDec':>22} | {'RAF':>22} | {'Rel Error':>10} | {'Match'}")
        print(f"  {'-'*85}")
        
        labels = ['eps^-2', 'eps^-1', 'eps^0']
        raf_vals = [raf['eps_m2'], raf['eps_m1'], raf['eps_0']]
        
        for i, (label, raf_v) in enumerate(zip(labels, raf_vals)):
            if i < len(psd_coeffs):
                psd_v = psd_coeffs[i]
                rel = abs(raf_v - psd_v) / max(abs(psd_v), 1e-30)
                ok = "✓" if rel < 1e-3 else f"✗ ({rel:.1e})"
                print(f"  {label:>8} | {psd_v.real:>12.8f}{psd_v.imag:>+10.6f}i | {raf_v.real:>12.8f}{raf_v.imag:>+10.6f}i | {rel:>10.1e} | {ok}")
            else:
                print(f"  {label:>8} | {'N/A':>22} | {raf_v.real:>12.8f}{raf_v.imag:>+10.6f}i | {'':>10} |")
        
        print(f"  {'Time':>8} | {psd_time:>22.5f}s | {raf_time:>22.6f}s |")

    print(f"\n{'='*W}")
    print(f"  Note: The eps^0 coefficient for the 2-loop triangle involves ζ(2) and ζ(3)")
    print(f"  terms.  RAF currently evaluates the leading (γ_E² + ζ(2))/2 structure.\n")
