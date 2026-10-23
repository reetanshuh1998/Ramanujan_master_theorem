# Third-party acknowledgements

The current source tree does not bundle third-party integration tools, their
source archives, binaries, or reference-paper PDFs. Earlier repository history
contains the former benchmark installations.

The optional `benchmarks/looptools/compare_looptools.sh` downloads LoopTools 2.16
from its upstream distribution into an ignored build directory. LoopTools is
Thomas Hahn's software and retains its upstream license and notices.

Python dependencies are declared in `pyproject.toml` and installed separately.
Scientific methods and external tools are credited in [Prior art](docs/PRIOR_ART.md)
and the [comparison guide](docs/COMPARISON.md). Historical comparisons with
FIESTA and SecDec do not make those tools dependencies of this package.
