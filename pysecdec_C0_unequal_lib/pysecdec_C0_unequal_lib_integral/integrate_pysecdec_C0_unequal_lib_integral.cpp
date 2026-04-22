#include <cstdlib> // std::atof
#include <iostream> // std::cout
#include <numeric> // std::accumulate
#include <vector> // std::vector

#include <secdecutil/integrators/cuba.hpp> // secdecutil::cuba::Vegas, secdecutil::cuba::Suave, secdecutil::cuba::Cuhre, secdecutil::cuba::Divonne
#include <secdecutil/integrators/qmc.hpp> // secdecutil::integrators::Qmc
#include <secdecutil/series.hpp> // secdecutil::Series
#include <secdecutil/uncertainties.hpp> // secdecutil::UncorrelatedDeviation
#include <secdecutil/deep_apply.hpp> // secdecutil::deep_apply

#include "pysecdec_C0_unequal_lib_integral.hpp"

void print_integral_info()
{
    std::cout << "-- print_integral_info --" << std::endl;
    std::cout << "pysecdec_C0_unequal_lib_integral::number_of_sectors " << pysecdec_C0_unequal_lib_integral::number_of_sectors << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::number_of_regulators " << pysecdec_C0_unequal_lib_integral::number_of_regulators << std::endl;
    std::cout << "pysecdec_C0_unequal_lib_integral::names_of_regulators ";
    for ( const auto& name : pysecdec_C0_unequal_lib_integral::names_of_regulators )
        std::cout << " " << name;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::number_of_real_parameters " << pysecdec_C0_unequal_lib_integral::number_of_real_parameters << std::endl;
    std::cout << "pysecdec_C0_unequal_lib_integral::names_of_real_parameters ";
    for ( const auto& name : pysecdec_C0_unequal_lib_integral::names_of_real_parameters )
        std::cout << " " << name;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::number_of_complex_parameters " << pysecdec_C0_unequal_lib_integral::number_of_complex_parameters << std::endl;
    std::cout << "pysecdec_C0_unequal_lib_integral::names_of_complex_parameters ";
    for ( const auto& name : pysecdec_C0_unequal_lib_integral::names_of_complex_parameters )
        std::cout << " " << name;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::lowest_orders";
    for ( const auto& lowest_order : pysecdec_C0_unequal_lib_integral::lowest_orders )
        std::cout << " " << lowest_order;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::highest_orders";
    for ( const auto& highest_order : pysecdec_C0_unequal_lib_integral::highest_orders )
        std::cout << " " << highest_order;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::lowest_prefactor_orders";
    for ( const auto& highest_order : pysecdec_C0_unequal_lib_integral::lowest_prefactor_orders )
        std::cout << " " << highest_order;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::highest_prefactor_orders";
    for ( const auto& highest_order : pysecdec_C0_unequal_lib_integral::highest_prefactor_orders )
        std::cout << " " << highest_order;
    std::cout << std::endl;

    std::cout << "pysecdec_C0_unequal_lib_integral::requested_orders";
    for ( const auto& requested_order : pysecdec_C0_unequal_lib_integral::requested_orders )
        std::cout << " " << requested_order;
    std::cout << std::endl;
}

int main(int argc, const char *argv[])
{
    // Check the command line argument number
    if (argc != 1 + 4 + 2*0) {
        std::cout << "usage: " << argv[0];
        for ( const auto& name : pysecdec_C0_unequal_lib_integral::names_of_real_parameters )
            std::cout << " " << name;
        for ( const auto& name : pysecdec_C0_unequal_lib_integral::names_of_complex_parameters )
            std::cout << " re(" << name << ") im(" << name << ")";
        std::cout << std::endl;
        return 1;
    }

    std::vector<pysecdec_C0_unequal_lib_integral::real_t> real_parameters; // = { real parameter values ("s","m1sq","m2sq","m3sq") go here };
    std::vector<pysecdec_C0_unequal_lib_integral::complex_t> complex_parameters; // = { complex parameter values () go here };

    // Load parameters from the command line arguments
    for (int i = 1; i < 1 + 4; i++)
        real_parameters.push_back(pysecdec_C0_unequal_lib_integral::real_t(std::atof(argv[i])));

    for (int i = 1 + 4; i < 1 + 4 + 2*0; i += 2) {
        pysecdec_C0_unequal_lib_integral::real_t re = std::atof(argv[i]);
        pysecdec_C0_unequal_lib_integral::real_t im = std::atof(argv[i+1]);
        complex_parameters.push_back(pysecdec_C0_unequal_lib_integral::complex_t(re, im));
    }

    // Generate the integrands (optimisation of the contour if applicable)
    std::cerr << "Generating integrands (optimising contour if required)" << std::endl;
    const std::vector<pysecdec_C0_unequal_lib_integral::nested_series_t<pysecdec_C0_unequal_lib_integral::integrand_t>> sector_integrands =
        pysecdec_C0_unequal_lib_integral::make_integrands(real_parameters, complex_parameters);

    // Add integrands of sectors (together flag)
    std::cerr << "Summing integrands" << std::endl;
    const pysecdec_C0_unequal_lib_integral::nested_series_t<pysecdec_C0_unequal_lib_integral::integrand_t> all_sectors =
        std::accumulate(++sector_integrands.begin(), sector_integrands.end(), *sector_integrands.begin());

    // Integrate
    std::cerr << "Integrating" << std::endl;
    secdecutil::cuba::Vegas<pysecdec_C0_unequal_lib_integral::integrand_return_t> integrator;
    integrator.flags = 2; // verbose output --> see cuba manual
    const pysecdec_C0_unequal_lib_integral::nested_series_t<secdecutil::UncorrelatedDeviation<pysecdec_C0_unequal_lib_integral::integrand_return_t>> result_all =
        secdecutil::deep_apply( all_sectors, integrator.integrate );

    std::cout << "------------" << std::endl << std::endl;

    std::cout << "-- integral info -- " << std::endl;
    print_integral_info();
    std::cout << std::endl;

    std::cout << "-- integral without prefactor -- " << std::endl;
    std::cout << result_all << std::endl << std::endl;

    std::cout << "-- prefactor -- " << std::endl;
    const pysecdec_C0_unequal_lib_integral::nested_series_t<pysecdec_C0_unequal_lib_integral::integrand_return_t> prefactor =
        pysecdec_C0_unequal_lib_integral::prefactor(real_parameters, complex_parameters);
    std::cout << prefactor << std::endl << std::endl;

    std::cout << "-- full result (prefactor*integral) -- " << std::endl;
    std::cout << prefactor*result_all << std::endl;

    return 0;
}
