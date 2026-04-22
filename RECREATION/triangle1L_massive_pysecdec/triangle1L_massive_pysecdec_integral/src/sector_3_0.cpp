#include "sector_3_0.hpp"
namespace triangle1L_massive_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
integrand_return_t sector_3_order_0_integrand
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto x1 = integration_variables[1]; (void)x1;
    const auto s = real_parameters[0]; (void)s;
    const auto msq = real_parameters[1]; (void)msq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
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
    return(tmp3_41);
}
#ifdef SECDEC_WITH_CUDA
__device__ secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* const device_sector_3_order_0_integrand = sector_3_order_0_integrand;
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_3_order_0_integrand()
{
    using IntegrandFunction = secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction;
    IntegrandFunction* device_address_on_host;
    auto errcode = cudaMemcpyFromSymbol(&device_address_on_host,device_sector_3_order_0_integrand, sizeof(IntegrandFunction*));
    if (errcode != cudaSuccess) throw secdecutil::cuda_error( cudaGetErrorString(errcode) );
    return device_address_on_host;
}
#endif
}
