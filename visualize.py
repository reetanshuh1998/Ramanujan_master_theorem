"""
Visualization of RMT vs Numerical Methods Performance

Creates plots comparing speed and accuracy of RMT vs numerical methods.
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy.special import gamma

from ramanujan_master_theorem import example_phi_exponential
from comparison import IntegralComparison


def create_comparison_plots():
    """Create visualization plots comparing RMT and numerical methods."""
    
    # Test different values of s
    s_values = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
    
    rmt_times = []
    rmt_errors = []
    numerical_times = []
    numerical_errors = []
    
    print("Running comparisons for plotting...")
    for s in s_values:
        print(f"  Testing s = {s}...")
        analytical = gamma(s)
        
        comparison = IntegralComparison(
            phi=example_phi_exponential,
            s=s,
            analytical_result=analytical
        )
        
        results = comparison.compare_all(
            upper_bound=30.0,
            n_points=2000,
            use_direct_function=lambda x: np.exp(-x)
        )
        
        rmt_times.append(results['rmt']['time'])
        rmt_errors.append(results['rmt']['error'] if results['rmt']['error'] is not None else 1e-16)
        
        # Get Scipy QUAD results
        scipy_result = [r for r in results['numerical'] if 'QUAD' in r['method']][0]
        numerical_times.append(scipy_result['time'])
        numerical_errors.append(scipy_result['error'] if scipy_result['error'] is not None else 1e-16)
    
    # Create figure with subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Computation Time Comparison
    x = np.arange(len(s_values))
    width = 0.35
    
    ax1.bar(x - width/2, rmt_times, width, label='RMT', alpha=0.8, color='green')
    ax1.bar(x + width/2, numerical_times, width, label='Scipy QUAD', alpha=0.8, color='blue')
    ax1.set_xlabel('Parameter s', fontsize=12)
    ax1.set_ylabel('Computation Time (seconds)', fontsize=12)
    ax1.set_title('Speed Comparison: RMT vs Numerical Integration', fontsize=14, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels([f'{s:.1f}' for s in s_values])
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')
    
    # Plot 2: Accuracy Comparison
    ax2.semilogy(s_values, rmt_errors, 'o-', label='RMT', linewidth=2, markersize=8, color='green')
    ax2.semilogy(s_values, numerical_errors, 's-', label='Scipy QUAD', linewidth=2, markersize=8, color='blue')
    ax2.set_xlabel('Parameter s', fontsize=12)
    ax2.set_ylabel('Absolute Error', fontsize=12)
    ax2.set_title('Accuracy Comparison: RMT vs Numerical Integration', fontsize=14, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=1e-15, color='r', linestyle='--', alpha=0.5, label='Machine Precision')
    
    plt.tight_layout()
    plt.savefig('rmt_comparison.png', dpi=300, bbox_inches='tight')
    print("\nPlot saved as 'rmt_comparison.png'")
    plt.show()
    
    # Print summary statistics
    print("\n" + "="*60)
    print("SUMMARY STATISTICS")
    print("="*60)
    print(f"Average RMT time: {np.mean(rmt_times):.6f} seconds")
    print(f"Average Numerical time: {np.mean(numerical_times):.6f} seconds")
    print(f"Average speedup: {np.mean(numerical_times) / np.mean(rmt_times):.2f}x")
    print(f"\nAverage RMT error: {np.mean(rmt_errors):.2e}")
    print(f"Average Numerical error: {np.mean(numerical_errors):.2e}")
    print("="*60)


if __name__ == "__main__":
    create_comparison_plots()
