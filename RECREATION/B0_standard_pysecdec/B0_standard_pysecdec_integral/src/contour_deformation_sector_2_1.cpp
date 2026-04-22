#include "contour_deformation_sector_2_1.hpp"
namespace B0_standard_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_2_order_1_contour_deformation_polynomial
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto psq = real_parameters[0]; (void)psq;
    const auto msq = real_parameters[1]; (void)msq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    auto tmp1_1 = 2*msq;
    auto tmp1_2 = 1 + x0;
    auto tmp3_1 = tmp1_2*tmp1_1;
    auto tmp3_2 = -psq + tmp3_1;
    auto tmp3_3 = -psq + tmp1_1;
    auto tmp1_3 = -1 + x0;
    auto tmp3_4 = x0*SecDecInternalLambda0*tmp1_3;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp3_2);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_4;
    return(__Deformedx0Call*tmp3_3 + msq + msq*SecDecInternalSqr(__Deformedx0Call));
}
}
