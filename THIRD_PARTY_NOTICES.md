# Third-Party Notices and Acknowledgements

This repository includes several vendored third-party codes to facilitate comparative benchmarking natively within the suite. These tools are strictly decoupled from the core `Ramanujan Algorithm Framework (RAF)` which is MIT Licensed. 

All third-party codes are stored inside the `third_party/` directory. By compiling or running these tools within the benchmark, you implicitly agree to their respective upstream licensing and redistribution notices.

### 1. FIESTA 4 & 5
* **Author(s)**: Alexander Smirnov
* **Path**: `third_party/fiesta-4.1/`, `third_party/fiesta-5.0/`
* **License**: GNU General Public License v3.0 (GPLv3)
* **Citation**: Smirnov, A. V. "FIESTA4: Optimized Feynman integral evaluation with sector decomposition" and subsequent versions.
* **Usage**: Provided as unmodified tarballs and local installations exclusively for the verification benchmarking `LocalToolManager`.

### 2. SecDec 3
* **Author(s)**: Sophia Borowka, Gudrun Heinrich, et al.
* **Path**: `third_party/SecDec-3.1.0/`
* **Citation**: Borowka, S., et al. "SecDec-3.0: numerical evaluation of multi-scale integrals beyond one loop."
* **Usage**: Provided for traditional algebraic and numerical integration benchmarking comparisons. Subject to the upstream academic distribution rules.

### 3. LoopTools
* **Author(s)**: Thomas Hahn
* **Path**: `third_party/LoopTools-2.16/`
* **License**: GNU Lesser General Public License (LGPL)
* **Usage**: Used for evaluating one-loop numerical tensor/scalar integrals.

---

> Note: If you plan to redistribute this repository, you must adhere strictly to the GPL/LGPL propagation requirements governing the `/third_party/` vendored code.
