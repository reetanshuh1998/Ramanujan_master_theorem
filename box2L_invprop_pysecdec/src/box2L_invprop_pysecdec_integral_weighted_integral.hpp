#ifndef box2L_invprop_pysecdec_integral_weighted_integral_hpp_included
#define box2L_invprop_pysecdec_integral_weighted_integral_hpp_included

#include <vector> // std::vector
#include <string> // std::string

#include "box2L_invprop_pysecdec.hpp"
#include "box2L_invprop_pysecdec_integral/box2L_invprop_pysecdec_integral.hpp"

namespace box2L_invprop_pysecdec
{
    namespace box2L_invprop_pysecdec_integral
    {
        template<typename integrator_t>
        std::vector<nested_series_t<sum_t>> make_integral
        (
            const std::vector<real_t>& real_parameters,
            const std::vector<complex_t>& complex_parameters,
            const integrator_t& integrator
            #if box2L_invprop_pysecdec_contour_deformation
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
