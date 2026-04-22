#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cuda.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}

extern "C" __global__ void
B0_standard_pysecdec_integral__sector_2_order_0(
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
    const real_t psq = realp[0]; (void)psq;
    const real_t msq = realp[1]; (void)msq;
    const real_t SecDecInternalLambda0 = deformp[0]; (void)SecDecInternalLambda0;
    const real_t invlattice = SecDecInternalDenominator((real_t)(double)lattice);
    result_t val = (result_t)0;
    uint64_t index = index1 + (bid*128 + tid)*8;
    uint64_t li_x0 = mulmod(index, genvec[0], lattice);
    for (uint64_t i = 0; (i < 8) && (index < index2); i++, index++) {
        real_t x0 = warponce(invlattice*(double)li_x0 + shift[0], 1.0);
        li_x0 = warponce_i(li_x0 + genvec[0], lattice);
        real_t w_x0 = korobov3x3_w(x0);
        real_t w = w_x0;
        x0 = korobov3x3_f(x0);
        auto tmp1_1 = 2*msq;
        auto tmp1_2 = 1 + x0;
        auto tmp3_1 = msq*tmp1_2;
        auto tmp3_2 = 2*tmp3_1-psq;
        auto tmp1_3 = tmp1_1-psq;
        auto tmp1_4 = x0*tmp1_3;
        auto tmp3_3 = msq + tmp1_4;
        auto tmp1_5 = -1 + 2*x0;
        auto tmp3_4 = SecDecInternalLambda0*tmp1_5;
        auto tmp1_6 = SecDecInternalLambda0*x0;
        auto __PowCall1 = SecDecInternalSqr(x0);
        auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
        auto tmp3_5 = msq*__PowCall1;
        auto tmp3_6 = tmp3_3 + tmp3_5;
        auto __RealPartCall2 = SecDecInternalRealPart(tmp3_2);
        auto tmp2_3 = SecDecInternalLambda0*__PowCall1;
        auto tmp3_7 = tmp2_3-tmp1_6;
        auto tmp2_4 = SecDecInternalI(__RealPartCall2);
        auto tmp2_5 = tmp2_4*tmp3_7;
        auto tmp3_8 = x0 + tmp2_5;
        auto tmp3_9 = SecDecInternalI(tmp3_7*__RealPartCall1);
        auto tmp3_10 = tmp3_4*tmp2_4;
        auto tmp3_11 = tmp3_10 + 1 + tmp3_9;
        auto tmp3_12 = 1 + tmp3_8;
        auto __PowCall2 = SecDecInternalSqr(tmp3_8);
        auto tmp3_13 = 1 + __PowCall2;
        auto tmp3_14 = msq*tmp3_13;
        auto tmp3_15 = tmp3_8*tmp1_3;
        auto tmp3_16 = tmp3_15 + tmp3_14;
        auto __PowCall3 = SecDecInternalSqr(tmp3_12);
        auto __DenominatorCall1 = SecDecInternalDenominator(__PowCall3);
        auto tmp3_17 = tmp3_16-tmp3_6;
        auto tmp3_18 = tmp3_11*__DenominatorCall1;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_17);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_19 = SecDecInternalRealPart(tmp3_12);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_19>=0), 1);
        val = val + w*(tmp3_18);
    }
    // Sum up 128*8=1024 values across 4 warps.
    typedef cub::BlockReduce<result_t, 128, cub::BLOCK_REDUCE_RAKING_COMMUTATIVE_ONLY> Reduce;
    __shared__ typename Reduce::TempStorage shared;
    result_t sum = Reduce(shared).Sum(val);
    if (tid == 0) result[bid] = sum;
}
