  #****
  #  NAME
  #    makemakeC.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makemakeC
  # 
  #  USES 
  #  arguments parsed from preparenumerics.pl
  #
  #  USED BY 
  #  preparenumerics.pl, writefiles.pm
  #
  #  PURPOSE
  #  writes the makefiles *make*file in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguments:
  #  filename: name of makefile to write
  #  integpath:path for numerical integrator
  #  Ccompiler:which C compiler is to be used
  #  kk:which make file is to be written, specifies *make${kk}file
  #  minf: first function to be integrated by *intfile${kk}.c
  #  maxf: last function to be integrated by *intfile${kk}.c
  #  variables: 
  #  $funlisto: is the list of functions to be made
  #  $lineflag: flag to decide whether a newline is needed in $funlisto
  #  $nfun: number of functions summed in *intfile${kk}.cc
  #    
  #  RESULT
  #  new functions make$[kk]file in the appropriate subdirectory
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****
use strict;
use warnings;

use File::Spec;

package makemakeC;

sub go {
    
my $kk=$_[0]; # grouping
my $minf=$_[1]; # number of first function in group
my $maxf=$_[2]; # number of last function in group
my $currentdir=$_[3]; # directory in which to place makefile
my %params = %{$_[4]};
my %paths = %{$_[5]};

my $Ccompiler=$params{"compiler"};
my $filename= $currentdir . $paths{"rp_out_make"} . $kk . $paths{"rp_out_makefile"};
my $intfile=$paths{"rp_out_intfile"};
my $intfilehead=$paths{"rp_out_intfilehead"};
my $intfileext=$paths{"rp_out_intfilextension"};
my $funcname=$paths{"rp_out_f"};
my $cfuncname=$paths{"rp_out_cf"};
my $contourdef=$params{"contourdef"};

my $sobollib=$paths{"rp_sobollib"};
my $soboldir=$paths{"ap_sobol"};
unless ( $params{"sobolpath"} ) { # unless user has specified sobol
    $soboldir=File::Spec->abs2rel($paths{"ap_sobol"}, $currentdir) ."/";  # relative path
}

my $integpath=$paths{"ap_integpath_dynamic"};
unless ( $params{"integpath_dynamic"} ) { # unless user has specified a path to the dynamically chosen integrator
    $integpath=File::Spec->abs2rel($paths{"ap_integpath_dynamic"}, $currentdir) . "/"; # relative path
}


my $funlisto="";
my $gunlisto="";
my $lineflag=0;
for (my $ii=$minf;$ii<=$maxf;$ii++) {
	$lineflag++;
	if($ii==$maxf){
	    $funlisto = "$funlisto " . $paths{"rp_out_f"} . "$ii\.o";
	    if($contourdef eq "True"){$gunlisto = "$gunlisto " . $paths{"rp_out_cf"} . "$ii\.o";}
	}elsif($lineflag >5){
	    $lineflag=0;
	    $funlisto = "$funlisto\\\n	" . $paths{"rp_out_f"} . "$ii\.o";
	    if($contourdef eq "True"){$gunlisto = "$gunlisto\\\n	" . $paths{"rp_out_cf"} . "$ii\.o";}
	} else {
	    $funlisto = "$funlisto " . $paths{"rp_out_f"} . "$ii\.o";
	    if($contourdef eq "True"){$gunlisto = "$gunlisto " . $paths{"rp_out_cf"} . "$ii\.o"}
	}
}#next ii
my $nfun=$maxf-$minf+1;


if ($nfun>0) {
    open(MAKEFILE, ">", "$filename") || die "cannot open $filename\n";
    print MAKEFILE "CC	= $Ccompiler " . $params{"CCargs"} . "\n";
    print MAKEFILE "LIBS	= -lm -lstdc++ \n";
    if($params{"integrator_dynamic"} == 6){
      my $incpath=$paths{"ap_integpath_dynamic"} . $paths{"rp_integinc_dynamic"};
      print MAKEFILE "INC=-I${incpath}\n";
    }
	print MAKEFILE "LIB	= ${integpath}" . $paths{"ext_integlib_dynamic"} . "\n";
    if ( $params{"contourdef"} eq "True" ){
        print MAKEFILE "SOBOLF	= ${soboldir}${sobollib}\n";
    }
    print MAKEFILE "%.o : %.cc ${intfilehead} \n";
    print MAKEFILE "	\$(CC) \$(INC) -c -o \$@ \$<\n";
    print MAKEFILE "MAIN	= ${intfile}${kk}.o\n";
    print MAKEFILE "CFILES	= $funlisto$gunlisto\n";
    print MAKEFILE "${intfile}${kk}: \$(MAIN)  \$(CFILES) \$(LIB)\n";
    print MAKEFILE "\t\$(CC) -o \$@" . ${intfileext} . " \\\n";
    if ( $params{"contourdef"} eq "True" ) {
        print MAKEFILE "\t\$(MAIN) \$(CFILES) \$(INC) \$(LIB) \$(SOBOLF) \$(LIBS)\n";
    } else {
        print MAKEFILE "\t\$(MAIN) \$(CFILES) \$(INC) \$(LIB) \$(LIBS)\n";
    }
    print MAKEFILE "clean:\n";
    print MAKEFILE "\trm \$(MAIN)  \$(CFILES)\n";
    close MAKEFILE;
}
};
1;	
