#ifndef bubble1L_pysecdec_integral_codegen_sector_1_0_hpp_included
#define bubble1L_pysecdec_integral_codegen_sector_1_0_hpp_included
#include "bubble1L_pysecdec_integral.hpp"
#include "functions.hpp"
#include "contour_deformation_sector_1_0.hpp"
namespace bubble1L_pysecdec_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction sector_1_order_0_integrand;
#ifdef SECDEC_WITH_CUDA
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_1_order_0_integrand();
#endif
}
#endif
