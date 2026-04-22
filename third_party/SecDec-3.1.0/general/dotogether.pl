#
#****s* SecDec/general/dotogether.pl
# NAME
#  dotogether.pl
# USAGE
# ./dotogether.pl ord1 ord2 ord3 ...
# PURPOSE
#  integrates all integrands for the specified order of epsilon
#  as one function, instead of individually integrating different
#  pole structures and numbers of integration variables separately.
#  this is particularly useful when intermediate calculations produce
#  large positive and negative outputs, which cancel to give a small
#  final result. NB if specifying a negative order, this must be expressed
#  as 'm1', instead of '-1'.
#  OPTIONS
#  to use a param.input file with a different name
#  use option "-p paramfile" 
#  to specify a different directory to work in
#  use option "-d workingdirectory" 
#****
use lib "perlsrc";
use header;
use getinfo;
use makeint;
use launchjob;
use makejob;
use dirform;
use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
unless ($templatefile) {
  $templatefile = "Template.m";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){
 $workingdir=~s/\/$//;
 $wdstring="-d=$workingdir ";
 $wparamfile="$workingdir/$paramfile";
 $templatefile="$workingdir/$templatefile"
}
my %hash_var=header::readparams($wparamfile);
my @dummylist=split(/,/,$hash_var{"dummys"});
$dummystring="";
foreach $dum (@dummylist){
 $dummystring="$dummystring\\\n      ../../${dum}.o"
}
$dummystring=~s/\\\n//;
my @epsord=@ARGV;
$dirbase=`pwd`;
chomp $dirbase;
$exe=$hash_var{"exe"};
if ($exe ne "0"){unless($exe){$exe=4}};
$compiler=$hash_var{"compiler"};
$makefile="Makefile.linux";
$maxtime=$hash_var{"cputime"};
unless($maxtime){$maxtime=1000};
unless ($compiler) {$compiler="gfortran"};
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
$clusterflag=$hash_var{"clusterflag"};
$batchsystem=$hash_var{"batch"};
$basespath=$hash_var{"basespath"};
unless ($basespath) {$basespath="$dirbase/src/basesv5.1"};
$basespath=~s/\/loop\//\//;
$basespath=~s/\/general\//\//;
$cubapath=$hash_var{"cubapath"};
unless ($cubapath) {$cubapath="$dirbase/src/Cuba-4.1"};
$cubapath=~s/\/loop\//\//;
$cubapath=~s/\/general\//\//;
$routine=$hash_var{"integrator"};
unless($routine){$routine=0};
$integpath=$basespath;
if($routine){$integpath=$cubapath;$makefile="makefile"};
$point=$hash_var{"pointname"};
$maxvar=getinfo::numvar("$currentdir/$graph.m");
$maxord=$hash_var{"epsord"};

if($clusterflag==0){system("perl perlsrc/remakebases.pl $integpath $compiler none $compiler $makefile $routine")};
unless(-d "$currentdir/together"){system("mkdir $currentdir/together")}; 
$infofile="$currentdir/${graph}OUT.info";
if(-e $infofile){
 @poleslist=getinfo::poles($infofile);
 $prefacord=getinfo::prefacord($infofile);
 if ( $prefacord<=-1 ) { $maxord=$maxord-$prefacord; }
} else {
 die "Could not find $infofile\n"
}
$glominpo=2;
foreach $polestruct (@poleslist){
 $pinf="$currentdir/$polestruct/infofile";
 if (-e $pinf){
  @pords=getinfo::poleorders($pinf);
  $pmintemp=$pords[0];
  if($pmintemp<$glominpo){$glominpo=$pmintemp};
 }
}
$ominpole=0;
open (INFO,">","$currentdir/together/infofile") || die "cannot open $currentdir/together/infofile\n";
#open (INFO,">>","$currentdir/together/infofile");
foreach $ord (@epsord) {
 $ord=~s/m/-/;
 if($ord<=$maxord) {
 @makelist=();
 @namelist=();
 $numvar=0;
 foreach $polestruct (@poleslist) {
     if ($polestruct=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
     $minpole=-$i-$j-$h;
     if($minpole<$ominpole){$ominpole=$minpole};
     if($ord>=$minpole+$prefacord) {
#maybe correct?     if($ord>=$minpole) {
	 $functdir="$currentdir/$polestruct/epstothe$ord";
	 $prestring="P$polestruct";
	 increaselists($functdir,$prestring);
	 #######################################
	 # if integrand is found to be independent of Feynpars, the number of
	 # feynpars to integrate over must be changed accordingly. Here, nb  
	 # of feynpars is read from infofile via sub nbconsts in getinfo.pm  
	 #######################################
	 $helpvar=getinfo::nbconsts("$currentdir/$polestruct/infofile",$ord);
	 if ($helpvar >= $numvar) {$numvar=$helpvar;}
	 print INFO "\"${polestruct}constants = $helpvar -> $numvar integrations\"\n";
	 #######################################
	 # change integrator to Vegas for integration 
	 # of only one Feynman parameter 
	 #######################################
	 if ( $numvar == 1 && ( $routine == 3 || $routine == 4) )
	 {
	     $routine=1;
	     print "Integration routine changed to Vegas, as integration ";
	     print "over 1 integration parameter not possible with integrator chosen in input file.\n";
	 }
	 if ( $numvar == 0 ) {
	     print "No Monte Carlo integration needed, computation done with Standard math library.\n";
	 }
	 #######################################
     }
 }
 if(@namelist){
  unless(-d "$currentdir/together/epstothe$ord"){system("mkdir $currentdir/together/epstothe$ord")};
  $numoffuns=@namelist;
  print INFO "\"${ord}functions = $numoffuns\"\n";
  if($clusterflag==1){$integpatht="$integpath/$graph/epstothe$ord"}else{$integpatht="$integpath/$compiler"};
  writemakefile("$currentdir/together/epstothe$ord/make$point",$dummystring);
  writesumfile("$currentdir/together/epstothe$ord/fullsum$point.f");
  $intfile="$currentdir/together/epstothe$ord/${point}intfile.f";
  $kk="1";
  $integrand="fullsum$point";
  @intargs=($intfile,$ord,$kk,$numvar,$glominpo,$wparamfile,$integrand,$routine);
  makeint::go(@intargs);
  if ($clusterflag==1){
   open(EXEFILE,">","$currentdir/together/epstothe$ord/subexe");
   print EXEFILE "perl $dirbase/perlsrc/remakebases.pl $integpath $graph epstothe$ord $compiler $makefile $routine\n";
   print EXEFILE "make -s -j -f make$point\n";
   print EXEFILE "if [ \$? -ne 0 ]\n";
   print EXEFILE "then\n";
   print EXEFILE "  make -s -j -f make$point clean\n";
   print EXEFILE " make -s -j -f make$point\n";
   print EXEFILE "fi\n";
   if($exe!=3){print EXEFILE "./${point}intfile.exe"};
   close EXEFILE;
   system("chmod +x $currentdir/together/epstothe$ord/subexe");
   @jobargs=($batchsystem,"$currentdir/together/epstothe$ord/togsub","$currentdir/together/epstothe$ord","subexe",$maxtime,1);
   makejob::go(@jobargs);
   if($exe!=2){
    print "submitting job for integration at order eps^$ord\n";
    launchjob::submit($batchsystem,"$currentdir/together/epstothe$ord/togsub")
   };
   if($exe==3){
    @jobargs=($batchsystem,"$currentdir/together/epstothe$ord/togsubint","$currentdir/together/epstothe$ord","${point}intfile.exe",$maxtime,1);
    makejob::go(@jobargs)
   }
  } else {
   $syststr="";
   if($exe!=2){
    $syststr="cd $currentdir/together/epstothe$ord;echo compiling functions needed for calculation at order eps^$ord...;make -s -f make$point";
    $syststr="$syststr;if [ \$? -ne 0 ]; then  make -s -f make$point clean;make -s -f make$point; fi";
    if($exe!=3){
     $syststr="$syststr;echo performing integration...;./${point}intfile.exe>${point}intfile.log"
    }
   }
   if ($syststr ne ""){
    system("$syststr");
    $texcode=$?>>8;
    unless($texcode==0){
     exit $texcode
    }
   }
  }
 }
 
} else {
     print "$ord is larger than the maximum expected order, integration will not take place at this order\n"
}
}
close INFO;





sub increaselists {
my $fdr=$_[0];
my $pref=$_[1];
$ili=1;
while (-e "$fdr/f$ili.f"){
 $tfuna="${pref}f$ili";
 $tfina="$fdr/f$ili.o";
 push(@makelist,$tfina);
 push(@namelist,$tfuna);
 $ili++
}
}

sub writemakefile {
my $filename=$_[0];
my $dummystring=$_[1];
my $funlisto="";
foreach $fun (@makelist){
 $funlisto = "$funlisto\\\n	$fun"
}
$funlisto="$funlisto \\\n $dummystring";
$funlisto = "$funlisto\\\n      fullsum${point}\.o";
open(MAKEFILE, ">", "$filename") || die "cannot open $filename\n";
	print MAKEFILE "FC	= $compiler\n";
if($routine==0){
	print MAKEFILE "FFLAGS	= -O\n";
	print MAKEFILE "LINKER	= \$(FC)\n";
	print MAKEFILE "GRACELDIR	= $integpatht\n";
	print MAKEFILE "BASESLIB	= bases\n";
	print MAKEFILE "\%\.o \: \%\.f\n";
	print MAKEFILE "	\$(FC) -c -o \$\@ \$(FFLAGS) \$<\n";
	print MAKEFILE "MAIN	= ${point}intfile.o\n";
	print MAKEFILE "FFILES	=$funlisto\n";
	print MAKEFILE "${point}intfile: \$(MAIN)  \$(FFILES)\n";
		
	print MAKEFILE "	\$(LINKER) \$(LDFLAGS) -o \$\@\.exe \$^";
	print MAKEFILE " \\\n";
	print MAKEFILE "	-L\$(GRACELDIR) -l\$(BASESLIB) \\\n";
	print MAKEFILE "	\$(LIB) \$(LIBS)\n";
}else{
	print MAKEFILE "FFLAGS	= -g -O2\n";
	print MAKEFILE "LIBS	= -lm\n";
	print MAKEFILE "LIB	= $integpatht/libcuba.a\n";
	print MAKEFILE "%.o : %.f\n";
	print MAKEFILE "	\$(FC) -c -o \$@ \$(FFLAGS) \$<\n";
	print MAKEFILE "MAIN	= ${point}intfile.o\n";
	print MAKEFILE "FFILES	= $funlisto\n";
	print MAKEFILE "${point}intfile: \$(MAIN)  \$(FFILES) \$(LIB)\n";
	print MAKEFILE "	 \$(FC) \$(FFLAGS) -o \$@.exe \\\n";
	print MAKEFILE "	\$(MAIN) \$(FFILES) \$(LIB) \$(LIBS)\n";
	print MAKEFILE "\n";
}
	print MAKEFILE "clean:\n";
	print MAKEFILE "	rm \$(MAIN)  \$(FFILES)\n";
close MAKEFILE;
}

sub writesumfile {
my $filename=$_[0];
my $sp="      ";
my $funlist="";
my $asslist = "";
my $gnum=0;
my $maxfuns=@namelist;
my $lineflag=0;
foreach $fun (@namelist){
	$gnum++;
	$lineflag++;
	if($gnum==$maxfuns){
		$funlist = "$funlist $fun\n";
	}elsif($lineflag >2){
		$lineflag=0;
		$funlist = "$funlist\n     # $fun,";
	} else {
		$funlist = "$funlist $fun,";
	}
	$asslist = "$asslist\n$sp g($gnum) = $fun(x)";
}

open(SUMFILE, ">", "$filename");
	print SUMFILE "${sp}double precision function fullsum$point(x)\n";
	print SUMFILE "${sp}double precision x\n";
	print SUMFILE "${sp}double precision g,sumg\n";
	print SUMFILE "${sp}integer ndi\n";
	print SUMFILE "${sp}common/ndimen/ndi\n";
	print SUMFILE "${sp}parameter (nfun=$gnum)\n";
	print SUMFILE "${sp}dimension x($numvar),g(nfun)\n";
	print SUMFILE "${sp}double precision $funlist";
	print SUMFILE "${sp}$asslist\n";
	print SUMFILE "${sp}sumg = 0.D0\n";
	print SUMFILE "${sp}do k=1,nfun\n";
	print SUMFILE "${sp}sumg = sumg+g(k)\n";
	print SUMFILE "${sp}enddo\n";
	print SUMFILE "${sp}fullsum$point = sumg\n";
	print SUMFILE "${sp}return\n";
	print SUMFILE "${sp}end";
close SUMFILE;
}
sub findmin {
my $tmin=0;
foreach $tem (@_){
 if($tem=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 my $tmin2=-$i-$j-$h;
 if($tmin>$tmin2){$tmin=$tmin2}
}
return $tmin
}
