#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cpu.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 1; }
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {*presult = REAL_NAN; return 2; }

extern "C" int
pysecdec_sunset_lib_integral__sector_4_order_1(
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
        auto tmp1_1 = 2*x0;
        auto tmp1_2 = tmp1_1 + 1;
        auto tmp1_3 = 2*x1;
        auto tmp1_4 = tmp1_3 + 1;
        auto tmp1_5 = x0*x1;
        auto tmp1_6 = 4*tmp1_5 + tmp1_4;
        auto tmp1_7 = psq*x0;
        auto tmp1_8 = 1 + x0;
        auto tmp3_1 = x0*tmp1_4;
        auto tmp1_9 = psq*x1;
        auto tmp1_10 = x1 + 1;
        auto tmp1_11 = x0*tmp1_3;
        auto tmp3_2 = tmp1_11 + tmp1_10;
        auto tmp1_12 = -psq*tmp1_5;
        auto tmp1_13 = x0*tmp1_10;
        auto tmp1_14 = tmp1_5 + tmp1_10;
        auto tmp1_15 = -1 + x0;
        auto tmp3_3 = SecDecInternalLambda0*tmp1_15;
        auto tmp1_16 = tmp1_3-1;
        auto tmp3_4 = tmp1_16*SecDecInternalLambda1;
        auto tmp1_17 = SecDecInternalLambda1*x1;
        auto tmp1_18 = SecDecInternalLambda0*x0;
        auto tmp1_19 = -1 + tmp1_1;
        auto tmp3_5 = SecDecInternalLambda0*tmp1_19;
        auto __PowCall4 = SecDecInternalSqr(x0);
        auto __PowCall5 = SecDecInternalSqr(x1);
        auto __PowCall6 = SecDecInternalSqr(m1);
        auto __PowCall7 = SecDecInternalSqr(m2);
        auto __PowCall8 = SecDecInternalSqr(m3);
        auto __DenominatorCall1 = SecDecInternalDenominator(x0);
        auto tmp2_15 = __PowCall5*__PowCall6;
        auto tmp2_16 = tmp1_3*__PowCall8;
        auto tmp3_6 = 2*tmp2_15 + tmp2_16;
        auto tmp2_17 = x0 + __PowCall4;
        auto tmp3_7 = tmp2_15*tmp2_17;
        auto tmp2_18 = __PowCall4*__PowCall8;
        auto tmp2_19 = x1*tmp2_18;
        auto tmp2_20 = tmp1_5*__PowCall6;
        auto tmp2_21 = tmp1_13*__PowCall8;
        auto tmp2_22 = tmp1_14*__PowCall7;
        auto tmp3_8 = tmp2_22 + tmp2_21 + tmp1_12 + tmp2_20 + tmp2_19 + tmp3_7;
        auto tmp3_9 = tmp1_10*__PowCall7;
        auto tmp3_10 = __PowCall4*__PowCall6;
        auto tmp3_11 = tmp1_1*__PowCall6;
        auto tmp3_12 = 2*tmp3_10 + tmp3_11;
        auto tmp3_13 = __PowCall7 + __PowCall6;
        auto tmp3_14 = tmp3_13*x1;
        auto tmp3_15 = tmp3_14-tmp1_9;
        auto tmp2_23 = tmp1_2*tmp2_15;
        auto tmp2_24 = tmp3_2*__PowCall8;
        auto tmp3_16 = tmp2_24 + tmp2_23 + tmp3_15;
        auto tmp3_17 = tmp1_10*__PowCall8;
        auto tmp3_18 = tmp3_17 + tmp2_15 + tmp3_15;
        auto tmp3_19 = tmp1_3*tmp3_10;
        auto tmp3_20 = x0*__PowCall8;
        auto tmp3_21 = tmp3_1*__PowCall6;
        auto tmp2_25 = tmp1_8*__PowCall7;
        auto tmp3_22 = tmp2_25-tmp1_7 + tmp3_21 + tmp3_20 + tmp2_18 + tmp3_19;
        auto tmp3_23 = tmp1_2*__PowCall8;
        auto tmp3_24 = tmp1_6*__PowCall6;
        auto tmp3_25 = -psq + tmp3_24 + __PowCall7 + tmp3_23;
        auto _logCall2 = SecDecInternalLog(__DenominatorCall1);
        auto __PowCall13 = SecDecInternalSqr(__DenominatorCall1);
        auto __RealPartCall7 = SecDecInternalRealPart(__PowCall7);
        auto tmp3_26 = SecDecInternalLambda1*__PowCall5;
        auto tmp3_27 = -tmp1_17 + tmp3_26;
        auto tmp3_28 = SecDecInternalI(__RealPartCall7);
        auto tmp3_29 = tmp3_28*tmp3_27;
        auto tmp3_30 = x1 + tmp3_29;
        auto tmp3_31 = tmp3_4*tmp3_28;
        auto tmp3_32 = 1 + tmp3_31;
        auto _logCall1 = SecDecInternalLog(__PowCall13);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp3_6);
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_12);
        auto __RealPartCall3 = SecDecInternalRealPart(tmp3_16);
        auto __RealPartCall4 = SecDecInternalRealPart(tmp3_18);
        auto __RealPartCall5 = SecDecInternalRealPart(tmp3_22);
        auto __RealPartCall6 = SecDecInternalRealPart(tmp3_25);
        auto tmp3_33 = tmp3_30 + 1;
        auto tmp3_34 = __PowCall7*tmp3_33;
        auto tmp3_35 = SecDecInternalI(tmp3_3*__RealPartCall3);
        auto tmp3_36 = 1 + tmp3_35;
        auto tmp3_37 = SecDecInternalI(__RealPartCall4*SecDecInternalLambda0);
        auto tmp3_38 = tmp3_37-1;
        auto tmp3_39 = SecDecInternalLambda0*__PowCall4;
        auto tmp3_40 = tmp3_39-tmp1_18;
        auto tmp3_41 = SecDecInternalI(tmp3_40);
        auto tmp3_42 = __RealPartCall3*tmp3_41;
        auto tmp3_43 = x0 + tmp3_42;
        auto tmp3_44 = __RealPartCall1*tmp3_40;
        auto tmp3_45 = __RealPartCall3*tmp3_5;
        auto tmp3_46 = tmp3_45 + tmp3_44;
        auto tmp3_47 = SecDecInternalI(tmp3_46);
        auto tmp3_48 = 1 + tmp3_47;
        auto tmp3_49 = __RealPartCall6*tmp3_41;
        auto tmp3_50 = __PowCall5*SecDecInternalLambda1;
        auto tmp3_51 = tmp3_50-tmp1_17;
        auto tmp3_52 = SecDecInternalI(tmp3_51);
        auto tmp3_53 = __RealPartCall5*tmp3_52;
        auto tmp3_54 = x1 + tmp3_53;
        auto tmp3_55 = __RealPartCall6*tmp3_52;
        auto tmp3_56 = __RealPartCall2*tmp3_51;
        auto tmp3_57 = __RealPartCall5*tmp3_4;
        auto tmp3_58 = tmp3_57 + tmp3_56;
        auto tmp3_59 = SecDecInternalI(tmp3_58);
        auto tmp3_60 = 1 + tmp3_59;
        auto __CondefFacx0Call2 = -tmp3_38;
        auto _d_Deformedx0d0Call2 = -tmp3_38;
        auto tmp3_61 = tmp3_43 + 1;
        auto tmp3_62 = tmp3_54*tmp3_61;
        auto tmp3_63 = 1 + tmp3_62;
        auto tmp3_64 = -tmp3_49*tmp3_55;
        auto tmp3_65 = tmp3_48*tmp3_60;
        auto tmp3_66 = tmp3_64 + tmp3_65;
        auto tmp3_67 = _d_Deformedx0d0Call2*tmp3_32;
        auto _logCall3 = SecDecInternalLog(tmp3_36);
        auto _logCall4 = SecDecInternalLog(__CondefFacx0Call2);
        auto _logCall6 = SecDecInternalLog(tmp3_34);
        auto _logCall8 = SecDecInternalLog(tmp3_33);
        auto __PowCall9 = SecDecInternalSqr(tmp3_43);
        auto __PowCall10 = SecDecInternalSqr(tmp3_54);
        auto __PowCall12 = SecDecInternalSqr(tmp3_33)*tmp3_33;
        auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_36);
        auto __DenominatorCall4 = SecDecInternalDenominator(__CondefFacx0Call2);
        auto tmp3_68 = __PowCall8*__PowCall9;
        auto tmp3_69 = __PowCall8 + __PowCall7-psq + __PowCall6;
        auto tmp3_70 = tmp3_43*tmp3_69;
        auto tmp3_71 = tmp3_70 + __PowCall7 + tmp3_68;
        auto tmp3_72 = tmp3_54*tmp3_71;
        auto tmp3_73 = __PowCall6*__PowCall10;
        auto tmp3_74 = __PowCall9*tmp3_73;
        auto tmp3_75 = tmp3_73 + __PowCall8;
        auto tmp3_76 = tmp3_43*tmp3_75;
        auto tmp3_77 = tmp3_72 + tmp3_76 + tmp3_74 + __PowCall7;
        auto _logCall7 = SecDecInternalLog(tmp3_63);
        auto __PowCall1 = SecDecInternalSqr(_logCall4);
        auto __PowCall2 = SecDecInternalSqr(_logCall6);
        auto __PowCall3 = SecDecInternalSqr(_logCall8);
        auto __PowCall11 = SecDecInternalSqr(tmp3_63)*tmp3_63;
        auto __DenominatorCall5 = SecDecInternalDenominator(__PowCall12);
        auto _logCall5 = SecDecInternalLog(tmp3_77);
        auto __DenominatorCall3 = SecDecInternalDenominator(__PowCall11);
        auto tmp3_78 = -tmp3_9 + tmp3_34;
        auto tmp3_79 = -tmp3_8 + tmp3_77;
        auto tmp3_80 = 2*_logCall6;
        auto tmp3_81 = tmp3_80-_logCall4;
        auto tmp3_82 = -3*_logCall2 + 2*_logCall1;
        auto tmp3_83 = 3*_logCall8;
        auto tmp3_84 = -tmp3_83 + tmp3_82 + tmp3_81;
        auto tmp3_85 = __DenominatorCall1*tmp3_84;
        auto tmp3_86 = -tmp3_81*tmp3_83;
        auto tmp3_87 = -_logCall4*tmp3_80;
        auto tmp3_88 = tmp3_85 + tmp3_86 + tmp3_87 + SecDecInternalQuo(9, 2)*__PowCall3 + SecDecInternalQuo(1, 2)*__PowCall1 + 2*__PowCall2;
        auto tmp3_89 = tmp3_34*__DenominatorCall5*__DenominatorCall4*tmp3_67*tmp3_88;
        auto tmp3_90 = 3*_logCall7 + _logCall3-2*_logCall5-tmp3_82;
        auto tmp3_91 = __DenominatorCall1*tmp3_77*__DenominatorCall3*__DenominatorCall2*tmp3_66*tmp3_90;
        auto tmp3_92 = tmp3_91 + tmp3_89;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_78);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_93 = SecDecInternalImagPart(tmp3_79);
        SecDecInternalSignCheckContourDeformation(!(tmp3_93<=0), 2);
        auto tmp3_94 = SecDecInternalRealPart(tmp3_33);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_94>=0), 1);
        auto tmp3_95 = SecDecInternalRealPart(tmp3_63);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_95>=0), 2);
        acc = acc + w*(tmp3_92);
    }
    *presult = componentsum(acc);
    return 0;
}

#define SecDecInternalOutputDeformationParameters(i, v) deformp[i] = vec_min(deformp[i], v);

extern "C" void
pysecdec_sunset_lib_integral__sector_4_order_1__maxdeformp(
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
        auto tmp1_1 = SecDecInternalSqr(m2);
        auto tmp1_2 = tmp1_1-psq;
        auto tmp1_3 = SecDecInternalSqr(m1);
        auto tmp1_4 = tmp1_2 + tmp1_3;
        auto tmp1_5 = 2*x0;
        auto tmp1_6 = tmp1_5-1;
        auto tmp1_7 = SecDecInternalSqr(m3);
        auto tmp1_8 = -tmp1_7*tmp1_6;
        auto tmp3_1 = tmp1_8-tmp1_4;
        auto tmp3_2 = x0*tmp3_1;
        auto tmp3_3 = -x0*tmp1_6;
        auto tmp3_4 = 1 + tmp3_3;
        auto tmp3_5 = x1*tmp1_3*tmp3_4;
        auto tmp3_6 = tmp3_5 + tmp3_2 + tmp1_7 + tmp1_4;
        auto tmp3_7 = x1*x0*tmp3_6;
        auto tmp3_8 = 1-x0;
        auto tmp3_9 = x0*tmp1_7*tmp3_8;
        auto tmp3_10 = tmp3_9 + tmp3_7;
        auto tmp3_11 = -tmp1_7 + 2*tmp1_3;
        auto tmp3_12 = x0*tmp3_11;
        auto tmp3_13 = tmp3_12 + tmp1_3-tmp1_2-tmp1_7;
        auto tmp3_14 = x0*tmp3_13;
        auto tmp3_15 = x0 + 1;
        auto tmp3_16 = -x1*tmp1_5*tmp1_3*tmp3_15;
        auto tmp3_17 = tmp3_16-tmp1_1 + tmp3_14;
        auto tmp3_18 = x1*tmp3_17;
        auto tmp3_19 = tmp1_7*tmp3_15;
        auto tmp3_20 = tmp3_19 + tmp1_4;
        auto tmp3_21 = x0*tmp3_20;
        auto tmp3_22 = tmp3_18 + tmp1_1 + tmp3_21;
        auto tmp3_23 = x1*tmp3_22;
        SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_10))));
        SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_23))));
    }
    maxdeformp[0] = componentmin(deformp[0]);
    maxdeformp[1] = componentmin(deformp[1]);
}

extern "C" int
pysecdec_sunset_lib_integral__sector_4_order_1__fpolycheck(
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
        auto tmp1_1 = SecDecInternalSqr(m2);
        auto tmp1_2 = SecDecInternalSqr(m3);
        auto tmp1_3 = SecDecInternalSqr(m1);
        auto tmp1_4 = tmp1_1 + tmp1_2 + tmp1_3-psq;
        auto tmp1_5 = x0*tmp1_2;
        auto tmp3_1 = tmp1_5 + tmp1_4;
        auto tmp3_2 = x0*tmp3_1;
        auto tmp1_6 = tmp1_3*x1;
        auto tmp1_7 = 1 + x0;
        auto tmp1_8 = 2*x0;
        auto tmp3_3 = tmp1_8*tmp1_7*tmp1_6;
        auto tmp3_4 = tmp3_3 + tmp1_1 + tmp3_2;
        auto tmp3_5 = tmp1_2*tmp1_8;
        auto tmp3_6 = 1 + tmp1_8;
        auto tmp3_7 = tmp3_6*tmp1_6;
        auto tmp3_8 = tmp3_7 + tmp3_5 + tmp1_4;
        auto tmp3_9 = x1*tmp3_8;
        auto tmp3_10 = tmp1_2 + tmp3_9;
        auto tmp3_11 = -1 + x1;
        auto tmp3_12 = x1*SecDecInternalLambda1*tmp3_11;
        auto tmp3_13 = -1 + x0;
        auto tmp3_14 = x0*SecDecInternalLambda0*tmp3_13;
        auto __RealPartCall1 = SecDecInternalRealPart(tmp3_10);
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_4);
        auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_14;
        auto __Deformedx1Call = x1 + i_*__RealPartCall2*tmp3_12;
        auto fpoly_im = SecDecInternalImagPart(tmp1_1 + __Deformedx1Call*tmp1_1 + __Deformedx0Call*tmp1_2 + __Deformedx0Call*__Deformedx1Call*tmp1_4 + __Deformedx0Call*SecDecInternalSqr(__Deformedx1Call)*tmp1_3 + SecDecInternalSqr(__Deformedx0Call)*__Deformedx1Call*tmp1_2 + SecDecInternalSqr(__Deformedx0Call)*SecDecInternalSqr(__Deformedx1Call)*tmp1_3);
        if (unlikely(!(fpoly_im <= 0))) return 1;
    }
    return 0;
}
