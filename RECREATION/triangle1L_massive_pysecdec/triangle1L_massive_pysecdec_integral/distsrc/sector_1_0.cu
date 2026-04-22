#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cuda.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}

extern "C" __global__ void
triangle1L_massive_pysecdec_integral__sector_1_order_0(
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
    const real_t s = realp[0]; (void)s;
    const real_t msq = realp[1]; (void)msq;
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
        auto tmp1_1 = 2*msq;
        auto tmp1_2 = x0 + 1;
        auto tmp1_3 = tmp1_2 + x1;
        auto tmp3_1 = tmp1_3*tmp1_1;
        auto tmp1_4 = x0*s;
        auto tmp3_2 = -tmp1_4 + tmp3_1;
        auto tmp1_5 = x1*s;
        auto tmp3_3 = -tmp1_5 + tmp3_1;
        auto tmp1_6 = tmp1_1-s;
        auto tmp1_7 = 2*x1;
        auto tmp3_4 = tmp1_2*tmp1_7;
        auto tmp3_5 = tmp3_4 + 1 + 2*x0;
        auto tmp3_6 = msq*tmp3_5;
        auto tmp3_7 = -x0*tmp1_5;
        auto tmp3_8 = tmp3_7 + tmp3_6;
        auto tmp3_9 = x1*SecDecInternalLambda1;
        auto tmp3_10 = -SecDecInternalLambda1 + 2*tmp3_9;
        auto tmp1_8 = x0*SecDecInternalLambda0;
        auto tmp1_9 = -SecDecInternalLambda0 + 2*tmp1_8;
        auto __PowCall1 = SecDecInternalSqr(x0);
        auto __PowCall2 = SecDecInternalSqr(x1);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
        auto tmp3_11 = __PowCall1 + __PowCall2;
        auto tmp3_12 = msq*tmp3_11;
        auto tmp3_13 = tmp3_8 + tmp3_12;
        auto __RealPartCall2 = SecDecInternalRealPart(tmp1_6);
        auto __RealPartCall3 = SecDecInternalRealPart(tmp3_3);
        auto __RealPartCall4 = SecDecInternalRealPart(tmp3_2);
        auto tmp2_5 = SecDecInternalLambda0*__PowCall1;
        auto tmp3_14 = tmp2_5-tmp1_8;
        auto tmp2_6 = SecDecInternalI(__RealPartCall3);
        auto tmp2_7 = tmp2_6*tmp3_14;
        auto tmp3_15 = x0 + tmp2_7;
        auto tmp2_8 = SecDecInternalI(__RealPartCall1);
        auto tmp2_9 = tmp2_8*tmp3_14;
        auto tmp3_16 = tmp1_9*tmp2_6;
        auto tmp3_17 = tmp3_16 + 1 + tmp2_9;
        auto tmp3_18 = SecDecInternalI(__RealPartCall2);
        auto tmp3_19 = tmp3_18*tmp3_14;
        auto tmp2_10 = SecDecInternalLambda1*__PowCall2;
        auto tmp3_20 = tmp2_10-tmp3_9;
        auto tmp2_11 = SecDecInternalI(__RealPartCall4);
        auto tmp2_12 = tmp2_11*tmp3_20;
        auto tmp3_21 = x1 + tmp2_12;
        auto tmp3_22 = tmp3_18*tmp3_20;
        auto tmp3_23 = tmp2_8*tmp3_20;
        auto tmp3_24 = tmp3_10*tmp2_11;
        auto tmp3_25 = tmp3_24 + 1 + tmp3_23;
        auto tmp3_26 = tmp3_15 + 1 + tmp3_21;
        auto tmp3_27 = -tmp3_19*tmp3_22;
        auto tmp3_28 = tmp3_17*tmp3_25;
        auto tmp3_29 = tmp3_27 + tmp3_28;
        auto __PowCall3 = SecDecInternalSqr(tmp3_15);
        auto __PowCall4 = SecDecInternalSqr(tmp3_21);
        auto tmp3_30 = tmp1_6*tmp3_21;
        auto tmp3_31 = tmp3_30 + tmp1_1;
        auto tmp3_32 = tmp3_15*tmp3_31;
        auto tmp3_33 = __PowCall3 + __PowCall4 + 1;
        auto tmp3_34 = msq*tmp3_33;
        auto tmp3_35 = tmp3_21*tmp1_1;
        auto tmp3_36 = tmp3_35 + tmp3_34 + tmp3_32;
        auto __DenominatorCall1 = SecDecInternalDenominator(tmp3_26);
        auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_36);
        auto tmp3_37 = -tmp3_13 + tmp3_36;
        auto tmp3_38 = tmp3_29*__DenominatorCall1*__DenominatorCall2;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_37);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_39 = SecDecInternalRealPart(tmp3_26);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_39>=0), 1);
        val = val + w*(tmp3_38);
    }
    // Sum up 128*8=1024 values across 4 warps.
    typedef cub::BlockReduce<result_t, 128, cub::BLOCK_REDUCE_RAKING_COMMUTATIVE_ONLY> Reduce;
    __shared__ typename Reduce::TempStorage shared;
    result_t sum = Reduce(shared).Sum(val);
    if (tid == 0) result[bid] = sum;
}
