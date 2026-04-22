#****
#  NAME
#  paths.pm
#
#  USAGE
#  TODO
#
#  USES
#  dirform.pm
#
#  USED BY
#  Most *.pl
#
#  PURPOSE
#  Stores the paths to all SecDec directories
#  ap = absolute path, eg /1/2/3
#  ext = extension directory, eg in the path /1/2/3/ then just 3/
#  apf = absolute path (to) file, eg /1/2/3/4.txt
#  apfp = absolute path to file partial,
#         these paths will have a partial filename + extension appended to them
#         in other perl scripts
#
#  INPUTS
#  TODO
#
#  RESULT
#  TODO
#
#  SEE ALSO
#  N/A
#
#****
package paths;

use strict;
use warnings;

use lib "loop/perlsrc/modules";
use dirform;
#use File::Copy::Recursive qw(dirmove dircopy);
use Recursive qw(dirmove dircopy);
use File::Path qw(make_path);

# Populates all paths with default paths
sub getpaths {
    my $secdecdir    = $_[0];    # absolute path to SecDec root directory
    my $workingdir   = $_[1];    # absolute path to working root directory
    my $paramfile    = $_[2];    # name of paramfile (with extension)
    my $mathfile     = $_[3];    # name of mathfile (with extension)
    my $kinemfile    = $_[4];    # name of kinematics file (with extension)
    unless ($secdecdir) {
        die "Error - SecDec directory not found";
    }
    unless ($workingdir) {
        die "Error - No working directory set";
    }
    unless ($paramfile) {
        die "Error - No parameter file specified";
    }
    unless ($mathfile) {
        die "Error - No math file specified";
    }
    unless ($kinemfile) {
        die "Error - No kinematics file specified";
    }

    # validate input
    chomp $secdecdir;
    chomp $workingdir;
    chomp $paramfile;
    chomp $mathfile;
    chomp $kinemfile;
    $secdecdir  = dirform::add_trailing_slash($secdecdir);
    $workingdir = dirform::add_trailing_slash($workingdir);
    unless ( -e $secdecdir )  { die "Error - " . $secdecdir . " does not exist\n" }
    unless ( -d $secdecdir )  { die "Error - " . $secdecdir . " is not a directory\n" }
    unless ( -e $workingdir ) { die "Error - " . $workingdir . " does not exist\n" }
    unless ( -d $workingdir ) { die "Error - " . $workingdir . " is not a directory\n" }

    my %paths = ();

    $paths{"ap_secdecdir"}  = $secdecdir;     # path to SecDec
    $paths{"ap_workingdir"} = $workingdir;    # path to paramfile/mathfile

    #
    # Input files
    #
    $paths{"apf_paramfile"}    = $workingdir . $paramfile;
    $paths{"apf_mathfile"} = $workingdir . $mathfile;
    $paths{"apf_kinemfile"}    = $workingdir . $kinemfile;

    # validate input
    unless ( -e $paths{"apf_paramfile"} )    { die "Error - Parameter file: " . $paths{"apf_paramfile"} . " does not exist\n" }
    unless ( -e $paths{"apf_mathfile"} ) { die "Error - Math file: " . $paths{"apf_mathfile"} . " does not exist\n" }
    unless ( -e $paths{"apf_kinemfile"} )    { die "Error - Kinematics file: " . $paths{"apf_kinemfile"} . " does not exist\n" }

    #
    # SecDec files
    #
    $paths{"ext_bases"} = "basesv5.1/";
    $paths{"ext_cquad"} = "cquad/";
    $paths{"ext_cuba"}  = "Cuba-4.1/";
    $paths{"ext_sobol"} = "sobol/";
    
    $paths{"rp_cquadlib"} = "lib/libcquad.a";
    $paths{"rp_cquadhead"} = "include/gsl/gsl_integration.h";
    $paths{"rp_cquadinc"} = "include";
    $paths{"rp_cubalib"} = "libcuba.a";
    $paths{"rp_cubahead"} = "cuba.h";
    $paths{"rp_sobollib"} = "sobol.o";
    $paths{"rp_sobolhead"} = "sobol.hh";

    $paths{"ap_src"}             = $paths{"ap_secdecdir"} . "src/";
    $paths{"ap_bases_default"}   = $paths{"ap_src"} . $paths{"ext_bases"};
    $paths{"ap_cquad_default"}   = $paths{"ap_src"} . $paths{"ext_cquad"};
    $paths{"ap_cuba_default"}    = $paths{"ap_src"} . $paths{"ext_cuba"};
    $paths{"ap_sobol_default"}   = $paths{"ap_src"} . $paths{"ext_sobol"};
    $paths{"ap_loop"}            = $paths{"ap_secdecdir"} . "loop/";
    $paths{"ap_loopsrc"}         = $paths{"ap_loop"} . "src/";
    $paths{"ap_loopshell"}       = $paths{"ap_loopsrc"} . "shell/";
    $paths{"ap_loopmath"}        = $paths{"ap_loopsrc"} . "math/";
    $paths{"ap_loopdeco"}        = $paths{"ap_loopmath"} . "deco/";
    $paths{"ap_loopmathparams"}  = $paths{"ap_loopmath"} . "mathparams/";
    $paths{"ap_loopnumerics"}    = $paths{"ap_loopsrc"} . "numerics/";
    $paths{"ap_loopsubexp"}      = $paths{"ap_loopmath"} . "subexp/";
    $paths{"ap_looputil"}        = $paths{"ap_loopmath"} . "util/";
    $paths{"ap_loopperlsrc"}     = $paths{"ap_loop"} . "perlsrc/";
    #$paths{"ap_looploop"}        = $paths{"ap_loopperlsrc"} . "loop/";
    $paths{"ap_loopmodules"}     = $paths{"ap_loopperlsrc"} . "modules/";
    #$paths{"ap_loopuserdefined"} = $paths{"ap_loopperlsrc"} . "userdefined/";
    $paths{"ap_general"}         = $paths{"ap_secdecdir"} . "general/";
    

    $paths{"apf_general_launch"}            = $paths{"ap_general"} . "launch";
    $paths{"apf_calcFU"}                    = $paths{"ap_loopdeco"} . "calcFU.m";
    $paths{"apf_decomposition"}             = $paths{"ap_loopdeco"} . "decomposition.m";
    $paths{"apf_deconoprimary"}             = $paths{"ap_loopdeco"} . "deconoprimary.m";
    $paths{"apf_geomethod1"}                = $paths{"ap_loopdeco"} . "geomethod1.m";
    $paths{"apf_geomethod2"}                = $paths{"ap_loopdeco"} . "geomethod2.m";
    $paths{"apf_NSDroutines"}               = $paths{"ap_loopdeco"} . "NSDroutines.m";
    $paths{"apf_prepareinput"}              = $paths{"ap_loopdeco"} . "prepareinput.m";
    $paths{"apf_primarySD"}                 = $paths{"ap_loopdeco"} . "primarySD.m";
    $paths{"apf_recastinput"}               = $paths{"ap_loopdeco"} . "recastinput.m";
    $paths{"apf_sdiQ"}                      = $paths{"ap_loopdeco"} . "sdiQ.m";
    $paths{"apf_sdiQnoprim"}                = $paths{"ap_loopdeco"} . "sdiQnoprim.m";
    $paths{"apf_SDroutines"}                = $paths{"ap_loopdeco"} . "SDroutines.m";
    $paths{"apf_split"}                     = $paths{"ap_loopdeco"} . "split.m";
    $paths{"apf_templatetail_loop"}         = $paths{"ap_loopdeco"} . "templatetail_loop.m.in";
    $paths{"apf_templatetailFU_loop"}       = $paths{"ap_loopdeco"} . "templatetailFU_loop.m.in";
    $paths{"apf_templatetail_userdefined"}  = $paths{"ap_loopdeco"} . "templatetail_userdefined.m";
    # $paths{"apf_intfileC"}                  = $paths{"ap_loopnumerics"} . "intfile.cc.in";
    $paths{"apf_intfileM"}                  = $paths{"ap_loopnumerics"} . "intfile.m.in";
    $paths{"apf_writeM"}                    = $paths{"ap_loopnumerics"} . "writeM.m";
    $paths{"apf_subfile"}                   = $paths{"ap_loopnumerics"} . "subfile.pl.in";
    $paths{"apf_submitpbs"}                   = $paths{"ap_loopnumerics"} . "submit_pbs.in";
    $paths{"apf_submitlsf"}                   = $paths{"ap_loopnumerics"} . "submit_lsf.in";
    $paths{"apf_runmakelsf"}                  = $paths{"ap_loopnumerics"} . "runmake.sh.in";
    $paths{"apf_runjoblsf"}                   = $paths{"ap_loopnumerics"} . "runjob.sh.in";
    $paths{"apf_condorcompile"}             = $paths{"ap_loopnumerics"} . "condor.compile.in";
    $paths{"apf_condorrun"}                 = $paths{"ap_loopnumerics"} . "condor.run.in";
    $paths{"apf_condordag"}                 = $paths{"ap_loopnumerics"} . "condor.dag.in";
    $paths{"apf_condorkinem"}               = $paths{"ap_loopnumerics"} . "condor.kinem.in";
    $paths{"apf_mathparams"}                = $paths{"ap_loopmathparams"} . "mathparams.m.in";
    $paths{"apf_Degeneracy"}                = $paths{"ap_loopsubexp"} . "Degeneracy.m";
    $paths{"apf_ExpOpt"}                    = $paths{"ap_loopsubexp"} . "ExpOpt.m";
    $paths{"apf_ExpOptP"}                   = $paths{"ap_loopsubexp"} . "ExpOptP.m";
    $paths{"apf_formC"}                     = $paths{"ap_loopsubexp"} . "formC.m";
    $paths{"apf_formContourC"}              = $paths{"ap_loopsubexp"} . "formContourC.m";
    $paths{"apf_formContourPC"}             = $paths{"ap_loopsubexp"} . "formContourPC.m";
    $paths{"apf_formfortran"}               = $paths{"ap_loopsubexp"} . "formfortran.m";
    $paths{"apf_formindlist"}               = $paths{"ap_loopsubexp"} . "formindlist.m";
    $paths{"apf_formPC"}                    = $paths{"ap_loopsubexp"} . "formPC.m";
    $paths{"apf_formPfortran"}              = $paths{"ap_loopsubexp"} . "formPfortran.m";
    $paths{"apf_parts"}                     = $paths{"ap_loopsubexp"} . "parts.m";
    $paths{"apf_subandexpand"}              = $paths{"ap_loopsubexp"} . "subandexpand.m";
    $paths{"apf_symbsub"}                   = $paths{"ap_loopsubexp"} . "symbsub.m";
    $paths{"apf_Format"}                    = $paths{"ap_looputil"} . "Format.m";
    $paths{"apf_miscel"}                    = $paths{"ap_looputil"} . "miscel.m";
    $paths{"apf_batch"}                     = $paths{"ap_loopshell"} . "batch.in";
    $paths{"apf_makefile"}                  = $paths{"ap_loopshell"} . "makefile.in"; # new
    $paths{"apf_collectresults"}            = $paths{"ap_loopperlsrc"} . "collectresults.pl";
    $paths{"apf_dotogetherC"}               = $paths{"ap_loopperlsrc"} . "dotogetherC.pl";
    #$paths{"apf_finishpreparenumerics"}        = $paths{"ap_loopperlsrc"} . "finishpreparenumerics.pl";
    $paths{"apf_makeFU"}                    = $paths{"ap_loopperlsrc"} . "makeFU.pl";
    $paths{"apf_makeparams"}                = $paths{"ap_loopperlsrc"} . "makeparams.pl";
    $paths{"apf_mathlaunch"}                = $paths{"ap_loopperlsrc"} . "mathlaunch.pl";
    $paths{"apf_numerics"}                  = $paths{"ap_loopperlsrc"} . "numerics.pl";
    $paths{"apf_preparenumerics"}              = $paths{"ap_loopperlsrc"} . "preparenumerics.pl";
    $paths{"apf_prefactor"}                 = $paths{"ap_loopperlsrc"} . "prefactor.pl";
    $paths{"apf_polenumerics"}           = $paths{"ap_loopperlsrc"} . "polenumerics.pl";
    #$paths{"apf_remakebases"}               = $paths{"ap_loopperlsrc"} . "remakebases.pl";
    $paths{"apf_subexpand"}                 = $paths{"ap_loopperlsrc"} . "subexpand.pl";
    $paths{"apf_decompose"}             = $paths{"ap_loopperlsrc"} . "decompose.pl";
    #$paths{"apf_finishnumericsloop"}        = $paths{"ap_looploop"} . "finishnumericsloop.pl";
    #$paths{"apf_justnumericsloop"}          = $paths{"ap_looploop"} . "justnumericsloop.pl";
    #$paths{"apf_multinumericsloop"}         = $paths{"ap_looploop"} . "multinumericsloop.pl";
    $paths{"apf_results"}               = $paths{"ap_loopperlsrc"} . "results.pl";
    $paths{"apf_preparesubexpand"}                = $paths{"ap_loopperlsrc"} . "preparesubexpand.pl";
    #$paths{"apf_decomposeuserdefined"}      = $paths{"ap_loopuserdefined"} . "decomposeuserdefined.pl";
    #$paths{"apf_finishnumericsuserdefined"} = $paths{"ap_loopuserdefined"} . "finishnumericsuserdefined.pl";
    #$paths{"apf_justnumericsuserdefined"}   = $paths{"ap_loopuserdefined"} . "justnumericsuserdefined.pl";
    #$paths{"apf_multinumericsuserdefined"}  = $paths{"ap_loopuserdefined"} . "multinumericsuserdefined.pl";
    #$paths{"apf_resultsuserdefined"}        = $paths{"ap_loopuserdefined"} . "resultsuserdefined.pl";
    #$paths{"apf_subexpuserdefined"}         = $paths{"ap_loopuserdefined"} . "subexpuserdefined.pl";
    $paths{"apf_normaliz"}   = $paths{"ap_src"} . "normaliz";

    return %paths;
}

# Updates all paths with values given in paramfile (i.e. specified by the user)
sub updatepaths {
    my %paths  = %{ $_[0] };    # store paths hash (should have been created using getpaths)
    my %params = %{ $_[1] };    # store input params hash

    #
    # Output files/directories
    #
    if ( $params{"outputdir"} ) {
        $paths{"ap_outputdir"} = $params{"outputdir"};
    }
    else {
        $paths{"ap_outputdir"} = $paths{"ap_workingdir"} . dirform::add_trailing_slash( $params{"graph"} );    # default path
    }
    
    $paths{"apf_out_makefile"} = $paths{"ap_outputdir"} . "Makefile";
    $paths{"apf_out_kinemfile"} = $paths{"ap_outputdir"} . "kinematics.input";
    
    # update integrator/sobol paths
    # if user has explicitly stated a path in the param file, use that location
    # else
    # if clusterflag == 0 all integrators are left in their default location (SecDec directory)
    # if clusterflag != 0 all integrators are copied into the output directory
    if ( $params{"basespath"} ) {
        $paths{"ap_bases"} = dirform::add_trailing_slash( $params{"basespath"} );
    }
    else {
        if ( $params{"clusterflag"} == 0 ) {
            $paths{"ap_bases"} = $paths{"ap_bases_default"};
        } else {
            $paths{"ap_bases"} = $paths{"ap_outputdir"} . $paths{"ext_bases"}; # bases will be stored in outputdir
        }
    }
    
    if ( $params{"cubapath"} ) {
        $paths{"ap_cuba"} = dirform::add_trailing_slash( $params{"cubapath"} );
    }
    else {
        if ( $params{"clusterflag"} == 0 ) {
            $paths{"ap_cuba"} = $paths{"ap_cuba_default"};
        } else {
            $paths{"ap_cuba"}          = $paths{"ap_outputdir"} . $paths{"ext_cuba"}; # cuba will be stored in outputdir
        }
    }
    
    if ( $params{"cquadpath"} ) {
        $paths{"ap_cquad"} = dirform::add_trailing_slash( $params{"cquadpath"} );
    }
    else {
        if ( $params{"clusterflag" } == 0 ) {
            $paths{"ap_cquad"} = $paths{"ap_cquad_default"};
        } else {
            $paths{"ap_cquad"} = $paths{"ap_outputdir"} . $paths{"ext_cquad"}; # cquad will be stored in outputdir
        }
    }
    
    if ( $params{"sobolpath"} ) {
        $paths{"ap_sobol"} = dirform::add_trailing_slash( $params{"sobolpath"} );
    } else {
        if ( $params{"clusterflag"} == 0 ) {
            $paths{"ap_sobol"} = $paths{"ap_sobol_default"};
        } else {
            $paths{"ap_sobol"} = $paths{"ap_outputdir"} . $paths{"ext_sobol"}; # sobol will be stored in outputdir
        }
    }

    # integrator directory
    if ( $params{"integrator"} == 0 ) {
        $paths{"ap_integpath_default"} = $paths{"ap_bases_default"};
        $paths{"ap_integpath"}         = $paths{"ap_bases"};
        $paths{"ext_integpath"}        = $paths{"ext_bases"};
    }
    elsif ( $params{"integrator"} < 5 ) {
        $paths{"ap_integpath_default"} = $paths{"ap_cuba_default"};
        $paths{"ap_integpath"}         = $paths{"ap_cuba"};
        $paths{"ext_integpath"}        = $paths{"ext_cuba"};
    }
    elsif ( $params{"integrator"} == 5 ) {
        $paths{"ap_integpath_default"} = "dummy";
        $paths{"ap_integpath"}  = "dummy";    # using Mathematica (only placeholder required)
        $paths{"ext_integpath"} = "";
    }
    elsif ( $params{"integrator"} == 6 ) {
        $paths{"ap_integpath_default"} = $paths{"ap_cquad_default"};
        $paths{"ap_integpath"}  = $paths{"ap_cquad"};
        $paths{"ext_integpath"} = $paths{"ext_cquad"};
    }

    #$paths{"ext_temp"} = "temp/";
    #$paths{"ap_temp"} = $paths{"ap_outputdir"} . $paths{"ext_temp"};
    #$paths{"apf_tmpgraph"} = $paths{"ap_temp"} . "tmp" . $params{"graph"} . ".m"; # makeFU.pl
    
    # files created by makeparams
    $paths{"ext_params"} = "params/";
    $paths{"ap_params"} = $paths{"ap_outputdir"} . $paths{"ext_params"}; # see makeparams.pl
    $paths{"apf_out_auxiliarygraphinfo"} = $paths{"ap_params"} . "auxiliary" . $params{"graph"} . "info.m"; # see makeparams.pl
    $paths{"apf_out_mathparamfile"} = $paths{"ap_params"} . $params{"graph"} . "paraminfo.m"; # see makeparams.pl, *.pl
    $paths{"apf_out_makeparaminfo"} =  $paths{"ap_params"} . "makeparaminfo.log"; # see makeparams.pl
    
    # files created by makeFU
    $paths{"exp_FU"} = "FU/";
    $paths{"ap_FU"} = $paths{"ap_outputdir"} . $paths{"exp_FU"};
    $paths{"apf_out_graph"}  = $paths{"ap_FU"}  . $params{"graph"} . ".m";    # see makeFU.pl, preparesubexpand.pl, results.pl
    $paths{"apf_out_calcFU"} = $paths{"ap_FU"}  . "calcFU.log";               # see makeFU.pl
    $paths{"apf_out_FUN"}    = $paths{"ap_FU"}  . "FUN.m";                    # see makeFU.pl, decomposeloop.pl

    # files created by decomposeloop
    $paths{"exp_decomposition"} = "decomposition/";
    $paths{"ap_decomposition"} = $paths{"ap_outputdir"} . $paths{"exp_decomposition"};
    $paths{"apfp_out_graphdeco"}          = $paths{"ap_decomposition"} . $params{"graph"};                      # see decomposeloop.pl, *.pl
    $paths{"apfp_out_graphdecomposition"} = $paths{"ap_decomposition"} . $params{"graph"} . "Decomposition";    # see decomposeloop.pl, *.pl
    $paths{"apfp_out_launchgraph"}        = $paths{"ap_decomposition"} . "launch" . $params{"graph"};           # see decomposeloop.pl, *.pl
    $paths{"apf_out_decomposegraph"}      = $paths{"ap_decomposition"} . "decompose" . $params{"graph"};        # see decomposeloop.pl

    # files created by subexp
    #$paths{"apf_out_makeclean"} = $paths{"ap_outputdir"} . "makeclean";           # see preparesubexpand.pl
    $paths{"exp_subexp"} = "subexp/";
    $paths{"ap_subexp"} = $paths{"ap_outputdir"} . $paths{"exp_subexp"};
    $paths{"exp_numerics"} = "numerics/";
    $paths{"ap_numerics"} = $paths{"ap_outputdir"} . $paths{"exp_numerics"};
    $paths{"exp_cluster"} = "cluster/";
    $paths{"ap_out_cluster"} = $paths{"ap_outputdir"} . $paths{"exp_cluster"};
    $paths{"ap_out_clustererr"} = $paths{"ap_out_cluster"} . "err/";
    $paths{"ap_out_clusterlog"} = $paths{"ap_out_cluster"} . "log/";
    $paths{"apf_out_condorcompile"} = $paths{"ap_out_cluster"} . "condor.compile";
    $paths{"apf_out_condorrunin"} = $paths{"ap_out_cluster"} . "condor.run.in";
    $paths{"apf_out_condorrun"} = $paths{"ap_out_cluster"} . "condor.run";
    $paths{"apf_out_condorkinem"} = $paths{"ap_out_cluster"} . "condor.kinem";

    $paths{"apfp_out_polestruct"}             = $paths{"ap_numerics"}; # DO NOT USE, see paths::polestruct() instead!
    $paths{"apfp_out_job"}                    = $paths{"ap_outputdir"} . "job";                             # see preparesubexpand.pl
    $paths{"apfp_out_batchpolestruct"}        = $paths{"ap_outputdir"} . "batch";                           # see preparesubexpand.pl
    $paths{"apfp_out_subandexpandpolestruct"} = $paths{"ap_subexp"} . "subandexpand";                    # see preparesubexpand.pl
    $paths{"apfp_out_batchpolelog"}           = $paths{"ap_subexp"};                                     # see preparesubexpand.pl

    $paths{"rp_out_together"} = "together/";
    $paths{"ap_out_together"} = $paths{"ap_outputdir"} .$paths{"exp_numerics"} . $paths{"rp_out_together"}; # see results.pl, justnumerics.pl
    $paths{"apf_out_togetherinfofile"} = $paths{"ap_out_together"} . "infofile";   # see results.pl
    
    
    $paths{"rp_out_infofile"} = "infofile";                                                                 # see preparenumerics.pl, results.pl
    $paths{"rp_out_epstothe"} = "epstothe";                                                                 # see preparenumerics.pl, results.pl, justnumerics.pl
    $paths{"rp_out_f1"}       = "f1";                                                                       # see preparenumerics.pl

    # sj - a lot of these files could be avoided by using a true makefile
    $paths{"rp_out_f"}              = "f";                                                                  # see polenumerics.pl
    $paths{"rp_out_cf"}             = "g";                                                                  # see polenumerics.pl
    $paths{"rp_out_kinematics"}     = "kinematics";                                                         # see polenumerics.pl, justnumerics.pl
    $paths{"rp_out_make"}           = "make";                                                               # see polenumerics.pl, preparenumerics.pl
    $paths{"rp_out_makefile"}       = "file";                                                               # see polenumerics.pl
    $paths{"rp_out_intfile"}        = "intfile";                                                            # see polenumerics.pl
    $paths{"rp_out_subfile"}        = "subfile.pl";                                                         # see polenumerics.pl, preparenumerics.pl
    $paths{"rp_out_makef"}          = "make.pl";                                                            # see polenumerics.pl
    $paths{"rp_out_intfilehead"}    = "intfile.hh"; # was previously rp_out_intf                            # see polenumerics.pl
    $paths{"rp_out_filespointinfo"} = "info";                                                               # see polenumerics.pl, results.pl, justnumerics.pl
    $paths{"rp_out_kinemfile"}      = "kinematics";                                                         # see polenumerics.pl
    $paths{"rp_out_pointinfo"}      = "info";                                                               # see multinumericsloop.pl
    $paths{"rp_out_intfilextension"} = ".exe";                                                              # see polenumerics

    # files created by results
    $paths{"exp_results"} = "results/";
    $paths{"ap_results"} = $paths{"ap_outputdir"} . $paths{"exp_results"};
    $paths{"exp_aux_results"} = "auxres/";
    $paths{"ap_aux_results"} = $paths{"ap_outputdir"} . $paths{"exp_aux_results"};
    $paths{"apfp_out_reslog"} = $paths{"exp_aux_results"}; # see results.pl
    $paths{"rp_out_reslog"} = "results"; # see results.pl
    $paths{"apfp_out_resfull"} = $paths{"ap_results"} . $params{"graph"}; # see results.pl
    $paths{"apfp_out_respart"} = $paths{"ap_aux_results"} . $params{"graph"}; # see results.pl
    $paths{"rp_out_resfull"} = ".res"; # see results.pl
    $paths{"apfp_out_plotfile"} = $paths{"ap_results"} . "plotfile"; # see results.pl
    
    # files created by results
    $paths{"exp_prefac"} = "prefactor/";
    $paths{"ap_prefac"} = $paths{"ap_aux_results"} . $paths{"exp_prefac"};
    $paths{"apfp_out_prefacdir"} = $paths{"ap_prefac"}; # see results.pl
    $paths{"rp_out_prefac"} = "prefac.m"; # see results.pl
    #$paths{"rp_out_prefacdir"} = "epsprefactor"; # see results.pl
    $paths{"rp_out_prefacdump"} = "prefactdump"; # see results.pl
    
    # debug files
    $paths{"apf_out_params"} = $paths{"ap_params"} . "params.input";
    
    return %paths;
}

# Updates integrator related paths if the integrator has dynamically changed (eg... the program has switched to cquad dynamically)
sub updatedynamicintegrator {
    my $integrator = $_[0];
    my %paths  = %{ $_[1] };    # store paths hash (should have been created using getpaths)
    
    # integrator directory
    if ( $integrator == 0 ) {
        $paths{"ap_integpath_default_dynamic"} = $paths{"ap_bases_default"};
        $paths{"ap_integpath_dynamic"}         = $paths{"ap_bases"};
        $paths{"ext_integpath_dynamic"}        = $paths{"ext_bases"};
    }
    elsif ( $integrator < 5 ) {
        $paths{"ap_integpath_default_dynamic"} = $paths{"ap_cuba_default"};
        $paths{"ap_integpath_dynamic"}         = $paths{"ap_cuba"};
        $paths{"ext_integpath_dynamic"}        = $paths{"ext_cuba"};
        $paths{"ext_integlib_dynamic"}         = $paths{"rp_cubalib"};
        $paths{"rp_integhead_dynamic"}         = $paths{"rp_cubahead"};
    }
    elsif ( $integrator == 5 ) {
        $paths{"ap_integpath_default_dynamic"} = "dummy";
        $paths{"ap_integpath_dynamic"}  = "dummy";    # using Mathematica (only placeholder required)
        $paths{"ext_integpath_dynamic"} = "dummy";
    }
    elsif ( $integrator == 6 ) {
        $paths{"ap_integpath_default_dynamic"} = $paths{"ap_cquad_default"};
        $paths{"ap_integpath_dynamic"}  = $paths{"ap_cquad"};
        $paths{"ext_integpath_dynamic"} = $paths{"ext_cquad"};
        $paths{"ext_integlib_dynamic"}  = $paths{"rp_cquadlib"};
        $paths{"rp_integhead_dynamic"}  = $paths{"rp_cquadhead"};
        $paths{"rp_integinc_dynamic"}   = $paths{"rp_cquadinc"};
    }
    return %paths;
}

# Back up the existing output directory in $workingdir/backup_<number>
sub backupoutputdir {
    my %paths = %{ $_[0] };    # store paths hash (should have been created using getpaths)
    my %params = %{ $_[1] };    # store input params hash
    
    #
    # Output files/directories
    #
    # if output directory exists move it to a backup directory outputdir/backup_<number>
    my @outputdir     = split( /\//, $paths{"ap_outputdir"} );
    my $outputdirlast = pop(@outputdir) . "/";                   # last folder in directory
    my $rootoutputdir = join( "/", @outputdir ) . "/";           # output dir with last folder removed
    if ( -e $paths{"ap_outputdir"} ) {
        my $num = 1;
        while ( -e $rootoutputdir . "backup\_$num/" ) { $num++ }
        
        File::Copy::Recursive::dirmove( $paths{"ap_outputdir"}, $rootoutputdir . "backup\_$num/" . $outputdirlast )
        or die "Cannot move " . $paths{"ap_outputdir"} . "\n";
        
        print "Output directory " . $paths{"ap_outputdir"} . " already exists\n";
        print "Output directory backup stored in " . $rootoutputdir . "backup\_$num/" . $outputdirlast . "\n\n";
    }
}

# Creates the output directory
# If required copies integrator (bases/cuba/cquadpack) into output directory
# If required copies sobol into output directory
sub createoutputdir {
    my %paths = %{ $_[0] };    # store paths hash (should have been created using getpaths)
    my %params = %{ $_[1] };    # store input params hash

    #
    # Output files/directories
    #
    # make output directories
    make_path( $paths{"ap_outputdir"} ) or die "Cannot create " . $paths{"ap_outputdir"} . "\n";
    make_path( $paths{"ap_params"} ) or die "Cannot create " . $paths{"ap_params"} . "\n";
    make_path( $paths{"ap_FU"} ) or die "Cannot create " . $paths{"ap_FU"} . "\n";
    make_path( $paths{"ap_decomposition"} ) or die "Cannot create " . $paths{"ap_decomposition"} . "\n";
    make_path( $paths{"ap_subexp"} ) or die "Cannot create " . $paths{"ap_subexp"} . "\n";
    make_path( $paths{"ap_numerics"} ) or die "Cannot create " . $paths{"ap_numerics"} . "\n";
    make_path( $paths{"ap_aux_results"} ) or die "Cannot create " . $paths{"ap_aux_results"} . "\n";
    make_path( $paths{"ap_results"} ) or die "Cannot create " . $paths{"ap_results"} . "\n";
    make_path( $paths{"ap_prefac"} ) or die "Cannot create " . $paths{"ap_prefac"} . "\n";
    make_path( $paths{"ap_out_cluster"} ) or die "Cannot create " . $paths{"ap_out_cluster"} . "\n";
    make_path( $paths{"ap_out_clustererr"} ) or die "Cannot create " . $paths{"ap_out_clustererr"} . "\n";
    make_path( $paths{"ap_out_clusterlog"} ) or die "Cannot create " . $paths{"ap_out_clusterlog"} . "\n";

    #make_path( $paths{"ap_temp"} ) or die "Cannot create " . $paths{"ap_temp"} . "\n";

    # copy the integrator if necessary
    if ( $params{"integrator"} == 0 ) {
        unless ( $params{"basespath"} ) {
            if ( $paths{"ap_integpath"} ne $paths{"ap_integpath_default"} ) {
                print "Copying " . $paths{"ap_integpath_default"} . " to " . $paths{"ap_integpath"} . "\n";
                File::Copy::Recursive::dircopy( $paths{"ap_integpath_default"}, $paths{"ap_integpath"} )
                or die "Cannot copy " . $paths{"ap_integpath_default"} . " to " . $paths{"ap_integpath"} . "\n";
            }
        }
    }
    if ( $params{"integrator"} < 5 ) {
        unless ( $params{"cubapath"} ) {
            if ( $paths{"ap_integpath"} ne $paths{"ap_integpath_default"} ) {
                print "Copying " . $paths{"ap_integpath_default"} . " to " . $paths{"ap_integpath"} . "\n";
                File::Copy::Recursive::dircopy( $paths{"ap_integpath_default"}, $paths{"ap_integpath"} )
                or die "Cannot copy " . $paths{"ap_integpath_default"} . " to " . $paths{"ap_integpath"} . "\n";
            }
        }
    }

    # always copy cquadpack if necessary (may be used if we have only 1 feynman parameter)
    unless ( $params{"cquadpath"} ) {
        if ( $paths{"ap_cquad"} ne $paths{"ap_cquad_default"} ) {
            print "Copying " . $paths{"ap_cquad_default"} . " to " . $paths{"ap_cquad"} . "\n";
            File::Copy::Recursive::dircopy( $paths{"ap_cquad_default"}, $paths{"ap_cquad"} )
            or die "Cannot copy " . $paths{"ap_cquad_default"} . " to " . $paths{"ap_cquad"} . "\n";
        }
    }

    # copy sobol if necessary and if contourdef is true
    if ( $params{"contourdef"} ) {
        unless ( $params{"sobolpath"} ) {
            if ( $paths{"ap_sobol"} ne $paths{"ap_sobol_default"} ) {
                print "Copying " . $paths{"ap_sobol_default"} . " to " . $paths{"ap_sobol"} . "\n";
                File::Copy::Recursive::dircopy( $paths{"ap_sobol_default"}, $paths{"ap_sobol"} )
                or die "Cannot copy " . $paths{"ap_sobol_default"} . " to " . $paths{"ap_sobol"} . "\n";
            }
        }
    }
    
    # copy makefile into the output directory
    print "Copying " . $paths{"apf_makefile"} . " to " . $paths{"apf_out_makefile"} . "\n";
    File::Copy::Recursive::fcopy( $paths{"apf_makefile"}, $paths{"apf_out_makefile"} )
    or die "Cannot copy " . $paths{"apf_makefile"} . " to " . $paths{"apf_out_makefile"} . "\n";
    
    copykinemtooutput ( \%paths );
    
    print "\n";
}

sub copykinemtooutput {
    my %paths  = %{ $_[0] };
    # copy user's kinemfile into the output directory
    print "Copying " . $paths{"apf_kinemfile"} . " to " . $paths{"apf_out_kinemfile"} . "\n";
    File::Copy::Recursive::fcopy( $paths{"apf_kinemfile"}, $paths{"apf_out_kinemfile"} )
    or die "Cannot copy " . $paths{"apf_kinemfile"} . " to " . $paths{"apf_out_kinemfile"} . "\n";
}
  
sub defaultinputfiles{
    my %definputfiles=();

    $definputfiles{"def_kinemfile"} = "kinem.input";
    $definputfiles{"def_mathfile"} = "math.m";
    $definputfiles{"def_paramfile"} = "param.input";

    return %definputfiles;
}

# Populates paths with the template file paths
# eg... templates for loop/userdefined/general
# used for copying template files to the user's working directory
sub gettemplatepaths{
    my $secdecdir    = $_[0];    # absolute path to SecDec root directory
    my $workingdir   = $_[1];    # absolute path to working root directory
    my $mode         = $_[2];    # 0 - loop, 1 - userdefined, 2 - general
    unless ($secdecdir) {
        die "Error - SecDec directory not found";
    }
    unless ($workingdir) {
        die "Error - No working directory set";
    }
    
    # validate input
    chomp $secdecdir;
    chomp $workingdir;
    $secdecdir  = dirform::add_trailing_slash($secdecdir);
    $workingdir = dirform::add_trailing_slash($workingdir);
    unless ( -e $secdecdir )  { die "Error - " . $secdecdir . " does not exist\n" }
    unless ( -d $secdecdir )  { die "Error - " . $secdecdir . " is not a directory\n" }
    unless ( -e $workingdir ) { die "Error - " . $workingdir . " does not exist\n" }
    unless ( -d $workingdir ) { die "Error - " . $workingdir . " is not a directory\n" }
    
    my %paths = ();
    
    $paths{"ap_secdecdir"}  = $secdecdir;     # path to SecDec
    $paths{"ap_workingdir"} = $workingdir;    # path to output paramfile/mathfile
    
    # path to template files
    if ( $mode == 0 ) {
        
        $paths{"ap_loop"}            = $paths{"ap_secdecdir"} . "loop/";
        $paths{"ap_looptemplate"}    = $paths{"ap_loop"} . "template/";
        
        $paths{"apf_paramfile_template"} = $paths{"ap_looptemplate"} . "paramloop.input";
        $paths{"apf_mathfile_template"} = $paths{"ap_looptemplate"} . "mathloop.m";
        $paths{"apf_kinemfile_template"} = $paths{"ap_looptemplate"} . "kinemloop.input";
        
    } elsif ( $mode == 1 ) {
        
        $paths{"ap_userdefined"}            = $paths{"ap_secdecdir"};
        $paths{"ap_userdefinedtemplate"}    = $paths{"ap_userdefined"} ."loop/" ."template/";
        
        $paths{"apf_paramfile_template"} = $paths{"ap_userdefinedtemplate"} . "paramuserdefined.input";
        $paths{"apf_mathfile_template"} = $paths{"ap_userdefinedtemplate"} . "mathuserdefined.m";
        $paths{"apf_kinemfile_template"} = $paths{"ap_userdefinedtemplate"} . "kinemuserdefined.input";
        
    } elsif ( $mode == 2 ) {
        
        $paths{"ap_general"}            = $paths{"ap_secdecdir"} . "general/";
        $paths{"ap_generaltemplate"}    = $paths{"ap_general"} . "template/";
        
        $paths{"apf_paramfile_template"} = $paths{"ap_generaltemplate"} . "paramgeneral.input";
        $paths{"apf_mathfile_template"} = $paths{"ap_generaltemplate"} . "mathgeneral.m";
        $paths{"apf_kinemfile_template"} = $paths{"ap_generaltemplate"} . "kinemgeneral.input";
        
    }
    
    # path to user's param/math/kinem files
    my %definputfiles=paths::defaultinputfiles;
    $paths{"apf_paramfile"}    = $paths{"ap_workingdir"} . $definputfiles{"def_paramfile"};
    $paths{"apf_mathfile"} = $paths{"ap_workingdir"} . $definputfiles{"def_mathfile"};
    $paths{"apf_kinemfile"}    = $paths{"ap_workingdir"} . $definputfiles{"def_kinemfile"};
    
    # validate ouput
    if ( -e $paths{"apf_paramfile"} )  { die "Error - " . $paths{"apf_paramfile"} . " already exists!\n" }
    if ( -e $paths{"apf_mathfile"} )  { die "Error - " . $paths{"apf_mathfile"} . " already exists!\n" }
    if ( -e $paths{"apf_kinemfile"} )  { die "Error - " . $paths{"apf_kinemfile"} . " already exists!\n" }
    
    return %paths;
}

#
#
# Special path functions for finding files dynamically
#
#

# returns the path to the decomposition infofile corresponding to the primary sector specified
sub decomposeinfo {
    my %paths  = %{ $_[0] };
    my %mathparams = %{ $_[1] };
    my $sector = $_[2]; # optional
    
    my $infofile;
    my $indflag=$mathparams{"indflag"};
    my $mode=$mathparams{"mode"};
    my @Nlist=@{$mathparams{"array_Nlist"}};
    
    if ($indflag==1 || $mode) {
        unless ( defined $sector ) { $sector = $Nlist[0]; }
        $infofile= $paths{"apfp_out_graphdeco"} . "Part" . $sector . "OUT.info"; # sj - warning hardcoded
#        ...;
    } else {
        $infofile= $paths{"apfp_out_graphdeco"} . "OUT.info";  # sj - warning hardcoded
    }
    
    unless (-e $infofile) {
        die "Warning - (iterated) sector decomposition not yet performed \n"
	   . "or $infofile not found\n"
           . "(Re-)Launch the program via secdec -p paramfile -m mathfile.\n";
    }
    
    return $infofile;
}

# returns the path to the decomposition log file corresponding to the primary sector specified
sub decomposelog {
    my %paths  = %{ $_[0] };
    my %mathparams = %{ $_[1] };
    my $sector = $_[2]; # optional
    
    my $declog;
    my $indflag=$mathparams{"indflag"};
    my @Nlist=@{$mathparams{"array_Nlist"}};
    
    # if ($indflag==1) {
    #     unless ( defined $sector ) { $sector = $Nlist[0]; }
    #     $declog= $paths{"apfp_out_graphdecomposition"} . "Sec" . $sector . ".log"; # sj - warning hardcoded
    # #     ...;
    # } else {
        $declog= $paths{"apfp_out_graphdecomposition"} . "SecAll.log"; # sj - warning hardcoded
    # }
    
    unless (-e $declog) {
        die "Warning - (iterated) sector decomposition not yet performed.\n"
        . "(Re-)Launch the program via secdec -p paramfile -m mathfile.\n";
    }
    
    return $declog;
}

# sj - for indflag/userdefined perhaps we also need to know the sector/function? (TODO)
# returns the path to the contributing polestruct
sub polestruct {
    my %paths  = %{ $_[0] };
    my %params = %{ $_[1] };
    my %mathparams = %{ $_[2] };
    my $polestruct = $_[3];
    my $sector = $_[4]; # optional

    my $indflag=$mathparams{"indflag"};
    my $mode=$mathparams{"mode"};
    my @Nlist=@{$mathparams{"array_Nlist"}};
    if ($indflag==1 || $mode==1 ) { unless ( defined $sector ) { $sector = $Nlist[0]; } }
    
    my $path;
    
    if ( $params{"together"} ) {
	if ($mode==1) {
	    $path = $paths{"apfp_out_polestruct"} . "func" . $sector . "/" . $paths{"rp_out_together"}
	} elsif ($indflag==1) {
	    $path = $paths{"apfp_out_polestruct"} . "sec" . $sector . "/" . $paths{"rp_out_together"}
	}else{
	    $path = $paths{"apfp_out_polestruct"} . $paths{"rp_out_together"};
	}
    } else {
	if ($mode==1) {
	    $path = $paths{"apfp_out_polestruct"} . "func" . $sector . "/" . $polestruct . "/";
    	} elsif ($indflag==1) {
	    $path = $paths{"apfp_out_polestruct"} . "sec" . $sector . "/" . $polestruct . "/";
	}else{
	    $path = $paths{"apfp_out_polestruct"} . $polestruct . "/";
	}
    }
    
    return $path;
}

1;
