#include <secdecutil/series.hpp>

#include "sector_1_0.hpp"
#include "contour_deformation_sector_1_0.hpp"
#include "optimize_deformation_parameters_sector_1_0.hpp"

namespace bubble1L_pysecdec_integral
{
nested_series_t<sector_container_t> get_integrand_of_sector_1()
{
return {0,0,{{1,{0},1,sector_1_order_0_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_1_order_0_integrand,
#endif
sector_1_order_0_contour_deformation_polynomial,sector_1_order_0_maximal_allowed_deformation_parameters}},true,"eps"};
}

}
