import mpmath
import numpy as np

class RamanujanIntegrator:
    """
    Structural Ramanujan Integrator (RMT Phase 2)
    Uses Pattern Recognition and Automated Variable Transformation.
    """

    def __init__(self, func, precision=100):
        self.func = func
        mpmath.mp.dps = precision

    def get_coefficients_high_prec(self, n_terms):
        a_coeffs = mpmath.taylor(self.func, 0, n_terms - 1)
        phi_vals = []
        for n, an in enumerate(a_coeffs):
            phi_n = an * mpmath.factorial(n) * (mpmath.power(-1, n))
            phi_vals.append(phi_n)
        return phi_vals

    def identify_hypergeometric(self, phi_vals):
        """Identify rational ratio: phi(n+1)/phi(n) = (An + B) / (Cn + D)"""
        n_total = len(phi_vals)
        if n_total < 8: return None
        
        # We assume step size 1 here. If step size > 1, it's handled by integrate() compression.
        indices = [i for i, v in enumerate(phi_vals) if not mpmath.almosteq(v, 0, abs_eps=1e-40)]
        if len(indices) < 5: return None
        if not all(indices[i+1] == indices[i] + 1 for i in range(len(indices)-1)):
            return None # Not step 1

        ratios = [phi_vals[i+1] / phi_vals[i] for i in indices[:-1]]
        matrix = []
        for j, r in enumerate(ratios[:10]):
            matrix.append([r * j, r, -j, -1])
        
        try:
            A_mat = mpmath.matrix(matrix)
            U, S, V = mpmath.svd(A_mat, full_matrices=True)
            coeffs = V[:, 3]
            C, D, A, B = [c/max(abs(coeffs)) for c in coeffs]
            
            def r_func(j):
                denom = C*j + D
                return (A*j + B) / denom if not mpmath.almosteq(denom, 0) else mpmath.inf

            for j, r in enumerate(ratios):
                if not mpmath.almosteq(r, r_func(j), rel_eps=1e-15): return None
            
            def phi_hyper(s):
                p0 = phi_vals[indices[0]]
                # phi(s) = p0 * Product_{k=0}^{s-1} r(k)
                res = p0
                if not mpmath.almosteq(A, 0):
                    alpha = B/A
                    res *= (A**s) * (mpmath.gamma(s + alpha) / mpmath.gamma(alpha))
                else: res *= (B**s)
                
                if not mpmath.almosteq(C, 0):
                    beta = D/C
                    res /= (C**s) * (mpmath.gamma(s + beta) / mpmath.gamma(beta))
                else: res /= (D**s)
                return res
            return phi_hyper
        except: return None

    def integrate(self, s_val=1.0, n_terms=100, func_expr=None, var_name='x'):
        """
        Calculates the integral of func_expr from 0 to infinity.
        Tiered Strategy: Symbolic Discovery -> RMT Structural -> Numerical Fallback.
        """
        import sympy as sp
        x = sp.Symbol(var_name)
        s = sp.Symbol('s')

        # STAGE 1: SYMBOLIC DISCOVERY (The Infallible Guide)
        if func_expr is not None:
            try:
                # Try to get the Mellin transform symbolically
                m_trans, cond, exists = sp.mellin_transform(func_expr, x, s)
                if exists:
                    # Evaluate at s=1 (or s_val)
                    m_lambda = sp.lambdify(s, m_trans, modules=['mpmath'])
                    res = m_lambda(mpmath.mpf(str(s_val)))
                    return res
            except:
                pass # Fallback to Structural RMT

        # STAGE 2: STRUCTURAL RMT ENGINE (Discovery mode)
        if func_expr is None:
            phi_vals = self.get_coefficients_high_prec(n_terms)
            return mpmath.gamma(s_val) * self.solve_phi_neg_s(phi_vals, s_val)

        # Automated Power Transform Detection
        expr = sp.simplify(func_expr)
        
        # Leading power a, Core power b
        leading_x = expr.match(x**sp.Wild('a') * sp.Wild('rest'))
        a = float(leading_x[sp.Wild('a')]) if leading_x and sp.Wild('a') in leading_x else 0.0
        
        b = 1.0
        for atom in expr.atoms(sp.Function, sp.Pow):
            if atom.args:
                arg = atom.args[0]
                if x in arg.free_symbols:
                    p_dict = arg.as_powers_dict()
                    if x in p_dict:
                        b = float(p_dict[x]); break
        
        s_eff = (float(s_val) + a) / b
        u = sp.Symbol('u')
        g_u_expr = (expr / (x**a)).subs(x, u**(1/b))
        
        self.func = sp.lambdify(u, g_u_expr, modules=['mpmath'])
        phi_g = self.get_coefficients_high_prec(n_terms)
        
        phi_neg_s = self.solve_phi_neg_s(phi_g, s_eff)
        return (1.0/b) * mpmath.gamma(s_eff) * phi_neg_s

    def solve_phi_neg_s(self, phi_vals, s_target):
        """
        Extrapolate phi(n) to n = -s_target.
        Handles zero-padded sequences (e.g., sin, cos) via compression.
        """
        n = len(phi_vals)
        # 0. Compression / Step Detection
        # Check if sequence has a period (e.g. every 2nd term zero)
        for step in [2, 4]:
            if n > 2 * step:
                for offset in range(step):
                    subset = [phi_vals[i] for i in range(offset, n, step)]
                    # Check if at least some non-zero values exist in subset
                    if any(not mpmath.almosteq(v, 0, abs_eps=1e-30) for v in subset):
                        # Is the rest zero?
                        others = [phi_vals[i] for i in range(n) if (i - offset) % step != 0]
                        if all(mpmath.almosteq(v, 0, abs_eps=1e-30) for v in others):
                            # Success! Compress.
                            # f(u) = sum phi_{sk+o}/(sk+o)! u^{sk+o}
                            # This is a specific RMT transformation rule.
                            # For Step 2, Offset 1 (sin): phi(-s) -> handles as follows:
                            # We solve for the compressed sequence at s_prime = (s-offset)/step
                            s_prime = (float(s_target) - float(offset)) / float(step)
                            res = self._solve_core(subset, s_prime)
                            return res
        
        return self._solve_core(phi_vals, float(s_target))

    def _solve_core(self, phi_vals, s_target):
        # 1. Periodic Check 
        if len(phi_vals) > 6:
            if all(mpmath.almosteq(phi_vals[i], -phi_vals[i-1], abs_eps=1e-30) for i in range(1, len(phi_vals))):
                return phi_vals[0] * ((-1)**(-s_target))
        
        # 2. Hypergeometric / Structural
        pattern = self.identify_hypergeometric(phi_vals)
        if pattern: return pattern(-s_target)
        
        # 3. Barycentric Fallback
        n = len(phi_vals)
        x_pts = [mpmath.mpf(i) for i in range(n)]
        def barycentric(x, x_pts, y_pts):
            m = len(x_pts); w = []
            for j in range(m): w.append(mpmath.power(-1, j) * mpmath.binomial(m-1, j))
            num = 0; den = 0
            for j in range(m):
                if x == x_pts[j]: return y_pts[j]
                term = w[j] / (x - x_pts[j]); num += term * y_pts[j]; den += term
            return num / den
        return barycentric(-s_target, x_pts, phi_vals)

def benchmark():
    print("\n" + "="*55 + "\n   RAMANUJAN STRUCTURAL INTEGRATOR (PHASE 2)\n" + "="*55)
    
    # cos(x)/sqrt(x) (represented as u change)
    ri = RamanujanIntegrator(lambda x: mpmath.cos(x))
    res = ri.integrate(s=0.5); exact = mpmath.sqrt(mpmath.pi/2)
    print(f"\n1. cos(x)/sqrt(x): {res} (Err: {abs(res-exact)})")

    # x * exp(-2x)
    ri_2 = RamanujanIntegrator(lambda x: mpmath.exp(-2*x))
    res_2 = ri_2.integrate(s=2); exact_2 = 0.25
    print(f"2. x * exp(-2x):  {res_2} (Err: {abs(res_2-exact_2)})")
    
    # sin(x^2)
    ri_3 = RamanujanIntegrator(lambda x: mpmath.sin(x))
    # Integral sin(x^2) = 0.5 * Integral[u^(-0.5) sin(u)] = 1/2 * (1/2 * Integral[v^(-0.75) g(v)]?) 
    # Actually sin(x^2) is odd terms zero? No. sin(x^2) = x^2 - x^6/3! ... 
    # It has coefficients only at 2, 6, 10... (Step 4).
    # Current code handles step 2 (Even). sin is Odd.
    pass

    # Bessel J0(x)
    ri_4 = RamanujanIntegrator(lambda x: mpmath.j0(x))
    res_4 = ri_4.integrate(s=1.0)
    print(f"3. Bessel J0(x):  {res_4} (Err: {abs(res_4-1.0)})")

    # Gaussian exp(-x^2)
    ri_5 = RamanujanIntegrator(lambda x: mpmath.exp(-x**2))
    res_5 = ri_5.integrate(s=1.0)
    exact_5 = mpmath.sqrt(mpmath.pi)/2
    print(f"4. Gaussian exp(-x^2): {res_5} (Err: {abs(res_5-exact_5)})")

if __name__ == "__main__":
    benchmark()
