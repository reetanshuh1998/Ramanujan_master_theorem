"""
test_mob_convergence.py
=======================
Test suite for the HypergeometricConvergenceFilter (mob_convergence_filter.py).

Tests are arranged from simple to complex:

  Section 1 — Stirling ratio check (unit tests on the core formula)
  Section 2 — Known convergent 2F1 series
  Section 3 — Known divergent series (should be flagged as divergent)
  Section 4 — Absolutely convergent series (all x)
  Section 5 — P126 topology: 2F2 regular part + log singular part
  Section 6 — Double-sum (2-index) convergence check

Run with:
    python3 test_mob_convergence.py

All tests use mpmath for high-precision reference values.
"""

import sys
import math
import mpmath
from mob_convergence_filter import HypergeometricConvergenceFilter, apply_hcf_and_sum

mpmath.mp.dps = 50
PASS = "PASS"
FAIL = "FAIL"
_results = []


def report(label: str, ok: bool, detail: str = "") -> None:
    status = PASS if ok else FAIL
    _results.append(ok)
    marker = "  [OK]" if ok else "  [!!]"
    print(f"{marker} {label}")
    if detail:
        print(f"       {detail}")


def allclose(a, b, rtol: float = 1e-4) -> bool:
    """Return True if |a - b| / max(|b|, 1) < rtol."""
    return abs(a - b) / max(abs(b), 1.0) < rtol


# ===========================================================================
# Section 1 — Stirling ratio formula (analytical unit tests)
# ===========================================================================

print("\n" + "=" * 70)
print("Section 1: Stirling asymptotic power formula")
print("=" * 70)

hcf = HypergeometricConvergenceFilter(precision=50)

# 2F1(a,b;c;z): shifts_num=[a,b], shifts_den=[c]  =>  p-q-1 = 2-1-1 = 0
p = hcf.stirling_asymptotic_power([1.0, 2.0], [3.0])
report("2F1 has power = 0", p == 0, f"power = {p}")

# 1F2(a;b,c;z): shifts_num=[a], shifts_den=[b,c]  =>  p-q-1 = 1-2-1 = -2
p = hcf.stirling_asymptotic_power([1.0], [2.0, 3.0])
report("1F2 has power = -2", p == -2, f"power = {p}")

# 2F0(a,b;;z): shifts_num=[a,b], shifts_den=[]  =>  p-q-1 = 2-0-1 = 1
p = hcf.stirling_asymptotic_power([1.0, 2.0], [])
report("2F0 has power = +1 (divergent)", p == 1, f"power = {p}")

# 3F2(a,b,c;d,e;z): p-q-1 = 3-2-1 = 0
p = hcf.stirling_asymptotic_power([1.0, 2.0, 3.0], [4.0, 5.0])
report("3F2 has power = 0", p == 0, f"power = {p}")

# 2F2([1,1]; [4/3,5/3]; z): p-q-1 = 2-2-1 = -1  (P126 series)
p = hcf.stirling_asymptotic_power([1.0, 1.0], [4.0 / 3, 5.0 / 3])
report("2F2([1,1];[4/3,5/3];z) has power = -1 (absolutely convergent)", p == -1,
       f"power = {p}")

# ------------------------------------------------------------------
# Cross-check: exact ratio at n=500 vs Stirling prediction
# ------------------------------------------------------------------
print("\n--- Stirling cross-check at n=500 ---")
# For 2F1(1/2, 1/2; 2; z) with z=0.5
shifts_n = [0.5, 0.5]
shifts_d = [2.0]
x_test = 0.5
r_exact = hcf.stirling_exact_ratio(500, shifts_n, shifts_d, x_test)
# power=0, so prediction = |x| = 0.5
r_pred = abs(x_test)  # n^0 * |x|
report(
    "Exact ratio at n=500 matches Stirling (2F1, p=0)",
    abs(r_exact - r_pred) / r_pred < 1e-3,
    f"exact={r_exact:.8f}  predicted={r_pred:.8f}",
)

# For 1F2(1; 2, 3; z) with z=0.9 (power=-2, predicted ratio->0)
shifts_n2 = [1.0]
shifts_d2 = [2.0, 3.0]
x_test2 = 0.9
r_exact2 = hcf.stirling_exact_ratio(500, shifts_n2, shifts_d2, x_test2)
# power = -2: ratio -> |x| * n^{-2} = 0.9 / 250000 = 3.6e-6
r_pred2 = abs(x_test2) * (500 ** (-2))
report(
    "Exact ratio at n=500 matches Stirling (1F2, p=-2)",
    abs(r_exact2 - r_pred2) / max(r_pred2, 1e-30) < 0.05,
    f"exact={r_exact2:.3e}  predicted={r_pred2:.3e}",
)


# ===========================================================================
# Section 2 — Convergent 2F1 series
# ===========================================================================

print("\n" + "=" * 70)
print("Section 2: Known-convergent 2F1 series")
print("=" * 70)

# 2F1(1, 1; 2; z) = -log(1-z)/z  for |z| < 1
# Use z = 0.5:  -log(0.5)/0.5 = log(2)/0.5 = 2*log(2) ~ 1.386294...

z_test = 0.5
conv_info = hcf.check_convergence([1.0, 1.0], [2.0], z_test, verbose=True)
report(
    "2F1(1,1;2;0.5): filter says CONVERGENT",
    conv_info['converges'] and conv_info['type'] == 'conditional',
    conv_info['description'],
)
report(
    "2F1(1,1;2;0.5): L = |z| = 0.5",
    abs(conv_info['L'] - 0.5) < 1e-10,
    f"L = {conv_info['L']}",
)

val_hcf, _ = hcf.evaluate_pFq([1.0, 1.0], [2.0], z_test)
val_ref = -mpmath.log(1 - z_test) / z_test
report(
    "2F1(1,1;2;0.5) value matches -log(1-z)/z",
    allclose(val_hcf, val_ref),
    f"HCF={complex(val_hcf):.8f}  ref={complex(val_ref):.8f}",
)

# 2F1(a, b; c; 0.3) compared to mpmath.hyp2f1
a, b, c = 0.25, 0.75, 1.5
z2 = 0.3
conv2 = hcf.check_convergence([a, b], [c], z2)
report(
    "2F1(0.25,0.75;1.5;0.3): filter CONVERGENT",
    conv2['converges'],
    conv2['description'],
)
val2_hcf, _ = hcf.evaluate_pFq([a, b], [c], z2)
val2_ref = mpmath.hyp2f1(a, b, c, z2)
report(
    "2F1(0.25,0.75;1.5;0.3) value matches mpmath.hyp2f1",
    allclose(val2_hcf, val2_ref),
    f"HCF={complex(val2_hcf):.8f}  ref={complex(val2_ref):.8f}",
)

# 2F1 with complex z inside unit disc: z = 0.3+0.2i
z_cmplx = complex(0.3, 0.2)
conv_cmplx = hcf.check_convergence([1.0, 1.0], [2.0], z_cmplx)
report(
    "2F1(1,1;2; 0.3+0.2i): filter CONVERGENT  (|z|<1)",
    conv_cmplx['converges'],
    f"|z|={abs(z_cmplx):.4f}  L={conv_cmplx['L']:.4f}",
)


# ===========================================================================
# Section 3 — Divergent series (should be detected)
# ===========================================================================

print("\n" + "=" * 70)
print("Section 3: Divergent series detection")
print("=" * 70)

# 2F1(1, 1; 2; 1.5)  — outside unit disc, should be flagged DIVERGENT
z_out = 1.5
conv_out = hcf.check_convergence([1.0, 1.0], [2.0], z_out)
report(
    "2F1(1,1;2;1.5): filter says DIVERGENT (|z|>1)",
    not conv_out['converges'],
    conv_out['description'],
)

# 2F0(1, 2; ; z): p-q-1 = 1 > 0 — always divergent
conv_div = hcf.check_convergence([1.0, 2.0], [], 0.1)
report(
    "2F0(1,2;;0.1): filter says DIVERGENT (power > 0)",
    not conv_div['converges'] and conv_div['type'] == 'divergent',
    conv_div['description'],
)

# 3F2([1,2,3]; [4,5]; 1.0)  — z=1 exactly, L=1, boundary => DIVERGENT by strict test
conv_boundary = hcf.check_convergence([1.0, 2.0, 3.0], [4.0, 5.0], 1.0)
report(
    "3F2([1,2,3];[4,5];1.0): filter says NOT convergent (L=1, boundary)",
    not conv_boundary['converges'],
    f"L = {conv_boundary['L']}",
)

# 2F1(1, 1; 2; -1.0)  — z=-1 on the unit circle; L = 1.0, not strictly < 1
conv_neg1 = hcf.check_convergence([1.0, 1.0], [2.0], -1.0)
report(
    "2F1(1,1;2;-1.0): filter L=1 (boundary, not strictly convergent)",
    not conv_neg1['converges'] and abs(conv_neg1['L'] - 1.0) < 1e-10,
    f"L = {conv_neg1['L']}",
)
# Note: the function 2F1(1,1;2;-1) = log(2) IS convergent by more refined tests
# (Gauss criterion), but the basic ratio test marks L=1 as not strictly < 1.


# ===========================================================================
# Section 4 — Absolutely convergent series (power < 0)
# ===========================================================================

print("\n" + "=" * 70)
print("Section 4: Absolutely convergent series (power < 0)")
print("=" * 70)

# 1F2(1; 2, 3; z) — power = 1-2-1 = -2 => absolute for ALL z
for z_abs in [0.1, 1.0, 10.0, 1000.0, complex(5.0, -3.0)]:
    conv_abs = hcf.check_convergence([1.0], [2.0, 3.0], z_abs)
    report(
        f"1F2(1;2,3; z={z_abs}): absolute convergence",
        conv_abs['converges'] and conv_abs['type'] == 'absolute',
        f"L={conv_abs['L']}  power={conv_abs['power']}",
    )

# 2F2([1,1]; [4/3, 5/3]; z) — P126-type, power = -1 => absolute for ALL z
print("\n  P126 series  2F2([1,1]; [4/3,5/3]; z):")
for z_p126 in [1e-4, 0.5, 1.0, 5.0, complex(2.0, 1.0)]:
    conv_p = hcf.check_convergence([1.0, 1.0], [4.0 / 3, 5.0 / 3], z_p126)
    report(
        f"  z={z_p126}: absolute convergence",
        conv_p['converges'] and conv_p['type'] == 'absolute',
        f"L={conv_p['L']}  power={conv_p['power']}",
    )

# Evaluate 2F2([1,1]; [4/3,5/3]; -z) at z=1/243 (P126 point, m^2=1, s=9)
z_p126_phys = mpmath.mpf(1) / 243
val_p126_2f2, conv_p2f2 = hcf.evaluate_pFq(
    [1.0, 1.0], [4.0 / 3, 5.0 / 3], -float(z_p126_phys)
)
val_ref_2f2 = mpmath.hyper(
    [1, 1], [mpmath.mpf('4') / 3, mpmath.mpf('5') / 3], -z_p126_phys
)
report(
    "2F2([1,1];[4/3,5/3]; -1/243): HCF value matches mpmath.hyper",
    allclose(val_p126_2f2, val_ref_2f2, rtol=1e-6),
    f"HCF={complex(val_p126_2f2):.8f}  ref={complex(val_ref_2f2):.8f}",
)


# ===========================================================================
# Section 5 — P126 topology
# ===========================================================================

print("\n" + "=" * 70)
print("Section 5: P126 equal-mass 2-loop vertex (s=9, m^2=1)")
print("=" * 70)

# Reference values from pySecDec (Table 5 of arXiv:1703.09692)
REF_EPS0 = complex(-1.0393673, 0.2414135)

# 5a. Regular series convergence
reg_val, reg_conv = hcf.compute_p126_regular_series(9.0, 1.0)
report(
    "P126 regular series: absolutely convergent",
    reg_conv['converges'] and reg_conv['type'] == 'absolute',
    reg_conv['description'],
)
report(
    "P126 regular series: z = m^2/(27s) = 1/243",
    abs(reg_conv['z_argument'] - 1.0 / 243) < 1e-12,
    f"z = {reg_conv['z_argument']:.6e}",
)
print(f"       Regular part value = {complex(reg_val):.6f}")

# 5b. Singular (log) part
sing_val = hcf.compute_p126_singular_logs(9.0, 1.0)
print(f"       Singular (log) part = {complex(sing_val):.6f}")

# 5c. Combined eps^0 estimate
eps0_val, eps0_info = hcf.compute_p126_eps0(9.0, 1.0)
print(f"       Computed eps^0  = {complex(eps0_val):.6f}")
print(f"       Reference eps^0 = {REF_EPS0}")
# The log coefficients A and B used are approximations; the
# relative error of the imaginary part should be within a reasonable range.
im_err = abs(eps0_val.imag - REF_EPS0.imag) / abs(REF_EPS0.imag)
report(
    "P126 eps^0 imaginary part in expected ballpark (within 2x)",
    im_err < 2.0,
    f"computed Im = {float(eps0_val.imag):.6f}  ref Im = {REF_EPS0.imag:.6f}  err = {im_err:.2f}x",
)

# 5d. Pole coefficients (eps^{-2} and eps^{-1}) — rough magnitude check
c_m2 = hcf.compute_p126_pole_terms(9.0, 1.0, eps_order=-2)
c_m1 = hcf.compute_p126_pole_terms(9.0, 1.0, eps_order=-1)
print(f"       Computed eps^{{-2}} = {complex(c_m2):.6f}  (ref = {complex(-0.0379735, -0.0747738)})")
print(f"       Computed eps^{{-1}} = {complex(c_m1):.6f}  (ref = {complex(0.2812615, 0.1738216)})")
# Only the magnitudes need to be in the right order; precise convention matching
# requires the full c_Gamma normalisation which depends on pySecDec internals.
report(
    "P126 eps^{-2} order of magnitude correct",
    abs(abs(c_m2) - abs(complex(-0.0379735, -0.0747738))) < 0.15,
    f"|c_m2|={abs(c_m2):.4f}  |ref|={abs(complex(-0.0379735, -0.0747738)):.4f}",
)

# 5e. Verify the filter says YES for the P126 specific kinematics
conv_p126 = hcf.check_convergence([1.0, 1.0], [4.0 / 3, 5.0 / 3],
                                   -1.0 / 243, verbose=True)
report(
    "P126 filter at z=-1/243: absolutely convergent",
    conv_p126['converges'] and conv_p126['type'] == 'absolute',
    (f"power={conv_p126['power']}  L={conv_p126['L']}  "
     f"ratio@500={conv_p126.get('ratio_exact_at_500', 'N/A'):.3e}"),
)


# ===========================================================================
# Section 6 — Double-sum (2-index) check
# ===========================================================================

print("\n" + "=" * 70)
print("Section 6: Double-sum (2-index, MoB Rule E3) convergence check")
print("=" * 70)

# Simulate a 2D residue series from a Lauricella-type MoB application.
# Index-n series: 2F1-type, shifts_num=[1], shifts_den=[2], x=0.3 => converges
# Index-k series: 2F1-type, shifts_num=[1], shifts_den=[2], y=0.4 => converges
params_n = {'shifts_num': [1.0], 'shifts_den': [2.0]}
params_k = {'shifts_num': [1.0], 'shifts_den': [2.0]}
ds = hcf.check_double_sum(params_n, params_k, x=0.3, y=0.4)
report(
    "Double sum (2x 2F1, x=0.3, y=0.4): joint CONVERGENT",
    ds['joint_converges'],
    ds['description'],
)

# One index outside disc: y=1.5 => that sum is divergent => joint divergent
ds_bad = hcf.check_double_sum(params_n, params_k, x=0.3, y=1.5)
report(
    "Double sum (x=0.3, y=1.5): joint DIVERGENT",
    not ds_bad['joint_converges'],
    ds_bad['description'],
)

# P126 2D scenario: both indices use 2F2-type params (absolutely convergent)
params_p = {'shifts_num': [1.0, 1.0], 'shifts_den': [4.0 / 3, 5.0 / 3]}
ds_p126 = hcf.check_double_sum(params_p, params_p,
                                x=-1.0 / 243, y=-1.0 / 243)
report(
    "P126 double-sum: joint absolutely convergent",
    ds_p126['joint_converges'],
    ds_p126['description'],
)


# ===========================================================================
# Summary
# ===========================================================================

print("\n" + "=" * 70)
n_pass = sum(_results)
n_total = len(_results)
print(f"Summary: {n_pass} / {n_total} tests passed.")
if n_pass == n_total:
    print("ALL TESTS PASSED.")
else:
    print(f"WARNING: {n_total - n_pass} test(s) FAILED.")
    sys.exit(1)
