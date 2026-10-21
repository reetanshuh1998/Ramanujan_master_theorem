#!/usr/bin/env bash
# Build LoopTools 2.16 (needs gfortran), then compare values and timings with ramanujan_qft.
#   bash benchmarks/looptools/compare_looptools.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="$HERE/_build"
mkdir -p "$BUILD"
cd "$BUILD"
if [ ! -d LoopTools-2.16 ]; then
  curl -fsSLO https://www.feynarts.de/looptools/LoopTools-2.16.tar.gz
  tar xzf LoopTools-2.16.tar.gz
fi
if [ ! -f inst/include/looptools.h ]; then
  (cd LoopTools-2.16 && ./configure --prefix="$BUILD/inst" >/dev/null && make -j4 >/dev/null && make install >/dev/null)
fi
LIBDIR="$(ls -d "$BUILD"/inst/lib* | head -1)"
gfortran -O2 -ffixed-line-length-none -I "$BUILD/inst/include" "$HERE/timing_driver.F" -o timing -L "$LIBDIR" -looptools
echo "== LoopTools"; ./timing | grep -E "C0|B0"
echo "== ramanujan_qft"
python3 - <<'PY'
import timeit
from ramanujan_qft import B0, C0
print("C0(0,0,10;1,2,3) =", C0(10, 1, 2, 3))
print("B0(5;1,1)        =", B0(5, 1, 1))
for dps in (15, 30, 50):
    n = 200
    tc = timeit.timeit(lambda: C0(10, 1, 2, 3, dps=dps), number=n) / n
    tb = timeit.timeit(lambda: B0(5, 1, 1, dps=dps), number=n) / n
    print(f"dps={dps}: C0 {tc*1e6:9.1f} us/call   B0 {tb*1e6:9.1f} us/call")
PY
