import mpmath

class RMTAtlas:
    """
    Registry of Mellin Transforms for Atomic Physics Building Blocks.
    Used by the RamanujanFramework to solve product integrals analytically.
    """

    @staticmethod
    def get_transform(func_type, params):
        """
        Returns a lambda M(s) for the given function type and parameters.
        """
        if func_type == 'exponential':
            # f(x) = exp(-k*x) => M(s) = k^-s * Gamma(s)
            k = mpmath.mpf(str(params['k']))
            return lambda s: mpmath.power(k, -s) * mpmath.gamma(s)

        if func_type == 'bessel_j0':
            # f(x) = J0(b*x) => M(s) = (2^(s-1) / b^s) * Gamma(s/2) / Gamma(1 - s/2)
            b = mpmath.mpf(str(params['b']))
            return lambda s: (mpmath.power(2, s - 1) / mpmath.power(b, s)) * \
                             (mpmath.gamma(s/2) / mpmath.gamma(1 - s/2))

        if func_type == 'gaussian':
            # f(x) = exp(-a*x^2) => M(s) = 0.5 * a^(-s/2) * Gamma(s/2)
            a = mpmath.mpf(str(params['a']))
            return lambda s: 0.5 * mpmath.power(a, -s/2) * mpmath.gamma(s/2)

        if func_type == 'inverse_power':
            # f(x) = (x + m)^-v => M(s) = m^(s-v) * Gamma(s) * Gamma(v-s) / Gamma(v)
            m = mpmath.mpf(str(params['m']))
            v = mpmath.mpf(str(params['v']))
            return lambda s: mpmath.power(m, s - v) * mpmath.gamma(s) * mpmath.gamma(v - s) / mpmath.gamma(v)

        if func_type == 'elliptic_pre':
            # M(s) for a component leading to elliptic integrals (e.g. K(k))
            # Simplified model for benchmark discovery
            return lambda s: mpmath.power(mpmath.pi, -s/2) * mpmath.gamma(s/2)**2 / mpmath.gamma(s)

        return None
