import pySecDec as psd

def generate_bubble():
    # 1-loop bubble graph
    internal_lines = [
        ['1', [0, 1]], # propagator 1
        ['2', [1, 0]], # propagator 2
    ]
    external_lines = [
        ['p1', [0]],
        ['p2', [1]]
    ]
    # Kinematics: p1^2 = p^2, m1=1, m2=1
    # Actually wait, we can just use loop_integral
    from pySecDec.loop_integral import LoopIntegralFromGraph
    li = LoopIntegralFromGraph(
        internal_lines=internal_lines,
        external_lines=external_lines,
        replacement_rules=[
            ('p1*p1', 's'),
            ('p2*p2', 's'),
            ('p1*p2', '-s'),
            ('m1sq', 'msq'),
            ('m2sq', 'msq')
        ],
        propagator_masses=['m1sq', 'm2sq']
    )
    # the integral in D=3
    psd.loop_package(
        name='bubble_1L_lib',
        loop_integral=li,
        real_parameters=['s', 'msq'],
        dimensionality='3-2*eps',
        functions=[],
        requested_order=0
    )

if __name__ == '__main__':
    generate_bubble()
