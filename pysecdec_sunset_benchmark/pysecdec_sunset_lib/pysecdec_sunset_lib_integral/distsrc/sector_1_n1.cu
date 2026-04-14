#define SECDEC_RESULT_IS_COMPLEX 1
#include "common_cuda.h"

#define SecDecInternalSignCheckPositivePolynomial(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}
#define SecDecInternalSignCheckContourDeformation(cond, id) if (unlikely(cond)) {val = REAL_NAN; break;}

extern "C" __global__ void
pysecdec_sunset_lib_integral__sector_1_order_n1(
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
        auto tmp1_1 = -x0*psq;
        auto tmp1_2 = x0 + 1;
        auto tmp1_3 = x0*SecDecInternalLambda0;
        auto tmp1_4 = -SecDecInternalLambda0 + 2*tmp1_3;
        auto __PowCall1 = SecDecInternalSqr(x0);
        auto __PowCall2 = SecDecInternalSqr(m1);
        auto __PowCall3 = SecDecInternalSqr(m2);
        auto __PowCall4 = SecDecInternalSqr(m3);
        auto tmp2_2 = tmp1_2*__PowCall2;
        auto __RealPartCall1 = SecDecInternalRealPart(__PowCall2);
        auto tmp2_3 = SecDecInternalLambda0*__PowCall1;
        auto tmp3_1 = -tmp1_3 + tmp2_3;
        auto tmp2_4 = SecDecInternalI(__RealPartCall1);
        auto tmp3_2 = tmp2_4*tmp3_1;
        auto tmp3_3 = x0 + tmp3_2;
        auto tmp3_4 = tmp1_4*tmp2_4;
        auto tmp3_5 = 1 + tmp3_4;
        auto tmp3_6 = tmp3_3 + 1;
        auto tmp3_7 = __PowCall2*tmp3_6;
        auto __PowCall5 = SecDecInternalSqr(tmp3_6)*tmp3_6;
        auto __DenominatorCall1 = SecDecInternalDenominator(__PowCall5);
        auto tmp3_8 = tmp3_7-tmp2_2;
        auto tmp3_9 = tmp3_5*__DenominatorCall1*tmp3_7;
        auto _SignCheckExpression = SecDecInternalImagPart(tmp3_8);
        SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
        auto tmp3_10 = SecDecInternalRealPart(tmp3_6);
        SecDecInternalSignCheckPositivePolynomial(!(tmp3_10>=0), 1);
        val = val + w*(tmp3_9);
    }
    // Sum up 128*8=1024 values across 4 warps.
    typedef cub::BlockReduce<result_t, 128, cub::BLOCK_REDUCE_RAKING_COMMUTATIVE_ONLY> Reduce;
    __shared__ typename Reduce::TempStorage shared;
    result_t sum = Reduce(shared).Sum(val);
    if (tid == 0) result[bid] = sum;
}
