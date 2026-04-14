#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "elliptic2L_pysecdec_integral.hpp"
#include "functions.hpp"

namespace elliptic2L_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define s real_parameters.at(0)
        #define msq complex_parameters.at(0)
        return {0,0,{{-1.0}},true,"eps"};
        #undef s
        #undef msq
    }
};
