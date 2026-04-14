#
  #****s* SecDec/general/subexp.pl
  #  NAME
  #    subexp.pl
  #
  #  USAGE
  #  ./launch or ./subexp.pl 
  # 
  #  USES 
  #  $paramfile, header.pm, makejob.pm, launchjob.pm, getinfo.pm, dirform.pm
  #  as templates: subandexpand.m, batch 
  #
  #  USED BY 
  #  launch
  #  
  #  PURPOSE
  #  prepares the intermediate files subandexpand*l*h*.m, batch*l*h*, and where
  #  applicable job*l*h*. Depending on values of $exe and $processlimit, it submits
  #  the job files, runs the batch files, or neither.  
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #  parameters parsed via ARGV:
  #  fromlaunch: a flag to indicate whether subexp.pl was run by launch, or from
  #  the terminal.
  #    
  #  RESULT
  #  intermediate files made. Depending on values of $exe and $clusterflag, the
  #  subtraction, eps expansion and creation of f*.f files is run or submitted.
  #  executable makeclean is created, which when run will remove all unneeded
  #  intermediate files.
  #  OPTIONS
  #  to use a param.input file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #     
  #  SEE ALSO
  #  launch, batch, subandexpand.m, cleanup.pl, makejob.pm, launchjob.pm, getinfo.pm
  #   
  #****
  #


use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){$workingdir=~s/\/$//;$wparamfile="$workingdir/$paramfile";$wdstring="-d=$workingdir "};
use lib "perlsrc";
use header;
use makejob;
use launchjob;
use getinfo;
use dirform;
my %hash_var=header::readparams($wparamfile);
$dirbase=`pwd`;
chomp $dirbase;
$srcdir="src/subexp";
$regexsrc=dirform::regex($srcdir);
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
#NEW
$language=$hash_var{"language"};
unless ($language) {$language="fortran"};
$contourdef=$hash_var{"contourdef"};
unless ($contourdef) {$contourdef="False"};
if ($contourdef eq "true"){$contourdef="True"};
if ($contourdef eq "false"){$contourdef="False"};
$xlambda=$hash_var{"xlambda"};
unless ($xlambda) {$xlambda="10"};
$oscillatory=$hash_var{"oscillatory"};
unless ($oscillatory) {$oscillatory="0"};
$endpointflag=$hash_var{"endpointflag"};
unless ($endpointflag) {$endpointflag="0"};
#END NEW
$graph=$hash_var{"graph"};
$batchsystem=$hash_var{"batch"};
$cputime=$hash_var{"cputime"};
unless($cputime){$cputime=1000};
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
$basespath=$hash_var{"basespath"};
unless ($basespath) {$basespath="$dirbase/src/basesv5.1"};
$basespath=~s/\/loop\//\//;
$basespath=~s/\/general\//\//;
$cubapath=$hash_var{"cubapath"};
unless ($cubapath) {$cubapath="$dirbase/src/Cuba-4.1"};
$cubapath=~s/\/loop\//\//;
$cubapath=~s/\/general\//\//;
$graphfile="$currentdir/$graph.m";
$dim=getinfo::dim($graphfile);
$numvar=getinfo::numvar($graphfile);
$infofile="$currentdir/${graph}OUT.info";
$prefacord=getinfo::prefacord($infofile);
$IBPflag=$hash_var{"IBPflag"};
$epsord=$hash_var{"epsord"};
$exe=$hash_var{"exe"};
if ($exe ne "0") {unless ($exe) {$exe=4};};
$clusterflag=$hash_var{"clusterflag"};
unless($clusterflag){$clusterflag=0};
$local=0;
if($clusterflag==0){if($exe>0){$local=1}};
$togetherflag=$hash_var{"together"};
if($togetherflag==1){if($exe>0){$exe=1}};
$compiler=$hash_var{"compiler"};
unless ($compiler) {$compiler="gfortran"};
$integrator=$hash_var{"integrator"};
$makefile="Makefile.linux";
$integpath=$basespath;
if($integrator){
 $makefile="makefile";
 $integpath=$cubapath
}
#New
if($language ne "fortran") {
 my $validintegrator=0;
 foreach $posinteg (1,2,3,4){
  if ($integrator==$posinteg){$validintegrator=1}
 }
 unless($validintegrator) {
  print "Warning - valid integrator not selected.\nVegas will be used.\n";
  open (WPARAM,"<$wparamfile");
  @wparam=<WPARAM>;
  close WPARAM;
  my $changed=0;
  open (PARAMOUT,">TEMPORARYPARAMETERFILE");
  foreach $pline (@wparam){
   if($pline=~m/integrator=/){
    print PARAMOUT "integrator=1\n";$changed=1
   }else{
    print PARAMOUT $pline
   }
  }
  unless($changed){print PARAMOUT "integrator=1\n"};
  close PARAMOUT;
  system("mv TEMPORARYPARAMETERFILE $wparamfile");
  $integrator=1;
  $makefile="makefile";
  $integpath=$cubapath;
  ################################################
#  print "Error - please select a numerical integrator compatible with C++.\n";
#  print "Valid selections are 1, 2, 3 and 4\n";
#  exit 10;
  ################################################
 }
}
#End new


$fromlaunch=$ARGV[0];
$valid=getinfo::validinput("$currentdir/${graph}Decomposition.log");
if($valid==0){
 if($fromlaunch eq "launch"){
  exit
 } else {
  die "Decomposition was not performed successfully\nPlease verify your inputs - undefined parameters detected\n"
 }
}
@comparlist=split(/,/,$hash_var{"symbconstants"});
@comparvals=split(/,/,$hash_var{"pointvalues"});

if(@comparlist){
 if(@comparvals){
  $complen=@comparlist;
  $complen2=@comparvals;
  if($complen2<$complen){
   if($fromlaunch ne "launch"){
    die "Need to specify numerical values for parameters in $paramfile\n"
   }else{
    exit
   }
  } elsif($complen2>$complen){
   if($fromlaunch ne "launch"){print "Warning - number of parameters < number of values specified. Additional values ignored\n"}
  }
 } else {
  if ($fromlaunch ne "launch"){
   die "Need to specify numerical values for parameters in $paramfile\n"
  }else{
   exit
  }
 }
} else {
 if(@comparvals){
  if($fromlaunch ne "launch"){print "Warning - number of parameters < number of values specified. Additional values ignored\n"}
 }
}

if(@comparlist){
 $comparstring="common\\/params\\/";
 foreach $par (@comparlist) {
  $comparstring="$comparstring,$par"
 }
 $comparstring=~s/\/,/\//g;
}
@dummylist=split(/,/,$hash_var{"dummys"});
my $ndum=@dummylist;
@dummyorderlist=split(/,/,$hash_var{"dummyorder"});
if (scalar @dummyorderlist != $ndum and $ndum != 0){
  if(scalar @dummyorderlist == 0){
    @dummyorderlist = (0) x $ndum;
    print "Warning - dummy functions assumed to be eps independent\n";
  } 
  else {
    die "Number of dummy variables does not match number of values specified for parameter 'dummyorder' in $paramfile\n";
  }
}
$dummystring=join(',',@dummylist);
$dummyorderstring=join(',',@dummyorderlist);

if ($fromlaunch ne "launch") {
print "paramfile= $paramfile\n";
print "currentdir = $currentdir\n";
print "graph = $graph\n";
print "IBPflag = $IBPflag\n";
print "subdir = $subdir\n";
print "epsord = $epsord\n";
print "dirbase = $dirbase\n";
}
@partsflaglims=qw(4 3 1);
$regexdir=dirform::regex($currentdir);
$regexdir="$regexdir\\/";
$regexdirbase=dirform::regex($dirbase);
$regexdirbase="$regexdirbase\\/";
$regexintegpath=dirform::regex($integpath);
$regexparamfile=dirform::regex($paramfile);
$regexwdstring="";
if($wdstring ne ""){$regexwdstring=dirform::regex($wdstring)};
$regexsubdir=dirform::regex($subdir);
$regexabspath=dirform::regex($currentdir);
if($local==1){
    system("perl perlsrc/remakebases.pl $integpath $compiler none $compiler $makefile $integrator");
    $makefile="none";
}
open($cleanfile, ">", "$currentdir/makeclean"); 
$infofile="$currentdir/${graph}OUT.info";
@polelist=getinfo::poles($infofile);
$minmin=0;
foreach (@polelist){
 $polestruct=$_;
 if ($polestruct=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 $mintp=-$i-$j-$h+$prefacord;if($mintp<$minmin){$minmin=$mintp};
 if ($i+$j+$h>=-$epsord+$prefacord) {
  $partsflag=partsflag();
  if($local==0){$basesstring="/$polestruct"};
  print $cleanfile "perl $dirbase/perlsrc/cleanup.pl $currentdir/$polestruct 0 \$1\n";
  $pli="s";$plj="s";$plh="s";
  if ($i==1) {$pli=""};
  if ($j==1) {$plj=""};
  if ($h==1) {$plh=""};
  print "working on pole structure: $i logarithmic pole$pli, $j linear pole$plj, $h higher pole$plh\n";
  preparesubandexpand("subandexpand$polestruct.m");
  preparebatch("batch$polestruct");
  if ($clusterflag==1) {
   $memuse=1;
   if ($partsflag==1) {$memuse=2};
   $jobfilename="${currentdir}/job$polestruct";
   $executable="batch$polestruct";
   @jobargs=($batchsystem,$jobfilename,$currentdir,$executable,$cputime,$memuse);
   makejob::go(@jobargs);
   if ($hash_var{"exe"}>0) {
    print "Submitting job$polestruct...\n";
    launchjob::submit($batchsystem,"${currentdir}/job$polestruct");
   }
  } else {
   if ($hash_var{"exe"}>0) {
    system("cd $currentdir;./batch$polestruct");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at pole structure $polestruct. Further pole structures will not be calculated\n";
     exit $texcode
    }
   }
  } # end if clusterflag==1
 } # end if ($i+$j+$h>=-$epsord)
} # next in polelist
if($local==0){print $cleanfile "rm -r $integpath/$graph\n"};
print $cleanfile "perl $dirbase/perlsrc/cleanup.pl $currentdir fullclean \$1\n";
print $cleanfile "if [ \"\$1\" == \"all\" ]\nthen\nrm $currentdir/makeclean\nfi";
close $cleanfile;
system("chmod +x $currentdir/makeclean");

if($togetherflag==1){
 if($hash_var{"exe"}>1){
  @ordlist=();
  for($i=$epsord;$i>=$minmin;$i--){
   $it=$i;
   $it=~s/-/m/;
   push(@ordlist,$it)
  }
  if($clusterflag==0){
   system("perl dotogether.pl -p=$paramfile $wdstring@ordlist")
  } else {
   print "Warning! This selection of flags cannot run to completion at this stage.\n";
   print "When all jobs have finished running, execute the command\n";
   print "perl dotogether.pl -p=$paramfile $wdstring@ordlist\n";
   print "from $dirbase to complete the calculation\n";
  }
 } 
}


sub preparesubandexpand{
 my $filename = $_[0];
 if (-e "${currentdir}/$filename"){system("rm -f ${currentdir}/$filename")};
 system("cp src/subexp/subandexpand.m ${currentdir}/$filename");
 $filestr="\<\<$regexdir${graph}P$polestruct.out;\n";
 system("perl -pi -e 's/outp=/outp=\"$regexabspath\"/' ${currentdir}/$filename");
 system("perl -pi -e 's/path\=/path\=\"$regexdirbase\"/g' ${currentdir}/$filename");
 system("perl -pi -e 's/inputdecomposition/$filestr/g' ${currentdir}/$filename");
 system("perl -pi -e 's/n=/n=$numvar/g' ${currentdir}/$filename");
 system("perl -pi -e 's/feynpars=/feynpars=$numvar/g' ${currentdir}/$filename");
 system("perl -pi -e 's/Dim=/Dim=$dim/g' ${currentdir}/$filename");
 system("perl -pi -e 's/diagramname=/diagramname=\"$graph\"/g' ${currentdir}/$filename");
 system("perl -pi -e 's/subdir=/subdir=\"$regexsubdir\\/\"/g' ${currentdir}/$filename");
 system("perl -pi -e 's/precisionrequired=/precisionrequired=$epsord/g' ${currentdir}/$filename");
 system("perl -pi -e 's/logi=/logi=$i/g' ${currentdir}/$filename");
 system("perl -pi -e 's/lini=/lini=$j/g' ${currentdir}/$filename");
 system("perl -pi -e 's/higheri=/higheri=$h/g' ${currentdir}/$filename");
 system("perl -pi -e 's/partsflag=/partsflag=$partsflag/g' ${currentdir}/$filename");
 system("perl -pi -e 's/srcdir=/srcdir=\"$regexsrc\\/\"/g' ${currentdir}/$filename");
 system("perl -pi -e 's/commonparamstring=/commonparamstring=\"$comparstring\"/g' ${currentdir}/$filename");
 system("perl -pi -e 's/dummys={/dummys={$dummystring/g' ${currentdir}/$filename");
 system("perl -pi -e 's/dummyorder={/dummyorder={$dummyorderstring/g' ${currentdir}/$filename");
#New Apr 24 2012
 system("perl -pi -e 's/language=/language=$language/g' ${currentdir}/$filename");
 system("perl -pi -e 's/contourdef=/contourdef=$contourdef/g' ${currentdir}/$filename");
 system("perl -pi -e 's/xlambda=/xlambda=$xlambda/g' ${currentdir}/$filename");
 system("perl -pi -e 's/oscillatory=/oscillatory=$oscillatory/g' ${currentdir}/$filename");
 system("perl -pi -e 's/endpointflag=/endpointflag=$endpointflag/g' ${currentdir}/$filename");
#End new
}

sub preparebatch {
 my $filename=$_[0];
 if (-e "${currentdir}/$filename"){system("rm -f ${currentdir}/$filename")};
 $minpole=-$i-$j-$h;
 system("cp perlsrc/batch ${currentdir}/$filename");
 if($language ne "fortran"){
         system("perl -pi -e 's/fortran/C\+\+/g' ${currentdir}/$filename");
 }
 system("perl -pi -e 's/basespath/$regexintegpath/g' ${currentdir}/$filename");
 system("perl -pi -e 's/mathfile/${regexdir}subandexpand$polestruct.m/g' ${currentdir}/$filename");
 system("perl -pi -e 's/dumpfile/$regexdir$polestruct.log/g' ${currentdir}/$filename");
 system("perl -pi -e 's/dirbase/$regexdirbase/g' ${currentdir}/$filename");
 system("perl -pi -e 's/path/$regexdir$polestruct/g' ${currentdir}/$filename");
 system("perl -pi -e 's/numsec/$Nn/g' ${currentdir}/$filename");
 system("perl -pi -e 's/minpole/$minpole/g' ${currentdir}/$filename");
 system("perl -pi -e 's/partsflag/$partsflag/g' ${currentdir}/$filename");
 system("perl -pi -e 's/polestruct/$polestruct/g' ${currentdir}/$filename");
 system("perl -pi -e 's/makedump/$regexdir$polestruct\\/makedump/g' ${currentdir}/$filename");
 system("perl -pi -e 's/paramfile/$regexparamfile $regexwdstring/g' ${currentdir}/$filename");
 system("perl -pi -e 's/compiler/$compiler/g' ${currentdir}/$filename");
 system("perl -pi -e 's/makefile/$makefile/g' ${currentdir}/$filename");
 if ($exe==1) {
  system("perl -pi -e 's/perl perlsrc/#perl perlsrc/g' ${currentdir}/$filename")
 } elsif ($togetherflag==1){
  system("perl -pi -e 's/perl perlsrc/#perl perlsrc/g' ${currentdir}/$filename")
 }
}


sub partsflag {
 if ($IBPflag==2) {
  if ($h>0) {
   $partsflag=1
  } else {
   if ($j>2) {
    $partsflag=1
   } else {
    if ($i>$partsflaglims[$j]) {
     $partsflag=1
    } else {
     $partsflag=0
    }
   }
  }
 } else {
  $partsflag=$IBPflag
 }
}
 

