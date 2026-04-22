#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cpu.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 1; }
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 2; }

extern "C" int
triangle1L_massive_pysecdec_integral__sector_3_order_0(
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
    const real_t msq = realp[1]; (void)msq;
    const real_t SecDecInternalLambda0 = deformp[0];
    const real_t SecDecInternalLambda1 = deformp[1];
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    resultvec_t acc = RESULTVEC_ZERO;
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    int_t li_x1 = mulmod(genvec[1], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[1], 1);
        auto w_x0 = korobov3x3_w(x0);
        auto w_x1 = korobov3x3_w(x1);
        realvec_t w = w_x0*w_x1;
        if (unlikely(index + 1 >= index2)) w.x[1] = 0;
        if (unlikely(index + 2 >= index2)) w.x[2] = 0;
        if (unlikely(index + 3 >= index2)) w.x[3] = 0;
        x0 = korobov3x3_f(x0);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = 2*msq;
        auto tmp1_2 = x0 + 1;
        auto tmp3_1 = msq*tmp1_2;
        auto tmp1_3 = x1*msq;
        auto tmp3_2 = tmp3_1 + tmp1_3;
        auto tmp3_3 = 2*tmp3_2;
        auto tmp1_4 = tmp3_3-s;
        auto tmp1_5 = 2*x1;
        auto tmp3_4 = tmp3_1*tmp1_5;
        auto tmp1_6 = tmp1_1-s;
        auto tmp1_7 = x0*tmp1_6;
        auto tmp3_5 = tmp3_4 + msq + tmp1_7;
        auto tmp3_6 = -1 + tmp1_5;
        auto tmp3_7 = SecDecInternalLambda1*tmp3_6;
        auto tmp3_8 = SecDecInternalLambda1*x1;
        auto tmp1_8 = SecDecInternalLambda0*x0;
        auto tmp1_9 = -1 + 2*x0;
        auto tmp3_9 = SecDecInternalLambda0*tmp1_9;
        auto __PowCall1 = SecDecInternalSqr(x0);
        auto __PowCall2 = SecDecInternalSqr(x1);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
        auto tmp2_4 = __PowCall2 + __PowCall1;
        auto tmp3_10 = msq*tmp2_4;
        auto tmp3_11 = tmp3_10 + tmp3_5;
        auto tmp2_5 = SecDecInternalLambda0*__PowCall1;
        auto tmp3_12 = -tmp1_8 + tmp2_5;
        auto tmp2_6 = SecDecInternalI(__RealPartCall1);
        auto tmp3_13 = tmp2_6*tmp3_12;
        auto tmp2_7 = SecDecInternalLambda1*__PowCall2;
        auto tmp3_14 = -tmp3_8 + tmp2_7;
        auto tmp3_15 = tmp2_6*tmp3_14;
        auto __RealPartCall2 = SecDecInternalRealPart(tmp1_4);
        auto __RealPartCall3 = SecDecInternalRealPart(tmp3_3);
        auto tmp3_16 = SecDecInternalLambda0*__PowCall1;
        auto tmp3_17 = tmp3_16-tmp1_8;
        auto tmp3_18 = SecDecInternalI(__RealPartCall2);
        auto tmp3_19 = tmp3_18*tmp3_17;
        auto tmp3_20 = x0 + tmp3_19;
        auto tmp2_8 = SecDecInternalI(__RealPartCall1);
        auto tmp3_21 = tmp2_8*tmp3_17;
        auto tmp3_22 = tmp3_9*tmp3_18;
        auto tmp3_23 = tmp3_22 + 1 + tmp3_21;
        auto tmp3_24 = SecDecInternalLambda1*__PowCall2;
        auto tmp3_25 = tmp3_24-tmp3_8;
        auto tmp2_9 = SecDecInternalI(__RealPartCall3);
        auto tmp2_10 = tmp2_9*tmp3_25;
        auto tmp3_26 = x1 + tmp2_10;
        auto tmp3_27 = tmp2_8*tmp3_25;
        auto tmp3_28 = tmp3_7*tmp2_9;
        auto tmp3_29 = tmp3_28 + 1 + tmp3_27;
        auto tmp3_30 = tmp3_20 + 1 + tmp3_26;
        auto tmp3_31 = -tmp3_13*tmp3_15;
        auto tmp3_32 = tmp3_23*tmp3_29;
        auto tmp3_33 = tmp3_31 + tmp3_32;
        auto __PowCall3 = SecDecInternalSqr(tmp3_20);
        auto __PowCall4 = SecDecInternalSqr(tmp3_26);
        auto tmp3_34 = tmp3_20 + 1;
        auto tmp3_35 = tmp3_34*tmp3_26*tmp1_1;
        auto tmp3_36 = __PowCall3 + __PowCall4 + 1;
        auto tmp3_37 = msq*tmp3_36;
        auto tmp3_38 = tmp1_6*tmp3_20;
        auto tmp3_39 = tmp3_38 + tmp3_37 + tmp3_35;
        auto __DenominatorCall1 = SecDecInternalDenominator(tmp3_30);
        auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_39);
        auto tmp3_40 = -tmp3_11 + tmp3_39;
        auto tmp3_41 = tmp3_33*__DenominatorCall1*__DenominatorCall2;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_40);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_42 = SecDecInternalRealPart(tmp3_30);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_42>=0), 1);
        acc = acc + w*(tmp3_41);
    }
    *presult = componentsum(acc);
    return 0;
}

#define SecDecInternalOutputDeformationParameters(i, v) deformp[i] = vec_min(deformp[i], v);

extern "C" void
triangle1L_massive_pysecdec_integral__sector_3_order_0__maxdeformp(
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
    const real_t msq = realp[1]; (void)msq;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    realvec_t deformp[2] = { REALVEC_CONST(10.0), REALVEC_CONST(10.0) };
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    int_t li_x1 = mulmod(genvec[1], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[1], 1);
        x0 = korobov3x3_f(x0);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = 2*msq;
        auto tmp1_2 = -x1-x0;
        auto tmp3_1 = x0*tmp1_2;
        auto tmp3_2 = tmp3_1 + 1 + x1;
        auto tmp3_3 = tmp3_2*tmp1_1;
        auto tmp1_3 = -1 + x0;
        auto tmp3_4 = s*tmp1_3;
        auto tmp3_5 = tmp3_4 + tmp3_3;
        auto tmp3_6 = x0*tmp3_5;
        auto tmp3_7 = SecDecInternalSqr(x1);
        auto tmp1_4 = 1-x1;
        auto tmp3_8 = x0*tmp1_4;
        auto tmp3_9 = tmp3_8 + 1-tmp3_7;
        auto tmp3_10 = tmp1_1*x1*tmp3_9;
        SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_6))));
        SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_10))));
    }
    maxdeformp[0] = componentmin(deformp[0]);
    maxdeformp[1] = componentmin(deformp[1]);
}

extern "C" int
triangle1L_massive_pysecdec_integral__sector_3_order_0__fpolycheck(
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
    const real_t msq = realp[1]; (void)msq;
    const real_t SecDecInternalLambda0 = deformp[0]; (void)SecDecInternalLambda0;
    const real_t SecDecInternalLambda1 = deformp[1]; (void)SecDecInternalLambda1;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    uint64_t index = index1;
    int_t li_x0 = mulmod(genvec[0], index, lattice);
    int_t li_x1 = mulmod(genvec[1], index, lattice);
    for (; index < index2; index += 4) {
        int_t li_x0_0 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_1 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_2 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        int_t li_x0_3 = li_x0; li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        realvec_t x0 = {{ li_x0_0*invlattice, li_x0_1*invlattice, li_x0_2*invlattice, li_x0_3*invlattice }};
        x0 = warponce(x0 + shift[0], 1);
        int_t li_x1_0 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_1 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_2 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        int_t li_x1_3 = li_x1; li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        realvec_t x1 = {{ li_x1_0*invlattice, li_x1_1*invlattice, li_x1_2*invlattice, li_x1_3*invlattice }};
        x1 = warponce(x1 + shift[1], 1);
        x0 = korobov3x3_f(x0);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = x0 + x1 + 1;
        auto tmp1_2 = 2*msq;
        auto tmp3_1 = tmp1_1*tmp1_2;
        auto tmp1_3 = -s + tmp3_1;
        auto tmp1_4 = -s + tmp1_2;
        auto tmp1_5 = -1 + x1;
        auto tmp3_2 = x1*SecDecInternalLambda1*tmp1_5;
        auto tmp1_6 = -1 + x0;
        auto tmp3_3 = x0*SecDecInternalLambda0*tmp1_6;
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_3);
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_1);
        auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_3;
        auto __Deformedx1Call = x1 + i_*__RealPartCall2*tmp3_2;
        auto fpoly_im = SecDecInternalImagPart(__Deformedx1Call*tmp1_2 + __Deformedx0Call*tmp1_4 + __Deformedx0Call*__Deformedx1Call*tmp1_2 + msq + msq*SecDecInternalSqr(__Deformedx1Call)+msq*SecDecInternalSqr(__Deformedx0Call));
        if (unlikely(!(fpoly_im <= 0))) return 1;
    }
    return 0;
}
