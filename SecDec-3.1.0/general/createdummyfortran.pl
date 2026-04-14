#
#****s* SecDec/general/createdummyfortran.pl
#
#  NAME
#  createdummyfortran.pl
#
#  USAGE
#  ./createdummyfortran.pl
# 
#  USES 
#  $paramfile, header.pm, mathlaunch.pl, getinfo.pm, dirform.pm,
#  dummytofortran.m
#
#  PURPOSE
#  To create optimized fortran code for any functions left implicit
#   at the algebraic level, to be used during the numerical integration
#    
#  INPUTS
#  $paramfile (default is param.input), read via module header
#    
#  RESULT    
#  -copies the file 'dummytofortran.m', and edits it to read the
#   files for functions specified in the parameter file 
#  -launches dummytofortran.m, which creates optimized fortran code
#   for these functions and puts them in the desired directory.
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
use Getopt::Long;
GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir);
unless ($paramfile) {
  $paramfile = "param.input";
}
$wdstring="";$wparamfile=$paramfile;
if($workingdir){$workingdir=~s/\/$//;$wparamfile="$workingdir/$paramfile";$wdstring="-d=$workingdir "};
use lib "perlsrc";
use header;
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
@comparlist=split(/,/,$hash_var{"symbconstants"});
if(@comparlist){
 $comparstring="common\\/params\\/";
 foreach $par (@comparlist) {
  $comparstring="$comparstring,$par"
 }
 $comparstring=~s/\/,/\//g;
}
@dummylist=split(/,/,$hash_var{"dummys"});
$dummystring=join(',',@dummylist);
@dummyorderlist=split(/,/,$hash_var{"dummyorder"});
$dummyorderstring=join(',',@dummyorderlist);
$regexdir=dirform::regex($currentdir);
$regexdir="$regexdir\\/";
$regexdirbase=dirform::regex($dirbase);
$regexdirbase="$regexdirbase\\/";
$regexparamfile=dirform::regex($paramfile);
$regexsubdir=dirform::regex($subdir);
preparedummytofortran("$currentdir/dummytofortran.m");
system("perl perlsrc/mathlaunch.pl $currentdir/dummytofortran.m dump");
#system("rm $currentdir/dummytofortran.m");

sub preparedummytofortran{
 my $filename = $_[0];
 if (-e $filename){system("rm -f $filename")};
 system("cp src/dummy/dummytofortran.m $filename");
 system("perl -pi -e 's/^dummys={/dummys={$dummystring/' $filename");
 system("perl -pi -e 's/^dummyorder={/dummyorder={$dummyorderstring/' $filename");
 system("perl -pi -e 's/^path\=/path\=\"$regexdirbase\"/g' $filename");
 system("perl -pi -e 's/^filepath=/filepath=\"$regexdir\"/g' $filename");
 system("perl -pi -e 's/^commonparamstring=/commonparamstring=\"$comparstring\"/g' $filename");
}


