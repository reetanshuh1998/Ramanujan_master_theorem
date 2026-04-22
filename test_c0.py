import mpmath
mpmath.mp.dps = 50

def c0_formula(s, msq):
    s_mp = mpmath.mpf(s)
    m2 = mpmath.mpf(msq)
    w = s_mp / (4 * m2)
    hyp = mpmath.hyp2f1(0.5, 0.5, 1.5, w)
    return - (1 / (2 * m2)) * hyp**2

print("C0 formula:  ", c0_formula(1.0, 1.0))
print("C0 reference:", -0.5483113556)
