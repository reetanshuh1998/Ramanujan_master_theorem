#ifndef pysecdec_C0_unequal_lib_integral_codegen_sector_2_0_hpp_included
#define pysecdec_C0_unequal_lib_integral_codegen_sector_2_0_hpp_included
#include "pysecdec_C0_unequal_lib_integral.hpp"
#include "functions.hpp"
#include "contour_deformation_sector_2_0.hpp"
namespace pysecdec_C0_unequal_lib_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction sector_2_order_0_integrand;
#ifdef SECDEC_WITH_CUDA
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_2_order_0_integrand();
#endif
}
#endif
