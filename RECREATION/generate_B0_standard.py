"""Generate pySecDec library for the standard B₀ in D=4-2ε."""
import pySecDec as psd

if __name__ == "__main__":
    li = psd.LoopIntegralFromGraph(
        internal_lines=[
            ['m1', [1, 2]],
            ['m2', [2, 1]]
        ],
        external_lines=[['p1', 1], ['p2', 2]],
        replacement_rules=[
            ('p1*p1', 'psq'), ('p2*p2', 'psq'), ('p1*p2', '-psq'),
            ('m1**2', 'msq'), ('m2**2', 'msq')
        ]
        # Default: D = 4-2*eps
    )
    psd.loop_package(
        name='B0_standard_pysecdec',
        loop_integral=li,
        real_parameters=['psq', 'msq'],
        requested_orders=[0],
        decomposition_method='geometric'
    )
