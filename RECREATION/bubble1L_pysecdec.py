import pySecDec as psd

if __name__ == "__main__":
    li = psd.LoopIntegralFromGraph(
        internal_lines = [
            ['m1', [1, 2]],
            ['m2', [2, 1]]
        ],
        external_lines = [['p1', 1], ['p2', 2]],
        replacement_rules = [
            ('p1*p1', 's'), ('p2*p2', 's'), ('p1*p2', '-s'),
            ('m1**2', 'm1sq'), ('m2**2', 'm2sq')
        ],
        dimensionality='3-2*eps' # Ensure we match the D=3 configuration
    )

    psd.loop_package(
        name = 'bubble1L_pysecdec',
        loop_integral = li,
        real_parameters = ['s', 'm1sq', 'm2sq'],
        requested_orders = [0],
        decomposition_method = 'geometric'
    )
