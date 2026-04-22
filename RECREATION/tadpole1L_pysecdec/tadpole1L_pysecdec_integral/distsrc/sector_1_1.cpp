#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cpu.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 1; }
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 2; }

extern "C" int
tadpole1L_pysecdec_integral__sector_1_order_1(
    result_t * restrict presult,
    const uint64_t lattice,
    const uint64_t index1,
    const uint64_t index2,
    const uint64_t * restrict genvec,
    const real_t * restrict shift,
    const real_t * restrict realp,
    const complex_t * restrict complexp,
    const real_t * restrict deformp
)
{
    const real_t msq = realp[0]; (void)msq;
    const real_t SecDecInternalLambda0 = deformp[0];
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    resultvec_t acc = RESULTVEC_ZERO;
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        auto w_x0 = korobov3x3_w(x0);
        realvec_t w = w_x0;
        if (unlikely(index + 1 >= index2)) w.x[1] = 0;
        if (unlikely(index + 2 >= index2)) w.x[2] = 0;
        if (unlikely(index + 3 >= index2)) w.x[3] = 0;
        x0 = korobov3x3_f(x0);
        auto _logCall1 = SecDecInternalLog(-msq);
        auto tmp2_1 = msq*1*_logCall1;
        auto _SignCheckExpression = SecDecInternalRealPart(1);
        SecDecInternalSignCheckPositivePolynomial(!(_SignCheckExpression>=0), 1);
        acc = acc + w*(tmp2_1);
    }
    *presult = componentsum(acc);
    return 0;
}

#define SecDecInternalOutputDeformationParameters(i, v) deformp[i] = vec_min(deformp[i], v);

extern "C" void
tadpole1L_pysecdec_integral__sector_1_order_1__maxdeformp(
    real_t * restrict maxdeformp,
    const uint64_t lattice,
    const uint64_t index1,
    const uint64_t index2,
    const uint64_t * restrict genvec,
    const real_t * restrict shift,
    const real_t * restrict realp,
    const complex_t * restrict complexp
)
{
    const real_t msq = realp[0]; (void)msq;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    realvec_t deformp[1] = { REALVEC_CONST(10.0) };
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        x0 = korobov3x3_f(x0);
        SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(0))));
    }
    maxdeformp[0] = componentmin(deformp[0]);
}

extern "C" int
tadpole1L_pysecdec_integral__sector_1_order_1__fpolycheck(
    const uint64_t lattice,
    const uint64_t index1,
    const uint64_t index2,
    const uint64_t * restrict genvec,
    const real_t * restrict shift,
    const real_t * restrict realp,
    const complex_t * restrict complexp,
    const real_t * restrict deformp
)
{
    const real_t msq = realp[0]; (void)msq;
    const real_t SecDecInternalLambda0 = deformp[0]; (void)SecDecInternalLambda0;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        x0 = korobov3x3_f(x0);
        auto tmp1_1 = -1 + x0;
        auto tmp3_1 = SecDecInternalLambda0*x0*tmp1_1;
        auto __RealPartCall1 = SecDecInternalRealPart(0);
        auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_1;
        auto fpoly_im = SecDecInternalImagPart(-msq);
        if (unlikely(!(fpoly_im <= 0))) return 1;
    }
    return 0;
}
