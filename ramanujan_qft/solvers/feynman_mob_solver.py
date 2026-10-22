"""
Backward-compatible solver API.

The validated implementations live in :mod:`ramanujan_qft.one_loop`,
:mod:`ramanujan_qft.sunset`, :mod:`ramanujan_qft.mellin` and :mod:`ramanujan_qft.rmt`.

Methods of the 0.1 API that returned numbers not corresponding to the stated
integral (fixed placeholder constants, polynomial strings that are not the
Symanzik polynomials of the named diagram, or silent zeros) now raise
``NotImplementedError`` with an explanation -- see AUDIT.md.
"""

import time

import mpmath
import sympy as sp

from ramanujan_qft import mellin, one_loop, rmt

__all__ = ["GeneralizedBracketSolver", "PolynomialStructuralParser", "FeynmanMoBSolver"]

_NOT_VALIDATED = (
    "{name} is not available: the 0.1 implementation did not compute the stated "
    "integral ({why}). See AUDIT.md and the roadmap in README.md."
)


class GeneralizedBracketSolver:
    """
    Method of Brackets, rule E2 for a square (index-0) bracket system:

        result = (1/|det A|) * Prod_i phi_i(n_i*) Gamma(-n_i*),   A n* = -c.
    """

    def __init__(self, precision=30):
        self.precision = precision

    @staticmethod
    def indicator(n):
        """MoB indicator  (-1)^n / Gamma(n+1)."""
        return mpmath.power(-1, n) * mpmath.rgamma(n + 1)

    def solve_bracket_integral(self, a_matrix, c_vector, phi_funcs):
        A = sp.Matrix(a_matrix)
        c = sp.Matrix(c_vector)
        det_A = A.det()
        if det_A == 0:
            raise ValueError("singular bracket system: rule E2 does not apply")
        n_star = A.solve(-c)
        with mpmath.workdps(self.precision):
            res = 1 / abs(mpmath.mpf(sp.N(det_A, self.precision + 5)))
            for phi, ni in zip(phi_funcs, n_star):
                ni = mpmath.mpf(sp.N(ni, self.precision + 5))
                res *= mpmath.gamma(-ni) * phi(ni)
            return res


class PolynomialStructuralParser:
    """Heuristic classification by degree / variable count. Informational only:
    distinct diagrams can share a signature, so it must not drive evaluation."""

    @staticmethod
    def identify(U, F):
        if U is None or F is None:
            return "unknown"
        U_expr = sp.sympify(U) if isinstance(U, str) else U
        loops = sp.total_degree(U_expr)
        nvars = len(U_expr.free_symbols)
        if loops == 2:
            return {2: "sunset", 3: "sunset", 4: "elliptic_kite", 5: "triangle2L", 6: "P126"}.get(nvars, "unknown")
        if loops == 3 and nvars == 6:
            return "triangle3L"
        return "unknown"


class FeynmanMoBSolver(GeneralizedBracketSolver):
    """Feynman-integral front end (RAF)."""

    def __init__(self, precision=30):
        super().__init__(precision)

    # ---- validated ---------------------------------------------------------

    def solve_B0_standard(self, psq, msq, return_pole=True):
        """
        Equal-mass B0(p^2; m^2, m^2) in D = 4 - 2 eps.

        Keeps the 0.1 convention: finite part of Gamma(eps) (m^2)^(-eps) 2F1(eps,1;3/2;w)
        minus 1/eps, i.e. LoopTools' value shifted by -gamma_E. For LoopTools
        conventions use :func:`ramanujan_qft.one_loop.B0`.
        """
        fin = one_loop.B0(psq, msq, msq, delta=-mpmath.euler, dps=self.precision)
        return (mpmath.mpf(1), fin) if return_pole else fin

    def solve_C0_standard(self, psq, msq):
        """C0(0, 0, s; m1^2, m2^2, m3^2); ``msq`` is a number (equal masses) or a 3-list."""
        if isinstance(msq, (list, tuple)):
            return one_loop.C0(psq, *msq, dps=self.precision)
        return one_loop.C0_mob(psq, msq, dps=self.precision)

    def solve_massive_bubble(self, v1=1, v2=1, s=None, m1_sq=None, m2_sq=None):
        """Finite D = 3 bubble (unit propagator powers)."""
        if (v1, v2) != (1, 1):
            raise NotImplementedError("only unit propagator powers are implemented")
        return one_loop.bubble_3d(1.0 if s is None else s, 1.0 if m1_sq is None else m1_sq,
                                  1.0 if m2_sq is None else m2_sq, dps=self.precision)

    def solve_massive_propagator(self, m2, D=3):
        """Int dq2 (q2)^(D/2-1)/(q2 + m^2) by Ramanujan's Master Theorem."""
        return rmt.massive_propagator_rmt(m2, D, dps=self.precision)

    def solve_bessel_exp_product(self, a, b):
        """Int_0^oo exp(-a x) J0(b x) dx (= 1/sqrt(a^2 + b^2)) by Mellin residues."""
        return mellin.product_integral(mellin.exponential(a), mellin.bessel_j(0, b), dps=self.precision)

    # ---- removed: did not compute the named integral ------------------------

    def massive_sunset_residue(self, m_sq, p2, D=4):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="massive_sunset_residue",
            why="below threshold it integrated F/U^3, which is not the sunset finite part; above "
                "threshold it used fixed subtraction constants and an Im part 16x too small. "
                "Use ramanujan_qft.sunset.sunset_im / sunset_subtracted"))

    def solve_massive_sunset(self, v1=1, v2=1, v3=1):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="solve_massive_sunset", why="symbolic placeholder"))

    def solve_graph_polynomials(self, U, F, indices=None, eps=0, s_val=1, msq_val=1, t_val=None):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="solve_graph_polynomials",
            why="it dispatched on degree heuristics and returned the sunset of unrelated "
                "masses, a hard-coded series, or 0 for most inputs"))

    def solve_P126(self, s=9.0, msq=1.0, eps=0):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="solve_P126", why="hard-coded logarithm coefficients; spurious imaginary part "
                                   "in the Euclidean region"))

    def solve_triangle3L(self, s=-1.0):
        raise NotImplementedError(_NOT_VALIDATED.format(name="solve_triangle3L", why="returned 0"))

    def solve_elliptic_kite(self, s, msq=1.0):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="solve_elliptic_kite", why="the input was misclassified as a sunset"))

    def solve_double_box_inv(self, s=-3.0, t=-2.0):
        raise NotImplementedError(_NOT_VALIDATED.format(
            name="solve_double_box_inv", why="the input was misclassified as a sunset"))


if __name__ == "__main__":
    solver = FeynmanMoBSolver(precision=30)
    print("C0(0,0,10;1,2,3) =", solver.solve_C0_standard(10, [1, 2, 3]))
    print("B0(5;1,1) (LoopTools conv.) =", one_loop.B0(5, 1, 1))
