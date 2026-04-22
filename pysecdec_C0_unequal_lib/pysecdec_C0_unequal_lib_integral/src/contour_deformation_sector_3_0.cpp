#include "contour_deformation_sector_3_0.hpp"
namespace pysecdec_C0_unequal_lib_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_3_order_0_contour_deformation_polynomial
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
    const auto m1sq = real_parameters[1]; (void)m1sq;
    const auto m2sq = real_parameters[2]; (void)m2sq;
    const auto m3sq = real_parameters[3]; (void)m3sq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
    auto tmp1_1 = SecDecInternalSqr(m3sq);
    auto tmp1_2 = SecDecInternalSqr(m1sq);
    auto tmp1_3 = tmp1_1 + tmp1_2;
    auto tmp1_4 = SecDecInternalSqr(m2sq);
    auto tmp1_5 = tmp1_4 + tmp1_2;
    auto tmp1_6 = x0*tmp1_5;
    auto tmp1_7 = x1*tmp1_2;
    auto tmp3_1 = tmp1_6 + 2*tmp1_7 + tmp1_3;
    auto tmp3_2 = -s + tmp1_1 + tmp1_4;
    auto tmp1_8 = x1*tmp1_5;
    auto tmp1_9 = x0*tmp1_4;
    auto tmp3_3 = 2*tmp1_9 + tmp1_8 + tmp3_2;
    auto tmp3_4 = -1 + x1;
    auto tmp3_5 = SecDecInternalLambda1*x1*tmp3_4;
    auto tmp1_10 = -1 + x0;
    auto tmp3_6 = SecDecInternalLambda0*x0*tmp1_10;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp3_3);
    auto __RealPartCall2 = SecDecInternalRealPart(tmp3_1);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_6;
    auto __Deformedx1Call = x1 + i_*__RealPartCall2*tmp3_5;
    return(tmp1_1 + __Deformedx1Call*tmp1_3 + SecDecInternalSqr(__Deformedx1Call)*tmp1_2 + __Deformedx0Call*tmp3_2 + __Deformedx0Call*__Deformedx1Call*tmp1_5 + SecDecInternalSqr(__Deformedx0Call)*tmp1_4);
}
}
