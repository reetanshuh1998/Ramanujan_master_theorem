#include "sector_5_n1.hpp"
namespace pysecdec_sunset_lib_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
integrand_return_t sector_5_order_n1_integrand
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    auto tmp1_1 = -x0*psq;
    auto tmp1_2 = x0 + 1;
    auto tmp1_3 = x0*SecDecInternalLambda0;
    auto tmp1_4 = -SecDecInternalLambda0 + 2*tmp1_3;
    auto __PowCall1 = SecDecInternalSqr(x0);
    auto __PowCall2 = SecDecInternalSqr(m1);
    auto __PowCall3 = SecDecInternalSqr(m2);
    auto __PowCall4 = SecDecInternalSqr(m3);
    auto tmp2_2 = tmp1_2*__PowCall4;
    auto __RealPartCall1 = SecDecInternalRealPart(__PowCall4);
    auto tmp2_3 = SecDecInternalLambda0*__PowCall1;
    auto tmp3_1 = -tmp1_3 + tmp2_3;
    auto tmp2_4 = SecDecInternalI(__RealPartCall1);
    auto tmp3_2 = tmp2_4*tmp3_1;
    auto tmp3_3 = x0 + tmp3_2;
    auto tmp3_4 = tmp1_4*tmp2_4;
    auto tmp3_5 = 1 + tmp3_4;
    auto tmp3_6 = tmp3_3 + 1;
    auto tmp3_7 = __PowCall4*tmp3_6;
    auto __PowCall5 = SecDecInternalSqr(tmp3_6)*tmp3_6;
    auto __DenominatorCall1 = SecDecInternalDenominator(__PowCall5);
    auto tmp3_8 = tmp3_7-tmp2_2;
    auto tmp3_9 = tmp3_5*__DenominatorCall1*tmp3_7;
    auto _SignCheckExpression = SecDecInternalImagPart(tmp3_8);
    SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
    auto tmp3_10 = SecDecInternalRealPart(tmp3_6);
    SecDecInternalSignCheckPositivePolynomial(!(tmp3_10>=0), 1);
    return(tmp3_9);
}
#ifdef SECDEC_WITH_CUDA
__device__ secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* const device_sector_5_order_n1_integrand = sector_5_order_n1_integrand;
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_5_order_n1_integrand()
{
    using IntegrandFunction = secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction;
    IntegrandFunction* device_address_on_host;
    auto errcode = cudaMemcpyFromSymbol(&device_address_on_host,device_sector_5_order_n1_integrand, sizeof(IntegrandFunction*));
    if (errcode != cudaSuccess) throw secdecutil::cuda_error( cudaGetErrorString(errcode) );
    return device_address_on_host;
}
#endif
}
