#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "bubble1L_pysecdec_integral.hpp"
#include "functions.hpp"

namespace bubble1L_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define s real_parameters.at(0)
        #define m1sq real_parameters.at(1)
        #define m2sq real_parameters.at(2)
        return {0,0,{{1.772453850905516}},true,"eps"};
        #undef s
        #undef m1sq
        #undef m2sq
    }
};
