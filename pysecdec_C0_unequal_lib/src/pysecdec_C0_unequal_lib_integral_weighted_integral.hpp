#ifndef pysecdec_C0_unequal_lib_integral_weighted_integral_hpp_included
#define pysecdec_C0_unequal_lib_integral_weighted_integral_hpp_included

#include <vector> // std::vector
#include <string> // std::string

#include "pysecdec_C0_unequal_lib.hpp"
#include "pysecdec_C0_unequal_lib_integral/pysecdec_C0_unequal_lib_integral.hpp"

namespace pysecdec_C0_unequal_lib
{
    namespace pysecdec_C0_unequal_lib_integral
    {
        template<typename integrator_t>
        std::vector<nested_series_t<sum_t>> make_integral
        (
            const std::vector<real_t>& real_parameters,
            const std::vector<complex_t>& complex_parameters,
            const integrator_t& integrator
            #if pysecdec_C0_unequal_lib_contour_deformation
                ,unsigned number_of_presamples,
                real_t deformation_parameters_maximum,
                real_t deformation_parameters_minimum,
                real_t deformation_parameters_decrease_factor
            #endif
        );
        nested_series_t<sum_t> make_weighted_integral
        (
            const std::vector<real_t>& real_parameters,
            const std::vector<complex_t>& complex_parameters,
            const std::vector<nested_series_t<sum_t>>& integrals,
            const unsigned int amp_idx,
            const std::string& lib_path
        );
    }
};
#endif
