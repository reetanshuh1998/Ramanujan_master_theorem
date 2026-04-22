  #****p* SecDec/general/perlsrc/makesum.pm
  #  NAME
  #    makesum.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makesum
  # 
  #  USES 
  #  arguements parsed from preparenumerics.pl
  #
  #  USED BY 
  #    
  #  preparenumerics.pl, writefiles.pm
  #
  #  PURPOSE
  #  writes the fortran files *sf*.f in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguements:
  #  filename:name and directory of the *sf*.f to be written
  #  kk:which sum file is to be written, specifies *sf$kk.f
  #  lowii: number of the first function in the sum
  #  highii: number of the last function in the sum
  #  point: name of numerical point
  #  polestruct; polestructure being calculated
  #  variables: 
  #  funlist: is the list of functions to be summed, to be written to the external declaration
  #   part of *sf*.f
  #  asslist:consists of a string of "      g(#1)=[prestring]f#2(x)\n"
  #  lineflag: flag to decide whether a newline is needed in $funlist or $asslist
  #  nfun: number of functions being summed
  #  $sp: 6 space characters, useful for preparing the fortran format of *sf*.f
  #    
  #  RESULT
  #  new function *sf*.f in the appropriate subdirectory 
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****
package makesum;

sub go {
my $filename=$_[0];
my $kk=$_[1];
my $lowii=$_[2];
my $highii=$_[3];
my $point=$_[4];
my $polestruct=$_[5];
my $numvar=$_[6];
my $sp="      ";
my $funlist="";
my $lineflag = 0;
my $asslist = "";
my $prestring="P$polestruct";
for ($ii=$lowii;$ii<=$highii;$ii++) {
	$lineflag++;
	if($ii==$highii){
		$funlist = "$funlist\n     # ${prestring}f$ii\n";
	}elsif($lineflag >1){
		$lineflag=0;
		$funlist = "$funlist\n     # ${prestring}f$ii,";
	} else {
		$funlist = "$funlist ${prestring}f$ii,";
	}
	my $gnum=$ii-$lowii+1;
	$asslist = "$asslist\n$sp g($gnum) = ${prestring}f$ii(x)";
}#next ii

my $nfun=$highii-$lowii+1;

if(-e $filename){system("rm -f $filename")};

open(SUMFILE, ">", "$filename");
	print SUMFILE "${sp}double precision function G$point${prestring}sf$kk(x)\n";
	print SUMFILE "${sp}double precision x\n";
	print SUMFILE "${sp}double precision g,sumg\n";
	print SUMFILE "${sp}integer ndi\n";
	print SUMFILE "${sp}common/ndimen/ndi\n";
	print SUMFILE "${sp}parameter (nfun=$nfun)\n";
	print SUMFILE "${sp}dimension x($numvar),g(nfun)\n";
	print SUMFILE "${sp}double precision$funlist";
	print SUMFILE "${sp}$asslist\n";
	print SUMFILE "${sp}sumg = 0.D0\n";
	print SUMFILE "${sp}do k=1,nfun\n";
	print SUMFILE "${sp}sumg = sumg+g(k)\n";
	print SUMFILE "${sp}enddo\n";
	print SUMFILE "${sp}G$point${prestring}sf$kk = sumg\n";
	print SUMFILE "${sp}return\n";
	print SUMFILE "${sp}end";
close SUMFILE;
};
1;
