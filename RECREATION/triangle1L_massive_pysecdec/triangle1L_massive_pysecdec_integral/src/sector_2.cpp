#include <secdecutil/series.hpp>

#include "sector_2_0.hpp"
#include "contour_deformation_sector_2_0.hpp"
#include "optimize_deformation_parameters_sector_2_0.hpp"

namespace triangle1L_massive_pysecdec_integral
{
nested_series_t<sector_container_t> get_integrand_of_sector_2()
{
return {0,0,{{2,{0},2,sector_2_order_0_integrand,
#ifdef SECDEC_WITH_CUDA
get_device_sector_2_order_0_integrand,
#endif
sector_2_order_0_contour_deformation_polynomial,sector_2_order_0_maximal_allowed_deformation_parameters}},true,"eps"};
}

}
