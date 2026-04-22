#
#****s* SecDec/general/decompose.pl
#
#  NAME
#  decompose.pl
#
#  USAGE
#  ./launch  or
#  ./decompose.pl 
# 
#  USES 
#  $paramfile, header.pm, mathlaunch.pl, getinfo.pm, dirform.pm
#
#  USED BY 
#  launch 
#      
#  PURPOSE
#  doing the iterated sector decomposition in Mathematica
#    
#  INPUTS
#  $paramfile (default is param.input), read via module header
#  $templatefile (default is Template.m)
#    
#  RESULT    
#  -adds decomposition part to the file $currentdir/$graph.m 
#  -launches the decomposition and writes the results to 
#   $currentdir in the form of lists containing the 
#   parametric functions for each pole structure
#  
#  OPTIONS
#  to use a param.input file with a different name
#  use option "-p paramfile" 
#  to use a template file with the a different name
#  use option "-t templatefile"
#  to specify a different directory to work in
#  use option "-d workingdirectory" 
# 
#****
##################################
# this file reads param.input and does the following:
# 1) creates a subdirectory named "$graph" 
# 2) does the decomposition in Math
#
########### input: #######################
# to use a param.input file with a different name
# call as "perl decompose.pl --parameter myparameterfilename" 
# to use a template file with the name mytemplate
# call as "perl decompose.pl --template mytemplate" 
use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
unless ($templatefile) {
  $templatefile = "Template.m";
}
$wparamfile=$paramfile;
if($workingdir){
 $workingdir=~s/\/$//;
 $wparamfile="$workingdir/$paramfile";
 $templatefile="$workingdir/$templatefile";
 $absdir=1;
}
  print "paramfile= $wparamfile\n";
  print "templatefile= $templatefile\n";
use lib "perlsrc";
use header;
use getinfo;
use dirform;
system("perl -pi -e 's/\\/(\\s*)\\n/\\n/g' $wparamfile");
my %hash_var=header::readparams($wparamfile);
$dirbase=`pwd`;
chomp $dirbase;
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
$graph=$hash_var{"graph"};
unless($graph){die "Calculation must have a name\n"};
print "integral name = $graph\n";
if ($currentdir) {
$absdir=1
}else{
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
@comparlist=split(/,/,$hash_var{"symbconstants"});
@comparvals=split(/,/,$hash_var{"pointvalues"});
@dummylist=split(/,/,$hash_var{"dummys"});
if(@comparlist){
 if(@comparvals){
  $complen=@comparlist;
  $complen2=@comparvals;
  if($complen2<$complen){
   die "Error: please specify numerical values for parameters in $paramfile\n"
  } elsif($complen2>$complen){
   print "Warning - number of parameters < number of values specified. Additional values ignored\n"
  }
 } else {
  die "Error: please specify numerical values for parameters in $paramfile\n"
 }
} else {
 if(@comparvals){
  print "Warning - number of parameters < number of values specified. Additional values ignored\n"
 }
}
$alsymb="";
foreach $par (@comparlist) {
 $alsymb="$alsymb,$par"
}
$alsymb=~s/,//;
$alldummys="";
foreach $dum (@dummylist) {
 $alldummys="$alldummys,$dum"
}
$alldummys=~s/,//;
#
############## end of user defined input ############
#
# insert main path etc in Template.m
open (ET,">tmp$graph") || die "cannot open tmp$graph\n";
open (EREAD,"$templatefile") || die "cannot open $templatefile\n";
while(<EREAD>) {
  chomp;
print ET "$_\n";
}
close (EREAD);
$templatetail="$dirbase/src/deco/template_tail.m";
open (EREAD,"$templatetail") || die "cannot open $templatetail\n";
while(<EREAD>) {
  chomp;
  s/path\s*=\s*(.*)/path=\"$dirbase\/\";/;
  s/integralname\s*=\s*ToString\[\w.*\]\s*/integralname="$graph"/;
  s/currentdir\s*=\s*(.*)/currentdir=\"$currentdir\/\";/;
  s/allowedsymbols=\{/allowedsymbols=\{$alsymb/;
  s/dummyfunctions=\{/dummyfunctions=\{$alldummys/;
    print ET "$_\n";
}
close (EREAD);
close (ET);
#
#####################################################
if($absdir){
 unless(-d $currentdir){
  @desdir=split(/\//,$currentdir);
  $dstring="";
  foreach $dirbit (@desdir){
   if($dirbit){
    $dstring="$dstring/$dirbit";
    unless($dstring eq "/"){
     unless (-d $dstring){
      system("mkdir $dstring");
      $mkerr=$?>>8;
      unless($mkerr==0){die "could not create directory $dstring\n"}
     }
    }
   }
  }
 }
} else { 
 if($subdir){
  unless ( -e "$subdir") {
   system ("mkdir -p $subdir");
  }
  chdir("$subdir") || die "cannot change to directory $subdir\n"; 
 }
 unless ( -e "$graph") {
  system ("mkdir  $graph");
 }
 chdir("$dirbase") || die "cannot change to directory $dirbase\n";
}
system("mv $dirbase/tmp${graph} $currentdir/${graph}.m");
$err=$?>>8;if ($err>0){exit $err};
 print "decomposing $graph . . . \n";
 $declog="$currentdir/${graph}Decomposition.log";
 system ("perl perlsrc/mathlaunch.pl $currentdir/${graph}.m $declog");
 $err=$?>>8;if ($err>0){exit $err};
 $valid=getinfo::validinput($declog);
 if($valid==1){
  print "done \n";
  print "written to $currentdir/${graph}P[i]*.out\n"; 
 } else {
  print "Failed\nPlease verify your input - undefined parameters dectected\n";
  exit 10
 }
print "\n"; 
#####################################################
