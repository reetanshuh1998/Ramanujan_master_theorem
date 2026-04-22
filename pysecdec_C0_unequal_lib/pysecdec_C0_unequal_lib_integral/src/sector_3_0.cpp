#include "sector_3_0.hpp"
namespace pysecdec_C0_unequal_lib_integral
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
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    const auto m3sq = real_parameters[3]; (void)m3sq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
    auto tmp1_1 = 2*x1;
    auto tmp1_2 = x0 + 1;
    auto tmp1_3 = tmp1_1 + tmp1_2;
    auto tmp1_4 = x1 + 1;
    auto tmp1_5 = 2*x0;
    auto tmp1_6 = tmp1_5 + tmp1_4;
    auto tmp1_7 = -s*x0;
    auto tmp1_8 = x1 + tmp1_2;
    auto tmp3_1 = x0*tmp1_4;
    auto tmp3_2 = x1*tmp1_2;
    auto tmp3_3 = -1 + tmp1_1;
    auto tmp3_4 = SecDecInternalLambda1*tmp3_3;
    auto tmp1_9 = SecDecInternalLambda1*x1;
    auto tmp1_10 = SecDecInternalLambda0*x0;
    auto tmp3_5 = -1 + tmp1_5;
    auto tmp3_6 = SecDecInternalLambda0*tmp3_5;
    auto __PowCall1 = SecDecInternalSqr(x0);
    auto __PowCall2 = SecDecInternalSqr(x1);
    auto __PowCall3 = SecDecInternalSqr(m1sq);
    auto __PowCall4 = SecDecInternalSqr(m2sq);
    auto __PowCall5 = SecDecInternalSqr(m3sq);
    auto tmp2_7 = __PowCall1 + tmp3_1;
    auto tmp3_7 = __PowCall4*tmp2_7;
    auto tmp2_8 = __PowCall2 + tmp3_2;
    auto tmp3_8 = __PowCall3*tmp2_8;
    auto tmp2_9 = tmp1_8*__PowCall5;
    auto tmp3_9 = tmp2_9 + tmp1_7 + tmp3_8 + tmp3_7;
    auto tmp3_10 = tmp1_6*__PowCall4;
    auto tmp3_11 = x1*__PowCall3;
    auto tmp3_12 = tmp3_11-s + __PowCall5 + tmp3_10;
    auto tmp3_13 = tmp1_3*__PowCall3;
    auto tmp2_10 = x0*__PowCall4;
    auto tmp3_14 = tmp2_10 + __PowCall5 + tmp3_13;
    auto tmp3_15 = __PowCall4 + __PowCall3;
    auto tmp2_11 = 2*__PowCall4;
    auto tmp2_12 = 2*__PowCall3;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp2_11);
    auto __RealPartCall2 = SecDecInternalRealPart(tmp2_12);
    auto __RealPartCall3 = SecDecInternalRealPart(tmp3_12);
    auto __RealPartCall4 = SecDecInternalRealPart(tmp3_14);
    auto __RealPartCall5 = SecDecInternalRealPart(tmp3_15);
    auto tmp3_16 = SecDecInternalLambda0*__PowCall1;
    auto tmp3_17 = tmp3_16-tmp1_10;
    auto tmp3_18 = SecDecInternalI(__RealPartCall3);
    auto tmp3_19 = tmp3_18*tmp3_17;
    auto tmp3_20 = x0 + tmp3_19;
    auto tmp3_21 = SecDecInternalI(__RealPartCall1*tmp3_17);
    auto tmp3_22 = tmp3_6*tmp3_18;
    auto tmp3_23 = tmp3_22 + 1 + tmp3_21;
    auto tmp3_24 = SecDecInternalI(__RealPartCall5);
    auto tmp3_25 = tmp3_24*tmp3_17;
    auto tmp3_26 = SecDecInternalLambda1*__PowCall2;
    auto tmp3_27 = tmp3_26-tmp1_9;
    auto tmp3_28 = SecDecInternalI(__RealPartCall4);
    auto tmp3_29 = tmp3_28*tmp3_27;
    auto tmp3_30 = x1 + tmp3_29;
    auto tmp3_31 = tmp3_24*tmp3_27;
    auto tmp3_32 = SecDecInternalI(__RealPartCall2*tmp3_27);
    auto tmp3_33 = tmp3_4*tmp3_28;
    auto tmp3_34 = tmp3_33 + 1 + tmp3_32;
    auto tmp3_35 = tmp3_20 + 1 + tmp3_30;
    auto tmp3_36 = -tmp3_25*tmp3_31;
    auto tmp3_37 = tmp3_23*tmp3_34;
    auto tmp3_38 = tmp3_36 + tmp3_37;
    auto __PowCall6 = SecDecInternalSqr(tmp3_20);
    auto __PowCall7 = SecDecInternalSqr(tmp3_30);
    auto tmp3_39 = 1 + tmp3_30;
    auto tmp3_40 = tmp3_20*tmp3_39;
    auto tmp3_41 = __PowCall6 + tmp3_40;
    auto tmp3_42 = __PowCall4*tmp3_41;
    auto tmp3_43 = tmp3_20 + 1;
    auto tmp3_44 = tmp3_30*tmp3_43;
    auto tmp3_45 = __PowCall7 + tmp3_44;
    auto tmp3_46 = __PowCall3*tmp3_45;
    auto tmp3_47 = tmp3_30 + tmp3_43;
    auto tmp3_48 = __PowCall5*tmp3_47;
    auto tmp3_49 = -s*tmp3_20;
    auto tmp3_50 = tmp3_49 + tmp3_48 + tmp3_46 + tmp3_42;
    auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_35);
    auto __DenominatorCall1 = SecDecInternalDenominator(tmp3_50);
    auto tmp3_51 = -tmp3_9 + tmp3_50;
    auto tmp3_52 = tmp3_38*__DenominatorCall1*__DenominatorCall2;
    auto _SignCheckExpression = SecDecInternalImagPart(tmp3_51);
    SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
    auto tmp3_53 = SecDecInternalRealPart(tmp3_35);
    SecDecInternalSignCheckPositivePolynomial(!(tmp3_53>=0), 1);
    return(tmp3_52);
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
