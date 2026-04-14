import numpy as np
from scipy import integrate

def integrand(x):
    return np.exp(-x) * np.cos(100000 * x)

# truncate infinity (bad idea)
result, error = integrate.quad(integrand, 0, 50)

print("Naive Result:", result)
print("Error:", error)