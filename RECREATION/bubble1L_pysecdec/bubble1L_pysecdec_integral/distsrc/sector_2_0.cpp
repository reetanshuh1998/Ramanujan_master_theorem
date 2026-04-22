#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cpu.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 1; }
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 2; }

extern "C" int
bubble1L_pysecdec_integral__sector_2_order_0(
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
    const real_t s = realp[0]; (void)s;
    const real_t m1sq = realp[1]; (void)m1sq;
    const real_t m2sq = realp[2]; (void)m2sq;
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
        auto tmp1_1 = 2*m1sq;
        auto tmp1_2 = -s + m1sq + m2sq;
        auto tmp1_3 = 2*x0;
        auto tmp3_1 = m1sq*tmp1_3;
        auto tmp3_2 = tmp3_1 + tmp1_2;
        auto tmp1_4 = x0*tmp1_2;
        auto tmp3_3 = m2sq + tmp1_4;
        auto tmp1_5 = x0*SecDecInternalLambda0;
        auto tmp1_6 = -SecDecInternalLambda0 + 2*tmp1_5;
        auto __PowCall2 = SecDecInternalSqr(x0);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
        auto tmp3_4 = m1sq*__PowCall2;
        auto tmp3_5 = tmp3_3 + tmp3_4;
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_2);
        auto tmp2_3 = SecDecInternalLambda0*__PowCall2;
        auto tmp3_6 = tmp2_3-tmp1_5;
        auto tmp2_4 = SecDecInternalI(__RealPartCall2);
        auto tmp2_5 = tmp2_4*tmp3_6;
        auto tmp3_7 = x0 + tmp2_5;
        auto tmp3_8 = SecDecInternalI(tmp3_6*__RealPartCall1);
        auto tmp3_9 = tmp1_6*tmp2_4;
        auto tmp3_10 = tmp3_9 + 1 + tmp3_8;
        auto tmp3_11 = 1 + tmp3_7;
        auto __PowCall3 = SecDecInternalSqr(tmp3_7);
        auto tmp3_12 = tmp3_7*tmp1_2;
        auto tmp3_13 = m1sq*__PowCall3;
        auto tmp3_14 = tmp3_13 + tmp3_12 + m2sq;
        auto __DenominatorCall1 = SecDecInternalDenominator(tmp3_11);
        auto __PowCall1 = SecDecInternalPow(tmp3_14, -SecDecInternalQuo(1, 2));
        auto tmp3_15 = -tmp3_5 + tmp3_14;
        auto tmp3_16 = tmp3_10*__PowCall1*__DenominatorCall1;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_15);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_17 = SecDecInternalRealPart(tmp3_11);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_17>=0), 1);
        acc = acc + w*(tmp3_16);
    }
    *presult = componentsum(acc);
    return 0;
}

#define SecDecInternalOutputDeformationParameters(i, v) deformp[i] = vec_min(deformp[i], v);

extern "C" void
bubble1L_pysecdec_integral__sector_2_order_0__maxdeformp(
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
    const real_t s = realp[0]; (void)s;
    const real_t m1sq = realp[1]; (void)m1sq;
    const real_t m2sq = realp[2]; (void)m2sq;
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
        auto tmp1_1 = -2*x0 + 1;
        auto tmp3_1 = m1sq*tmp1_1;
        auto tmp1_2 = m2sq-s;
        auto tmp3_2 = -tmp1_2 + tmp3_1;
        auto tmp3_3 = x0*tmp3_2;
        auto tmp3_4 = tmp3_3 + m1sq + tmp1_2;
        auto tmp3_5 = x0*tmp3_4;
        SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_5))));
    }
    maxdeformp[0] = componentmin(deformp[0]);
}

extern "C" int
bubble1L_pysecdec_integral__sector_2_order_0__fpolycheck(
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
    const real_t s = realp[0]; (void)s;
    const real_t m1sq = realp[1]; (void)m1sq;
    const real_t m2sq = realp[2]; (void)m2sq;
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
        auto tmp1_1 = 1 + 2*x0;
        auto tmp3_1 = m1sq*tmp1_1;
        auto tmp1_2 = s-m2sq;
        auto tmp3_2 = -tmp1_2 + tmp3_1;
        auto tmp3_3 = m1sq-tmp1_2;
        auto tmp1_3 = -1 + x0;
        auto tmp3_4 = SecDecInternalLambda0*x0*tmp1_3;
        auto __RealPartCall1 = SecDecInternalRealPart(tmp3_2);
        auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_4;
        auto fpoly_im = SecDecInternalImagPart(__Deformedx0Call*tmp3_3 + m2sq + m1sq*SecDecInternalSqr(__Deformedx0Call));
        if (unlikely(!(fpoly_im <= 0))) return 1;
    }
    return 0;
}
