#include <secdecutil/series.hpp>

#include "sector_5_n1.hpp"
#include "contour_deformation_sector_5_n1.hpp"
#include "optimize_deformation_parameters_sector_5_n1.hpp"
#include "sector_5_0.hpp"
#include "contour_deformation_sector_5_0.hpp"
#include "optimize_deformation_parameters_sector_5_0.hpp"
#include "sector_5_1.hpp"
#include "contour_deformation_sector_5_1.hpp"
#include "optimize_deformation_parameters_sector_5_1.hpp"

namespace pysecdec_sunset_lib_integral
{
nested_series_t<sector_container_t> get_integrand_of_sector_5()
{
return {-1,1,{{5,{-1},1,sector_5_order_n1_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_5_order_n1_integrand,
#endif
sector_5_order_n1_contour_deformation_polynomial,sector_5_order_n1_maximal_allowed_deformation_parameters},{5,{0},2,sector_5_order_0_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_5_order_0_integrand,
#endif
sector_5_order_0_contour_deformation_polynomial,sector_5_order_0_maximal_allowed_deformation_parameters},{5,{1},2,sector_5_order_1_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_5_order_1_integrand,
#endif
sector_5_order_1_contour_deformation_polynomial,sector_5_order_1_maximal_allowed_deformation_parameters}},true,"eps"};
}

}
