#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "P126_pysecdec_integral.hpp"
#include "functions.hpp"

namespace P126_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define s real_parameters.at(0)
        #define msq complex_parameters.at(0)
        return {0,2,{{1.0},{0.84556867019693428},{1.6473613217057588}},true,"eps"};
        #undef s
        #undef msq
    }
};
