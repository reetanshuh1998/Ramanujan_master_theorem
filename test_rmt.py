"""
Unit tests for Ramanujan Master Theorem implementation
"""

import unittest
import numpy as np
from scipy.special import gamma

from ramanujan_master_theorem import (
    RamanujanMasterTheorem,
    example_phi_exponential,
    example_phi_bessel,
    example_phi_laguerre
)
from numerical_methods import NumericalIntegration
from comparison import IntegralComparison


class TestRamanujanMasterTheorem(unittest.TestCase):
    """Test cases for RMT implementation."""
    
    def test_exponential_case(self):
        """Test φ(n) = 1 gives Γ(s)."""
        rmt = RamanujanMasterTheorem(example_phi_exponential)
        s = 2.5
        result = rmt.compute_integral(s)
        expected = gamma(s)
        self.assertAlmostEqual(result, expected, places=10)
    
    def test_exponential_evaluation(self):
        """Test that f(x) evaluation gives e^(-x)."""
        rmt = RamanujanMasterTheorem(example_phi_exponential)
        x = 1.0
        result = rmt.evaluate_f(x, terms=100)
        expected = np.exp(-x)
        self.assertAlmostEqual(result, expected, places=10)
    
    def test_multiple_s_values(self):
        """Test RMT for various s values."""
        rmt = RamanujanMasterTheorem(example_phi_exponential)
        for s in [0.5, 1.0, 2.0, 3.5, 5.0]:
            result = rmt.compute_integral(s)
            expected = gamma(s)
            self.assertAlmostEqual(result, expected, places=10)


class TestNumericalMethods(unittest.TestCase):
    """Test cases for numerical integration methods."""
    
    def test_trapezoidal_simple(self):
        """Test trapezoidal rule on simple function."""
        def f(x):
            return x**2
        
        num_int = NumericalIntegration(f)
        result, _ = num_int.trapezoidal_rule(0, 1, 1000)
        expected = 1.0 / 3.0
        self.assertAlmostEqual(result, expected, places=3)
    
    def test_simpsons_simple(self):
        """Test Simpson's rule on simple function."""
        def f(x):
            return x**2
        
        num_int = NumericalIntegration(f)
        result, _ = num_int.simpsons_rule(0, 1, 1000)
        expected = 1.0 / 3.0
        self.assertAlmostEqual(result, expected, places=5)
    
    def test_scipy_quad_simple(self):
        """Test scipy quad on exponential."""
        def f(x):
            return np.exp(-x)
        
        num_int = NumericalIntegration(f)
        result, _ = num_int.scipy_quad(0, 10)
        expected = 1 - np.exp(-10)
        self.assertAlmostEqual(result, expected, places=8)


class TestComparison(unittest.TestCase):
    """Test cases for comparison framework."""
    
    def test_comparison_runs(self):
        """Test that comparison framework runs without errors."""
        s = 2.5
        analytical = gamma(s)
        
        comparison = IntegralComparison(
            phi=example_phi_exponential,
            s=s,
            analytical_result=analytical
        )
        
        # Just test it runs without errors
        rmt_result = comparison.run_rmt()
        self.assertEqual(rmt_result['status'], 'success')
        self.assertIsNotNone(rmt_result['result'])
    
    def test_rmt_accuracy(self):
        """Test RMT provides exact results."""
        s = 2.5
        analytical = gamma(s)
        
        comparison = IntegralComparison(
            phi=example_phi_exponential,
            s=s,
            analytical_result=analytical
        )
        
        rmt_result = comparison.run_rmt()
        self.assertAlmostEqual(rmt_result['result'], analytical, places=10)
        self.assertLess(rmt_result['error'], 1e-10)


class TestExamples(unittest.TestCase):
    """Test example phi functions."""
    
    def test_phi_exponential(self):
        """Test exponential phi returns 1."""
        for n in range(10):
            self.assertEqual(example_phi_exponential(n), 1.0)
    
    def test_phi_laguerre(self):
        """Test Laguerre phi function."""
        alpha = 2.0
        phi = example_phi_laguerre(alpha)
        
        # Test a few values
        for n in range(5):
            result = phi(n)
            expected = gamma(n + alpha + 1) / gamma(n + 1)
            self.assertAlmostEqual(result, expected, places=10)


if __name__ == '__main__':
    unittest.main()
