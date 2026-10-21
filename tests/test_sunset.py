"""Sunset: dispersion results vs independent 2-D Feynman-parameter integrals (scipy)."""
import mpmath as mp
import numpy as np
import pytest

si = pytest.importorskip("scipy.integrate")

from ramanujan_qft import sunset_d2, sunset_im, sunset_subtracted, sunset_threshold

M = (1.0, 2.0, 3.0)


def _simplex(fun):
    opts = dict(epsabs=1e-11, epsrel=1e-10)
    return si.dblquad(lambda x2, x1: fun(x1, x2, 1 - x1 - x2), 0, 1, 0, lambda x1: 1 - x1, **opts)[0]


def _UF(x1, x2, x3, s, m):
    U = x1 * x2 + x2 * x3 + x3 * x1
    F0 = (m[0] * x1 + m[1] * x2 + m[2] * x3) * U
    return U, F0, F0 - s * x1 * x2 * x3


def _im_feynman(s, m):
    # eps^0 imaginary part of -Gamma(-1+2eps) Int U^(-3+3eps) F^(1-2eps):  pi Int F theta(-F)/U^3
    def f(a, b, c):
        U, _, F = _UF(a, b, c, s, m)
        return np.pi * F / U**3 if F < 0 else 0.0
    return _simplex(f)


def test_threshold_and_below():
    assert abs(sunset_threshold(*M) - (1 + mp.sqrt(2) + mp.sqrt(3))**2) < 1e-14
    assert sunset_im(10, *M) == 0


@pytest.mark.slow
@pytest.mark.parametrize("s,m", [(100, M), (20, (1, 1, 1)), (50, (1, 1, 1))])
def test_im_vs_feynman(s, m):
    assert abs(float(sunset_im(s, *m)) - _im_feynman(s, m)) < 1e-8 * abs(_im_feynman(s, m))


def test_im_mass_symmetry():
    a = sunset_im(60, 1, 2, 3)
    for perm in [(3, 2, 1), (2, 3, 1), (1, 3, 2)]:
        assert abs(sunset_im(60, *perm) - a) < 1e-12 * abs(a)


@pytest.mark.slow
@pytest.mark.parametrize("s", [-5, 3, 10])
def test_second_derivative_vs_feynman(s):
    feyn = _simplex(lambda a, b, c: -(a * b * c)**2 / (_UF(a, b, c, s, M)[0]**3 * _UF(a, b, c, s, M)[2]))
    assert abs(float(sunset_d2(s, *M)) - feyn) < 1e-9 * abs(feyn)


def _sub_feynman(s, m):
    def part(a, b, c, k):
        U, F0, F = _UF(a, b, c, s, m)
        L = complex(np.log(abs(F)), -np.pi if F < 0 else 0.0)
        v = -(F * L - F0 * np.log(F0) + s * a * b * c * (np.log(F0) + 1)) / U**3
        return v.real if k == 0 else v.imag
    return complex(_simplex(lambda a, b, c: part(a, b, c, 0)), _simplex(lambda a, b, c: part(a, b, c, 1)))


@pytest.mark.slow
@pytest.mark.parametrize("s,tol", [(-5, 1e-10), (10, 1e-10), (100, 1e-8)])
def test_subtracted_vs_feynman(s, tol):
    a = complex(sunset_subtracted(s, *M))
    b = _sub_feynman(s, M)
    assert abs(a - b) < tol * abs(b)
