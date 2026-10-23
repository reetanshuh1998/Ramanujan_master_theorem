"""Graph algebra, independent integral references, and honest failure modes."""
import math
from dataclasses import FrozenInstanceError

import mpmath as mp
import pytest
import sympy as sp
from scipy.integrate import quad
from scipy.special import gamma

from ramanujan_qft import (ScalarEdge, ScalarGraph, integrate_graph,
                           MultiloopConvergenceError)


def banana(n, masses=None, p=0, powers=None):
    masses = masses or [1] * n
    powers = powers or [1] * n
    return ScalarGraph([ScalarEdge("a", "b", m, a) for m, a in zip(masses, powers)],
                       {"a": [p], "b": [-p]})


def test_sunset_polynomials():
    graph = banana(3, [1, 4, 9], p=2)
    (x, y, z), U, F = graph.symanzik()
    assert graph.loops == 2
    assert sp.expand(U - (x*y + x*z + y*z)) == 0
    assert sp.expand(F - (U*(x + 4*y + 9*z) + 4*x*y*z)) == 0


def test_triangle_general_external_momenta():
    graph = ScalarGraph([ScalarEdge(0, 1, 1), ScalarEdge(1, 2, 2), ScalarEdge(2, 0, 3)],
                        {0: [1, 0], 1: [0, 2], 2: [-1, -2]})
    (x, y, z), U, F = graph.symanzik()
    assert U == x + y + z
    assert sp.expand(F - U*(x + 2*y + 3*z) - (4*x*y + x*z + 5*y*z)) == 0
    # Independent direct integration over the two-dimensional simplex, D=2.
    def outer(a):
        def inner(b):
            c = 1-a-b
            denominator = a + 2*b + 3*c + 4*a*b + a*c + 5*b*c
            return denominator**-2
        return quad(inner, 0, 1-a, epsabs=1e-11)[0]
    expected = quad(outer, 0, 1, epsabs=1e-11)[0]
    result = integrate_graph(graph, D=2, epsrel=2e-4)
    assert result.value == pytest.approx(expected, rel=2e-4)


def test_bridge_self_loops_and_tree_polynomials():
    graph = ScalarGraph([ScalarEdge(0, 0, 2), ScalarEdge(0, 1, 3), ScalarEdge(1, 1, 5)],
                        {0: [2], 1: [-2]})
    (x, y, z), U, F = graph.symanzik()
    assert graph.loops == 2
    assert U == x*z
    assert sp.expand(F - x*z*(2*x + 7*y + 5*z)) == 0
    tree = ScalarGraph([ScalarEdge(0, 1, 3), ScalarEdge(1, 2, 5)],
                       {0: [2], 2: [-2]})
    (x, y), U, F = tree.symanzik()
    assert tree.loops == 0 and U == 1 and F == 7*x + 9*y
    assert integrate_graph(tree, D=4).value == pytest.approx(1/63, rel=1e-4)


def test_uv_subdivergence_even_when_overall_finite():
    # A divergent tadpole times a strongly convergent tadpole.
    graph = ScalarGraph([ScalarEdge(0, 0, 1, 1), ScalarEdge(0, 0, 1, 5)])
    margins = graph.uv_margins(4)
    assert margins[(0, 1)] == 2
    assert margins[(0,)] == -1
    with pytest.raises(ValueError, match=r"UV divergent edge subset \(0,\)"):
        integrate_graph(graph, D=4)


def test_overlapping_uv_subgraphs_and_exact_boundary():
    graph = banana(3)
    assert graph.uv_margins(4)[(0, 1)] == 0
    with pytest.raises(ValueError, match="UV divergent"):
        integrate_graph(graph, D=3)
    # Exact rational power counting must not turn a boundary into convergence.
    graph = banana(2, powers=["0.500000000000000000000000000001", "0.5"])
    assert graph.uv_margins(2)[(0, 1)] == sp.Rational(1, 10**30)


@pytest.mark.parametrize("D,power,mass", [(1, 1, 4), (3, 3, 2), ("2.5", "1.75", "0.01")])
def test_tadpole_normalization(D, power, mass):
    graph = ScalarGraph([ScalarEdge(0, 0, mass, power)])
    result = integrate_graph(graph, D=D)
    d, a, m = float(D), float(power), float(mass)
    expected = gamma(a-d/2)/gamma(a) * m**(d/2-a)
    assert result.value == pytest.approx(expected, rel=2e-14)
    assert result.evaluations == 1 and result.standard_error == 0


@pytest.mark.parametrize("D,powers,masses,p", [
    (3, [1, 1], [1, 4], 2),
    ("2.5", ["1.25", "0.875"], ["0.3", "2.5"], 3),
    (4, [2, 2], [2, 5], 0),
])
def test_bubble_against_independent_feynman_parameter_quad(D, powers, masses, p):
    d = float(D)
    a, b = map(float, powers)
    m1, m2 = map(float, masses)
    shape = a+b-d/2
    reference = gamma(shape)/gamma(a)/gamma(b) * quad(
        lambda x: x**(a-1)*(1-x)**(b-1)
        / (x*m1+(1-x)*m2+x*(1-x)*p*p)**shape,
        0, 1, epsabs=1e-10, epsrel=1e-10)[0]
    result = integrate_graph(banana(2, masses, p, powers), D=D, epsrel=2e-5)
    assert result.converged
    assert result.value == pytest.approx(reference, rel=2e-5)


def test_two_loop_sunset_clausen_reference():
    with mp.workdps(40):
        reference = float(4/mp.sqrt(3) * mp.im(mp.polylog(2, mp.exp(mp.j*mp.pi/3))))
    result = integrate_graph(banana(3), D=2, epsrel=1e-5)
    assert result.value == pytest.approx(reference, rel=1e-5)
    assert result.sectors == 6


def test_three_loop_banana_zeta_reference():
    # The independent coordinate-space Bessel moment is 8*int r*K0(r)^4 dr = 7*zeta(3).
    reference = float(7*mp.zeta(3))
    result = integrate_graph(banana(4), D=2, epsrel=1e-4)
    assert result.value == pytest.approx(reference, rel=1e-4)
    assert result.sectors == 24


@pytest.mark.parametrize("n", [3, 4, 5])
def test_one_dimensional_multiloop_fourier_convolution(n):
    # Fourier transform of 1/(k^2+m^2) is pi/m * exp(-m*abs(x)).
    masses = list(range(1, n+1))
    p = 2
    M = sum(masses)
    reference = math.pi**((n-1)/2) * M/(math.prod(masses)*(M*M+p*p))
    result = integrate_graph(banana(n, [m*m for m in masses], p), D=1,
                             epsrel=1e-3, max_evaluations=4000000)
    assert result.value == pytest.approx(reference, rel=1e-3)


def test_two_loop_bridge_factorization():
    graph = ScalarGraph([ScalarEdge(0, 0, 2, 2), ScalarEdge(0, 1, 3, 2),
                         ScalarEdge(1, 1, 5, 2)], {0: [2], 1: [-2]})
    result = integrate_graph(graph, D=2, epsrel=1e-4)
    assert result.value == pytest.approx(1/(2*5*7**2), rel=1e-4)


@pytest.mark.parametrize("scale", ["1e-80", "1e80"])
def test_mass_homogeneity_extreme_scales(scale):
    a = sp.Rational(scale)
    original = integrate_graph(banana(3), D=2, epsrel=1e-4)
    scaled = integrate_graph(banana(3, [a]*3), D=2, epsrel=1e-4)
    assert scaled.value * float(a) == pytest.approx(original.value, rel=1e-12)
    assert scaled.error_estimate * float(a) == pytest.approx(original.error_estimate, rel=1e-7)


def test_permutation_and_relabelling_invariance():
    graph = banana(3, [1, 2, 5], 2, [1, "1.5", 2])
    reordered = ScalarGraph([ScalarEdge("y", "x", e.mass_squared, e.power)
                             for e in reversed(graph.edges)], {"x": [2], "y": [-2]})
    a = integrate_graph(graph, D=2, epsrel=2e-4)
    b = integrate_graph(reordered, D=2, epsrel=2e-4)
    assert a.value == pytest.approx(b.value, rel=1e-12)


def test_reproducibility_and_budget_failure():
    graph = banana(3, [1, 4, 9], p=3)
    options = dict(epsrel=1e-12, min_power=3, max_power=4, replicates=4, seed=123)
    result = integrate_graph(graph, **options, strict=False)
    assert not result.converged and result.evaluations == 6*4*16
    assert result == integrate_graph(graph, **options, strict=False)
    with pytest.raises(MultiloopConvergenceError) as caught:
        integrate_graph(graph, **options)
    assert caught.value.result == result
    by_budget = integrate_graph(graph, **{**options, "max_power": 20},
                                max_evaluations=6*4*16, strict=False)
    assert by_budget == result
    assert result.error_estimate >= 3*result.standard_error


@pytest.mark.parametrize("value", [0, -1, "nan", "inf", complex(1, 2), True])
def test_invalid_mass_and_power(value):
    with pytest.raises(ValueError):
        ScalarEdge(0, 1, value)
    with pytest.raises(ValueError):
        ScalarEdge(0, 1, 1, value)


@pytest.mark.parametrize("edges,momenta,match", [
    ([], {}, "nonempty"),
    ([(0, 1, 1)], {}, "ScalarEdge"),
    ([ScalarEdge(0, 1, 1), ScalarEdge(2, 3, 1)], {}, "connected"),
    ([ScalarEdge(0, 1, 1)], {2: [1]}, "unknown"),
    ([ScalarEdge(0, 1, 1)], {0: [1]}, "sum to zero"),
    ([ScalarEdge(0, 1, 1)], {0: [1], 1: [-1, 0]}, "same nonzero length"),
    ([ScalarEdge(0, 1, 1)], {0: []}, "same nonzero length"),
    ([ScalarEdge(0, 1, 1)], {0: 0}, "component sequence"),
])
def test_invalid_graphs(edges, momenta, match):
    with pytest.raises(ValueError, match=match):
        ScalarGraph(edges, momenta)


def test_inputs_are_immutable_copies():
    edges = [ScalarEdge(0, 1, "0.1")]
    momenta = {0: [1], 1: [-1]}
    graph = ScalarGraph(edges, momenta)
    edges.clear()
    momenta[0][0] = 10
    assert graph.edges[0].mass_squared == sp.Rational(1, 10)
    assert graph.external_momenta[0] == (1,)
    with pytest.raises(FrozenInstanceError):
        graph.edges = ()
    with pytest.raises(TypeError):
        graph.external_momenta[0] = (2,)


@pytest.mark.parametrize("kwargs", [
    {"D": 0}, {"D": float("inf")}, {"epsrel": 0}, {"epsrel": "1e-14"},
    {"epsrel": "1e400"}, {"epsabs": -1}, {"epsabs": float("nan")},
    {"min_power": 0}, {"max_power": 6}, {"max_power": 31}, {"replicates": 2},
    {"seed": -1}, {"seed": 1.5}, {"max_sectors": 1}, {"max_sectors": True},
    {"max_evaluations": 10}, {"max_forests": 1},
])
def test_invalid_options(kwargs):
    with pytest.raises(ValueError):
        integrate_graph(banana(3), **kwargs)


def test_resource_limits_and_float_range():
    with pytest.raises(ValueError, match="max_subgraphs"):
        banana(4).uv_margins(2, max_subgraphs=5)
    with pytest.raises(ValueError, match="max_sectors"):
        integrate_graph(banana(8))
    with pytest.raises(ArithmeticError, match="coefficient range"):
        integrate_graph(banana(2, ["1e-400", 1]))
    with pytest.raises(ArithmeticError):
        integrate_graph(ScalarGraph([ScalarEdge(0, 0, "1e-400", 2)]))


def test_kite_graph_against_independent_position_space_integral():
    # In D=1, each propagator Fourier transforms to an exponential. At zero
    # external momentum, ordering the vertex coordinates gives elementary
    # exponential integrals: each gap is weighted by the masses crossing it.
    from itertools import permutations
    links = [(0, 1), (1, 3), (0, 2), (2, 3), (1, 2)]
    masses = [1, 2, 1, 2, 1]
    graph = ScalarGraph([ScalarEdge(a, b, m*m) for (a, b), m in zip(links, masses)])
    coordinate_integral = 0.0
    for order in permutations(range(4)):
        term = 1.0
        for j in range(1, 4):
            left = set(order[:j])
            term /= sum(m for (a, b), m in zip(links, masses) if (a in left) != (b in left))
        coordinate_integral += term
    reference = math.pi**(graph.loops/2) / (2**3 * math.prod(masses)) * coordinate_integral
    result = integrate_graph(graph, D=1, epsrel=1e-3, max_evaluations=4000000)
    assert graph.loops == 2
    assert result.value == pytest.approx(reference, rel=1e-3)


def test_kite_polynomials_against_weighted_laplacian():
    links = [(0, 1), (1, 3), (0, 2), (2, 3), (1, 2)]
    graph = ScalarGraph([ScalarEdge(a, b, i+1) for i, (a, b) in enumerate(links)],
                        {0: [2, 1], 3: [-2, -1]})
    x, U, F = graph.symanzik()
    for parameters in [(1, 2, 3, 4, 5), (2, 5, 1, 3, 2)]:
        laplacian = sp.zeros(4)
        for (a, b), parameter in zip(links, parameters):
            conductance = sp.Rational(1, parameter)
            laplacian[a, a] += conductance
            laplacian[b, b] += conductance
            laplacian[a, b] -= conductance
            laplacian[b, a] -= conductance
        reduced = laplacian[:3, :3]
        expected_U = math.prod(parameters)*reduced.det()
        resistance = reduced.inv()[0, 0]
        expected_F = expected_U*(sum((i+1)*t for i, t in enumerate(parameters)) + 5*resistance)
        substitutions = dict(zip(x, parameters))
        assert U.subs(substitutions) == expected_U
        assert F.subs(substitutions) == expected_F


@pytest.mark.parametrize("vertex", [[], float("nan")])
def test_invalid_vertex_labels(vertex):
    with pytest.raises(ValueError, match="vertex labels"):
        ScalarEdge(vertex, 0, 1)
