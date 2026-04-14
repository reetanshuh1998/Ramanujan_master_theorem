#include "optimize_deformation_parameters_sector_1_n1.hpp"
namespace pysecdec_sunset_lib_integral
{
void sector_1_order_n1_maximal_allowed_deformation_parameters
(
    real_t * restrict const output_deformation_parameters,
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    auto tmp1_1 = 1-x0;
    auto tmp3_1 = x0*tmp1_1*SecDecInternalSqr(m1);
    SecDecInternalOutputDeformationParameters(0, SecDecInternalDenominator(SecDecInternalAbs(SecDecInternalRealPart(tmp3_1))));
}
}
