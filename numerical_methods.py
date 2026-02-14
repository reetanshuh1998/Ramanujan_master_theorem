"""
Classical Numerical Integration Methods for Comparison
"""

import numpy as np
from typing import Callable, Tuple
from scipy import integrate


class NumericalIntegration:
    """
    Classical numerical integration methods for comparison with RMT.
    """
    
    def __init__(self, f: Callable[[float], float]):
        """
        Initialize numerical integration methods.
        
        Args:
            f: Function to integrate
        """
        self.f = f
    
    def trapezoidal_rule(self, a: float, b: float, n: int = 1000) -> Tuple[float, str]:
        """
        Trapezoidal rule for numerical integration.
        
        Args:
            a: Lower bound
            b: Upper bound
            n: Number of subdivisions
            
        Returns:
            Tuple of (result, method_name)
        """
        x = np.linspace(a, b, n + 1)
        y = np.array([self.f(xi) for xi in x])
        h = (b - a) / n
        result = h * (0.5 * y[0] + np.sum(y[1:-1]) + 0.5 * y[-1])
        return result, "Trapezoidal Rule"
    
    def simpsons_rule(self, a: float, b: float, n: int = 1000) -> Tuple[float, str]:
        """
        Simpson's rule for numerical integration.
        
        Args:
            a: Lower bound
            b: Upper bound
            n: Number of subdivisions (must be even)
            
        Returns:
            Tuple of (result, method_name)
        """
        if n % 2 != 0:
            n += 1
        
        x = np.linspace(a, b, n + 1)
        y = np.array([self.f(xi) for xi in x])
        h = (b - a) / n
        
        result = h / 3 * (y[0] + 4 * np.sum(y[1:-1:2]) + 2 * np.sum(y[2:-1:2]) + y[-1])
        return result, "Simpson's Rule"
    
    def gaussian_quadrature(self, a: float, b: float, n: int = 50) -> Tuple[float, str]:
        """
        Gaussian quadrature using scipy.
        
        Args:
            a: Lower bound
            b: Upper bound
            n: Number of points
            
        Returns:
            Tuple of (result, method_name)
        """
        try:
            result, _ = integrate.fixed_quad(self.f, a, b, n=n)
            return result, "Gaussian Quadrature"
        except Exception as e:
            return float('nan'), f"Gaussian Quadrature (failed: {e})"
    
    def scipy_quad(self, a: float, b: float) -> Tuple[float, str]:
        """
        Scipy's adaptive quadrature (QUADPACK).
        
        Args:
            a: Lower bound
            b: Upper bound
            
        Returns:
            Tuple of (result, method_name)
        """
        try:
            result, error = integrate.quad(self.f, a, b)
            return result, "Scipy QUAD (Adaptive)"
        except Exception as e:
            return float('nan'), f"Scipy QUAD (failed: {e})"
    
    def monte_carlo(self, a: float, b: float, n: int = 100000) -> Tuple[float, str]:
        """
        Monte Carlo integration.
        
        Args:
            a: Lower bound
            b: Upper bound
            n: Number of random samples
            
        Returns:
            Tuple of (result, method_name)
        """
        rng = np.random.default_rng(42)  # Create generator for reproducibility
        x_random = rng.uniform(a, b, n)
        y_values = np.array([self.f(x) for x in x_random])
        result = (b - a) * np.mean(y_values)
        return result, "Monte Carlo"


def create_integrand(phi_func: Callable[[float], float], s: float, 
                     max_terms: int = 50) -> Callable[[float], float]:
    """
    Create the integrand x^(s-1) * f(x) where f(x) = Σ φ(n)(-x)^n/n!
    
    Args:
        phi_func: The φ function
        s: Parameter for x^(s-1)
        max_terms: Maximum terms in series
        
    Returns:
        Function representing the integrand
    """
    from ramanujan_master_theorem import RamanujanMasterTheorem
    
    rmt = RamanujanMasterTheorem(phi_func, max_terms)
    
    def integrand(x: float) -> float:
        if x <= 0:
            return 0.0
        try:
            f_x = rmt.evaluate_f(x)
            return (x ** (s - 1)) * f_x
        except (OverflowError, ValueError):
            return 0.0
    
    return integrand
