"""One-loop integrals: LoopTools reference values, internal consistency, independent quadrature."""
import mpmath as mp
import pytest

from ramanujan_qft import B0, B0_mob, C0, C0_mob, bubble_3d

EPS = mp.mpf(10)**-40


@pytest.mark.parametrize("dps", [15, 30, 60])
def test_against_looptools(lt_case, dps):
    """Agreement with LoopTools to double precision at every working precision."""
    f, args, ref = lt_case
    val = complex((B0 if f == "B0" else C0)(*args, dps=dps))
    assert abs(val - ref) <= 2e-15 * max(1, abs(ref)), (val, ref)


# ---- B0 ------------------------------------------------------------------

def _B0_quad(p2, m1, m2):
    """Independent: -Int_0^1 log(Delta - i0), split at the roots of Delta."""
    p2, m1, m2 = mp.mpf(p2), mp.mpf(m1), mp.mpf(m2)
    f = lambda x: mp.log(mp.mpc(x * m1 + (1 - x) * m2 - x * (1 - x) * p2, -EPS))
    pts = [0, mp.mpf(1) / 2, 1]     # x = 1/2: minimum of Delta for equal masses
    if p2 != 0:
        d = (p2 - m1 + m2)**2 - 4 * p2 * m2
        if d > 0:
            pts += [r for r in (((p2 - m1 + m2) + s * mp.sqrt(d)) / (2 * p2) for s in (1, -1)) if 0 < r < 1]
    return -mp.quad(f, sorted(pts))


@pytest.mark.parametrize("p2,m1,m2", [(-7.5, 0.3, 4), (2, 0.3, 4), (12, 0.3, 4), (1e4, 1, 1),
                                      (-1e-3, 2, 2), (3.99, 1, 1), (4.01, 1, 1), (0.7, 0, 2)])
def test_B0_independent_quadrature(p2, m1, m2):
    with mp.workdps(30):
        assert abs(B0(p2, m1, m2, dps=30) - _B0_quad(p2, m1, m2)) < 1e-20


@pytest.mark.parametrize("p2", [-50, -1, 0, 0.5, 3.9, 4, 4.1, 7, 100, 1e5])
def test_B0_mob_series_equals_closed_form(p2):
    """The Method-of-Brackets 2F1 representation reproduces the closed form to 50 digits."""
    a, b = B0_mob(p2, 1, dps=55), B0(p2, 1, 1, dps=55)
    assert abs(a - b) < mp.mpf(10)**-48


def test_B0_scale_and_delta():
    base = B0(5, 1, 2)
    assert abs(B0(5, 1, 2, mu2=3, delta=0.25) - (base + mp.log(3) + 0.25)) < 1e-14


def test_B0_im_is_two_body_phase_space():
    p2, m1, m2 = mp.mpf(30), mp.mpf(1), mp.mpf(4)
    lam = p2**2 + m1**2 + m2**2 - 2 * (p2 * m1 + p2 * m2 + m1 * m2)
    assert abs(B0(p2, m1, m2).imag - mp.pi * mp.sqrt(lam) / p2) < 1e-14


def test_B0_invalid():
    with pytest.raises(ValueError):
        B0(0, 0, 0)
    with pytest.raises(ValueError):
        B0(1, -1, 1)


# ---- C0 ------------------------------------------------------------------

def _C0_quad(s, m1, m2, m3):
    """Independent: Feynman parameters, inner integral analytic, outer by quadrature."""
    s, m1, m2, m3 = (mp.mpf(x) for x in (s, m1, m2, m3))

    def inner(b):
        al = m1 - m2 - b * s
        be = mp.mpc((1 - b) * m2 + b * m3, -EPS)
        return (1 - b) / be if al == 0 else (mp.log(al * (1 - b) + be) - mp.log(be)) / al

    pts, d = [0, 1], (s + m1 - m3)**2 - 4 * s * m1
    if d > 0 and s != 0:
        pts += [r for r in (((s + m1 - m3) + t * mp.sqrt(d)) / (2 * s) for t in (1, -1)) if 0 < r < 1]
    return -mp.quad(inner, sorted(pts))


@pytest.mark.parametrize("s,ms", [(-100, (5, 0.2, 1)), (2.5, (5, 0.2, 1)), (40, (5, 0.2, 1)),
                                  (9, (1, 1, 2)), (16, (0.25, 9, 0.25)), (0, (1, 2, 3)),
                                  (3, (2, 2, 2)), (8.5, (2, 2, 2)), (1e3, (1, 1, 1))])
def test_C0_independent_quadrature(s, ms):
    with mp.workdps(30):
        assert abs(C0(s, *ms, dps=30) - _C0_quad(s, *ms)) < 1e-18


@pytest.mark.parametrize("s", [-3, 1, 3.999, 4.001, 10, 300])   # (not at threshold: Im ~ sqrt(s - th))
def test_C0_equal_mass_limit_is_continuous(s):
    """Unequal-mass formula approaches the closed equal-mass MoB form."""
    with mp.workdps(40):
        a = C0(s, 1, 1 + mp.mpf(10)**-20, 1 - mp.mpf(10)**-20, dps=40)
        b = C0_mob(s, 1, dps=40)
        assert abs(a - b) < 1e-15


def test_C0_symmetry_m1_m3():
    assert abs(C0(17, 1, 2, 5) - C0(17, 5, 2, 1)) < 1e-14


def test_C0_mob_arcsin_form():
    s, m = mp.mpf(3), mp.mpf(1)
    assert abs(C0_mob(s, m) - (-2 / s * mp.asin(mp.sqrt(s / (4 * m)))**2)) < 1e-14


def test_C0_massless_rejected():
    with pytest.raises(ValueError):
        C0(1, 0, 1, 1)


# ---- D = 3 bubble ----------------------------------------------------------

def _bubble3_quad(p2, m1, m2):
    p2, m1, m2 = mp.mpf(p2), mp.mpf(m1), mp.mpf(m2)

    def f(x):
        d = x * m1 + (1 - x) * m2 - x * (1 - x) * p2
        return d**mp.mpf(-0.5) if d > 0 else 1j * (-d)**mp.mpf(-0.5)   # (d - i0)^(-1/2)

    pts, dd = [0, 1], (p2 - m1 + m2)**2 - 4 * p2 * m2
    if p2 > 0 and dd > 0:
        pts += [r for r in (((p2 - m1 + m2) + t * mp.sqrt(dd)) / (2 * p2) for t in (1, -1)) if 0 < r < 1]
    return mp.sqrt(mp.pi) * mp.quad(f, sorted(pts))


@pytest.mark.parametrize("p2,m1,m2", [(-3, 1, 1), (0, 1, 4), (2, 1, 4), (8, 1, 4), (20, 1, 4), (50, 0.5, 0.5)])
def test_bubble_3d(p2, m1, m2):
    with mp.workdps(25):
        assert abs(bubble_3d(p2, m1, m2, dps=25) - _bubble3_quad(p2, m1, m2)) < 1e-10
