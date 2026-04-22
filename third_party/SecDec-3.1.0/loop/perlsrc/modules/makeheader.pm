  #****
  #  NAME
  #    makeheader.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makeheader
  # 
  #  USES 
  #
  #  $paramfile, header.pm, arguments parsed from preparenumerics.pl
  #
  #  USED BY 
  #    
  #  preparenumerics.pl, writefiles.pm
  #
  #  PURPOSE
  #  writes the C++ header file intfile.hh for the *intfile*.cc in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguments:
  #  filename:name and directory of the *intfile*.cc to be written
  #  lowii: lowest individual function number to integrate
  #  highii: highest individual function number to integrate
  #  prestring: prefix of the functions to be integrated
  #  jj:epsilon order
  #  kk:which integration file is to be written, specifies *intfile$kk.cc
  #  numvar: number of variables in integration
  #  maxpole: maximal pole for this pole structure (can be spurious)
  #  paramfile: file to read parameters from
  #
  #  parameters read from $paramfile:
  #  oscillatory:flag stating whether functions minimizing the complex argument exist
  #  contourdef:flag stating whether g*.cc files from contour deformation optimizing the deformation exist
  #    
  #  RESULT
  #  new functions $[point]intfile$[kk].cc in the appropriate subdirectory graph/polestructure/epsilonorder/
  #    
  #  SEE ALSO
  #  preparenumerics.pl
  #   
  #****
use strict;
use warnings;

use File::Spec;

package makeheader;

sub go {
    my $funcount=$_[0];
    my $numvar=$_[1];
    my $polestruct=$_[2];
    my $currentdir=$_[3];
    my %params = %{$_[4]};
    my %paths = %{$_[5]};
    
    my $contourdef=$params{"contourdef"};
    my $oscillatory=$params{"oscillatory"};
    my $filename= $currentdir . $paths{"rp_out_intfilehead"};
    my $prestring= "P$polestruct";
    my $soboldir=$paths{"ap_sobol"};
    unless ( $params{"sobolpath"} ) { # unless user has specified sobol
        $soboldir=File::Spec->abs2rel($paths{"ap_sobol"}, $currentdir) ."/";  # relative path
    }
    my $sobolhead = $soboldir . $paths{"rp_sobolhead"};
    
    my $integpath=$paths{"ap_integpath_dynamic"};
    unless ( $params{"integpath_dynamic"} ) { # unless user has specified a path to the dynamically chosen integrator
        $integpath=File::Spec->abs2rel($paths{"ap_integpath_dynamic"}, $currentdir) . "/"; # relative path
    }
    my $integhead = $integpath . $paths{"rp_integhead_dynamic"};

    my @headers=();
 if ( $params{"contourdef"} eq "True") {
     @headers=("<math.h>","<complex>","<fstream>","<time.h>","<iostream>","<cstdlib>","<iomanip>","\"$integhead\"","\"$sobolhead\"","<string.h>");
 } else {
     @headers=("<math.h>","<complex>","<fstream>","<time.h>","<iostream>","<cstdlib>","<iomanip>","\"$integhead\"","<string.h>");
 }
 my $headstring=join("\n#include ",@headers);
 $headstring="#include $headstring";
 my $fstr1=""; my $fstr2=""; my $fstr3="";my $fstr5=""; my $fstr4=""; my $fstr6="";
    my $masstype="double";
    if($params{"complexmasses"}==1) { $masstype = "dcmplx"; }
 for(my $i=1;$i<=$funcount;$i++) {
 if(($contourdef eq "True") || ($params{"complexmasses"} == 1)) {
	 $fstr1="${fstr1}dcmplx ${prestring}f$i(const double x[],double esx[],$masstype em[],double lambda, double lrs[], double bi);\n";
 if($contourdef eq "True") {
	 $fstr2="${fstr2}double ${prestring}r$i(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);\n";
	 $fstr3="${fstr3}double ${prestring}m$i(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);\n";
	 $fstr5="${fstr5}double ${prestring}s$i(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);\n";
	 $fstr6="${fstr6}double ${prestring}a$i(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);\n";
	 for(my $j=1;$j<=$numvar;$j++) {
	     $fstr4="${fstr4}double ${prestring}t${i}t$j(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);\n";
	 }
     }	 
     } else {
	 $fstr1="${fstr1}double ${prestring}f$i(const double x[],double esx[],$masstype em[],double lambda, double lrs[], double bi);\n";
     }
 }
 my $functiondeclare="$fstr1 $fstr2 $fstr3 $fstr5 $fstr4 ";
 open(HEADFILE, ">", "$filename");
 print HEADFILE "#ifndef _chead_h\n";
 print HEADFILE "#define _chead_h\n";
 print HEADFILE "$headstring\n";
 print HEADFILE "using namespace std;\n";
 if(($contourdef eq "True") || ($params{"complexmasses"} == 1)) {
     print HEADFILE "typedef complex<double> dcmplx;\n";
     print HEADFILE "\ndcmplx myLog(dcmplx myarg);\n";
 }
 if($contourdef eq "True") {
     print HEADFILE "int findoptlam (const int dim, const int maxeval, const int nrcomp);\n";
     print HEADFILE "int Integrand2 (const double xx[], const int ncomp);\n";
     print HEADFILE "int Integrand3 (const double xx[], const int ncomp);\n";
     print HEADFILE "int Integrand4 (const double xx[], const int ncomp);\n";
     if ($oscillatory)
     {
	 print HEADFILE "$fstr6";
	 print HEADFILE "int Integrand5 (const double xx[], const int ncomp);\n";
     }
 }
 print HEADFILE "$functiondeclare";
 if ($numvar != 1) {
     print HEADFILE "int Integrand (const int *ndim, const double x[], const int *ncomp, double f[], void *userdata);\n";
 } else {
     print HEADFILE "double fgsl (double y, void * params);\n";
 }
 print HEADFILE "#endif\n";
 close HEADFILE;
}
1;
