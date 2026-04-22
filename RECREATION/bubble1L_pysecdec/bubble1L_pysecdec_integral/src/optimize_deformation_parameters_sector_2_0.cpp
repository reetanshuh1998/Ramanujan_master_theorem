#include "optimize_deformation_parameters_sector_2_0.hpp"
namespace bubble1L_pysecdec_integral
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
    const auto s = real_parameters[0]; (void)s;
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    auto tmp1_1 = -2*x0 + 1;
    auto tmp3_1 = m1sq*tmp1_1;
    auto tmp1_2 = m2sq-s;
    auto tmp3_2 = -tmp1_2 + tmp3_1;
    auto tmp3_3 = x0*tmp3_2;
    auto tmp3_4 = tmp3_3 + m1sq + tmp1_2;
    auto tmp3_5 = x0*tmp3_4;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_5))));
}
}
