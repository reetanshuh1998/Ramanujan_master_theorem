  #****s* SecDec/general/perlsrc/polenumerics.pl
  #  NAME
  #    polenumerics.pl
  #
  #  USAGE
  #  is called from batch*l*h*, finishnumerics.pl
  # 
  #  USES 
  #  $paramfile, header.pm, getinfo.pm, dirform.pm
  #
  #  USED BY 
  #  batch*l*h*, finishnumerics.pl
  #  
  #  PURPOSE
  #  calls preparenumerics.pl with the appropriate arguements to create the intermediate
  #  files in all necessary subdirectories, and, depending on the value of exe, compiles
  #  the executables and runs/launches them
  #    
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #  parameters parsed via ARGV:
  #  polestruct: [i]l[j]h[h] - i logarithmic poles, j linear poles, h higher poles
  #  integpath: where to find bases or cuba directory
  #  compiler: Fortran compiler to use
  #  makefile: makefile to use to compile numerical integrator, or 'none' to indicate the program is running locally
  #    
  #  RESULT
  #  intermediate functions created in all appropriate subdirectories of polestruct/
  #  if exe>=3 *intfile*.exe s are compiled
  #  if exe==4 *intfile*.exe s are run/launched
  #    
  #  SEE ALSO
  #  preparenumerics.pl, header.pm, batch*l*h*, getinfo.pm
  #   
  #****
  #
$polestruct=$ARGV[0];
$integpath=$ARGV[1];
$compiler=$ARGV[2];
$makefile=$ARGV[3];
$local=0;
if($makefile eq "none"){$local=1};

use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){
 $workingdir=~s/\/$//;
 $wdstring="-d=$workingdir ";
 $templatefile = "$workingdir/$templatefile";
 $wparamfile = "$workingdir/$paramfile"
}
use lib "perlsrc";
use header;
use getinfo;
use dirform;
my %hash_var=header::readparams($wparamfile);

$point=$hash_var{"pointname"};
unless ($point) {$point=""};
$dirbase=`pwd`;
chomp $dirbase;
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
$graph=$hash_var{"graph"};
unless ($currentdir) {
if($workingdir){
 if ($workingdir=~m/^\//){
  $diry=dirform::norm("$workingdir/$subdir");
  $currentdir="$diry/$graph";
 } else {
  $subdir="$workingdir/$subdir";
  $diry=dirform::norm("${dirbase}/$subdir");
  $currentdir="$diry/$graph"
 }
} else {
 $currentdir="$diry/$graph"
}
}
#get number of parameters to integrate over:
$maxvar=getinfo::numvar("$currentdir/$graph.m"); 

$epsord=$hash_var{"epsord"};
$clusterflag=$hash_var{"clusterflag"};
unless($clusterflag){$clusterflag=0};
$exe=$hash_var{"exe"};
if ($exe ne "0") {unless ($exe) {$exe=4};};
if ($exe<=1) {$exe=4};

if ($polestruct=~/.*P(.*)l(.*)h(.*)/) {
 $i=$1;
 $j=$2;
 $h=$3;
} elsif ($polestruct=~/(.*)l(.*)h(.*)/) {
 $i=$1;
 $j=$2;
 $h=$3;
} else {
 die "invalid pole structure parsed"
}
$routine=$hash_var{"integrator"};
unless($routine){$routine=0};
if (-e "$currentdir/$polestruct/infofile") {
 if ($exe>=3) {
  if($local==0){system("perl perlsrc/remakebases.pl $integpath $graph $polestruct $compiler $makefile $routine")}
 }
 $regexdir=dirform::regex($currentdir);
 $regexdir="$regexdir\\/";
 $regexdirbase=dirform::regex($dirbase);
 $regexdirbase="$regexdirbase\\/";
 @poleorders=getinfo::poleorders("$currentdir/$polestruct/infofile");
 $prefacord=getinfo::prefacord("$currentdir/${graph}OUT.info");
 $minpole=$poleorders[0];
 $overallmaxpole=getinfo::overallmaxpole("$currentdir/${graph}OUT.info");
 # maxlogpole is the absolute value of the overall logarithmic pole order
############
#outdated: $numvar="noparts";
 $truemin=$minpole+$prefacord;
 $tominpole=$minpole;
 $tominpole=~s/-/m/;
 $numvar=$maxvar; 
  for ($ord=$epsord;$ord>=$minpole;$ord--) {
      ####################################################################
      # if integrand is found to be independent of Feynpars, the number of
      # feynpars to integrate over must be changed accordingly. Here, nb 
      # of feynpars is read from infofile via sub nbconsts in getinfo.pm
      $helpvar=getinfo::nbconsts("$currentdir/$polestruct/infofile",$ord);
      $numvar=$helpvar;
      ####################################################################
      if (-e "$currentdir/$polestruct/epstothe$ord/f1.f") {
	  $to=$ord;
	  $to=~s/-/m/;
	  system("perl perlsrc/preparenumerics.pl $to $numvar $tominpole $polestruct $overallmaxpole -p=$paramfile $wdstring");
	  if ($exe>=3) {
	      if($exe==3) {
		  system("cd $currentdir/$polestruct/epstothe$ord; perl ${point}make.pl");
	      } else {
		  $exstat=system("cd $currentdir/$polestruct/epstothe$ord; perl ${point}subfile.pl");
		  $texstat=$?>>8;
		  unless($texstat==0){exit $texstat};
	      }
	  }
      }
  }
} else {
    print "no poles of this type\n";
}
