# Ramanujan Extension: Unequal Mass $C_0$

When evaluating the scalar triangle $C_0$ with unequal internal masses ($m_1 \neq m_2 \neq m_3$), the standard Gauss $_2F_1$ hypergeometric reduction is no longer sufficient.

## The MoB Double Series (Appell $F_1$)
Using the Method of Brackets (MoB), the Feynman parameter simplex for unequal masses natively produces a **double hypergeometric series**. Specifically, it maps to the Appell $F_1$ function:

$$ C_0 = -\frac{1}{2 m_3^2} F_1\left(1, 1, 1; 2; 1 - \frac{m_1^2}{m_3^2}, 1 - \frac{m_2^2}{m_3^2}\right) $$

*(Note: The exact parameters depend on the momentum invariants $s$, but the structure is fundamentally $F_1$)*.

To analytically continue the Appell $F_1$ series into the Minkowski regime ($s > \text{threshold}$) strictly via Ramanujan principles (zero numerical integration), we face a choice:
1. Build a multi-variable algebraic phase-tracking engine for the Appell $F_1$ power series.
2. Utilize the exact algebraic reduction of $F_1$ to single-variable Polylogarithms.

## The Dilogarithm Reduction
The Appell $F_1$ series with these specific integer/half-integer parameters enjoys a mathematically exact reduction to sums of Dilogarithms ($\text{Li}_2(z)$), first categorized by 't Hooft and Veltman.

By mapping the Appell $F_1$ into $\text{Li}_2(z)$, we can achieve pure algebraic continuation by tracking the Minkowski $+i\epsilon$ phase through the fundamental inversion identity of the Dilogarithm:

$$ \text{Li}_2(z + i\epsilon) = -\text{Li}_2(1/z) - \frac{\pi^2}{6} - \frac{1}{2} \ln^2(-z+i\epsilon) $$

### Pure Phase Generation
Just like we did for $_2F_1$, the imaginary part (particle production cut) emerges instantly and exactly from the logarithm of a negative argument:

$$ \ln(-z+i\epsilon) = \ln|z| - i\pi \implies \text{Im}[\text{Li}_2(z)] = \pi \ln|z| $$

This completely bypasses numerical contour stitching.

## Implementation in RAF
I have already added the exact identity solver `algebraic_continuation_Li2(z)` to `RamanujanContinuationEngine`. 

To complete the solver in `feynman_mob_solver.py`, we construct the 't Hooft-Veltman rational roots $x_1, x_2$ and pass them through this Dilogarithm engine. This allows `RAF MoB` to rival LoopTools directly in Python without compiled Fortran, maintaining 100% Ramanujan integrity.
