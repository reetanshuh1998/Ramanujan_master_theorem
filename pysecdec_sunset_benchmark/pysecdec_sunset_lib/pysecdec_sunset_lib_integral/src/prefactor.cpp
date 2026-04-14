#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "pysecdec_sunset_lib_integral.hpp"
#include "functions.hpp"

namespace pysecdec_sunset_lib_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define m1 real_parameters.at(0)
        #define m2 real_parameters.at(1)
        #define m3 real_parameters.at(2)
        #define psq real_parameters.at(3)
        return {-1,1,{{0.5},{0.42278433509846714},{2.8236806608528794}},true,"eps"};
        #undef m1
        #undef m2
        #undef m3
        #undef psq
    }
};
