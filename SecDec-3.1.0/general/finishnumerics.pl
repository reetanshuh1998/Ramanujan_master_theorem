#
  #****s* SecDec/general/finishnumerics.pl
  #  NAME
  #    finishnumerics.pl
  #
  #  USAGE
  #  ./finishnumerics.pl
  # 
  #  USES 
  #  $paramfile, header.pm, batch*l*h*, job*l*h*, polenumerics.pl, getinfo.pm, launchjob.pm, finishpolenumerics.pl
  #  
  #  PURPOSE
  #  completes the calculation from where it was left off (specified via $exe in paramfile)
  #    
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #    
  #  RESULT
  #  rest of the calculation is run/submitted to be run, numerical result is then displayed
  #  where possible, or available via 'perl results.pl -d workingdirectory -p paramfile' once all integrations
  #  have been completed 
  #  OPTIONS
  #  to use a param.input file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #    
  #  SEE ALSO
  #  polenumerics.pl, remakebases.pl, finishpolenumerics.pl, results.pl, batch*l*h*, job*l*h*
  #   
  #****
  #

use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){
 $workingdir=~s/\/$//;
 $wdstring="-d=$workingdir ";
 $wparamfile="$workingdir/$paramfile"
};
use lib "perlsrc";
use header;
use getinfo;
use launchjob;
use dirform;
my %hash_var=header::readparams($wparamfile);

$point=$hash_var{"pointname"};
unless ($point) {$point="DEFAULT"};
$dirbase=`pwd`;
chomp $dirbase;
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
$graph=$hash_var{"graph"};
$exe=$hash_var{"exe"};
$compiler=$hash_var{"compiler"};
$togetherflag=$hash_var{"together"};
unless ($compiler) {$compiler="gfortran"};
$makefile="Makefile.linux";
$batchsystem=$hash_var{"batch"};
$epsord=$hash_var{"epsord"};
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

if ($exe ne "0") {unless ($exe) {$exe=4};};
if ($exe==4) {
 system("perl results.pl -p=$paramfile $wdstring");exit
}
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
$local=0;
$clusterflag=$hash_var{"clusterflag"};
if($clusterflag==0){if($exe>0){$local=1}};
if($local==1){$makefile="none"};
$valid=getinfo::validinput("$currentdir/${graph}Decomposition.log");
if($valid==0){
  die "Decomposition was not performed successfully\nPlease verify your inputs - undefined parameters detected\n"
}
@comparlist=split(/,/,$hash_var{"symbconstants"});
@comparvals=split(/,/,$hash_var{"pointvalues"});
if(@comparlist){
 if(@comparvals){
  $complen=@comparlist;
  $complen2=@comparvals;
  if($complen2<$complen){
   die "Need to specify numerical values for parameters in $paramfile\n"
  } elsif($complen2>$complen){
   print "Warning - number of parameters < number of values specified. Additional values ignored\n"
  }
 } else {
  die "Need to specify numerical values for parameters in $paramfile\n"
 }
} else {
 if(@comparvals){
  print "Warning - number of parameters < number of values specified.\nAdditional values ignored\n"
 }
}
$infofile="$currentdir/${graph}OUT.info";
$prefacord=getinfo::prefacord($infofile);
@polelist=getinfo::poles($infofile);
$continue=1;
if($togetherflag==1){
 $continue=0;
 $minmin=findmin(@polelist)+$prefacord;
 @ordlist=();
 for($i=$epsord;$i>=$minmin;$i--){
  $it=$i;
  $it=~s/-/m/;
  push(@ordlist,$it)
 }
 if($exe==1){
  system("perl dotogether.pl -p=$paramfile $wdstring@ordlist")
 } elsif($exe==2){
  @ordlist=getinfo::poleorders("$currentdir/together/infofile");
  foreach $ord (@ordlist){
   if($clusterflag==0){
    system("cd $currentdir/together/epstothe$ord;echo compiling functions needed for calculation at order eps^$ord...;make -s -f make$point;
    echo performing integration...;./${point}intfile.exe>${point}intfile.log");
    $texcode=$?>>8;
    unless($texcode==0){
     exit $texcode
    }
   } else {
    launchjob::submit($batchsystem,"$currentdir/together/epstothe$ord/togsub")
   }
  }
 } elsif($exe==3){
  @ordlist=getinfo::poleorders("$currentdir/together/infofile");
  foreach $ord (@ordlist){
   if($clusterflag==0){
    system("cd $currentdir/together/epstothe$ord;echo performing integration for eps^$ord...;./${point}intfile.exe>${point}intfile.log");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at order eps^$ord. Further orders will not be calculated\n";
     exit $texcode
    }
   } else {
    launchjob::submit($batchsystem,"$currentdir/together/epstothe$ord/togsubint")
   }
  }
 } else {
  $continue=1
 }
}
if ($continue==1){
$minp=0;
foreach (@polelist){
 $polestruct=$_;
 if ($polestruct=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 if ($i+$j+$h>=-$epsord+$prefacord) {
  $mintp=-$i-$j-$h;
  if($mintp<$minp){$minp=$mintp};
  if ($exe>=2) {
   if (-e "$currentdir/$polestruct/infofile") {
    if($local==0){system("perl perlsrc/remakebases.pl $integpath $graph $polestruct $compiler $makefile $routine")};
    system("perl perlsrc/finishpolenumerics.pl $currentdir/$polestruct $point");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at pole structure $polestruct. Further pole structures will not be calculated\n";
     exit $texcode
    }
   } else {
    print "Warning - the subtraction for $polestruct has not been completed\n"
   }
  } elsif ($exe==1) {
   if (-e "$currentdir/$polestruct/infofile") {
    system("perl perlsrc/polenumerics.pl $polestruct $integpath $compiler $makefile -p=$paramfile $wdstring");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at pole structure $polestruct. Further pole structures will not be calculated\n";
     exit $texcode
    }
   } else {
    print "Warning - the subtraction for $polestruct has not been completed\n"
   }
  } else {
   if ($clusterflag==0) {
    print "Finishing pole structure $polestruct...\n";
    system("cd $currentdir;./batch$polestruct");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at pole structure $polestruct. Further pole structures will not be calculated\n";
     exit $texcode
    }
    if($togetherflag==1){$nowdotogether=1};
   } else {
    launchjob::submit($batchsystem,"${currentdir}/job$polestruct");
    if($togetherflag==1){$nowdotogether=2};
   }
  }
 }
}
if($nowdotogether==1){
 @ordlist=();
 for($i=$epsord;$i>=$minp;$i--){
  $it=$i;
  $it=~s/-/m/;
  push(@ordlist,$it)
 }
 system("perl dotogether.pl -p=$paramfile $wdstring@ordlist")
} elsif ($nowdotogether==2){
 @ordlist=();
 for($i=$epsord;$i>=$minp;$i--){
  $it=$i;
  $it=~s/-/m/;
  push(@ordlist,$it)
 }
 print "Warning! This selection of flags cannot run to completion at this stage.\n";
 print "When all jobs have finished running, execute the command\n";
 print "perl dotogether.pl -p=$paramfile $wdstring@ordlist\n";
 print "from $dirbase to complete the calculation\n";
}
}
if($clusterflag==0){system("perl results.pl -p=$paramfile $wdstring")};


sub findmin {
my $tmin=0;
foreach $tem (@_){
 if($tem=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 my $tmin2=-$i-$j-$h;
 if($tmin>$tmin2){$tmin=$tmin2}
}
return $tmin
}
 
