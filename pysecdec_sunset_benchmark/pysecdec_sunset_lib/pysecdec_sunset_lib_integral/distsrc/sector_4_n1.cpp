#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cpu.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 1; }
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 2; }

extern "C" int
pysecdec_sunset_lib_integral__sector_4_order_n1(
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
    const real_t m1 = realp[0]; (void)m1;
    const real_t m2 = realp[1]; (void)m2;
    const real_t m3 = realp[2]; (void)m3;
    const real_t psq = realp[3]; (void)psq;
    const real_t SecDecInternalLambda1 = deformp[0];
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    resultvec_t acc = RESULTVEC_ZERO;
    uint64_t index = index1;
    int_t li_x1 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[0], 1);
        auto w_x1 = korobov3x3_w(x1);
        realvec_t w = w_x1;
        if (unlikely(index + 1 >= index2)) w.x[1] = 0;
        if (unlikely(index + 2 >= index2)) w.x[2] = 0;
        if (unlikely(index + 3 >= index2)) w.x[3] = 0;
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = -x1*psq;
        auto tmp1_2 = x1 + 1;
        auto tmp1_3 = x1*SecDecInternalLambda1;
        auto tmp1_4 = -SecDecInternalLambda1 + 2*tmp1_3;
        auto __PowCall1 = SecDecInternalSqr(x1);
        auto __PowCall2 = SecDecInternalSqr(m1);
        auto __PowCall3 = SecDecInternalSqr(m2);
        auto __PowCall4 = SecDecInternalSqr(m3);
        auto tmp2_2 = tmp1_2*__PowCall3;
        auto __RealPartCall1 = SecDecInternalRealPart(__PowCall3);
        auto tmp2_3 = SecDecInternalLambda1*__PowCall1;
        auto tmp3_1 = -tmp1_3 + tmp2_3;
        auto tmp2_4 = SecDecInternalI(__RealPartCall1);
        auto tmp3_2 = tmp2_4*tmp3_1;
        auto tmp3_3 = x1 + tmp3_2;
        auto tmp3_4 = tmp1_4*tmp2_4;
        auto tmp3_5 = 1 + tmp3_4;
        auto tmp3_6 = tmp3_3 + 1;
        auto tmp3_7 = __PowCall3*tmp3_6;
        auto __PowCall5 = SecDecInternalSqr(tmp3_6)*tmp3_6;
        auto __DenominatorCall1 = SecDecInternalDenominator(__PowCall5);
        auto tmp3_8 = tmp3_7-tmp2_2;
        auto tmp3_9 = tmp3_5*__DenominatorCall1*tmp3_7;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_8);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_10 = SecDecInternalRealPart(tmp3_6);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_10>=0), 1);
        acc = acc + w*(tmp3_9);
    }
    *presult = componentsum(acc);
    return 0;
}

#define SecDecInternalOutputDeformationParameters(i, v) deformp[i] = vec_min(deformp[i], v);

extern "C" void
pysecdec_sunset_lib_integral__sector_4_order_n1__maxdeformp(
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
    const real_t m1 = realp[0]; (void)m1;
    const real_t m2 = realp[1]; (void)m2;
    const real_t m3 = realp[2]; (void)m3;
    const real_t psq = realp[3]; (void)psq;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    realvec_t deformp[1] = { REALVEC_CONST(10.0) };
    uint64_t index = index1;
    int_t li_x1 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[0], 1);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = 1-x1;
        auto tmp3_1 = x1*tmp1_1*SecDecInternalSqr(m2);
        SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_1))));
    }
    maxdeformp[0] = componentmin(deformp[0]);
}

extern "C" int
pysecdec_sunset_lib_integral__sector_4_order_n1__fpolycheck(
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
    const real_t m1 = realp[0]; (void)m1;
    const real_t m2 = realp[1]; (void)m2;
    const real_t m3 = realp[2]; (void)m3;
    const real_t psq = realp[3]; (void)psq;
    const real_t SecDecInternalLambda1 = deformp[0]; (void)SecDecInternalLambda1;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    uint64_t index = index1;
    int_t li_x1 = mulmod(genvec[0], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[0], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[0], 1);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = SecDecInternalSqr(m2);
        auto tmp1_2 = -1 + x1;
        auto tmp3_1 = SecDecInternalLambda1*x1*tmp1_2;
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
        auto __Deformedx1Call = x1 + i_*__RealPartCall1*tmp3_1;
        auto fpoly_im = SecDecInternalImagPart(tmp1_1 + __Deformedx1Call*tmp1_1);
        if (unlikely(!(fpoly_im <= 0))) return 1;
    }
    return 0;
}
