import numpy as np
from scipy import integrate

# integrand
def f(x):
    return x**6 * np.sin(x**8)

# integrate with upper cutoff (infinity truncated)
result, error = integrate.quad(f, 0, 10, limit=200)

print("Numerical result:", result)
print("Estimated error:", error)