#ifndef pysecdec_sunset_lib_integral_codegen_sector_6_n1_hpp_included
#define pysecdec_sunset_lib_integral_codegen_sector_6_n1_hpp_included
#include "pysecdec_sunset_lib_integral.hpp"
#include "functions.hpp"
#include "contour_deformation_sector_6_n1.hpp"
namespace pysecdec_sunset_lib_integral
{
#ifdef SECDEC_WITH_CUDA
__host__ __device__
#endif
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction sector_6_order_n1_integrand;
#ifdef SECDEC_WITH_CUDA
secdecutil::SectorContainerWithDeformation<real_t, complex_t>::DeformedIntegrandFunction* get_device_sector_6_order_n1_integrand();
#endif
}
#endif
