#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "B0_standard_pysecdec_integral.hpp"
#include "functions.hpp"

namespace B0_standard_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define psq real_parameters.at(0)
        #define msq real_parameters.at(1)
        return {-1,0,{{1.0},{-0.57721566490153286}},true,"eps"};
        #undef psq
        #undef msq
    }
};
