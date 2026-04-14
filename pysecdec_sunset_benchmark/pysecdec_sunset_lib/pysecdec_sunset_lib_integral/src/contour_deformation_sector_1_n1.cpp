#include "contour_deformation_sector_1_n1.hpp"
namespace pysecdec_sunset_lib_integral
{
#ifdef SECDEC_WITH_CUDA
#define SecDecInternalRealPart(x) (complex_t{x}).real()
#else
#define SecDecInternalRealPart(x) std::real(x)
#endif
integrand_return_t sector_1_order_n1_contour_deformation_polynomial
(
    real_t const * restrict const integration_variables,
    real_t const * restrict const real_parameters,
    complex_t const * restrict const complex_parameters,
    real_t const * restrict const deformation_parameters,
    secdecutil::ResultInfo * restrict const result_info
)
{
    const auto x0 = integration_variables[0]; (void)x0;
    const auto m1 = real_parameters[0]; (void)m1;
    const auto m2 = real_parameters[1]; (void)m2;
    const auto m3 = real_parameters[2]; (void)m3;
    const auto psq = real_parameters[3]; (void)psq;
    const auto SecDecInternalLambda0 = deformation_parameters[0]; (void)SecDecInternalLambda0;
    auto tmp1_1 = SecDecInternalSqr(m1);
    auto tmp1_2 = -1 + x0;
    auto tmp3_1 = SecDecInternalLambda0*x0*tmp1_2;
    auto __RealPartCall1 = SecDecInternalRealPart(tmp1_1);
    auto __Deformedx0Call = x0 + i_*__RealPartCall1*tmp3_1;
    return(tmp1_1 + __Deformedx0Call*tmp1_1);
}
}
