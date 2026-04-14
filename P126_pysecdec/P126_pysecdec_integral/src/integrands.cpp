#include <secdecutil/deep_apply.hpp>
#include <secdecutil/sector_container.hpp>
#include <secdecutil/series.hpp>
#include <string>
#include <vector>

#include "P126_pysecdec_integral.hpp"

namespace P126_pysecdec_integral
{
    nested_series_t<sector_container_t> get_integrand_of_sector_1();
nested_series_t<sector_container_t> get_integrand_of_sector_2();
nested_series_t<sector_container_t> get_integrand_of_sector_3();
nested_series_t<sector_container_t> get_integrand_of_sector_4();
nested_series_t<sector_container_t> get_integrand_of_sector_5();
nested_series_t<sector_container_t> get_integrand_of_sector_6();
nested_series_t<sector_container_t> get_integrand_of_sector_7();
nested_series_t<sector_container_t> get_integrand_of_sector_8();
nested_series_t<sector_container_t> get_integrand_of_sector_9();
nested_series_t<sector_container_t> get_integrand_of_sector_10();
nested_series_t<sector_container_t> get_integrand_of_sector_11();
nested_series_t<sector_container_t> get_integrand_of_sector_12();
nested_series_t<sector_container_t> get_integrand_of_sector_13();
nested_series_t<sector_container_t> get_integrand_of_sector_14();
nested_series_t<sector_container_t> get_integrand_of_sector_15();
nested_series_t<sector_container_t> get_integrand_of_sector_16();
nested_series_t<sector_container_t> get_integrand_of_sector_17();
nested_series_t<sector_container_t> get_integrand_of_sector_18();
nested_series_t<sector_container_t> get_integrand_of_sector_19();
nested_series_t<sector_container_t> get_integrand_of_sector_20();
nested_series_t<sector_container_t> get_integrand_of_sector_21();
nested_series_t<sector_container_t> get_integrand_of_sector_22();
nested_series_t<sector_container_t> get_integrand_of_sector_23();
nested_series_t<sector_container_t> get_integrand_of_sector_24();
nested_series_t<sector_container_t> get_integrand_of_sector_25();
nested_series_t<sector_container_t> get_integrand_of_sector_26();
nested_series_t<sector_container_t> get_integrand_of_sector_27();
nested_series_t<sector_container_t> get_integrand_of_sector_28();
nested_series_t<sector_container_t> get_integrand_of_sector_29();
nested_series_t<sector_container_t> get_integrand_of_sector_30();
nested_series_t<sector_container_t> get_integrand_of_sector_31();
nested_series_t<sector_container_t> get_integrand_of_sector_32();
nested_series_t<sector_container_t> get_integrand_of_sector_33();
nested_series_t<sector_container_t> get_integrand_of_sector_34();
nested_series_t<sector_container_t> get_integrand_of_sector_35();
nested_series_t<sector_container_t> get_integrand_of_sector_36();


    static std::unique_ptr<std::vector<nested_series_t<sector_container_t>>> sectors;
    const std::vector<nested_series_t<sector_container_t>>& get_sectors()
    {
        if (!sectors)
            sectors.reset( new std::vector<nested_series_t<sector_container_t>>{get_integrand_of_sector_1(),get_integrand_of_sector_2(),get_integrand_of_sector_3(),get_integrand_of_sector_4(),get_integrand_of_sector_5(),get_integrand_of_sector_6(),get_integrand_of_sector_7(),get_integrand_of_sector_8(),get_integrand_of_sector_9(),get_integrand_of_sector_10(),get_integrand_of_sector_11(),get_integrand_of_sector_12(),get_integrand_of_sector_13(),get_integrand_of_sector_14(),get_integrand_of_sector_15(),get_integrand_of_sector_16(),get_integrand_of_sector_17(),get_integrand_of_sector_18(),get_integrand_of_sector_19(),get_integrand_of_sector_20(),get_integrand_of_sector_21(),get_integrand_of_sector_22(),get_integrand_of_sector_23(),get_integrand_of_sector_24(),get_integrand_of_sector_25(),get_integrand_of_sector_26(),get_integrand_of_sector_27(),get_integrand_of_sector_28(),get_integrand_of_sector_29(),get_integrand_of_sector_30(),get_integrand_of_sector_31(),get_integrand_of_sector_32(),get_integrand_of_sector_33(),get_integrand_of_sector_34(),get_integrand_of_sector_35(),get_integrand_of_sector_36()} );
        return *sectors;
    };

    void check_parameter_sizes(const std::vector<real_t>& real_parameters, const std::vector<complex_t>& complex_parameters)
    {
        if ( real_parameters.size() != P126_pysecdec_integral::number_of_real_parameters )
            throw std::logic_error(
                                        "Called \"P126_pysecdec_integral::make_integrands\" with " +
                                        std::to_string(real_parameters.size()) + " \"real_parameters\" (" +
                                        std::to_string(P126_pysecdec_integral::number_of_real_parameters) + " expected)."
                                  );

        if ( complex_parameters.size() != P126_pysecdec_integral::number_of_complex_parameters )
            throw std::logic_error(
                                        "Called \"P126_pysecdec_integral::make_integrands\" with " +
                                        std::to_string(complex_parameters.size()) + " \"complex_parameters\" (" +
                                        std::to_string(P126_pysecdec_integral::number_of_complex_parameters) + " expected)."
                                  );
    };


    #define P126_pysecdec_integral_contour_deformation 1

    std::vector<nested_series_t<secdecutil::IntegrandContainer<integrand_return_t, real_t const * const, real_t>>> make_integrands
    (
        const std::vector<real_t>& real_parameters,
        const std::vector<complex_t>& complex_parameters
        #if P126_pysecdec_integral_contour_deformation
            ,unsigned number_of_presamples,
            real_t deformation_parameters_maximum,
            real_t deformation_parameters_minimum,
            real_t deformation_parameters_decrease_factor
        #endif
    )
    {
        check_parameter_sizes(real_parameters, complex_parameters);
        #if P126_pysecdec_integral_contour_deformation
            return secdecutil::deep_apply
            (
                get_sectors(),
                secdecutil::SectorContainerWithDeformation_to_IntegrandContainer
                    (
                        real_parameters,
                        complex_parameters,
                        number_of_presamples,
                        deformation_parameters_maximum,
                        deformation_parameters_minimum,
                        deformation_parameters_decrease_factor
                    )
            );
        #else
            return secdecutil::deep_apply( get_sectors(), secdecutil::SectorContainerWithoutDeformation_to_IntegrandContainer<integrand_return_t>(real_parameters, complex_parameters) );
        #endif
    };

    #ifdef SECDEC_WITH_CUDA
        #if P126_pysecdec_integral_contour_deformation
            std::vector<nested_series_t<
                secdecutil::CudaIntegrandContainerWithDeformation<real_t,complex_t,1/*maximal_number_of_functions*/,
                maximal_number_of_integration_variables,number_of_real_parameters,number_of_complex_parameters,'P','1','2','6','_','p','y','s','e','c','d','e','c','_','i','n','t','e','g','r','a','l'>
            >> make_cuda_integrands
            (
                const std::vector<real_t>& real_parameters,
                const std::vector<complex_t>& complex_parameters,
                unsigned number_of_presamples,
                real_t deformation_parameters_maximum,
                real_t deformation_parameters_minimum,
                real_t deformation_parameters_decrease_factor
            )
            {
                check_parameter_sizes(real_parameters, complex_parameters);
                return secdecutil::deep_apply
                (
                    get_sectors(),
                    secdecutil::SectorContainerWithDeformation_to_CudaIntegrandContainer
                        <
                            maximal_number_of_integration_variables,
                            number_of_real_parameters,
                            number_of_complex_parameters,
                            'P','1','2','6','_','p','y','s','e','c','d','e','c','_','i','n','t','e','g','r','a','l'
                        >
                        (
                            real_parameters,
                            complex_parameters,
                            number_of_presamples,
                            deformation_parameters_maximum,
                            deformation_parameters_minimum,
                            deformation_parameters_decrease_factor
                        )
                );
            };
        #else
            std::vector<nested_series_t<
            secdecutil::CudaIntegrandContainerWithoutDeformation<real_t,complex_t,integrand_return_t,1/*maximal_number_of_functions*/,number_of_real_parameters,number_of_complex_parameters,'P','1','2','6','_','p','y','s','e','c','d','e','c','_','i','n','t','e','g','r','a','l'>
            >> make_cuda_integrands
            (
                const std::vector<real_t>& real_parameters,
                const std::vector<complex_t>& complex_parameters
            )
            {
                check_parameter_sizes(real_parameters, complex_parameters);
                return secdecutil::deep_apply
                (
                    get_sectors(),
                    secdecutil::SectorContainerWithoutDeformation_to_CudaIntegrandContainer
                        <
                            integrand_return_t,
                            number_of_real_parameters,
                            number_of_complex_parameters,
                            'P','1','2','6','_','p','y','s','e','c','d','e','c','_','i','n','t','e','g','r','a','l'
                        >
                        (
                            real_parameters,
                            complex_parameters
                        )
                );
            };
        #endif
    #endif

    #undef P126_pysecdec_integral_contour_deformation
};
