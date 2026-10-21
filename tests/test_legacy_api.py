"""The 0.1 API: validated methods delegate correctly, withdrawn ones fail loudly."""
import mpmath as mp
import pytest

from ramanujan_qft import B0, C0, FeynmanMoBSolver, RamanujanContinuationEngine
from ramanujan_qft.core import MoBDynamicEngine
from ramanujan_qft.utils import HypergeometricConvergenceFilter


@pytest.fixture
def solver():
    return FeynmanMoBSolver(precision=20)


@pytest.mark.parametrize("precision", [15, 30, 50])
def test_B0_standard_keeps_old_convention_at_any_precision(precision):
    pole, fin = FeynmanMoBSolver(precision=precision).solve_B0_standard(1, 1)
    assert pole == 1
    assert abs(fin - (B0(1, 1, 1) - mp.euler)) < 1e-14          # = -0.3910150291...
    assert abs(fin - mp.mpf("-0.391015029136")) < 1e-11


def test_C0_standard(solver):
    assert abs(solver.solve_C0_standard(10, [1, 2, 3]) - C0(10, 1, 2, 3)) < 1e-15
    assert abs(solver.solve_C0_standard(5, 1) - mp.mpc("-0.894334511878058", "-0.604708613771115")) < 1e-13


def test_rmt_methods(solver):
    assert abs(solver.solve_bessel_exp_product(3, 4) - mp.mpf("0.2")) < 1e-14
    assert abs(solver.solve_massive_propagator(4, 1) - mp.pi / 2) < 1e-15


@pytest.mark.parametrize("call", [
    lambda s: s.massive_sunset_residue([1, 2, 3], 100),
    lambda s: s.solve_graph_polynomials("x1*x2", "x1*x2"),
    lambda s: s.solve_P126(),
    lambda s: s.solve_triangle3L(),
    lambda s: s.solve_elliptic_kite(10),
    lambda s: s.solve_double_box_inv(),
    lambda s: RamanujanContinuationEngine().sunset_real_dispersion(100, [1, 2, 3]),
    lambda s: HypergeometricConvergenceFilter().compute_p126_eps0(),
    lambda s: MoBDynamicEngine().stage_D_dynamic_evaluation("x1+x2", "x1*x2", 1, 1),
])
def test_withdrawn_methods_raise(solver, call):
    with pytest.raises(NotImplementedError):
        call(solver)


def test_phase_space_normalisation():
    # 0.1 was 16x too small with the wrong sign
    eng = RamanujanContinuationEngine(precision=15)
    assert abs(eng.phase_space_3body(100, 1, 2, 3) - mp.mpf("-88.1849955506")) < 1e-8


def test_Li2_continuation_agree():
    eng = RamanujanContinuationEngine(precision=25)
    with mp.workdps(25):
        for z in [3, 7.5, 1.0001]:
            assert abs(eng.Li2_phys(z) - eng.algebraic_continuation_Li2(z)) < 1e-20


def test_hypergeom_continuation_matches_mpmath_branch():
    eng = RamanujanContinuationEngine(precision=25)
    with mp.workdps(25):
        a, b, c, z = mp.mpf("0.3"), mp.mpf("0.8"), mp.mpf("1.7"), mp.mpf(4)
        assert abs(eng.hypergeom_continuation_2F1(a, b, c, z) - mp.conj(mp.hyp2f1(a, b, c, z))) < 1e-18
