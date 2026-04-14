#
  #****s* SecDec/general/justnumerics.pl
  #  NAME
  #    justnumerics.pl
  #
  #  USAGE
  #  ./justnumerics.pl 
  # 
  #  USES 
  #  $paramfile, header.pm, makejob.pm, launchjob.pm, getinfo.pm, dirform.pm
  #  as a template - batch
  #
  #  PURPOSE
  #  if different phase space points are required for the same graph, justnumerics.pl
  #  will use the f*.f already made using subexp.pl, and follow the same route as subexp.pl
  #  from this point.
  #    
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #    
  #  RESULT
  #  if $exe>=0, batch*l*h* and where applicable job*l*h* are created.
  #  if $exe==1, this is not applicable, so $exe is taken to be 4
  #  if $exe>=2, intermediate files are created by polenumerics.pl (from batch*l*h*)
  #  if $exe>=3, .exes are made for the numerical integrations
  #  if $exe==4, .exes are run/submitted
  #  OPTIONS
  #  to use a param.input file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #   
  #  SEE ALSO
  #  polenumerics.pl, subexp.pl, batch, header.pm, makejob.pm launchjob.pm getinfo.pm
  #   
  #****
  #
use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir, "xplot=s"=>\$xplot,"file=s"=>\$plotfile);
unless ($paramfile) {
  $paramfile = "param.input";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){$workingdir=~s/\/$//;$wparamfile="$workingdir/$paramfile";$wdstring="-d=$workingdir "};
$plotstring="";
if($plotfile){$plotstring="-x $xplot -f $plotfile"};
use lib "perlsrc";
use header;
use makejob;
use launchjob;
use getinfo;
use dirform;
my %hash_var=header::readparams($wparamfile);
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
$makefile="Makefile.linux";
if($routine){$integpath=$cubapath;$makefile="makefile"};
$IBPflag=$hash_var{"IBPflag"};
$epsord=$hash_var{"epsord"};
$exe=$hash_var{"exe"};
$clusterflag=$hash_var{"clusterflag"};
$cputime=$hash_var{"cputime"};
unless($cputime){$cputime=1000};
if ($exe ne "0") {unless ($exe) {$exe=4};};
if ($exe==1){$exe=4};
$local=0;
if($clusterflag==0){if($exe>0){$local=1}};
$batchsystem=$hash_var{"batch"};
$compiler=$hash_var{"compiler"};
unless ($compiler) {$compiler="gfortran"};
if($local==1){
 system("perl perlsrc/remakebases.pl $integpath $compiler none $compiler $makefile $routine");
 $makefile="none"
}

@partsflaglims=qw(4 3 1);

$regexdir=dirform::regex($currentdir);
$regexdir="$regexdir\\/";
$regexdirbase=dirform::regex($dirbase);
$regexdirbase="$regexdirbase\\/";
$regexintegpath=dirform::regex($integpath);
$regexparamfile=dirform::regex($paramfile);
$regexwdstring="";
if($wdstring){$regexwdstring=dirform::regex($wdstring)};

open($cleanfile, ">", "$currentdir/makeclean"); 
$infofile="$currentdir/${graph}OUT.info";
@polelist=getinfo::poles($infofile);
$prefacord=getinfo::prefacord($infofile);
$togetherflag=$hash_var{"together"};
if($togetherflag==1){
 $minmin=findmin(@polelist)+$prefacord;
 @ordlist=();
 for($i=$epsord;$i>=$minmin;$i--){
  $it=$i;
  $it=~s/-/m/;
  push(@ordlist,$it)
 }
 system("perl dotogether.pl -p=$paramfile $wdstring@ordlist");
 exit
}
foreach (@polelist){
 $polestruct=$_;
 if ($polestruct=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 if ($i+$j+$h>=-$epsord+$prefacord) {
  $partsflag=partsflag();
  print $cleanfile "perl $dirbase/perlsrc/cleanup.pl $currentdir/$polestruct 0 \$1\n";
  $pli="s";$plj="s";$plh="s";
  if ($i==1) {$pli=""};
  if ($j==1) {$plj=""};
  if ($h==1) {$plh=""};
  print "working on pole structure: $i logarithmic pole$pli, $j linear pole$plj, $h higher pole$plh\n";
  preparebatch("batch$polestruct");
  if ($clusterflag==1) {
   $memuse=1;
   if ($partsflag==1) {$memuse=2};
   $jobfilename="${currentdir}/job$polestruct";
   $executable="batch$polestruct";
   @jobargs=($batchsystem,$jobfilename,$currentdir,$executable,$cputime,$memuse);
   makejob::go(@jobargs);
   if ($exe>0) {
    print "Submitting job$polestruct...\n";
    launchjob::submit($batchsystem,"${currentdir}/job$polestruct");
   }
  } else {
   if ($exe>0) {
    system("cd $currentdir;./batch$polestruct");
    $texcode=$?>>8;
    unless($texcode==0){
     print "Exiting at pole structure $polestruct. Further pole structures will not be calculated\n";
     exit $texcode
    }
   };
  } # end if clusterflag==1
 } # end if ($i+$j+$h>=-$epsord)
} # next in polelist
if($local==0){print $cleanfile "rm -r $integpath/$graph\n"};
print $cleanfile "perl $dirbase/perlsrc/cleanup.pl $currentdir fullclean \$1\n";
print $cleanfile "if [ \"\$1\" == \"all\" ]\nthen\nrm $currentdir/makeclean\nfi";
print $cleanfile "if [ \"\$1\" == \"-h\" ]\nthen\necho \"makeclean: Removes all intermediate files produced by the program\"\necho \"makeclean all: Additionally removes itself\" \nfi";
close $cleanfile;
system("chmod +x $currentdir/makeclean");

if($exe==4){if($clusterflag==0){system("perl results.pl -p=$paramfile $wdstring $plotstring")}};


sub preparebatch {
 my $filename=$_[0];
 if (-e "${currentdir}/$filename"){system("rm -f ${currentdir}/$filename")};
 $minpole=-$i-$j-$h;
 system("cp perlsrc/batch ${currentdir}/$filename");
 system("perl -pi -e 's/basespath/$regexintegpath/g' ${currentdir}/$filename");
 system("perl -pi -e 's/dumpfile/$regexdir$polestruct.log/g' ${currentdir}/$filename");
 system("perl -pi -e 's/echo fortran/#echo fortran/g' ${currentdir}/$filename");
 system("perl -pi -e 's/perl d/#perl d/g' ${currentdir}/$filename");
 system("perl -pi -e 's/rm mathfile/#rm mathfile/g' ${currentdir}/$filename");
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
 system("perl -pi -e 's/^runcheck(.*)\$/runcheck=\"True\"/g' ${currentdir}/$filename");
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
sub findmin {
my $tmin=0;
foreach $tem (@_){
 if($tem=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
 my $tmin2=-$i-$j-$h;
 if($tmin>$tmin2){$tmin=$tmin2}
}
return $tmin
}
