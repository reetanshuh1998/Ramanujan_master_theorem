#include "optimize_deformation_parameters_sector_4_1.hpp"
namespace pysecdec_sunset_lib_integral
{
void sector_4_order_1_maximal_allowed_deformation_parameters
(
    real_t * restrict const output_deformation_parameters,
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto x1 = integration_variables[1]; (void)x1;
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    auto tmp1_1 = SecDecInternalSqr(m2);
    auto tmp1_2 = tmp1_1-psq;
    auto tmp1_3 = SecDecInternalSqr(m1);
    auto tmp1_4 = tmp1_2 + tmp1_3;
    auto tmp1_5 = 2*x0;
    auto tmp1_6 = tmp1_5-1;
    auto tmp1_7 = SecDecInternalSqr(m3);
    auto tmp1_8 = -tmp1_7*tmp1_6;
    auto tmp3_1 = tmp1_8-tmp1_4;
    auto tmp3_2 = x0*tmp3_1;
    auto tmp3_3 = -x0*tmp1_6;
    auto tmp3_4 = 1 + tmp3_3;
    auto tmp3_5 = x1*tmp1_3*tmp3_4;
    auto tmp3_6 = tmp3_5 + tmp3_2 + tmp1_7 + tmp1_4;
    auto tmp3_7 = x1*x0*tmp3_6;
    auto tmp3_8 = 1-x0;
    auto tmp3_9 = x0*tmp1_7*tmp3_8;
    auto tmp3_10 = tmp3_9 + tmp3_7;
    auto tmp3_11 = -tmp1_7 + 2*tmp1_3;
    auto tmp3_12 = x0*tmp3_11;
    auto tmp3_13 = tmp3_12 + tmp1_3-tmp1_2-tmp1_7;
    auto tmp3_14 = x0*tmp3_13;
    auto tmp3_15 = x0 + 1;
    auto tmp3_16 = -x1*tmp1_5*tmp1_3*tmp3_15;
    auto tmp3_17 = tmp3_16-tmp1_1 + tmp3_14;
    auto tmp3_18 = x1*tmp3_17;
    auto tmp3_19 = tmp1_7*tmp3_15;
    auto tmp3_20 = tmp3_19 + tmp1_4;
    auto tmp3_21 = x0*tmp3_20;
    auto tmp3_22 = tmp3_18 + tmp1_1 + tmp3_21;
    auto tmp3_23 = x1*tmp3_22;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_10))));
    SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_23))));
}
}
