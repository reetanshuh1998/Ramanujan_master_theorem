import pySecDec as psd
import os

# 1. Define the 2-loop Sunset Diagram
# The 'replacement_rules' must be defined HERE to transform p*p -> p_sq
夕 = psd.loop_integral.LoopIntegralFromGraph(
    internal_lines = [
        ['m1', [1, 2]],
        ['m2', [1, 2]],
        ['m3', [1, 2]]
    ],
    external_lines = [
        ['p', 1],
        ['-p', 2]
    ],
    replacement_rules = [
        ('p*p', 'psq')
    ]
)

# 2. Configure and Generate the Package
output_dir = 'pysecdec_sunset_lib'
if not os.path.exists(output_dir):
    psd.loop_package(
        name = output_dir,
        loop_integral = 夕,
        requested_orders = [0],
        real_parameters = ['m1', 'm2', 'm3', 'psq']
    )
    print(f"Package generated in {output_dir}")
else:
    print(f"Package already exists in {output_dir}")
