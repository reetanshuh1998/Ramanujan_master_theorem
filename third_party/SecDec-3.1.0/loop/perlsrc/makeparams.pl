
#****s* SecDec/loop/makeparams.pl
#
#  NAME
#  makeparams.pl
#
#  USAGE
#  ./makeparams.pl or ./launch
# 
#  USES 
#  $paramfile,$mathfile,header.pm., dirform.pm, mathlaunch.pl
#
#  USED BY 
#  launch 
#      
#  PURPOSE
#  runs mathematica input file to extract basic parameters like 
#  number of propagators, loops, cutconstruct
#    
#  INPUTS
#  $paramfile (default is paramloop.input), read via module header
#  $mathfile (default is mathloop.m)
#    
#  RESULT    
#  produces the file $currentdir/$graphinfo.m: will be used by header.pm to fill 
#  values for Nn, loops, cutconstruct etc
#
#  OPTIONS
#  to use a parameter file with a different name
#  use option "-p paramfile" 
#  to use a math file with the a different name
#  use option "-m mathfile"
#  to specify a different directory to work in
#  use option "-d workingdirectory" 
# 
#****
##################################

use strict;
use warnings;

use lib "loop/perlsrc/modules";
use banner;
use paths;
use params;
use Text::Template;
use Cwd;
use Getopt::Long;

# Get command line parameters + secdec directory
my $paramfile = undef;
my $mathfile = undef;
my $kinemfile = undef;
my $workingdir = undef;
my $userdefined = 0;
GetOptions("parameter=s" => \$paramfile, "math=s"=>\$mathfile, "kinem=s"=>\$kinemfile, "dirwork=s"=>\$workingdir, 'userdefined=i' =>\$userdefined);
my $secdecdir = getcwd(); # SecDec dir

print "- 1/8 makeparams\n";

# Read paramfile + construct paths
my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile= $paths{"apf_out_mathparamfile"};
#my %hash_varmath=params::readmathparams($mathparamfile,\%params);

# Declare local path variables
my $wmathfile = $paths{"apf_mathfile"}; # (now) path to mathfile including filename + extension

############ BEGIN construct makeparams file ######

# Copy user's math file to auxiliary graph info file
File::Copy::Recursive::fcopy( $wmathfile, $paths{"apf_out_auxiliarygraphinfo"})
or die "Cannot copy " . $wmathfile . " to " . $paths{"apf_out_auxiliarygraphinfo"} . "\n";

#  Populate makeparam template
my $template = Text::Template->new(SOURCE => $paths{"apf_mathparams"}, DELIMITERS => [ '(*{', '}*)' ])
or die "Couldn't construct template: $Text::Template::ERROR";
my %vars =
    ( mathparamfile => $mathparamfile,
      userdefined => $userdefined
    );
my $result = $template->fill_in(HASH => \%vars);

# Append makeparam lines to auxiliary graph info file
if (defined $result) {
    open(INTFILE, ">>", $paths{"apf_out_auxiliarygraphinfo"});
    print INTFILE $result;
    close(INTFILE);
} else {
    die "Couldn't fill in template: $Text::Template::ERROR"
}

######################################################################

#print "extracting parameters \n";

if (-e $paths{"apf_out_auxiliarygraphinfo"})
{
    system ("perl " . $paths{"apf_mathlaunch"} . " " . $paths{"apf_out_auxiliarygraphinfo"} . " " . $paths{"apf_out_makeparaminfo"}) ==0 or die "Error - cannot launch " . $paths{"apf_out_auxiliarygraphinfo"} . "\n";
} else {
    print "could not find " . $paths{"apf_out_auxiliarygraphinfo"} . "\n";
    exit 1;
}

print "Success - parameters written to " . $paths{"ap_params"} . "\n";
print "\n";

#print "extraction of parameters done \n";
