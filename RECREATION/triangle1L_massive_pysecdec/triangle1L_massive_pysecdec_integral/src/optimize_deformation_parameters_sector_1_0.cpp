#include "optimize_deformation_parameters_sector_1_0.hpp"
namespace triangle1L_massive_pysecdec_integral
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
    const auto msq = real_parameters[1]; (void)msq;
    auto tmp1_1 = 2*msq;
    auto tmp1_2 = tmp1_1-s;
    auto tmp1_3 = tmp1_2*x0;
    auto tmp3_1 = -tmp1_3 + tmp1_2;
    auto tmp3_2 = x1*tmp3_1;
    auto tmp1_4 = -SecDecInternalSqr(x0);
    auto tmp3_3 = 1 + tmp1_4;
    auto tmp3_4 = msq*tmp3_3;
    auto tmp3_5 = 2*tmp3_4 + tmp3_2;
    auto tmp3_6 = x0*tmp3_5;
    auto tmp3_7 = -x1*tmp1_1;
    auto tmp3_8 = -tmp1_3 + tmp3_7;
    auto tmp3_9 = x1*tmp3_8;
    auto tmp3_10 = tmp3_9 + tmp1_1 + tmp1_3;
    auto tmp3_11 = x1*tmp3_10;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_6))));
    SecDecInternalOutputDeformationParameters(1, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_11))));
}
}
