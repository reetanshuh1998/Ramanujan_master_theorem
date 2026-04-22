#include "optimize_deformation_parameters_sector_1_0.hpp"
namespace pysecdec_C0_unequal_lib_integral
{
void sector_1_order_0_maximal_allowed_deformation_parameters
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
    auto tmp1_1 = SecDecInternalSqr(m2sq);
    auto tmp1_2 = SecDecInternalSqr(m3sq);
    auto tmp1_3 = -s + tmp1_1 + tmp1_2;
    auto tmp1_4 = tmp1_3*x0;
    auto tmp3_1 = -tmp1_4 + tmp1_3;
    auto tmp3_2 = x1*tmp3_1;
    auto tmp1_5 = -2*x0 + 1;
    auto tmp3_3 = tmp1_2*tmp1_5;
    auto tmp1_6 = SecDecInternalSqr(m1sq);
    auto tmp3_4 = -tmp1_6 + tmp3_3;
    auto tmp3_5 = x0*tmp3_4;
    auto tmp3_6 = tmp3_2 + tmp3_5 + tmp1_6 + tmp1_2;
    auto tmp3_7 = x0*tmp3_6;
    auto tmp3_8 = -2*x1 + 1;
    auto tmp3_9 = tmp1_1*tmp3_8;
    auto tmp3_10 = tmp1_4 + tmp1_6;
    auto tmp3_11 = -tmp3_10 + tmp3_9;
    auto tmp3_12 = x1*tmp3_11;
    auto tmp3_13 = tmp3_12 + tmp1_1 + tmp3_10;
    auto tmp3_14 = x1*tmp3_13;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_7))));
    SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_14))));
}
}
