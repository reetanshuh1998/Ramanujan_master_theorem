"""
mob_convergence_filter.py
=========================
Stage C of the Method of Brackets (MoB) Engine:
  Hypergeometric Convergence Filter (HCF)
"""

import math
from typing import Dict, List, Optional, Tuple, Union
import functools

import mpmath

def _to_mpf(x: Union[float, complex, str]) -> mpmath.mpf:
    if isinstance(x, complex):
        return mpmath.mpc(x.real, x.imag)
    return mpmath.mpf(str(x))

def _with_precision(method):
    """Run a method at self.precision without changing the global mpmath context."""
    @functools.wraps(method)
    def wrapper(self, *args, **kwargs):
        with mpmath.workdps(self.precision):
            return method(self, *args, **kwargs)
    return wrapper


class HypergeometricConvergenceFilter:
    def __init__(self, precision: int = 50) -> None:
        self.precision = precision

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

    @_with_precision
    def check_convergence(self, shifts_num: List[float], shifts_den: List[float],
                          x: Union[float, complex], verbose: bool = False) -> Dict:
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
            kind = 'conditional' if converges else 'divergent'

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

    @_with_precision
    def evaluate_series(self, shifts_num: List[float], shifts_den: List[float],
                        x: Union[float, complex], prefactor: Union[float, complex] = 1.0,
                        force: bool = False) -> Tuple[Optional[object], Dict]:
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

        # term() is defined on integers only, so use integer-sampling methods
        method = 'r+s' if conv['converges'] else 'levin'
        result = mpmath.nsum(term, [0, mpmath.inf], method=method)

        pf = mpmath.mpc(prefactor.real, prefactor.imag) if isinstance(prefactor, complex) else mpmath.mpf(str(prefactor))
        return result * pf, conv

    @_with_precision
    def evaluate_pFq(self, a_params: List[float], b_params: List[float],
                     z: Union[float, complex]) -> Tuple[Optional[object], Dict]:
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

    _P126_MSG = ("The P126 routines of version 0.1 used hard-coded logarithm coefficients "
                 "(A = -1/(4s), B = 3/(2s)) and a fixed +i*pi phase, which gives a spurious imaginary "
                 "part in the Euclidean region; the results did not match pySecDec. They are "
                 "withdrawn until derived and validated - see AUDIT.md.")

    def compute_p126_regular_series(self, s_val, msq_val):
        raise NotImplementedError(self._P126_MSG)

    def compute_p126_singular_logs(self, s_val, msq_val):
        raise NotImplementedError(self._P126_MSG)

    def compute_p126_eps0(self, s_val=9.0, msq_val=1.0):
        raise NotImplementedError(self._P126_MSG)

    def compute_p126_pole_terms(self, s_val, msq_val, eps_order):
        raise NotImplementedError(self._P126_MSG)

def apply_hcf_and_sum(shifts_num: List[float], shifts_den: List[float],
                      x: Union[float, complex], prefactor: Union[float, complex] = 1.0,
                      precision: int = 50) -> Tuple[Optional[object], Dict]:
    hcf = HypergeometricConvergenceFilter(precision=precision)
    return hcf.evaluate_series(shifts_num, shifts_den, x, prefactor=prefactor, force=False)
