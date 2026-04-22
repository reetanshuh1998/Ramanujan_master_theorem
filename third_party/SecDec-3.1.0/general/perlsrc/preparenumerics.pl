  #****s* SecDec/general/perlsrc/preparenumerics.pl
  #  NAME
  #    preparenumerics.pl
  #
  #  USAGE
  #  is called from polenumerics.pl
  # 
  #  USES 
  #  $paramfile, header.pm, writefiles.pm, getinfo.pm, dirform.pm
  #  $polestructure determined by polenumerics.pl,
  #
  #  USED BY 
  #    
  #  PURPOSE
  #  writes the fortran files sf*.f, intfile*.f, and the files 
  #  makefile*, subfile.pl, for each given
  #  polestructure, order, number of variables 
  #  in the corresponding subdirectory of $currentdir.
  #  also writes $jobfile to submit the jobs to a queue in batch mode
  #    
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #  parameters parsed via ARGV:
  #  jj: eps^jj
  #  numvar: number of integration variables, or "noparts" if IBP not used
  #  maxpole: maximal pole for this structure
  #  polestruct: [i]l[j]h[h] -  i logarithmic poles, j linear poles, h higher poles
  #    
  #  RESULT
  #  new functions in $currentdir and subdirectories corresponding to polestructure
  #    
  #  SEE ALSO
  #  polenumerics.pl, subexp.pl writefiles.pm, getinfo.pm
  #   
  #****
  #
use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
unless ($templatefile) {
  $templatefile = "Template.m";
}
$wdstring="";
if($workingdir){
 $workingdir=~s/\/$//;
 $wdstring="-d=$workingdir ";
 $templatefile = "$workingdir/$templatefile";
 $paramfile = "$workingdir/$paramfile"
}
use lib "perlsrc";
use header;
use getinfo;
use writefiles;
use dirform;
my %hash_var=header::readparams($paramfile);
$dirbase=`pwd`;
chomp $dirbase;
$compiler=$hash_var{"compiler"};
unless ($compiler) {$compiler="gfortran"};
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
$graph=$hash_var{"graph"};
unless ($currentdir) {
    if($workingdir) {
	if ($workingdir=~m/^\//){
	    $diry=dirform::norm("$workingdir/$subdir");
	    $currentdir="$diry/$graph";
	} else {
	    $subdir="$workingdir/$subdir";
	    $diry=dirform::norm("${dirbase}/$subdir");
	    $currentdir="$diry/$graph"
	}
    } else {
	$currentdir="$diry/$graph";
    }
}
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
if($routine){$integpath=$cubapath}else{$integpath=$basespath};
$point=$hash_var{"pointname"};
unless ($point) {$point="DEFAULT"};
$processlimit=$hash_var{"processlimit"};
unless($processlimit){$processlimit=200};
if($processlimit<20){$processlimit=20};
$exe=$hash_var{"exe"};
if ($exe ne "0") {unless ($exe) {$exe=4};};
$clusterflag=$hash_var{"clusterflag"};
$local=0;
if($clusterflag==0){if($exe>0){$local=1}};
$cputime=$hash_var{"cputime"};
unless($cputime){$cputime=1000};
@dummylist=split(/,/,$hash_var{"dummys"});
@dummyorder=split(/,/,$hash_var{"dummyorder"});
my $maxi=@dummylist;
for(my $i=0; $i<$maxi; $i++){
  for(my $j=1; $j<=$dummyorder[$i]; $j++){
    push(@dummylist,"$dummylist[$i]Deps$j");
  }
}
$dummystring="";
foreach $dum (@dummylist){
 $dummystring="$dummystring\\\n      ../../${dum}.o"
}
$dummystring=~s/\\\n//;
$jj=$ARGV[0];
$jj=~s/m/-/;
$numvar=$ARGV[1]; # in polenumerics.pl, $numvar=nmax from {graph}.m
$maxpole=$ARGV[2];
$maxpole=~s/m/-/;
$polestruct=$ARGV[3];
$overallmaxpole=$ARGV[4];
################## end of input parameters ################
#
############## BEGIN choose correct integrator ############
if ( $numvar == 1 && ( $routine == 3 || $routine == 4) )
{
 $routine=1;
 print "Integration routine changed to Vegas, as integration ";
 print "over 1 parameter not possible with integrator chosen in input file.\n";
}
if ( $numvar == 0 ) {
    print "No Monte Carlo integration needed, computation done with Standard math library.\n";
}
my $maindir = "$currentdir/$polestruct";
$currentdir="$maindir/epstothe$jj";
############## END choose correct integrator ##############
$maxsize=$hash_var{"grouping"};
if($maxsize ne "0"){unless($maxsize){$maxsize=2000000}};
$funcount=1;
$fmax[0]=0;
$groupcount=0;
$sizesum=0;
while (-e "$currentdir/f$funcount.f") {
 $filesize = -s "$currentdir/f$funcount.f";
 $sizesum=$sizesum+$filesize;
 if($sizesum>$maxsize){
  $groupcount++;
  $fmax[$groupcount]=$funcount;
  $sizesum=0
 }
 $funcount++
}
$funcount--;
unless ($sizesum==0){
 $groupcount++;
 $fmax[$groupcount]=$funcount
}
$filepoint=$point;
$filepoint=~s/DEFAULT//;
$batchsystem=$hash_var{"batch"};
$integpathstring="";
for ($kk=1;$kk<=$groupcount;$kk++) {
	$minf=$fmax[$kk-1]+1;
	$maxf=$fmax[$kk];
 	if($local==0){$integpathstring="$graph/$polestruct"}else{$integpathstring=$compiler}
	@makeargs=("$currentdir/${filepoint}make${kk}file","$integpath/$integpathstring",$compiler,$point,$kk,$minf,$maxf,$routine,$dummystring);
	writefiles::makemake(@makeargs);#creates makefiles
	$singflag=$minf;
	if($minf<$maxf){
	 $singflag=0;
	 @sumargs=("$currentdir/${filepoint}sf$kk\.f",$kk,$minf,$maxf,$point,$polestruct,$numvar);
	 writefiles::makesum(@sumargs); #creates sf*.f
	}
	$prestring="P$polestruct";
	if ($singflag==0){
	 $integrand="G$point${prestring}sf$kk";
	} else {
	 $integrand="${prestring}f$singflag";
	};
	@intargs=("$currentdir/${filepoint}intfile$kk\.f",$jj,$kk,$numvar,$maxpole,$paramfile,$integrand,$routine,$overallmaxpole);
	writefiles::makeint(@intargs); #creates intfile*.f
	if ($clusterflag==1) {
	 if ($filepoint ne "") {
	  $jobfilename="$currentdir/$polestruct.${point}.$jj.$kk"
	 } else {
	  $jobfilename="$currentdir/$polestruct.$jj.$kk"
	 }
	}
	@jobargs=($batchsystem,$jobfilename,$currentdir,"${filepoint}intfile$kk.exe",$cputime,1);
	writefiles::makejob(@jobargs); #creates job submission files
}#next kk

@subargs=("$currentdir/${filepoint}subfile.pl",$jj,$point,$graph,$polestruct,$processlimit,$numvar,$exe,"$dirbase/perlsrc",$batchsystem,$currentdir,$clusterflag);
writefiles::makesub(@subargs); #creates subfile.pl
@makemakerunargs=("$currentdir/${filepoint}make.pl",$jj,$point,$polestruct);
writefiles::makemakerun(@makemakerunargs); #creates make.pl

open (INFO,">$currentdir/${filepoint}info");
 print INFO "Number of integrations = $groupcount";
close INFO;





