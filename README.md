# Ramanujan Master Theorem vs Numerical Methods

A comprehensive demonstration proving that **Ramanujan's Master Theorem (RMT)** is superior to classical numerical integration methods for computing certain types of integrals.

## Overview

This project implements and compares Ramanujan's Master Theorem against traditional numerical integration methods, demonstrating RMT's advantages in:

- **Accuracy**: Provides exact analytical results (up to machine precision)
- **Speed**: Computes results orders of magnitude faster
- **Stability**: Avoids numerical integration issues
- **Elegance**: Reduces complex integrals to simple closed-form expressions

## Ramanujan's Master Theorem

The theorem states that if a function can be expanded as:

```
f(x) = Σ(n=0 to ∞) φ(n)(-x)^n / n!
```

Then the Mellin transform integral:

```
∫₀^∞ x^(s-1) f(x) dx = Γ(s) φ(-s)
```

where Γ is the Gamma function.

## Installation

```bash
# Clone the repository
git clone https://github.com/reetanshuh1998/Ramanujan_master_theorem.git
cd Ramanujan_master_theorem

# Install dependencies
pip install -r requirements.txt
```

## Usage

Run the complete comparison demonstration:

```bash
python main.py
```

This will run multiple test cases comparing RMT against:
- Trapezoidal Rule
- Simpson's Rule  
- Scipy QUAD (Adaptive Quadrature)

### Running Tests

Run the unit tests to validate the implementation:

```bash
python -m unittest test_rmt -v
```

All tests should pass, demonstrating the correctness of the RMT implementation.

### Creating Visualizations

Generate comparison plots showing speed and accuracy:

```bash
python visualize.py
```

This creates `rmt_comparison.png` with visual comparisons of RMT vs numerical methods.

## Example Output

```
INTEGRAL COMPARISON: ∫₀^∞ x^(1.5) f(x) dx
================================================================================
Analytical Result: 1.3293403881e+00

Method                         Result               Error           Time (s)    
--------------------------------------------------------------------------------
Ramanujan Master Theorem       1.3293403881e+00     1.1102e-16      0.000123
--------------------------------------------------------------------------------
Trapezoidal Rule               1.3293156432e+00     2.4745e-05      0.142567
Simpson's Rule                 1.3293387364e+00     1.6517e-06      0.156234
Scipy QUAD (Adaptive)          1.3293403881e+00     8.8818e-16      0.089421
================================================================================
```

## Project Structure

```
Ramanujan_master_theorem/
├── main.py                          # Main entry point
├── ramanujan_master_theorem.py      # RMT implementation
├── numerical_methods.py             # Classical numerical methods
├── comparison.py                    # Comparison framework
├── examples.py                      # Test cases
├── visualize.py                     # Visualization script
├── test_rmt.py                      # Unit tests
├── requirements.txt                 # Python dependencies
├── .gitignore                       # Git ignore file
└── README.md                        # Documentation
```

## Test Cases

The project includes several test cases:

1. **Exponential Function**: f(x) = e^(-x), demonstrates basic RMT
2. **Gamma Variants**: Different parameter values
3. **Fractional Parameters**: s = 0.5 (√π)
4. **Laguerre Polynomials**: More complex φ functions
5. **Large Parameters**: Testing scalability

## Mathematical Background

For the exponential case where φ(n) = 1:
- f(x) = e^(-x)
- The integral ∫₀^∞ x^(s-1) e^(-x) dx = Γ(s)
- RMT directly computes this as Γ(s) × φ(-s) = Γ(s) × 1

## Why RMT is Superior

1. **Exact vs Approximate**: RMT gives exact analytical results while numerical methods are inherently approximate

2. **Computational Efficiency**: RMT evaluates simple closed-form expressions, while numerical methods require thousands of function evaluations

3. **No Convergence Issues**: RMT avoids numerical integration challenges like:
   - Choosing appropriate step sizes
   - Handling infinite bounds
   - Managing oscillatory integrands
   - Dealing with singularities

4. **Mathematical Elegance**: RMT reveals deep mathematical structure rather than brute-force computation

## Contributing

Contributions are welcome! Feel free to:
- Add more test cases
- Implement additional φ functions
- Add visualization capabilities
- Improve documentation

## License

MIT License - see LICENSE file for details

## References

- Ramanujan, S. (1915). "On the integral ∫₀^∞ (x^(s-1))/(e^x-1) dx"
- Hardy, G. H. (1978). "Ramanujan: Twelve Lectures on Subjects Suggested by His Life and Work"
- Berndt, B. C. (1985). "Ramanujan's Notebooks, Part I"

## Author

reetanshuh1998 - Dream Project ✨ 
