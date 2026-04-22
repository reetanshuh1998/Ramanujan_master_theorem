#include "contour_deformation_sector_2_0.hpp"
namespace triangle1L_massive_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_2_order_0_contour_deformation_polynomial
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
    const auto s = real_parameters[0]; (void)s;
    const auto msq = real_parameters[1]; (void)msq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
    auto tmp1_1 = x0 + x1 + 1;
    auto tmp1_2 = 2*msq;
    auto tmp3_1 = tmp1_1*tmp1_2;
    auto tmp1_3 = -s + tmp3_1;
    auto tmp1_4 = -s + tmp1_2;
    auto tmp1_5 = -1 + x1;
    auto tmp3_2 = x1*SecDecInternalLambda1*tmp1_5;
    auto tmp1_6 = -1 + x0;
    auto tmp3_3 = x0*SecDecInternalLambda0*tmp1_6;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp1_3);
    auto __RealPartCall2 = SecDecInternalRealPart(tmp3_1);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_3;
    auto __Deformedx1Call = x1 + i_*__RealPartCall2*tmp3_2;
    return(__Deformedx1Call*tmp1_2 + __Deformedx0Call*tmp1_4 + __Deformedx0Call*__Deformedx1Call*tmp1_2 + msq + msq*SecDecInternalSqr(__Deformedx1Call)+msq*SecDecInternalSqr(__Deformedx0Call));
}
}
