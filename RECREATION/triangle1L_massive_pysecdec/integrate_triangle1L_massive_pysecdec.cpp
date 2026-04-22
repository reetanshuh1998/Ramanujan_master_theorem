#include <cstdlib> // std::atof
#include <iostream> // std::cout
#include <vector> // std::vector

#include <secdecutil/integrators/cuba.hpp> // secdecutil::cuba::Vegas, secdecutil::cuba::Suave, secdecutil::cuba::Cuhre, secdecutil::cuba::Divonne
#include <secdecutil/integrators/qmc.hpp> // secdecutil::integrators::Qmc
#include <secdecutil/series.hpp> // secdecutil::Series
#include <secdecutil/uncertainties.hpp> // secdecutil::UncorrelatedDeviation

#include "triangle1L_massive_pysecdec.hpp"

int main(int argc, const char *argv[])
{
    // Check the command line argument number
    if (argc != 1 + 2 + 2*0) {
        std::cout << "usage: " << argv[0];
        for ( const auto& name : triangle1L_massive_pysecdec::names_of_real_parameters )
            std::cout << " " << name;
        for ( const auto& name : triangle1L_massive_pysecdec::names_of_complex_parameters )
            std::cout << " re(" << name << ") im(" << name << ")";
        std::cout << std::endl;
        return 1;
    }

    std::vector<triangle1L_massive_pysecdec::real_t> real_parameters; // = { real parameter values ("s","msq") go here };
    std::vector<triangle1L_massive_pysecdec::complex_t> complex_parameters; // = { complex parameter values () go here };

    // Load parameters from the command line arguments
    for (int i = 1; i < 1 + 2; i++)
        real_parameters.push_back(triangle1L_massive_pysecdec::real_t(std::atof(argv[i])));

    for (int i = 1 + 2; i < 1 + 2 + 2*0; i += 2) {
        triangle1L_massive_pysecdec::real_t re = std::atof(argv[i]);
        triangle1L_massive_pysecdec::real_t im = std::atof(argv[i+1]);
        complex_parameters.push_back(triangle1L_massive_pysecdec::complex_t(re, im));
    }

    // Set up Integrator
    std::cerr << "Setting up integrator" << std::endl;
    //secdecutil::cuba::Vegas<triangle1L_massive_pysecdec::integrand_return_t> integrator;
    secdecutil::integrators::Qmc<
                                    triangle1L_massive_pysecdec::integrand_return_t,
                                    triangle1L_massive_pysecdec::maximal_number_of_integration_variables,
                                    integrators::transforms::Korobov<3>::type,
                                    triangle1L_massive_pysecdec::user_integrand_t
                                > integrator;
    integrator.verbosity = 1;

    // Construct the amplitudes
    std::cerr << "Generating amplitudes (optimising contour if required)" << std::endl;
    std::vector<triangle1L_massive_pysecdec::nested_series_t<triangle1L_massive_pysecdec::sum_t>> unwrapped_amplitudes =
        triangle1L_massive_pysecdec::make_amplitudes(real_parameters, complex_parameters, "triangle1L_massive_pysecdec_data", integrator);

    // Pack amplitudes into handler
    std::cerr << "Packing amplitudes into handler" << std::endl;
    triangle1L_massive_pysecdec::handler_t<triangle1L_massive_pysecdec::amplitudes_t> amplitudes
    (
        unwrapped_amplitudes,
        integrator.epsrel, integrator.epsabs
        // further optional arguments: maxeval, mineval, maxincreasefac, min_epsrel, min_epsabs, max_epsrel, max_epsabs
    );
    amplitudes.verbose = true;

    // The optional further arguments of the handler are set for all orders.
    // To specify different settings for a particular order in a particular amplitude,
    // type e.g.: amplitudes.expression.at(<amplitude index>).at(<order>).epsrel = 1e-5;

    // optionally set wall clock limit (in seconds)
    // Note: Only the wall clock time spent in "amplitudes.evaluate()" is considered for these limits.
    // amplitudes.wall_clock_limit = 60 *  8;

    // optionally the errormode, which defines how epsrel and epsabs are defined for complex values, can be changed. The default is
    // amplitudes.errormode = amplitudes.abs;
    // Possible choices besides abs are: all, largest, real, imag
    // With the choice  'largest', the relative uncertainty is defined as 'max( |Re(error)|, |Im(error)|)/max( |Re(result)|, |Im(result)|)'.
    // Choosing 'all' will apply epsrel and epsabs to both the real and imaginary part separately.
    // Note: If either the real or imaginary part integrate to 0, the choices 'all', 'real' or 'imag' might prevent the integration
    // from stopping since the requested precision epsrel cannot be reached.

    // optionally compute multiple integrals concurrently
    // Note: The integrals themselves may also be computed in parallel irrespective of this option.
    // amplitudes.number_of_threads = 12;

    // The cuda driver does not automatically remove unnecessary functions from the device memory
    // such that the device may run out of memory after some time. This option controls after how many
    // integrals "cudaDeviceReset()" is called to clear the memory. With the default "0", "cudaDeviceReset()"
    // is never called. This option is ignored if compiled without cuda.
    // amplitudes.reset_cuda_after = 2000;

    // compute the amplitudes
    std::cerr << "Integrating" << std::endl;
    const std::vector<triangle1L_massive_pysecdec::nested_series_t<secdecutil::UncorrelatedDeviation<triangle1L_massive_pysecdec::integrand_return_t>>> result = amplitudes.evaluate();

    // print the result
    for (unsigned int amp_idx = 0; amp_idx < triangle1L_massive_pysecdec::number_of_amplitudes; ++amp_idx)
        std::cout << "amplitude" << amp_idx << " = " << result.at(amp_idx) << std::endl;
}
