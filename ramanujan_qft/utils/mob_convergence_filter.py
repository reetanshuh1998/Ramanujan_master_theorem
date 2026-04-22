"""
mob_convergence_filter.py
=========================
Stage C of the Method of Brackets (MoB) Engine:
  Hypergeometric Convergence Filter (HCF)
"""

import math
from typing import Dict, List, Optional, Tuple, Union
import mpmath

def _to_mpf(x: Union[float, complex, str]) -> mpmath.mpf:
    if isinstance(x, complex):
        return mpmath.mpc(x.real, x.imag)
    return mpmath.mpf(str(x))

class HypergeometricConvergenceFilter:
    def __init__(self, precision: int = 50) -> None:
        self.precision = precision
        mpmath.mp.dps = precision

    @staticmethod
    def stirling_asymptotic_power(shifts_num: List[float],
                                  shifts_den: List[float]) -> int:
        return len(shifts_num) - len(shifts_den) - 1

    @staticmethod
    def stirling_exact_ratio(n: int,
                              shifts_num: List[float],
                              shifts_den: List[float],
                              x: Union[float, complex]) -> float:
        num = abs(x)
        for a in shifts_num:
            num *= abs(a + n)
        den = float(n + 1)
        for b in shifts_den:
            den *= abs(b + n)
        return num / den if den != 0 else float('inf')

    def check_convergence(self, shifts_num: List[float], shifts_den: List[float],
                          x: Union[float, complex], verbose: bool = False) -> Dict:
        mpmath.mp.dps = self.precision
        power = self.stirling_asymptotic_power(shifts_num, shifts_den)
        abs_x = abs(x)

        if power < 0:
            L = 0.0
            converges = True
            kind = 'absolute'
            desc = f"[HCF] p-q-1 = {power} < 0 => absolutely convergent for all x. L = 0."
        elif power == 0:
            L = abs_x
            converges = bool(abs_x < 1.0)
            verdict = 'CONVERGENT' if converges else 'DIVERGENT — analytic continuation needed'
            desc = f"[HCF] p-q-1 = 0 => ratio test: L = |x| = {abs_x:.8g}. {verdict}."
        else:
            L = float('inf')
            converges = False
            kind = 'divergent'
            desc = f"[HCF] p-q-1 = {power} > 0 => series diverges. Analytic continuation required."

        if power == 0:
            kind = 'conditional'

        result: Dict = {
            'converges': converges, 'L': L, 'power': power,
            'p': len(shifts_num), 'q': len(shifts_den),
            'type': kind, 'description': desc,
        }

        if verbose:
            n_test = 500
            r_exact = self.stirling_exact_ratio(n_test, shifts_num, shifts_den, x)
            r_pred = abs_x * (n_test ** power) if power != 0 else abs_x
            result['ratio_exact_at_500'] = float(r_exact)
            result['ratio_stirling_at_500'] = float(r_pred)
            denom = max(abs(r_pred), 1e-30)
            result['stirling_relative_error_at_500'] = abs(r_exact - r_pred) / denom

        return result

    def check_double_sum(self, params_n: Dict, params_k: Dict,
                         x: Union[float, complex], y: Union[float, complex]) -> Dict:
        res_n = self.check_convergence(params_n['shifts_num'], params_n['shifts_den'], x)
        res_k = self.check_convergence(params_k['shifts_num'], params_k['shifts_den'], y)
        joint = res_n['converges'] and res_k['converges']
        return {
            'joint_converges': joint, 'index_n': res_n, 'index_k': res_k,
            'description': f"Joint convergence: {'YES' if joint else 'NO'} (n: {res_n['type']}, k: {res_k['type']})",
        }

    def evaluate_series(self, shifts_num: List[float], shifts_den: List[float],
                        x: Union[float, complex], prefactor: Union[float, complex] = 1.0,
                        force: bool = False) -> Tuple[Optional[object], Dict]:
        mpmath.mp.dps = self.precision
        conv = self.check_convergence(shifts_num, shifts_den, x)

        if not conv['converges'] and not force:
            return None, conv

        x_mp = mpmath.mpc(x.real, x.imag) if isinstance(x, complex) else mpmath.mpf(str(x))
        a_list = [mpmath.mpf(str(a)) for a in shifts_num]
        b_list = [mpmath.mpf(str(b)) for b in shifts_den]

        def term(n: int) -> mpmath.mpf:
            n = int(n)
            try:
                num = mpmath.mpf(1)
                for a in a_list: num *= mpmath.gamma(a + n)
                den = mpmath.gamma(n + 1)
                for b in b_list: den *= mpmath.gamma(b + n)
                return (num / den) * mpmath.power(x_mp, n)
            except Exception:
                return mpmath.mpf(0)

        method = 'euler-maclaurin' if conv['converges'] else 'levin'
        result = mpmath.nsum(term, [0, mpmath.inf], method=method)

        pf = mpmath.mpc(prefactor.real, prefactor.imag) if isinstance(prefactor, complex) else mpmath.mpf(str(prefactor))
        return result * pf, conv

    def evaluate_pFq(self, a_params: List[float], b_params: List[float],
                     z: Union[float, complex]) -> Tuple[Optional[object], Dict]:
        mpmath.mp.dps = self.precision
        conv = self.check_convergence(a_params, b_params, z)

        z_mp = mpmath.mpc(z.real, z.imag) if isinstance(z, complex) else mpmath.mpf(str(z))
        a_mp = [mpmath.mpf(str(a)) for a in a_params]
        b_mp = [mpmath.mpf(str(b)) for b in b_params]

        try:
            result = mpmath.hyper(a_mp, b_mp, z_mp)
            if not conv['converges']:
                conv['note'] = 'mpmath analytic continuation applied (|z| >= 1)'
            return result, conv
        except Exception as exc:
            return None, {**conv, 'error': str(exc)}

    def compute_p126_regular_series(self, s_val: float, msq_val: float) -> Tuple[object, Dict]:
        mpmath.mp.dps = self.precision
        s = mpmath.mpf(str(s_val))
        m2 = mpmath.mpf(str(msq_val))
        z = m2 / (27 * s)
        
        triplication_const = (
            2 * mpmath.pi / (mpmath.power(3, mpmath.mpf('5') / 2) *
            mpmath.gamma(mpmath.mpf('4') / 3) * mpmath.gamma(mpmath.mpf('5') / 3))
        )

        shifts_num = [1.0, 1.0]
        shifts_den = [4.0 / 3, 5.0 / 3]

        conv = self.check_convergence(shifts_num, shifts_den, -z, verbose=True)
        val = mpmath.hyper([mpmath.mpf(1), mpmath.mpf(1)], [mpmath.mpf('4') / 3, mpmath.mpf('5') / 3], -z)

        result = triplication_const * val / s
        conv['z_argument'] = float(z)
        conv['2F2_value'] = complex(val)
        return result, conv

    def compute_p126_singular_logs(self, s_val: float, msq_val: float) -> object:
        mpmath.mp.dps = self.precision
        s = mpmath.mpf(str(s_val))
        m2 = mpmath.mpf(str(msq_val))

        log_ms = mpmath.log(s) + mpmath.mpc(0, mpmath.pi)
        ratio_log = log_ms - mpmath.log(m2)

        A = mpmath.mpf(-1) / (4 * s)
        B = mpmath.mpf(3) / (2 * s)
        return A * ratio_log ** 2 + B * ratio_log

    def compute_p126_eps0(self, s_val: float = 9.0, msq_val: float = 1.0) -> Tuple[object, Dict]:
        reg, conv = self.compute_p126_regular_series(s_val, msq_val)
        sing = self.compute_p126_singular_logs(s_val, msq_val)
        result = reg + sing
        info = {
            'regular_part': complex(reg), 'singular_part': complex(sing),
            'total': complex(result), 'convergence': conv,
        }
        return result, info

    def compute_p126_pole_terms(self, s_val: float, msq_val: float, eps_order: int) -> object:
        mpmath.mp.dps = self.precision
        s = mpmath.mpf(str(s_val))
        m2 = mpmath.mpf(str(msq_val))

        log_ms = mpmath.log(s) + mpmath.mpc(0, mpmath.pi)
        log_m2 = mpmath.log(m2)

        if eps_order == -2:
            c_eucl = mpmath.mpf(3) / (2 * s)
            return c_eucl
        elif eps_order == -1:
            c_eucl_m1 = mpmath.mpf(3) / (2 * s) * (log_m2 - log_ms)
            return c_eucl_m1
        else:
            raise ValueError(f"eps_order must be -2 or -1; got {eps_order}")

def apply_hcf_and_sum(shifts_num: List[float], shifts_den: List[float],
                      x: Union[float, complex], prefactor: Union[float, complex] = 1.0,
                      precision: int = 50) -> Tuple[Optional[object], Dict]:
    hcf = HypergeometricConvergenceFilter(precision=precision)
    return hcf.evaluate_series(shifts_num, shifts_den, x, prefactor=prefactor, force=False)
