"""Generate pySecDec libraries for the benchmark ladder."""
import pySecDec as psd

# ─── 1-loop Tadpole ────────────────────────────────────────────
print("Generating tadpole1L...")
li_tad = psd.LoopIntegralFromPropagators(
    loop_momenta=['k'],
    propagators=['k**2 + msq'],
    replacement_rules=[],
)
psd.loop_package(
    name='tadpole1L_pysecdec',
    loop_integral=li_tad,
    real_parameters=['msq'],
    requested_orders=[0],
    decomposition_method='geometric',
)
print("  tadpole1L done.")

# ─── 1-loop Massive Triangle ──────────────────────────────────
print("Generating triangle1L_massive...")
li_tri = psd.LoopIntegralFromGraph(
    internal_lines=[
        ['m', [1, 2]], ['m', [2, 3]], ['m', [3, 1]]
    ],
    external_lines=[['p1', 1], ['p2', 2], ['p3', 3]],
    replacement_rules=[
        ('p1*p1', '0'), ('p2*p2', '0'), ('p3*p3', 's'),
        ('p1*p2', 's/2'), ('p2*p3', '-s/2'), ('p1*p3', '-s/2'),
        ('m**2', 'msq')
    ]
)
psd.loop_package(
    name='triangle1L_massive_pysecdec',
    loop_integral=li_tri,
    real_parameters=['s', 'msq'],
    requested_orders=[0],
    decomposition_method='geometric',
)
print("  triangle1L_massive done.")
