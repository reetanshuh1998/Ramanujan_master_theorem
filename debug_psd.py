import pySecDec as psd
import os

lib_path = os.path.abspath('pysecdec_sunset_benchmark/pysecdec_sunset_lib/pysecdec_sunset_lib.so')
psd_lib = psd.integral_interface.IntegralLibrary(lib_path)
res = psd_lib(real_parameters=[1.0, 1.0, 1.0, -1.0])
print(f"Type: {type(res[0])}")
print(f"Content: {res[0]}")
print(f"Dir: {dir(res[0])}")
