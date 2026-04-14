#include <secdecutil/series.hpp>

#include "sector_3_n1.hpp"
#include "contour_deformation_sector_3_n1.hpp"
#include "optimize_deformation_parameters_sector_3_n1.hpp"
#include "sector_3_0.hpp"
#include "contour_deformation_sector_3_0.hpp"
#include "optimize_deformation_parameters_sector_3_0.hpp"
#include "sector_3_1.hpp"
#include "contour_deformation_sector_3_1.hpp"
#include "optimize_deformation_parameters_sector_3_1.hpp"

namespace pysecdec_sunset_lib_integral
{
nested_series_t<sector_container_t> get_integrand_of_sector_3()
{
return {-1,1,{{3,{-1},1,sector_3_order_n1_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_3_order_n1_integrand,
#endif
sector_3_order_n1_contour_deformation_polynomial,sector_3_order_n1_maximal_allowed_deformation_parameters},{3,{0},2,sector_3_order_0_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_3_order_0_integrand,
#endif
sector_3_order_0_contour_deformation_polynomial,sector_3_order_0_maximal_allowed_deformation_parameters},{3,{1},2,sector_3_order_1_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_3_order_1_integrand,
#endif
sector_3_order_1_contour_deformation_polynomial,sector_3_order_1_maximal_allowed_deformation_parameters}},true,"eps"};
}

}
