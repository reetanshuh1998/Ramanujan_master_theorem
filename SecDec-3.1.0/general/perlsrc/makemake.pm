  #****p* SecDec/general/perlsrc/makemake.pm
  #  NAME
  #    makemake.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makemake
  # 
  #  USES 
  #  arguements parsed from preparenumerics.pl
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
  #  compiler:which compiler is to be used
  #  point:name of numerical point being calculated
  #  kk:which make file is to be written, specifies *make${kk}file
  #  lowii: first function in the *sf*.f file to be integrated
  #  highii: last function in the *sf*.f file to be integrated
  #  variables: 
  #  $funlisto: is the list of functions to be made
  #  $lineflag: flag to decide whether a newline is needed in $funlisto
  #  $nfun: number of functions summed in *sf*.f
  #    
  #  RESULT
  #  new functions *make*file in the appropriate subdirectory
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****

package makemake;

sub go {

my $filename=$_[0];
my $integpath=$_[1];
my $compiler=$_[2];
my $point=$_[3];
$point=~s/DEFAULT//;
my $kk=$_[4];
my $lowii=$_[5];
my $highii=$_[6];
my $integrator=$_[7];
my $dummystring=$_[8];
my $funlisto="";
my $lineflag = 0;

for ($ii=$lowii;$ii<=$highii;$ii++) {
	$lineflag++;
	if($ii==$highii){
		$funlisto = "$funlisto f$ii\.o"
	}elsif($lineflag >5){
			$lineflag=0;
			$funlisto = "$funlisto\\\n	f$ii\.o"
	} else {
		$funlisto = "$funlisto f$ii\.o"
	}
}#next ii
if ($lowii<$highii){$funlisto = "$funlisto ${point}sf$kk\.o"};
$funlisto="$funlisto $dummystring";
#print "$funlisto\n";
$nfun=$highii-$lowii+1;
if ($nfun>0) {
if(-e $filename){system("rm -f $filename")};

open(MAKEFILE, ">", "$filename") || die "cannot open $filename\n";
	print MAKEFILE "FC	= $compiler\n";
if($integrator==0){
	print MAKEFILE "FFLAGS	= -O\n";
	print MAKEFILE "LINKER	= \$(FC)\n";
	print MAKEFILE "GRACELDIR	= $integpath\n";
	print MAKEFILE "BASESLIB	= bases\n";
	print MAKEFILE "\%\.o \: \%\.f\n";
	print MAKEFILE "	\$(FC) -c -o \$\@ \$(FFLAGS) \$<\n";
	print MAKEFILE "MAIN	= ${point}intfile${kk}.o\n";
	print MAKEFILE "FFILES	=$funlisto\n";
	print MAKEFILE "${point}intfile${kk}: \$(MAIN)  \$(FFILES)\n";
	print MAKEFILE "	\$(LINKER) \$(LDFLAGS) -o \$\@\.exe \$^";
	print MAKEFILE " \\\n";
	print MAKEFILE "	-L\$(GRACELDIR) -l\$(BASESLIB) \\\n";
	print MAKEFILE "	\$(LIB) \$(LIBS)";
}else{
	print MAKEFILE "FFLAGS	= -g -O2\n";
	print MAKEFILE "LIBS	= -lm\n";
	print MAKEFILE "LIB	= $integpath/libcuba.a\n";
	print MAKEFILE "%.o : %.f\n";
	print MAKEFILE "	\$(FC) -c -o \$@ \$(FFLAGS) \$<\n";
	print MAKEFILE "MAIN	= ${point}intfile${kk}.o\n";
	print MAKEFILE "FFILES	= $funlisto\n";
	print MAKEFILE "${point}intfile${kk}: \$(MAIN)  \$(FFILES) \$(LIB)\n";
	print MAKEFILE "	 \$(FC) \$(FFLAGS) -o \$@.exe \\\n";
	print MAKEFILE "	\$(MAIN) \$(FFILES) \$(LIB) \$(LIBS)\n";
}
	print MAKEFILE "\n";
	print MAKEFILE "clean:\n";
	print MAKEFILE "	rm \$(MAIN)  \$(FFILES)\n";
close MAKEFILE;
}
};
1;

