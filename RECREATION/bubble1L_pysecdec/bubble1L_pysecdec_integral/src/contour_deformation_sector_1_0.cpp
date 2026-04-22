#include "contour_deformation_sector_1_0.hpp"
namespace bubble1L_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_1_order_0_contour_deformation_polynomial
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto s = real_parameters[0]; (void)s;
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    auto tmp1_1 = 1 + 2*x0;
    auto tmp3_1 = m2sq*tmp1_1;
    auto tmp1_2 = s-m1sq;
    auto tmp3_2 = -tmp1_2 + tmp3_1;
    auto tmp3_3 = m2sq-tmp1_2;
    auto tmp1_3 = -1 + x0;
    auto tmp3_4 = SecDecInternalLambda0*x0*tmp1_3;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp3_2);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_4;
    return(__Deformedx0Call*tmp3_3 + m2sq*SecDecInternalSqr(__Deformedx0Call)+m1sq);
}
}
