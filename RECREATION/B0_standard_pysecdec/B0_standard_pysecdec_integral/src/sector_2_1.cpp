#include "sector_2_1.hpp"
namespace B0_standard_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
integrand_return_t sector_2_order_1_integrand
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto psq = real_parameters[0]; (void)psq;
    const auto msq = real_parameters[1]; (void)msq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
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
    auto _logCall2 = SecDecInternalLog(tmp3_12);
    auto __PowCall3 = SecDecInternalSqr(tmp3_12);
    auto _logCall1 = SecDecInternalLog(tmp3_16);
    auto __DenominatorCall1 = SecDecInternalDenominator(__PowCall3);
    auto tmp3_17 = -tmp3_6 + tmp3_16;
    auto tmp3_18 = 2*_logCall2-_logCall1;
    auto tmp3_19 = tmp3_18*tmp3_11*__DenominatorCall1;
    auto _SignCheckExpression = SecDecInternalImagPart(tmp3_17);
    SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
    auto tmp3_20 = SecDecInternalRealPart(tmp3_12);
    SecDecInternalSignCheckPositivePolynomial(!(tmp3_20>=0), 1);
    return(tmp3_19);
}
#ifdef SECDEC_WITH_CUDA
__device__ secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* const device_sector_2_order_1_integrand = sector_2_order_1_integrand;
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_2_order_1_integrand()
{
    using IntegrandFunction = secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction;
    IntegrandFunction* device_address_on_host;
    auto errcode = cudaMemcpyFromSymbol(&device_address_on_host,device_sector_2_order_1_integrand, sizeof(IntegrandFunction*));
    if (errcode != cudaSuccess) throw secdecutil::cuda_error( cudaGetErrorString(errcode) );
    return device_address_on_host;
}
#endif
}
