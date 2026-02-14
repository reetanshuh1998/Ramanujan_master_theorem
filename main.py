"""
Main entry point for demonstrating RMT superiority over numerical methods.
"""

import sys
from examples import run_all_tests


def main():
    """
    Main function to run the RMT comparison demonstration.
    """
    print("""
╔═══════════════════════════════════════════════════════════════════════════╗
║                  RAMANUJAN MASTER THEOREM DEMONSTRATION                   ║
║                                                                           ║
║  This program demonstrates that Ramanujan's Master Theorem (RMT) is      ║
║  superior to classical numerical integration methods for computing       ║
║  certain types of integrals.                                             ║
║                                                                           ║
║  The RMT states that if f(x) = Σ φ(n)(-x)^n/n!, then:                   ║
║  ∫₀^∞ x^(s-1) f(x) dx = Γ(s) φ(-s)                                       ║
║                                                                           ║
║  We compare RMT against:                                                 ║
║  - Trapezoidal Rule                                                      ║
║  - Simpson's Rule                                                        ║
║  - Scipy QUAD (Adaptive Quadrature)                                      ║
╚═══════════════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        run_all_tests()
    except KeyboardInterrupt:
        print("\n\nInterrupted by user.")
        sys.exit(0)
    except Exception as e:
        print(f"\n\nError occurred: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
