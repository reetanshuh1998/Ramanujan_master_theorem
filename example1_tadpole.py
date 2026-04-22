"""
example1_tadpole.py
====================
DIFFICULTY: ★☆☆☆☆  (Trivial — pure Gamma function)

Topology:  1-loop Tadpole  (1 propagator, 1 loop)
    ○───○
     ╲_╱
      
Integral:  A₀(m²) = ∫ dᴰk / (k² + m²)

MoB Discovery:
    The single bracket <n + D/2> = 0 yields n* = -D/2.
    Rule E2 gives:  A₀ = Gamma(1 - D/2) * (m²)^{D/2-1}
    This is an exact Gamma function — no series needed.

In D = 4-2ε:
    eps^{-1} coefficient:  -m²
    eps^0   coefficient:   m² * (γ_E - 1 + ln(m²))
"""
import os, re, time, mpmath
from pySecDec.integral_interface import IntegralLibrary

mpmath.mp.dps = 30

# ═══════════════════════════════════════════════════════════════════
#  RAF ANALYTICAL FORMULA  (MoB Rule E2: pure Gamma function)
# ═══════════════════════════════════════════════════════════════════
def tadpole_raf(msq):
    """
    A₀(m²) in D = 4-2ε.
    Laurent expansion:  Γ(-1+ε) * (m²)^{1-ε}
    
    eps^{-1}:  -m²
    eps^{0}:   m² * (γ_E - 1)   [for m²=1, omitting ln(m²)]
    """
    m = mpmath.mpf(str(msq))
    gamma_E = mpmath.euler

    pole_m1 = -m                     # coefficient of 1/ε
    finite  = m * (gamma_E - 1 + mpmath.log(m))  # coefficient of ε^0 (real part)
    # The imaginary part at eps^0 comes from the pySecDec convention
    # for the loop momentum integration measure: -iπ * m²
    finite_im = -mpmath.pi * m
    
    return pole_m1, complex(finite, float(finite_im))

# ═══════════════════════════════════════════════════════════════════
#  pySecDec BASELINE
# ═══════════════════════════════════════════════════════════════════
LIB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'RECREATION', 'tadpole1L_pysecdec',
                        'tadpole1L_pysecdec_pylink.so')

def tadpole_pysecdec(msq):
    lib = IntegralLibrary(LIB_PATH)
    t0 = time.time()
    raw = lib(real_parameters=[msq])
    psd_time = time.time() - t0
    result_str = raw[0] if isinstance(raw, (list, tuple)) else str(raw)

    # Parse Laurent expansion: eps^{-1} and eps^{0} terms
    coeffs = {}
    for m in re.finditer(r'\(\(([^,]+),([^)]+)\)\s*\+/-\s*\(([^,]+),([^)]+)\)\)', result_str):
        val = complex(float(m.group(1)), float(m.group(2)))
        # Find what eps power this belongs to
        remaining = result_str[m.end():]
        if 'eps^-1' in remaining[:20]:
            coeffs['pole'] = val
        elif 'eps^-2' in remaining[:20]:
            coeffs['pole2'] = val
        else:
            coeffs['finite'] = val

    # Simpler parsing: just extract all ((re,im)) pairs in order
    pairs = re.findall(r'\(\(([^,]+),([^)]+)\)', result_str)
    if len(pairs) >= 2:
        coeffs['pole'] = complex(float(pairs[0][0]), float(pairs[0][1]))
        coeffs['finite'] = complex(float(pairs[1][0]), float(pairs[1][1]))

    return coeffs, psd_time

# ═══════════════════════════════════════════════════════════════════
#  BENCHMARK
# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("\n" + "=" * 90)
    print("  EXAMPLE 1: 1-LOOP TADPOLE  (★☆☆☆☆)")
    print("  Topology: A₀(m²) = Γ(1-D/2) · (m²)^{D/2-1}")
    print("  D = 4-2ε,  comparing Laurent coefficients")
    print("=" * 90)

    for msq in [1.0, 4.0, 0.25]:
        psd_coeffs, psd_time = tadpole_pysecdec(msq)
        
        t0 = time.time()
        raf_pole, raf_finite = tadpole_raf(msq)
        raf_time = time.time() - t0

        psd_pole = psd_coeffs.get('pole', 0)
        psd_fin = psd_coeffs.get('finite', 0)

        pole_match = abs(float(raf_pole) - psd_pole.real) / max(abs(psd_pole.real), 1e-30)
        fin_match = abs(raf_finite.real - psd_fin.real) / max(abs(psd_fin.real), 1e-30)
        
        pole_ok = "✓" if pole_match < 1e-4 else f"✗ ({pole_match:.1e})"
        fin_ok  = "✓" if fin_match < 1e-4 else f"✗ ({fin_match:.1e})"

        print(f"\n  m² = {msq}")
        print(f"  {'':>8} | {'pySecDec':>20} | {'RAF (Γ-func)':>20} | {'Match':>8}")
        print(f"  {'eps^-1':>8} | {psd_pole.real:>20.10f} | {float(raf_pole):>20.10f} | {pole_ok:>8}")
        print(f"  {'eps^0 Re':>8} | {psd_fin.real:>20.10f} | {raf_finite.real:>20.10f} | {fin_ok:>8}")
        print(f"  {'Time':>8} | {psd_time:>20.6f}s | {raf_time:>20.6f}s |")
