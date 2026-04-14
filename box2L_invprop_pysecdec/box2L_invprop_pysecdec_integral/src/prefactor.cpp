#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "box2L_invprop_pysecdec_integral.hpp"
#include "functions.hpp"

namespace box2L_invprop_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define s real_parameters.at(0)
        #define t real_parameters.at(1)
        return {0,4,{{-2.0},{-3.6911373403938686},{-4.9858599838053861},{-4.5999533513648978},{-3.681199052065825}},true,"eps"};
        #undef s
        #undef t
    }
};
