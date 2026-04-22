#include "optimize_deformation_parameters_sector_1_1.hpp"
namespace B0_standard_pysecdec_integral
{
void sector_1_order_1_maximal_allowed_deformation_parameters
(
    real_t * restrict const output_deformation_parameters,
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto psq = real_parameters[0]; (void)psq;
    const auto msq = real_parameters[1]; (void)msq;
    auto tmp1_1 = 2*msq;
    auto tmp1_2 = -x0*tmp1_1;
    auto tmp3_1 = psq + tmp1_2;
    auto tmp3_2 = x0*tmp3_1;
    auto tmp3_3 = tmp3_2-psq + tmp1_1;
    auto tmp3_4 = x0*tmp3_3;
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_4))));
}
}
