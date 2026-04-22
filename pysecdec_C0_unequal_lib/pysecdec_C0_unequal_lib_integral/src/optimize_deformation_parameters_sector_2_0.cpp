#include "optimize_deformation_parameters_sector_2_0.hpp"
namespace pysecdec_C0_unequal_lib_integral
{
void sector_2_order_0_maximal_allowed_deformation_parameters
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
    const auto s = real_parameters[0]; (void)s;
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    const auto m3sq = real_parameters[3]; (void)m3sq;
    auto tmp1_1 = SecDecInternalSqr(m1sq);
    auto tmp1_2 = SecDecInternalSqr(m3sq);
    auto tmp1_3 = tmp1_1 + tmp1_2;
    auto tmp1_4 = tmp1_3*x1;
    auto tmp1_5 = SecDecInternalSqr(m2sq);
    auto tmp3_1 = tmp1_4 + tmp1_5-s;
    auto tmp1_6 = -2*x0 + 1;
    auto tmp3_2 = tmp1_2*tmp1_6;
    auto tmp3_3 = tmp3_2-tmp3_1;
    auto tmp3_4 = x0*tmp3_3;
    auto tmp3_5 = tmp3_4 + tmp1_2 + tmp3_1;
    auto tmp3_6 = x0*tmp3_5;
    auto tmp3_7 = -2*x1 + 1;
    auto tmp3_8 = tmp1_1*tmp3_7;
    auto tmp3_9 = -tmp1_5 + tmp3_8;
    auto tmp3_10 = x1*tmp3_9;
    auto tmp3_11 = -x1 + 1;
    auto tmp3_12 = x0*tmp1_3*tmp3_11;
    auto tmp3_13 = tmp3_12 + tmp3_10 + tmp1_5 + tmp1_1;
    auto tmp3_14 = x1*tmp3_13;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_6))));
    SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_14))));
}
}
