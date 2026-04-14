#include "contour_deformation_sector_6_1.hpp"
namespace pysecdec_sunset_lib_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_6_order_1_contour_deformation_polynomial
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
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    const auto SecDecInternalLambda1 = deformation_parameters[1]; (void)SecDecInternalLambda1;
    auto tmp1_1 = SecDecInternalSqr(m3);
    auto tmp1_2 = SecDecInternalSqr(m2);
    auto tmp1_3 = SecDecInternalSqr(m1);
    auto tmp1_4 = tmp1_1 + tmp1_2 + tmp1_3-psq;
    auto tmp1_5 = tmp1_3*x0;
    auto tmp1_6 = tmp1_5 + tmp1_4;
    auto tmp3_1 = x0*tmp1_6;
    auto tmp3_2 = tmp1_2 + tmp1_5;
    auto tmp1_7 = 2*x0;
    auto tmp3_3 = x1*tmp3_2*tmp1_7;
    auto tmp3_4 = tmp3_3 + tmp1_2 + tmp3_1;
    auto tmp3_5 = tmp1_7*tmp1_3;
    auto tmp3_6 = tmp1_2 + tmp3_5;
    auto tmp3_7 = x1*tmp3_6;
    auto tmp3_8 = tmp3_7 + tmp3_5 + tmp1_4;
    auto tmp3_9 = x1*tmp3_8;
    auto tmp3_10 = tmp1_1 + tmp3_9;
    auto tmp3_11 = -1 + x1;
    auto tmp3_12 = x1*SecDecInternalLambda1*tmp3_11;
    auto tmp1_8 = -1 + x0;
    auto tmp3_13 = x0*SecDecInternalLambda0*tmp1_8;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp3_10);
    auto __RealPartCall2 = SecDecInternalRealPart(tmp3_4);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_13;
    auto __Deformedx1Call = x1 + i_*__RealPartCall2*tmp3_12;
    return(tmp1_1 + __Deformedx1Call*tmp1_2 + __Deformedx0Call*tmp1_1 + __Deformedx0Call*__Deformedx1Call*tmp1_4 + __Deformedx0Call*SecDecInternalSqr(__Deformedx1Call)*tmp1_2 + SecDecInternalSqr(__Deformedx0Call)*__Deformedx1Call*tmp1_3 + SecDecInternalSqr(__Deformedx0Call)*SecDecInternalSqr(__Deformedx1Call)*tmp1_3);
}
}
