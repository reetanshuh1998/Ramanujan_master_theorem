#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cuda.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}

extern "C" __global__ void
pysecdec_sunset_lib_integral__sector_2_order_0(
    result_t * __restrict__ result,
    const uint64_t lattice,
    const uint64_t index1,
    const uint64_t index2,
    const uint64_t * __restrict__ genvec,
    const real_t * __restrict__ shift,
    const real_t * __restrict__ realp,
    const complex_t * __restrict__ complexp,
    const real_t * __restrict__ deformp
)
{
    // assert(blockDim.x == 128);
    const uint64_t bid = blockIdx.x;
    const uint64_t tid = threadIdx.x;
    const real_t m1 = realp[0]; (void)m1;
    const real_t m2 = realp[1]; (void)m2;
    const real_t m3 = realp[2]; (void)m3;
    const real_t psq = realp[3]; (void)psq;
    const real_t SecDecInternalLambda0 = deformp[0]; (void)SecDecInternalLambda0;
    const real_t SecDecInternalLambda1 = deformp[1]; (void)SecDecInternalLambda1;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    result_t val = (result_t)0;
    uint64_t index = index1 + (bid*128 + tid)*8;
    uint64_t li_x0 = mulmod(index, genvec[0], lattice);
    uint64_t li_x1 = mulmod(index, genvec[1], lattice);
    for (uint64_t i = 0; (i < 8) && (index < index2); i++, index++) {
        real_t x0 = warponce(invlattice*(double)li_x0 + shift[0], 1.0);
        li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        real_t x1 = warponce(invlattice*(double)li_x1 + shift[1], 1.0);
        li_x1 = warponce_i(li_x1 + genvec[1], lattice);
        real_t w_x0 = korobov3x3_w(x0);
        real_t w_x1 = korobov3x3_w(x1);
        real_t w = w_x0*w_x1;
        x0 = korobov3x3_f(x0);
        x1 = korobov3x3_f(x1);
        auto tmp1_1 = 2*x0;
        auto tmp1_2 = tmp1_1 + 1;
        auto tmp1_3 = x1*x0;
        auto tmp1_4 = 4*tmp1_3 + tmp1_2;
        auto tmp1_5 = 2*x1;
        auto tmp1_6 = tmp1_5 + 1;
        auto tmp1_7 = psq*x0;
        auto tmp1_8 = x0 + 1;
        auto tmp1_9 = x1*tmp1_1;
        auto tmp3_1 = tmp1_9 + tmp1_8;
        auto tmp1_10 = psq*x1;
        auto tmp3_2 = x1*tmp1_2;
        auto tmp1_11 = 1 + x1;
        auto tmp1_12 = -psq*tmp1_3;
        auto tmp1_13 = tmp1_3 + tmp1_8;
        auto tmp1_14 = x1*tmp1_8;
        auto tmp1_15 = -1 + x1;
        auto tmp3_3 = SecDecInternalLambda1*tmp1_15;
        auto tmp1_16 = -1 + tmp1_5;
        auto tmp3_4 = SecDecInternalLambda1*tmp1_16;
        auto tmp1_17 = SecDecInternalLambda1*x1;
        auto tmp1_18 = SecDecInternalLambda0*x0;
        auto tmp1_19 = tmp1_1-1;
        auto tmp3_5 = tmp1_19*SecDecInternalLambda0;
        auto __PowCall2 = SecDecInternalSqr(x0);
        auto __PowCall3 = SecDecInternalSqr(x1);
        auto __PowCall4 = SecDecInternalSqr(m1);
        auto __PowCall5 = SecDecInternalSqr(m2);
        auto __PowCall6 = SecDecInternalSqr(m3);
        auto __DenominatorCall1 = SecDecInternalDenominator(x1);
        auto __DenominatorCall6 = SecDecInternalDenominator(x0);
        auto tmp2_15 = __PowCall3*__PowCall6;
        auto tmp2_16 = tmp1_5*__PowCall6;
        auto tmp3_6 = 2*tmp2_15 + tmp2_16;
        auto tmp2_17 = x1 + __PowCall3;
        auto tmp2_18 = __PowCall2*__PowCall6;
        auto tmp3_7 = tmp2_18*tmp2_17;
        auto tmp2_19 = __PowCall3*__PowCall4;
        auto tmp2_20 = x0*tmp2_19;
        auto tmp2_21 = tmp1_3*__PowCall6;
        auto tmp2_22 = tmp1_13*__PowCall5;
        auto tmp2_23 = tmp1_14*__PowCall4;
        auto tmp3_8 = tmp2_23 + tmp2_22 + tmp1_12 + tmp2_21 + tmp2_20 + tmp3_7;
        auto tmp3_9 = tmp1_8*__PowCall5;
        auto tmp3_10 = tmp1_1*__PowCall4;
        auto tmp3_11 = 2*tmp2_18 + tmp3_10;
        auto tmp3_12 = tmp1_1*tmp2_15;
        auto tmp3_13 = x1*__PowCall4;
        auto tmp3_14 = tmp3_2*__PowCall6;
        auto tmp2_24 = tmp1_11*__PowCall5;
        auto tmp3_15 = tmp2_24-tmp1_10 + tmp3_14 + tmp3_13 + tmp2_19 + tmp3_12;
        auto tmp3_16 = __PowCall5 + __PowCall6;
        auto tmp3_17 = tmp3_16*x0;
        auto tmp3_18 = tmp3_17-tmp1_7;
        auto tmp3_19 = tmp1_6*tmp2_18;
        auto tmp3_20 = tmp3_1*__PowCall4;
        auto tmp3_21 = tmp3_20 + tmp3_19 + tmp3_18;
        auto tmp3_22 = tmp1_8*__PowCall4;
        auto tmp3_23 = tmp3_22 + tmp2_18 + tmp3_18;
        auto tmp3_24 = tmp1_6*__PowCall4;
        auto tmp3_25 = tmp1_4*__PowCall6;
        auto tmp3_26 = -psq + tmp3_25 + __PowCall5 + tmp3_24;
        auto __PowCall1 = SecDecInternalSqr(__DenominatorCall6);
        auto __RealPartCall7 = SecDecInternalRealPart(__PowCall5);
        auto tmp3_27 = __DenominatorCall6*__PowCall1;
        auto tmp3_28 = SecDecInternalLambda0*__PowCall2;
        auto tmp3_29 = -tmp1_18 + tmp3_28;
        auto tmp3_30 = SecDecInternalI(__RealPartCall7);
        auto tmp3_31 = tmp3_30*tmp3_29;
        auto tmp3_32 = x0 + tmp3_31;
        auto tmp3_33 = tmp3_5*tmp3_30;
        auto tmp3_34 = 1 + tmp3_33;
        auto _logCall1 = SecDecInternalLog(__PowCall1);
        auto _logCall2 = SecDecInternalLog(tmp3_27);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp3_6);
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_11);
        auto __RealPartCall3 = SecDecInternalRealPart(tmp3_15);
        auto __RealPartCall4 = SecDecInternalRealPart(tmp3_21);
        auto __RealPartCall5 = SecDecInternalRealPart(tmp3_23);
        auto __RealPartCall6 = SecDecInternalRealPart(tmp3_26);
        auto tmp3_35 = tmp3_32 + 1;
        auto tmp3_36 = __PowCall5*tmp3_35;
        auto tmp3_37 = SecDecInternalI(tmp3_3*__RealPartCall4);
        auto tmp3_38 = 1 + tmp3_37;
        auto tmp3_39 = SecDecInternalI(__RealPartCall5*SecDecInternalLambda1);
        auto tmp3_40 = tmp3_39-1;
        auto tmp3_41 = __PowCall2*SecDecInternalLambda0;
        auto tmp3_42 = tmp3_41-tmp1_18;
        auto tmp3_43 = SecDecInternalI(tmp3_42);
        auto tmp3_44 = __RealPartCall3*tmp3_43;
        auto tmp3_45 = x0 + tmp3_44;
        auto tmp3_46 = __RealPartCall1*tmp3_42;
        auto tmp3_47 = __RealPartCall3*tmp3_5;
        auto tmp3_48 = tmp3_47 + tmp3_46;
        auto tmp3_49 = SecDecInternalI(tmp3_48);
        auto tmp3_50 = 1 + tmp3_49;
        auto tmp3_51 = __RealPartCall6*tmp3_43;
        auto tmp3_52 = SecDecInternalLambda1*__PowCall3;
        auto tmp3_53 = tmp3_52-tmp1_17;
        auto tmp3_54 = SecDecInternalI(tmp3_53);
        auto tmp3_55 = __RealPartCall4*tmp3_54;
        auto tmp3_56 = x1 + tmp3_55;
        auto tmp3_57 = __RealPartCall6*tmp3_54;
        auto tmp3_58 = __RealPartCall2*tmp3_53;
        auto tmp3_59 = __RealPartCall4*tmp3_4;
        auto tmp3_60 = tmp3_59 + tmp3_58;
        auto tmp3_61 = SecDecInternalI(tmp3_60);
        auto tmp3_62 = 1 + tmp3_61;
        auto __CondefFacx1Call2 = -tmp3_40;
        auto _d_Deformedx1d1Call2 = -tmp3_40;
        auto tmp3_63 = tmp3_56 + 1;
        auto tmp3_64 = tmp3_45*tmp3_63;
        auto tmp3_65 = 1 + tmp3_64;
        auto tmp3_66 = -tmp3_51*tmp3_57;
        auto tmp3_67 = tmp3_50*tmp3_62;
        auto tmp3_68 = tmp3_66 + tmp3_67;
        auto tmp3_69 = tmp3_34*_d_Deformedx1d1Call2;
        auto _logCall3 = SecDecInternalLog(__CondefFacx1Call2);
        auto _logCall4 = SecDecInternalLog(tmp3_36);
        auto _logCall5 = SecDecInternalLog(tmp3_35);
        auto __PowCall7 = SecDecInternalSqr(tmp3_45);
        auto __PowCall8 = SecDecInternalSqr(tmp3_56);
        auto __PowCall9 = SecDecInternalSqr(tmp3_35)*tmp3_35;
        auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_38);
        auto __DenominatorCall4 = SecDecInternalDenominator(__CondefFacx1Call2);
        auto tmp3_70 = __PowCall6*__PowCall7;
        auto tmp3_71 = __PowCall6 + __PowCall5-psq + __PowCall4;
        auto tmp3_72 = tmp3_45*tmp3_71;
        auto tmp3_73 = tmp3_72 + __PowCall4 + tmp3_70;
        auto tmp3_74 = tmp3_56*tmp3_73;
        auto tmp3_75 = __PowCall8*tmp3_70;
        auto tmp3_76 = __PowCall4*__PowCall8;
        auto tmp3_77 = tmp3_76 + __PowCall5;
        auto tmp3_78 = tmp3_45*tmp3_77;
        auto tmp3_79 = tmp3_74 + tmp3_78 + __PowCall5 + tmp3_75;
        auto __PowCall10 = SecDecInternalSqr(tmp3_65)*tmp3_65;
        auto __DenominatorCall5 = SecDecInternalDenominator(__PowCall9);
        auto __DenominatorCall3 = SecDecInternalDenominator(__PowCall10);
        auto tmp3_80 = tmp3_36-tmp3_9;
        auto tmp3_81 = tmp3_79-tmp3_8;
        auto tmp3_82 = _logCall2 + _logCall4;
        auto tmp3_83 = _logCall1 + _logCall5;
        auto tmp3_84 = _logCall3-__DenominatorCall1 + 3*tmp3_83-2*tmp3_82;
        auto tmp3_85 = tmp3_84*tmp3_69*__DenominatorCall4*__DenominatorCall5*tmp3_36;
        auto tmp3_86 = tmp3_68*__DenominatorCall2*__DenominatorCall3*tmp3_79*__DenominatorCall1;
        auto tmp3_87 = tmp3_86 + tmp3_85;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_80);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_88 = SecDecInternalImagPart(tmp3_81);
        SecDecInternalSignCheckContourDeformation(!(tmp3_88<=0), 2);
        auto tmp3_89 = SecDecInternalRealPart(tmp3_35);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_89>=0), 1);
        auto tmp3_90 = SecDecInternalRealPart(tmp3_65);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_90>=0), 2);
        val = val + w*(tmp3_87);
    }
    // Sum up 128*8=1024 values across 4 warps.
    typedef cub::BlockReduce<result_t, 128, cub::BLOCK_REDUCE_RAKING_COMMUTATIVE_ONLY> Reduce;
    __shared__ typename Reduce::TempStorage shared;
    result_t sum = Reduce(shared).Sum(val);
    if (tid == 0) result[bid] = sum;
}
