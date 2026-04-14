  #****
  #  NAME
  #    preparenumerics.pl
  #
  #  USAGE
  #  is called from polenumerics.pl
  # 
  #  USES 
  #  $paramfile, header.pm, writefiles.pm, dirform.pm
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
  #  numvar: number of integration variables 
  #  maxpole: maximal pole for this structure
  #  polestruct: [i]l[j]h[h] or sec*P[i]l[j]h[h], i logarithmic poles, j linear poles, h higher poles
  #    
  #  RESULT
  #  new functions in $currentdir and subdirectories corresponding to polestructure
  #    
  #  SEE ALSO
  #  polenumerics.pl, subexploop.pl, subexpuserdefined.pl, writefiles.pm
  #   
  #****
use lib "loop/perlsrc/modules";
use paths;
use Fraction ':constants';
use params;
use getkinematics;
use dirform;
use makeheader;
use makeintC;
use makeintmath;
use makejob;
use makemakeC;
use makemakerun;
use makesub;
use Cwd;
use Getopt::Long;

GetOptions("parameter=s" => \$paramfile, "math=s"=>\$mathfile, "kinem=s"=>\$kinemfile, "dirwork=s"=>\$workingdir, "userdefined=i" => \$userdefined);
$secdecdir = getcwd(); # SecDec dir

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

$workingdir = $paths{"ap_workingdir"};
$dirbase = $paths{"ap_secdecdir"};
$wkinemfile=$paths{"apf_kinemfile"};
$cquadpath=$paths{"ap_cquad"};
$integpath = $paths{"ap_integpath"};

$jj=$ARGV[0]; #order in eps
$jj=~s/m/-/;
# in polenumerics.pl, $numvar=$feynpars
$numvar=$ARGV[1];
$maxpole=$ARGV[2]; #minpole
$maxpole=~s/m/-/;
$polestruct=$ARGV[3];
$threshold=$ARGV[4];
$cursec=$ARGV[5];
$overallmaxpole=$ARGV[6];

$language=$params{"language"};
$suf=$params{"language_suffix"};
$compiler=$params{"compiler"};
$Ccompiler=$params{"compiler"};
$graph=$params{"graph"};
$rescaleflag=$params{"rescaleflag"};
$integrator=$params{"integrator"};
$point=$params{"pointname"};
$processlimit=$params{"processlimit"};
$clusterflag=$params{"clusterflag"};
$oscillatory=$params{"oscillatory"};
$contourdef=$params{"contourdef"};

# read from mathparamfile:
$Nn=$hash_varmath{"Nn"};
@invariants=@{$hash_varmath{"array_invariants"}};
#####################################
$filepoint=$point;
$filepoint=~s/DEFAULT//;
$batchsystem=$params{"batch"};
#$integpathstring="";
$maxsize=$params{"grouping"};
######################################### # johannes - check on kinematics should go into the subfile/submit file
#my %hash_valueskinem=getkinematics::readmultikinem($wkinemfile);
#$linenumbers=$hash_valueskinem{"lines"};
##my @values = getkinematics::readkinem("$wkinemfile");
#$nbinvariants=@invariants;
#my @points=split(/;/,$hash_valueskinem{"points"});
#my @values1=split(/\s/,$points[0]);
#shift @values1; # tz: first argument is now the pointname -> dropped here because not needed
#$nbvalues=@values1;
##foreach $m (@values1) {print "el point1=$m "} print "\n";
#unless ($nbinvariants eq $nbvalues) {
#print "Warning: number of values given in $kinemfile is different from number of invariants given in $mathfile\n";
#print "number of values given in $kinemfile: $nbvalues\n";
#print "number of invariants (including masses)  given in $mathfile: $nbinvariants\n";
#}
#######################################
# change integrator to Quadpack for integration 
# of only one Feynman parameter 
#######################################
if ( ($numvar == 1) && ($integrator!=5) ) #unless NIntegrate is used
{
    $integrator=6;
    print "Integrator switched to GSL CQUAD for polestruct ${polestruct}, epsord ${jj} ";
    print "(for faster integration over 1 Feynman parameter)\n";
}

# populate "dynamic" integrator paths
%params=params::updatedynamicintegrator($integrator,\%params);
%paths=paths::updatedynamicintegrator($integrator,\%paths);

if ( ($numvar == 0) && ($integrator!=5) ) {
    print "No Monte Carlo integration needed, computation done with Standard math library.\n";
}

############################################################
#
my $currentdir= paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec) . $paths{"rp_out_epstothe"} . $jj . "/";
#
############################################################
@fmax;
$funcount=1;
$fmax[0]=0;
$groupcount=0;
$sizesum=0;
$ffile= $currentdir . $paths{"rp_out_f"} . $funcount . $suf;
while (-e $ffile) {
 $filesize = -s $ffile;
 $sizesum=$sizesum+$filesize;
 if($sizesum> $maxsize ){
  $groupcount++;
  $fmax[$groupcount]=$funcount;
  $sizesum=0
 }
 $funcount++;
 $ffile= $currentdir . $paths{"rp_out_f"} . $funcount . $suf;
}
$funcount--;
unless ($sizesum==0) {
 $groupcount++;
 $fmax[$groupcount]=$funcount
}

makejob::go(\%paths,\%params,$currentdir,$polestruct,$jj,$groupcount,\@fmax); #creates job submission files

$kinf = $currentdir . $paths{"rp_out_kinematics"};
for ($kk=1;$kk<=$groupcount;$kk++) {
    $minf=$fmax[$kk-1]+1;
    $maxf=$fmax[$kk];
    if($integrator==5) {
        makeintmath::go($minf,$maxf,$jj,$kk,$numvar,$currentdir,\%params,\%paths,\%hash_varmath);
    } else {
        makemakeC::go($kk,$minf,$maxf,$currentdir,\%params,\%paths);
        makeintC::go($minf,$maxf,$jj,$kk,$threshold,$numvar,$maxpole,$polestruct,$currentdir,$overallmaxpole,\%params,\%paths,\%hash_varmath);
    }
} #next kk

makesub::go($currentdir,\%params,\%paths); #creates subfile.pl

if($integrator!=5){
$makef = $currentdir . $paths{"rp_out_makef"};
makemakerun::go($makef,$jj,$Nn,$graph,$polestruct,$language); #creates make.pl
makeheader::go($funcount,$numvar,$polestruct,$currentdir,\%params,\%paths);
}

#$filepointf = $currentdir . $filepoint. $paths{"rp_out_filespointinfo"};
$filepointf = $currentdir . $paths{"rp_out_filespointinfo"}; # tz: $filepoint no longer necessary
open (INFO,">$filepointf");
print INFO "Number of integrations = $groupcount";
close INFO;

