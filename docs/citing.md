# Citing and dedication

## Citing ramanujan-qft

If ramanujan-qft helps your work, please cite the software:

```bibtex
@software{ramanujan_qft,
  author  = {Reet},
  title   = {ramanujan-qft: Ramanujan's Master Theorem, Mellin residue summation
             and arbitrary-precision Feynman integrals},
  version = {0.3.0rc1.dev1},
  year    = {2026},
  url     = {https://github.com/reetanshuh1998/Ramanujan_master_theorem},
  license = {MIT}
}
```

The repository also has a
[`CITATION.cff`](https://github.com/reetanshuh1998/Ramanujan_master_theorem/blob/main/CITATION.cff)
file, from which GitHub generates citations in other formats ("Cite this
repository" on the repository page).

## Cite the methods too

The methods implemented here are classical. Please also cite the work they come
from, as appropriate for what you used ({doc}`PRIOR_ART` has the full review):

**Ramanujan's Master Theorem**

* G. H. Hardy, *Ramanujan: Twelve Lectures on Subjects Suggested by His Life and
  Work*, Cambridge University Press, 1940, chapter XI.
* T. Amdeberhan, O. Espinosa, I. Gonzalez, M. Harrison, V. H. Moll, A. Straub,
  *Ramanujan's Master Theorem*, Ramanujan J. 29 (2012) 103.

**Mellin residue summation (`product_integral`)**

* O. I. Marichev, *Handbook of Integral Transforms of Higher Transcendental
  Functions: Theory and Algorithmic Tables*, Ellis Horwood, 1983.
* V. S. Adamchik, O. I. Marichev, *The algorithm for calculating integrals of
  hypergeometric type functions and its realization in REDUCE system*, Proc.
  ISSAC '90 (Tokyo), ACM 1990, pp. 212–224.
* G. Fikioris, *Mellin-Transform Method for Integral Evaluation: Introduction and
  Applications to Electromagnetics*, Morgan & Claypool, 2007.

**The Method of Brackets for Feynman integrals (`B0_mob`, `C0_mob`)**

* I. Gonzalez, V. H. Moll, I. Schmidt, *Ramanujan's Master Theorem applied to the
  evaluation of Feynman diagrams*, Adv. Appl. Math. 63 (2015) 214.

**One-loop integrals and conventions (`B0`, `C0`)**

* G. 't Hooft, M. Veltman, *Scalar one-loop integrals*, Nucl. Phys. B 153 (1979) 365.
* T. Hahn, M. Pérez-Victoria, *Automatized one-loop calculations in four and D
  dimensions*, Comput. Phys. Commun. 118 (1999) 153.

**Two-loop sunset**

* A. I. Davydychev, J. B. Tausk, *Two-loop self-energy diagrams with different
  masses and the momentum expansion*, Nucl. Phys. B 397 (1993) 123.
* S. Laporta, E. Remiddi, *Analytic treatment of the two loop equal mass sunrise
  graph*, [hep-ph/0406160](https://arxiv.org/abs/hep-ph/0406160).
* S. Müller-Stach, S. Weinzierl, R. Zayadeh, *A second-order differential equation
  for the two-loop sunrise graph with arbitrary masses*,
  [arXiv:1112.4360](https://arxiv.org/abs/1112.4360).
* B. Ananthanarayan, S. Friot, S. Ghosh, *New Series Representations for the
  Two-Loop Massive Sunset Diagram*, [arXiv:1911.10096](https://arxiv.org/abs/1911.10096).

**Arbitrary-precision arithmetic**

* The mpmath development team, *mpmath: a Python library for arbitrary-precision
  floating-point arithmetic*, <https://mpmath.org>.

## In memory of Srinivasa Ramanujan

Srinivasa Ramanujan (1887–1920) stated the Master Theorem in his quarterly
reports to the University of Madras. G. H. Hardy made it widely known, with a
proof under explicit conditions, in *Ramanujan: Twelve Lectures* (1940). The
theorem turns an integral into the evaluation of Taylor coefficients, and that
idea runs through every module of this package.

ramanujan-qft is dedicated to his memory. The implementation follows the
classical methods cited on the {doc}`PRIOR_ART` page. Reference calculations,
regression tests and documented numerical limits accompany the implementation.

The citation above identifies this unreleased development version. For results
obtained with the published alpha, cite version 0.3.0a5 instead.
