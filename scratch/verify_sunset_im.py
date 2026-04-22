import mpmath

def sunset_numerical_im(s, m1sq, m2sq, m3sq):
    # Direct 2D integral of the imaginary part of the propagator
    # We use the spectral representation or direct Feynman integral with i-epsilon
    eps = 1e-6
    def integrand(x1, x2):
        x3 = 1 - x1 - x2
        U = x1*x2 + x2*x3 + x3*x1
        F = -s*x1*x2*x3 + (m1sq*x1 + m2sq*x2 + m3sq*x3)*U
        # Im [ 1 / (F - i*eps) ] = pi * delta(F)
        # This is hard to quad directly. 
        # Better use the 1-loop bubble spectral density:
        return 0 # Placeholder

    # Let's use the Bubble spectral density integration (The Global Residue proof)
    def lambda_func(a, b, c):
        return a**2 + b**2 + c**2 - 2*a*b - 2*b*c - 2*c*a

    def phase_space(t, m2sq, m3sq):
        l = lambda_func(t, m2sq, m3sq)
        if l < 0: return 0
        return mpmath.sqrt(l) / t

    def spectral_integrand(t):
        # 1-loop bubble Im part
        im_bubble = phase_space(t, m2sq, m3sq)
        # 1-loop bubble Re part (not needed for Im sunset)
        
        # Threshold condition for the outer loop
        l_outer = lambda_func(s, t, m1sq)
        if l_outer < 0: return 0
        return im_bubble * mpmath.sqrt(l_outer)

    lower = (mpmath.sqrt(m2sq) + mpmath.sqrt(m3sq))**2
    upper = (mpmath.sqrt(s) - mpmath.sqrt(m1sq))**2
    
    # Normalization for Sunset (2-loop)
    # The spectral relation is: Im S(s) = (1/16s) * Integral rho(t) * lambda(s,t,m1^2)^0.5
    res = mpmath.quad(spectral_integrand, [lower, upper])
    return (mpmath.pi / (16 * s)) * res

s = 100
m_sq = [1, 2, 3]
val = sunset_numerical_im(s, m_sq[0], m_sq[1], m_sq[2])
print(f"Spectral Im S: {val}")
