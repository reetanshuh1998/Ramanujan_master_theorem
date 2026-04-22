/*
 * looptools_wrapper.c
 * ====================
 * Minimal C wrapper around LoopTools Fortran library
 * to expose B0 and C0 functions via a shared library
 * that Python's ctypes can load.
 *
 * Fortran functions (with trailing underscore):
 *   ltini_()          — initialize
 *   ltexi_()          — finalize
 *   setmudim_(double*) — set μ²
 *   setdelta_(double*) — set Δ = 1/ε - γ + ln(4π) (0 for finite part)
 *   b0_(double*, double*, double*) → complex
 *   c0_(double*, double*, double*, double*, double*, double*) → complex
 */
#include <complex.h>

/* Fortran function declarations (name-mangled with trailing _) */
extern void ltini_(void);
extern void ltexi_(void);
extern void setmudim_(double *mudim);
extern void setdelta_(double *delta);

/* B0(p², m1², m2²) → complex  (LoopTools returns as double[2]) */
extern void bput_(double complex *result, double *p, double *m1, double *m2);

/* C0(p1², p2², p3², m1², m2², m3²) → complex */
extern void cput_(double complex *result,
                  double *p1, double *p2, double *p3,
                  double *m1, double *m2, double *m3);

/* ═══ Python-callable wrapper functions ═══ */

void lt_init(void) {
    ltini_();
}

void lt_exit(void) {
    ltexi_();
}

void lt_set_mudim(double mu2) {
    setmudim_(&mu2);
}

void lt_set_delta(double delta) {
    setdelta_(&delta);
}

/* B0(p², m1², m2²) → writes Re, Im into result[0], result[1] */
void lt_B0(double psq, double m1sq, double m2sq,
           double *re, double *im) {
    double complex res;
    /* LoopTools B function: result array has Nbb entries,
       B0 is at index 0 */
    double complex cache[36];  /* Nbb = 36 */
    bput_(cache, &psq, &m1sq, &m2sq);
    res = cache[0];  /* bb0 = 0 → B0 */
    *re = creal(res);
    *im = cimag(res);
}

/* C0(p1², p2², p3², m1², m2², m3²) → writes Re, Im */
void lt_C0(double p1sq, double p2sq, double p3sq,
           double m1sq, double m2sq, double m3sq,
           double *re, double *im) {
    double complex cache[63];  /* Ncc = 63 */
    cput_(cache, &p1sq, &p2sq, &p3sq, &m1sq, &m2sq, &m3sq);
    double complex res = cache[0];  /* cc0 = 0 → C0 */
    *re = creal(res);
    *im = cimag(res);
}
