#include <secdecutil/series.hpp>
#include <secdecutil/uncertainties.hpp>
#include <vector>

#include "tadpole1L_pysecdec_integral.hpp"
#include "functions.hpp"

namespace tadpole1L_pysecdec_integral
{
    nested_series_t<integrand_return_t> prefactor(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        #define msq real_parameters.at(0)
        return {-1,0,{{1.0},{0.42278433509846714}},true,"eps"};
        #undef msq
    }
};
