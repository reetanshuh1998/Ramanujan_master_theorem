# Prior art and originality

This page lists the mathematical methods and prior software used by
`ramanujan_qft`, based on the October 2026 literature review.

## Summary

| Part of `ramanujan_qft` | Status | Closest prior art |
|---|---|---|
| Ramanujan's Master Theorem (`rmt`) | classical (1910s; proof by Hardy) | Amdeberhan et al. 2012 |
| Mellin residue engine RACE (`mellin.product_integral`) | **known method** | Marichev; Adamchik–Marichev 1990; Slater's theorem; Fikioris 2007; SymPy `meijerint`; mpmath `meijerg` |
| "Taylor coefficients = residues of the Mellin transform" | known | Ramanujan / Hardy; Flajolet–Gourdon–Dumas 1995 |
| Choosing which side to close the contour; perturbing at coinciding poles | known | mpmath `meijerg` (`series=1/2`), `hypercomb`; MBConicHulls |
| RMT / Method of Brackets for Feynman integrals | known | Gonzalez–Moll–Schmidt 2015; Prausa 2017; Gonzalez–Kondrashuk–Moll–Recabarren 2022 |
| B0 as Γ(ε)(m²)^(−ε) ₂F₁(ε,1;3/2;w) and its ε-expansion | known | standard one-loop literature (Boos–Davydychev and later) |
| C0(0,0,s; m,m,m) = −(2/s) arcsin²(√(s/4m²)) | known | Higgs → γγ triangle function |
| 't Hooft–Veltman C0 | known | 't Hooft & Veltman 1979; Denner 1993; LoopTools |
| Sunset Im part as a phase-space integral; twice-subtracted dispersion relation | known | dispersive two-loop literature; TSIL computes the sunset for arbitrary masses |
| MoB series for the sunset with three masses | known | Ananthanarayan–Friot–Ghosh 2020 |

The package implements established methods. Its contributions are the
Python interfaces, numerical evaluation and validation:

* an arbitrary-precision Mellin residue evaluator in Python;
* an *a-priori* check of which expansion closes the contour legitimately, plus
  cancellation control and explicit errors for unmet accuracy targets
  (`SeriesConvergenceError`, `ValueError`);
* LoopTools-convention one-loop functions with adjustable precision;
* a test suite validated against LoopTools and independent integrations.

The implementation does not establish a new integration identity or a general
performance advantage over existing tools.

## The Mellin-convolution method (what RACE implements)

* O. I. Marichev, *Handbook of Integral Transforms of Higher Transcendental
  Functions: Theory and Algorithmic Tables*, Ellis Horwood, 1983 (Russian
  original 1978). This is the algorithmic method: write the integral as a
  Mellin convolution of Meijer-G functions and expand the resulting G-function
  into residue series (Slater's theorem). Its history is recounted in
  *Oleg Marichev: On the occasion of the eightieth anniversary*,
  [arXiv:2509.25246](https://arxiv.org/abs/2509.25246).
* V. S. Adamchik, O. I. Marichev, *The algorithm for calculating integrals of
  hypergeometric type functions and its realization in REDUCE system*,
  Proc. ISSAC '90 (Tokyo), ACM 1990, pp. 212–224. This is the
  computer-algebra realisation, which also underlies Mathematica's definite
  integration.
  ([REDUCE bibliography](https://reduce-algebra.sourceforge.io/bibliography.php))
* A. P. Prudnikov, Yu. A. Brychkov, O. I. Marichev, *Integrals and Series,
  Vol. 3: More Special Functions*, Gordon & Breach, 1990. Tables and validity
  conditions for ∫ G·G dx.
* G. Fikioris, *Mellin-Transform Method for Integral Evaluation: Introduction
  and Applications to Electromagnetics*, Morgan & Claypool, 2007,
  DOI 10.2200/S00076ED1V01Y200612CEM013.
* N. Bleistein, R. A. Handelsman, *Asymptotic Expansions of Integrals*, Holt,
  Rinehart & Winston, 1975 (Dover 1986). Mellin-convolution asymptotics. See also [DLMF §2.5](https://dlmf.nist.gov/2.5).
* Ph. Flajolet, X. Gourdon, P. Dumas, *Mellin transforms and asymptotics:
  Harmonic sums*, Theor. Comput. Sci. 144 (1995) 3–58. This is the
  correspondence between expansions and poles (direct and converse mapping).
* G. Lovat, S. Celozzi, *Rapidly convergent series and closed-form expressions
  for a class of integrals involving products of spherical Bessel functions*,
  J. Comput. Appl. Math. 445 (2024) 115802. It reports residue-type series
  "at least 1000 times faster than specific quadrature schemes", for the
  inputs studied in that paper.
* **Software.**
  * SymPy `sympy.integrals.meijerint`: symbolic integration by Mellin
    convolution of Meijer-G functions (Luke §5.6.2; Prudnikov–Brychkov–Marichev;
    K. Roach).
  * mpmath `meijerg`: numerical G-function by Slater series, selecting
    `series=1` or `2` (closing the contour on either side); `hypercomb` perturbs
    parameters at raised precision when poles coincide.
  * In tests, SymPy returns exact closed forms in 0.03–0.4 s for the atlas pairs,
    e.g. ∫e^(−x²)cos x dx = √π e^(−1/4)/2 and ∫J₀(x)cos(x/2) dx = 2√3/3.

## Ramanujan's Master Theorem and the Method of Brackets in HEP

* T. Amdeberhan, O. Espinosa, I. Gonzalez, M. Harrison, V. H. Moll, A. Straub,
  *Ramanujan's Master Theorem*, Ramanujan J. 29 (2012) 103.
* I. Gonzalez, V. H. Moll, I. Schmidt, *Ramanujan's Master Theorem applied to
  the evaluation of Feynman diagrams*, Adv. Appl. Math. 63 (2015) 214.
* I. Gonzalez, L. Jiu, V. H. Moll, *An extension of the method of brackets.
  Part 2*, Open Math. 18 (2020) 983–995, DOI 10.1515/math-2020-0062. Combines
  the method of brackets with the Mellin transform of a second factor, which is
  RACE's "expand one factor, use the Mellin transform of the other".
* M. Prausa, *Mellin–Barnes meets Method of Brackets: a novel approach to
  Mellin–Barnes representations of Feynman integrals*, Eur. Phys. J. C 77 (2017)
  594, [arXiv:1706.09852](https://arxiv.org/abs/1706.09852).
* I. Gonzalez, I. Kondrashuk, V. H. Moll, L. M. Recabarren, *Mellin–Barnes
  integrals and the method of brackets*, Eur. Phys. J. C 82 (2022),
  DOI 10.1140/epjc/s10052-021-09977-x, [arXiv:2108.09421](https://arxiv.org/abs/2108.09421).
* Z. P. Bradshaw, O. Atale, *A generalized Ramanujan Master Theorem and integral
  representation of meromorphic functions*, [arXiv:2408.08725](https://arxiv.org/abs/2408.08725).
* B. Ananthanarayan, S. Banik, S. Friot, S. Ghosh, *Multiple series
  representations of N-fold Mellin–Barnes integrals*, Phys. Rev. Lett. 127
  (2021) 151601, [arXiv:2012.15108](https://arxiv.org/abs/2012.15108)
  (MBConicHulls; resonant/logarithmic cases included).
* B. Ananthanarayan, S. Friot, S. Ghosh, *New series representations for the
  two-loop massive sunset diagram*, Eur. Phys. J. C 80 (2020),
  [arXiv:1911.10096](https://arxiv.org/abs/1911.10096).
* S. Friot, D. Greynat, E. de Rafael, *Asymptotics of Feynman diagrams and the
  Mellin–Barnes representation*, [hep-ph/0505038](https://arxiv.org/abs/hep-ph/0505038).

## Mellin–Barnes and other HEP integral tools

* M. Czakon, *Automatized analytic continuation of Mellin–Barnes integrals*
  (MB.m), Comput. Phys. Commun. 175 (2006) 559,
  [hep-ph/0511200](https://arxiv.org/abs/hep-ph/0511200).
* M. Ochman, T. Riemann, *MBsums – a Mathematica package for the representation
  of Mellin–Barnes integrals by multiple sums*, Acta Phys. Polon. B 46 (2015)
  2117, [arXiv:1511.01323](https://arxiv.org/abs/1511.01323). Contour closing
  plus residue sums inside a HEP tool.
* S. P. Martin, D. G. Robertson, *TSIL: a program for the calculation of
  two-loop self-energy integrals*, Comput. Phys. Commun. (2006),
  DOI 10.1016/j.cpc.2005.08.005, [hep-ph/0501132](https://arxiv.org/abs/hep-ph/0501132).

## Research directions

Extensions need explicit convergence arguments and independent benchmarks
against tools suited to the target integrals, such as AMFlow, pySecDec, FIESTA,
TSIL and Mellin–Barnes packages. Possible directions include:

1. **An open-source Python counterpart of MBConicHulls / MBsums.**
   Automatically derive and sum the convergent multiple series of N-fold
   Mellin–Barnes representations of Feynman integrals, with certified error
   control. MBConicHulls and MBsums are Mathematica packages.
2. **Crossing convergence boundaries in physical kinematics.** Stitch series
   from different regions, or hand exact series values to
   differential-equation solvers as high-precision boundary data. This is a
   recognised bottleneck.
3. **Products of three or more factors** that are not a product of two Meijer-G
   functions (bivariate Fox-H). Possible targets
   are configuration-space propagators, Bessel moments, and Hankel transforms
   of power spectra.
4. **Rigorous foundations of the Method of Brackets.** Prove when its heuristic
   rules agree with the Mellin–Barnes / residue answer.

## Attribution and performance claims

Cite the software version and the mathematical methods used in a calculation.
Performance comparisons should specify inputs, precision, accuracy checks and
work budgets; measurements on selected products do not rank whole libraries.
