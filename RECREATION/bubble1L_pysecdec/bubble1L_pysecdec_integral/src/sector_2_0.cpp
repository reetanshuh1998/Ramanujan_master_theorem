#include "sector_2_0.hpp"
namespace bubble1L_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
integrand_return_t sector_2_order_0_integrand
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto s = real_parameters[0]; (void)s;
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
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
    return(tmp3_16);
}
#ifdef SECDEC_WITH_CUDA
__device__ secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* const device_sector_2_order_0_integrand = sector_2_order_0_integrand;
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_2_order_0_integrand()
{
    using IntegrandFunction = secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction;
    IntegrandFunction* device_address_on_host;
    auto errcode = cudaMemcpyFromSymbol(&device_address_on_host,device_sector_2_order_0_integrand, sizeof(IntegrandFunction*));
    if (errcode != cudaSuccess) throw secdecutil::cuda_error( cudaGetErrorString(errcode) );
    return device_address_on_host;
}
#endif
}
