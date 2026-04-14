#include "sector_2_1.hpp"
namespace pysecdec_sunset_lib_integral
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
    const auto x1 = integration_variables[1]; (void)x1;
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
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
    auto __PowCall7 = SecDecInternalSqr(x0);
    auto __PowCall8 = SecDecInternalSqr(x1);
    auto __PowCall9 = SecDecInternalSqr(m1);
    auto __PowCall10 = SecDecInternalSqr(m2);
    auto __PowCall11 = SecDecInternalSqr(m3);
    auto __DenominatorCall1 = SecDecInternalDenominator(x1);
    auto __DenominatorCall6 = SecDecInternalDenominator(x0);
    auto tmp2_15 = __PowCall8*__PowCall11;
    auto tmp2_16 = tmp1_5*__PowCall11;
    auto tmp3_6 = 2*tmp2_15 + tmp2_16;
    auto tmp2_17 = x1 + __PowCall8;
    auto tmp2_18 = __PowCall7*__PowCall11;
    auto tmp3_7 = tmp2_18*tmp2_17;
    auto tmp2_19 = __PowCall8*__PowCall9;
    auto tmp2_20 = x0*tmp2_19;
    auto tmp2_21 = tmp1_3*__PowCall11;
    auto tmp2_22 = tmp1_13*__PowCall10;
    auto tmp2_23 = tmp1_14*__PowCall9;
    auto tmp3_8 = tmp2_23 + tmp2_22 + tmp1_12 + tmp2_21 + tmp2_20 + tmp3_7;
    auto tmp3_9 = tmp1_8*__PowCall10;
    auto tmp3_10 = tmp1_1*__PowCall9;
    auto tmp3_11 = 2*tmp2_18 + tmp3_10;
    auto tmp3_12 = tmp1_1*tmp2_15;
    auto tmp3_13 = x1*__PowCall9;
    auto tmp3_14 = tmp3_2*__PowCall11;
    auto tmp2_24 = tmp1_11*__PowCall10;
    auto tmp3_15 = tmp2_24-tmp1_10 + tmp3_14 + tmp3_13 + tmp2_19 + tmp3_12;
    auto tmp3_16 = __PowCall10 + __PowCall11;
    auto tmp3_17 = tmp3_16*x0;
    auto tmp3_18 = tmp3_17-tmp1_7;
    auto tmp3_19 = tmp1_6*tmp2_18;
    auto tmp3_20 = tmp3_1*__PowCall9;
    auto tmp3_21 = tmp3_20 + tmp3_19 + tmp3_18;
    auto tmp3_22 = tmp1_8*__PowCall9;
    auto tmp3_23 = tmp3_22 + tmp2_18 + tmp3_18;
    auto tmp3_24 = tmp1_6*__PowCall9;
    auto tmp3_25 = tmp1_4*__PowCall11;
    auto tmp3_26 = -psq + tmp3_25 + __PowCall10 + tmp3_24;
    auto __PowCall6 = SecDecInternalSqr(__DenominatorCall6);
    auto __PowCall16 = SecDecInternalSqr(__DenominatorCall1);
    auto __RealPartCall7 = SecDecInternalRealPart(__PowCall10);
    auto tmp3_27 = __DenominatorCall6*__PowCall6;
    auto tmp3_28 = __PowCall16*tmp3_27;
    auto tmp3_29 = __DenominatorCall1*__PowCall6;
    auto tmp3_30 = SecDecInternalLambda0*__PowCall7;
    auto tmp3_31 = -tmp1_18 + tmp3_30;
    auto tmp3_32 = SecDecInternalI(__RealPartCall7);
    auto tmp3_33 = tmp3_32*tmp3_31;
    auto tmp3_34 = x0 + tmp3_33;
    auto tmp3_35 = tmp3_5*tmp3_32;
    auto tmp3_36 = 1 + tmp3_35;
    auto _logCall1 = SecDecInternalLog(__PowCall6);
    auto _logCall2 = SecDecInternalLog(tmp3_28);
    auto _logCall3 = SecDecInternalLog(tmp3_27);
    auto _logCall4 = SecDecInternalLog(tmp3_29);
    auto __RealPartCall1 = SecDecInternalRealPart(tmp3_6);
    auto __RealPartCall2 = SecDecInternalRealPart(tmp3_11);
    auto __RealPartCall3 = SecDecInternalRealPart(tmp3_15);
    auto __RealPartCall4 = SecDecInternalRealPart(tmp3_21);
    auto __RealPartCall5 = SecDecInternalRealPart(tmp3_23);
    auto __RealPartCall6 = SecDecInternalRealPart(tmp3_26);
    auto tmp3_37 = tmp3_34 + 1;
    auto tmp3_38 = __PowCall10*tmp3_37;
    auto tmp3_39 = SecDecInternalI(tmp3_3*__RealPartCall4);
    auto tmp3_40 = 1 + tmp3_39;
    auto tmp3_41 = SecDecInternalI(__RealPartCall5*SecDecInternalLambda1);
    auto tmp3_42 = tmp3_41-1;
    auto tmp3_43 = __PowCall7*SecDecInternalLambda0;
    auto tmp3_44 = tmp3_43-tmp1_18;
    auto tmp3_45 = SecDecInternalI(tmp3_44);
    auto tmp3_46 = __RealPartCall3*tmp3_45;
    auto tmp3_47 = x0 + tmp3_46;
    auto tmp3_48 = __RealPartCall1*tmp3_44;
    auto tmp3_49 = __RealPartCall3*tmp3_5;
    auto tmp3_50 = tmp3_49 + tmp3_48;
    auto tmp3_51 = SecDecInternalI(tmp3_50);
    auto tmp3_52 = 1 + tmp3_51;
    auto tmp3_53 = __RealPartCall6*tmp3_45;
    auto tmp3_54 = SecDecInternalLambda1*__PowCall8;
    auto tmp3_55 = tmp3_54-tmp1_17;
    auto tmp3_56 = SecDecInternalI(tmp3_55);
    auto tmp3_57 = __RealPartCall4*tmp3_56;
    auto tmp3_58 = x1 + tmp3_57;
    auto tmp3_59 = __RealPartCall6*tmp3_56;
    auto tmp3_60 = __RealPartCall2*tmp3_55;
    auto tmp3_61 = __RealPartCall4*tmp3_4;
    auto tmp3_62 = tmp3_61 + tmp3_60;
    auto tmp3_63 = SecDecInternalI(tmp3_62);
    auto tmp3_64 = 1 + tmp3_63;
    auto __PowCall1 = SecDecInternalSqr(_logCall1);
    auto __PowCall2 = SecDecInternalSqr(_logCall3);
    auto __CondefFacx1Call2 = -tmp3_42;
    auto _d_Deformedx1d1Call2 = -tmp3_42;
    auto tmp3_65 = tmp3_58 + 1;
    auto tmp3_66 = tmp3_47*tmp3_65;
    auto tmp3_67 = 1 + tmp3_66;
    auto tmp3_68 = -tmp3_53*tmp3_59;
    auto tmp3_69 = tmp3_52*tmp3_64;
    auto tmp3_70 = tmp3_68 + tmp3_69;
    auto tmp3_71 = tmp3_36*_d_Deformedx1d1Call2;
    auto _logCall5 = SecDecInternalLog(tmp3_40);
    auto _logCall6 = SecDecInternalLog(__CondefFacx1Call2);
    auto _logCall8 = SecDecInternalLog(tmp3_38);
    auto _logCall10 = SecDecInternalLog(tmp3_37);
    auto __PowCall12 = SecDecInternalSqr(tmp3_47);
    auto __PowCall13 = SecDecInternalSqr(tmp3_58);
    auto __PowCall15 = SecDecInternalSqr(tmp3_37)*tmp3_37;
    auto __DenominatorCall2 = SecDecInternalDenominator(tmp3_40);
    auto __DenominatorCall4 = SecDecInternalDenominator(__CondefFacx1Call2);
    auto tmp3_72 = __PowCall11*__PowCall12;
    auto tmp3_73 = __PowCall11 + __PowCall10-psq + __PowCall9;
    auto tmp3_74 = tmp3_47*tmp3_73;
    auto tmp3_75 = tmp3_74 + __PowCall9 + tmp3_72;
    auto tmp3_76 = tmp3_58*tmp3_75;
    auto tmp3_77 = __PowCall13*tmp3_72;
    auto tmp3_78 = __PowCall9*__PowCall13;
    auto tmp3_79 = tmp3_78 + __PowCall10;
    auto tmp3_80 = tmp3_47*tmp3_79;
    auto tmp3_81 = tmp3_76 + tmp3_80 + __PowCall10 + tmp3_77;
    auto _logCall9 = SecDecInternalLog(tmp3_67);
    auto __PowCall3 = SecDecInternalSqr(_logCall6);
    auto __PowCall4 = SecDecInternalSqr(_logCall8);
    auto __PowCall5 = SecDecInternalSqr(_logCall10);
    auto __PowCall14 = SecDecInternalSqr(tmp3_67)*tmp3_67;
    auto __DenominatorCall5 = SecDecInternalDenominator(__PowCall15);
    auto _logCall7 = SecDecInternalLog(tmp3_81);
    auto __DenominatorCall3 = SecDecInternalDenominator(__PowCall14);
    auto tmp3_82 = -tmp3_9 + tmp3_38;
    auto tmp3_83 = -tmp3_8 + tmp3_81;
    auto tmp3_84 = 2*_logCall8;
    auto tmp3_85 = tmp3_84-_logCall6;
    auto tmp3_86 = -3*_logCall4 + 2*_logCall2;
    auto tmp3_87 = 3*_logCall10;
    auto tmp3_88 = -tmp3_87 + tmp3_86 + tmp3_85;
    auto tmp3_89 = __DenominatorCall1*tmp3_88;
    auto tmp3_90 = -2*_logCall3 + 3*_logCall1;
    auto tmp3_91 = -_logCall6-tmp3_90;
    auto tmp3_92 = tmp3_91*tmp3_84;
    auto tmp3_93 = tmp3_90-tmp3_85;
    auto tmp3_94 = tmp3_93*tmp3_87;
    auto tmp3_95 = __PowCall4 + __PowCall2;
    auto tmp3_96 = __PowCall5 + __PowCall1;
    auto tmp3_97 = _logCall3*_logCall1;
    auto tmp3_98 = _logCall6*tmp3_90;
    auto tmp3_99 = tmp3_89 + tmp3_94 + tmp3_92 + tmp3_98-6*tmp3_97 + SecDecInternalQuo(1, 2)*__PowCall3 + SecDecInternalQuo(9, 2)*tmp3_96 + 2*tmp3_95;
    auto tmp3_100 = tmp3_38*__DenominatorCall5*__DenominatorCall4*tmp3_71*tmp3_99;
    auto tmp3_101 = 3*_logCall9 + _logCall5-2*_logCall7-tmp3_86;
    auto tmp3_102 = __DenominatorCall1*tmp3_81*__DenominatorCall3*__DenominatorCall2*tmp3_70*tmp3_101;
    auto tmp3_103 = tmp3_102 + tmp3_100;
    auto _SignCheckExpression = SecDecInternalImagPart(tmp3_82);
    SecDecInternalSignCheckContourDeformation(!(_SignCheckExpression<=0), 1);
    auto tmp3_104 = SecDecInternalImagPart(tmp3_83);
    SecDecInternalSignCheckContourDeformation(!(tmp3_104<=0), 2);
    auto tmp3_105 = SecDecInternalRealPart(tmp3_37);
    SecDecInternalSignCheckPositivePolynomial(!(tmp3_105>=0), 1);
    auto tmp3_106 = SecDecInternalRealPart(tmp3_67);
    SecDecInternalSignCheckPositivePolynomial(!(tmp3_106>=0), 2);
    return(tmp3_103);
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
