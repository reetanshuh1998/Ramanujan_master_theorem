"""
Comparison Framework: RMT vs Numerical Methods
"""

import time
import numpy as np
from typing import Callable, Dict, List, Tuple
from ramanujan_master_theorem import RamanujanMasterTheorem
from numerical_methods import NumericalIntegration, create_integrand


class IntegralComparison:
    """
    Compare RMT against classical numerical methods.
    """
    
    def __init__(self, phi: Callable[[float], float], s: float, 
                 analytical_result: float = None, max_terms: int = 50):
        """
        Initialize comparison framework.
        
        Args:
            phi: Coefficient function φ(n)
            s: Parameter in the integral
            analytical_result: Known analytical result (if available)
            max_terms: Maximum terms for series evaluation
        """
        self.phi = phi
        self.s = s
        self.analytical_result = analytical_result
        self.max_terms = max_terms
        self.rmt = RamanujanMasterTheorem(phi, max_terms)
    
    def run_rmt(self) -> Dict:
        """
        Run RMT computation.
        
        Returns:
            Dictionary with results
        """
        start_time = time.time()
        try:
            result = self.rmt.compute_integral(self.s)
            computation_time = time.time() - start_time
            
            error = None
            if self.analytical_result is not None:
                error = abs(result - self.analytical_result)
            
            return {
                'method': 'Ramanujan Master Theorem',
                'result': result,
                'time': computation_time,
                'error': error,
                'status': 'success'
            }
        except Exception as e:
            return {
                'method': 'Ramanujan Master Theorem',
                'result': None,
                'time': time.time() - start_time,
                'error': None,
                'status': f'failed: {e}'
            }
    
    def run_numerical_methods(self, upper_bound: float = 50.0, 
                             n_points: int = 1000,
                             use_direct_function: Callable[[float], float] = None) -> List[Dict]:
        """
        Run various numerical integration methods.
        
        Args:
            upper_bound: Upper bound for integration (approximating infinity)
            n_points: Number of points for numerical methods
            use_direct_function: If provided, use this function instead of series expansion
            
        Returns:
            List of result dictionaries
        """
        if use_direct_function is not None:
            # Use the direct closed-form function for fair comparison
            def integrand(x):
                if x <= 0:
                    return 0.0
                try:
                    return (x ** (self.s - 1)) * use_direct_function(x)
                except (OverflowError, ValueError):
                    return 0.0
        else:
            integrand = create_integrand(self.phi, self.s, self.max_terms)
        
        num_int = NumericalIntegration(integrand)
        
        results = []
        
        # Trapezoidal Rule
        start_time = time.time()
        try:
            result, method = num_int.trapezoidal_rule(0.0001, upper_bound, n_points)
            computation_time = time.time() - start_time
            error = abs(result - self.analytical_result) if self.analytical_result is not None else None
            results.append({
                'method': method,
                'result': result,
                'time': computation_time,
                'error': error,
                'status': 'success'
            })
        except Exception as e:
            results.append({
                'method': 'Trapezoidal Rule',
                'result': None,
                'time': time.time() - start_time,
                'error': None,
                'status': f'failed: {e}'
            })
        
        # Simpson's Rule
        start_time = time.time()
        try:
            result, method = num_int.simpsons_rule(0.0001, upper_bound, n_points)
            computation_time = time.time() - start_time
            error = abs(result - self.analytical_result) if self.analytical_result is not None else None
            results.append({
                'method': method,
                'result': result,
                'time': computation_time,
                'error': error,
                'status': 'success'
            })
        except Exception as e:
            results.append({
                'method': "Simpson's Rule",
                'result': None,
                'time': time.time() - start_time,
                'error': None,
                'status': f'failed: {e}'
            })
        
        # Scipy QUAD with infinity support
        start_time = time.time()
        try:
            import scipy.integrate as integrate
            result, error_est = integrate.quad(integrand, 0, np.inf)
            computation_time = time.time() - start_time
            error = abs(result - self.analytical_result) if self.analytical_result is not None else None
            results.append({
                'method': 'Scipy QUAD (∞)',
                'result': result,
                'time': computation_time,
                'error': error,
                'status': 'success'
            })
        except Exception as e:
            results.append({
                'method': 'Scipy QUAD (∞)',
                'result': None,
                'time': time.time() - start_time,
                'error': None,
                'status': f'failed: {e}'
            })
        
        return results
    
    def compare_all(self, upper_bound: float = 50.0, 
                   n_points: int = 1000,
                   use_direct_function: Callable[[float], float] = None) -> Dict:
        """
        Run complete comparison between RMT and numerical methods.
        
        Args:
            upper_bound: Upper bound for numerical integration
            n_points: Number of points for numerical methods
            use_direct_function: If provided, use this for numerical integration
            
        Returns:
            Dictionary containing all results
        """
        rmt_result = self.run_rmt()
        numerical_results = self.run_numerical_methods(upper_bound, n_points, use_direct_function)
        
        return {
            'rmt': rmt_result,
            'numerical': numerical_results,
            'analytical': self.analytical_result
        }
    
    def print_comparison(self, results: Dict):
        """
        Print formatted comparison results.
        
        Args:
            results: Results dictionary from compare_all()
        """
        print("\n" + "="*80)
        print(f"INTEGRAL COMPARISON: ∫₀^∞ x^({self.s}-1) f(x) dx")
        print("="*80)
        
        if results['analytical'] is not None:
            print(f"\nAnalytical Result: {results['analytical']:.10e}")
        
        print("\n" + "-"*80)
        print(f"{'Method':<30} {'Result':<20} {'Error':<15} {'Time (s)':<12}")
        print("-"*80)
        
        # RMT result
        rmt = results['rmt']
        if rmt['status'] == 'success':
            error_str = f"{rmt['error']:.4e}" if rmt['error'] is not None else "N/A"
            print(f"{rmt['method']:<30} {rmt['result']:.10e} {error_str:<15} {rmt['time']:.6f}")
        else:
            print(f"{rmt['method']:<30} {'FAILED':<20} {rmt['status']}")
        
        print("-"*80)
        
        # Numerical results
        for num_result in results['numerical']:
            if num_result['status'] == 'success':
                error_str = f"{num_result['error']:.4e}" if num_result['error'] is not None else "N/A"
                print(f"{num_result['method']:<30} {num_result['result']:.10e} {error_str:<15} {num_result['time']:.6f}")
            else:
                print(f"{num_result['method']:<30} {'FAILED':<20} {num_result['status']}")
        
        print("="*80)
        
        # Summary
        if rmt['status'] == 'success' and results['analytical'] is not None:
            print("\nSUMMARY:")
            print(f"  RMT Error: {rmt['error']:.4e}")
            print(f"  RMT Time: {rmt['time']:.6f} seconds")
            
            # Find best numerical method
            successful_numerical = [r for r in results['numerical'] if r['status'] == 'success' and r['error'] is not None]
            if successful_numerical:
                best_numerical = min(successful_numerical, key=lambda x: x['error'])
                print(f"  Best Numerical Method: {best_numerical['method']}")
                print(f"  Best Numerical Error: {best_numerical['error']:.4e}")
                print(f"  Best Numerical Time: {best_numerical['time']:.6f} seconds")
                
                speedup = best_numerical['time'] / rmt['time']
                accuracy_ratio = best_numerical['error'] / rmt['error'] if rmt['error'] > 0 else float('inf')
                
                print(f"\n  RMT is {speedup:.2f}x FASTER than best numerical method")
                print(f"  RMT is {accuracy_ratio:.2f}x MORE ACCURATE than best numerical method")
        
        print("="*80 + "\n")
