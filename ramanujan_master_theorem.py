"""
Ramanujan Master Theorem Implementation

The Ramanujan Master Theorem states that if a function f(x) can be expanded as:
f(x) = Σ(n=0 to ∞) φ(n)(-x)^n / n!

Then:
∫(0 to ∞) x^(s-1) f(x) dx = Γ(s) φ(-s)

where Γ is the Gamma function.
"""

import numpy as np
from scipy.special import gamma, factorial
from typing import Callable, Tuple


class RamanujanMasterTheorem:
    """
    Implementation of Ramanujan's Master Theorem for computing integrals.
    """
    
    def __init__(self, phi: Callable[[float], float], max_terms: int = 50):
        """
        Initialize RMT calculator.
        
        Args:
            phi: The coefficient function φ(n) in the series expansion
            max_terms: Maximum number of terms to use in series evaluation
        """
        self.phi = phi
        self.max_terms = max_terms
    
    def compute_integral(self, s: float) -> float:
        """
        Compute the integral ∫(0 to ∞) x^(s-1) f(x) dx using RMT.
        
        Args:
            s: Parameter in the integral
            
        Returns:
            The value of the integral
        """
        try:
            gamma_s = gamma(s)
            phi_neg_s = self.phi(-s)
            return gamma_s * phi_neg_s
        except (ValueError, OverflowError) as e:
            raise ValueError(f"RMT computation failed for s={s}: {e}")
    
    def evaluate_f(self, x: float, terms: int = None) -> float:
        """
        Evaluate f(x) = Σ φ(n)(-x)^n / n! for verification.
        
        Args:
            x: Point at which to evaluate
            terms: Number of terms (defaults to max_terms)
            
        Returns:
            Value of f(x)
        """
        if terms is None:
            terms = self.max_terms
        
        result = 0.0
        for n in range(terms):
            try:
                term = self.phi(n) * ((-x) ** n) / factorial(n)
                result += term
                # Early termination if converged
                if abs(term) < 1e-15:
                    break
            except (OverflowError, ValueError):
                break
        
        return result


def example_phi_exponential(n: float) -> float:
    """
    Example φ(n) = 1 for all n.
    This gives f(x) = e^(-x), and the integral should be Γ(s).
    """
    return 1.0


def example_phi_bessel(n: float) -> float:
    """
    Example for modified Bessel function.
    φ(n) = 1/Γ(n+1)^2
    """
    try:
        return 1.0 / (gamma(n + 1) ** 2)
    except (OverflowError, ValueError):
        return 0.0


def example_phi_laguerre(alpha: float):
    """
    Generate φ for Laguerre polynomials.
    φ(n) = Γ(n+α+1)/Γ(n+1)
    """
    def phi(n: float) -> float:
        try:
            return gamma(n + alpha + 1) / gamma(n + 1)
        except (OverflowError, ValueError):
            return 0.0
    return phi
