"""Exact Schwinger/Method-of-Brackets algebra, without convergence claims.

This module produces candidate Gamma series. A nonsingular bracket basis is
an algebraic condition only: selecting and summing the correct families needs
an independent analytic justification, as in :mod:`ramanujan_qft.sunset_rmt`.
"""
from dataclasses import dataclass

import sympy as sp

from .multiloop import ScalarGraph

__all__ = ["BracketSystem", "BracketSolution", "schwinger_brackets"]


@dataclass(frozen=True)
class BracketSolution:
    """One exact bracket basis and its formal Gamma-function summand.

    ``values`` contains every index, with bound indices solved in terms of the
    free ones. ``term`` includes free factorial indicators, coefficient powers,
    Gamma factors from the bound indices, and the graph normalization. It is
    not automatically a convergent representation of the integral.
    """
    bound_columns: tuple
    free_columns: tuple
    determinant: object
    values: tuple
    term: object


@dataclass(frozen=True)
class BracketSystem:
    """Exact system ``matrix * indices + offsets = 0``.

    Columns first describe the kinetic polynomial F-U*sum(m_i^2*x_i), then
    the mass exponentials, then the monomials of U. The last bracket row comes
    from the multinomial expansion of U**(-D/2-sum(kinetic indices)).
    """
    matrix: object
    offsets: object
    indices: tuple
    coefficients: tuple
    kinetic_columns: tuple
    mass_columns: tuple
    u_columns: tuple
    u_exponents: tuple
    gamma_denominator: object
    normalization: object

    def solve(self, bound_columns):
        """Solve a square bracket basis over exact SymPy arithmetic.

        Rejects duplicate, missing, out-of-range and singular column choices.
        No rows are dropped and no floating-point rank threshold is used.
        """
        bound = tuple(bound_columns)
        rows, columns = self.matrix.shape
        if (len(bound) != rows
                or any(isinstance(i, bool) or not isinstance(i, (int, sp.Integer))
                       or not 0 <= i < columns for i in bound)
                or len(set(bound)) != rows):
            raise ValueError(f"bound_columns must contain {rows} distinct column indices")
        free = tuple(i for i in range(columns) if i not in bound)
        basis = self.matrix[:, bound]
        determinant = basis.det()
        if determinant == 0:
            raise ValueError("singular bracket basis")
        rhs = -self.offsets
        if free:
            rhs -= self.matrix[:, free] * sp.ImmutableMatrix([self.indices[i] for i in free])
        solution = basis.inv() * rhs
        substitutions = {self.indices[i]: sp.expand(v) for i, v in zip(bound, solution)}
        values = tuple(substitutions.get(n, n) for n in self.indices)
        term = self.normalization / sp.Abs(determinant)
        term *= sp.prod(sp.gamma(-values[i]) for i in bound)
        term *= sp.prod((-1)**self.indices[i] / sp.gamma(1 + self.indices[i]) for i in free)
        term *= sp.prod(c**n for c, n in zip(self.coefficients, values))
        term /= self.gamma_denominator.subs(substitutions, simultaneous=True)
        return BracketSolution(bound, free, determinant, values, term)


def schwinger_brackets(graph, D=2, *, propagator_shifts=None, max_forests=100000):
    """Compile graph polynomials into a formal exact Schwinger bracket system.

    D and propagator_shifts may be SymPy expressions; symbolic shifts are
    useful for exposing coalescing poles. They are formal regulators, not an
    epsilon expansion implementation. Numeric input conversion uses SymPy.
    Graph construction itself enforces positive masses and powers.
    """
    if not isinstance(graph, ScalarGraph):
        raise TypeError("graph must be a ScalarGraph")
    dimension = sp.sympify(D)
    if not isinstance(dimension, sp.Expr):
        raise ValueError("D must be a scalar expression")
    if dimension.is_number and (dimension.is_real is not True or dimension.is_positive is not True
                                or dimension.is_finite is not True):
        raise ValueError("numeric D must be finite, real and positive")
    n = len(graph.edges)
    shifts = (sp.S.Zero,) * n if propagator_shifts is None else tuple(map(sp.sympify, propagator_shifts))
    if len(shifts) != n:
        raise ValueError("one propagator shift is required per edge")
    if any(not isinstance(s, sp.Expr) or s.is_finite is False for s in shifts):
        raise ValueError("propagator shifts must be finite scalar expressions")
    x, U, F = graph.symanzik(max_forests=max_forests)
    kinetic = sp.expand(F - U * sum(e.mass_squared * t for e, t in zip(graph.edges, x)))
    kinetic_terms = [] if kinetic == 0 else sp.Poly(kinetic, *x).terms()
    u_terms = sp.Poly(U, *x).terms()
    nk, nu = len(kinetic_terms), len(u_terms)
    k_cols = tuple(range(nk))
    m_cols = tuple(range(nk, nk + n))
    u_cols = tuple(range(nk + n, nk + n + nu))
    indices = tuple(sp.Symbol(f"k{i}") for i in range(nk))
    indices += tuple(sp.Symbol(f"m{i}") for i in range(n))
    indices += tuple(sp.Symbol(f"u{i}") for i in range(nu))
    mass_terms = [(tuple(int(i == j) for i in range(n)), e.mass_squared)
                  for j, e in enumerate(graph.edges)]
    terms = kinetic_terms + mass_terms + u_terms
    rows = [[exponents[i] for exponents, _ in terms] for i in range(n)]
    rows.append([1] * nk + [0] * n + [1] * nu)
    powers = tuple(e.power + shift for e, shift in zip(graph.edges, shifts))
    return BracketSystem(
        sp.ImmutableMatrix(rows), sp.ImmutableMatrix(powers + (dimension / 2,)),
        indices, tuple(c for _, c in terms), k_cols, m_cols, u_cols,
        tuple(p for p, _ in u_terms), sp.gamma(dimension / 2 + sum(indices[i] for i in k_cols)),
        1 / sp.prod(sp.gamma(v) for v in powers))
