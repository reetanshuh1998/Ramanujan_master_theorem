#****
#
#  NAME
#  makeFU.pl
#
#  USAGE
#  perl makeFU.pl or ./launch
# 
#  USES 
#  $paramfile, header.pm, mathlaunch.pl, dirform.pm
#
#  USED BY 
#  launch 
#      
#  PURPOSE
#  creation of subdirectory for the integral to be calculated
#  construction of the functions F and U from the propagators 
#  given in the mathfile
#    
#  INPUTS
#  $paramfile (default is paramloop.input), read via module header
#  $mathfile (default is mathloop.m)
#    
#  RESULT    
#  produces the files $currentdir/$graph.m: will be used later for decomposition 
#  and $currentdir/FUN.m: contains the functions F and U (and numerator in tensor case)
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
use getinfo;
use dirform;
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

print "- 2/8 makeFU\n";

# Read paramfile + construct paths
my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

# Declare local path variables
my $dirbase = $paths{"ap_secdecdir"};
my $currentdir= $paths{"ap_outputdir"};
my $wmathfile = $paths{"apf_mathfile"};

# Declare local paramfile variables
my $graph=$params{"graph"};

# Declare local mathparamfile variables
my $externallegs=$hash_varmath{"externallegs"};
my $loops=$hash_varmath{"loops"};
my $feynpars = $hash_varmath{"feynpars"};
my $cutconstruct=$hash_varmath{"cutconstruct"};
my @masses=@{$hash_varmath{"array_masslist"}};
my @lorentz=@{$hash_varmath{"array_lorentzlist"}};
my $Nn=$hash_varmath{"Nn"};
my @Nlist=@{$hash_varmath{"array_Nlist"}};

print "graph = $graph\n";
if ($userdefined == 0) {    
    print "primary sectors = ";
} elsif ($userdefined == 1) {   
    print "user functions = ";
}
print join(',',@Nlist) . "\n";
#print " will be calculated\n";
############## end of user defined input #############################

# Map user's lorentz/mass variables onto SecDec internal variables
my @lmap=();
my $count=1;
foreach my $s (@lorentz) {
my $repl= dirform::trim($s) . " -> ssp[$count]";
#print "repl=$repl\n";
push(@lmap,$repl);
$count++;
}
$count=1;
foreach my $s (@masses) {
my $repl= dirform::trim($s) . " -> ms[$count]";
#print "repl=$repl\n";
push(@lmap,$repl);
$count++;
}
my $lmapstring = join(", ",@lmap);

print "variables mapped: " . join(', ',@lmap) . "\n";
############ BEGIN construct graph file ######

# Copy user's math file to graph file
File::Copy::Recursive::fcopy( $wmathfile, $paths{"apf_out_graph"})
or die "Cannot copy " . $wmathfile . " to " . $paths{"apf_out_graph"} . "\n";

#  Populate templatetail template
my $template = Text::Template->new(SOURCE => $paths{"apf_templatetail_loop"}, DELIMITERS => [ '(*{', '}*)' ])
or die "Couldn't construct template: $Text::Template::ERROR";
my %vars =
    (
        cutconstruct => $cutconstruct,
        dirbase => $dirbase,
        graph => $graph,
        externallegs => $externallegs,
        loops => $loops,
        currentdir => $currentdir,
        normaliz => $paths{"apf_normaliz"},
        userdefined => $userdefined,
        feynpars => $feynpars,
        rescaleflag => $params{"rescaleflag"},
        ibpflag => $params{"IBPflag"},
        nbofkernels => $params{"nbmathsubkrnls"},
        strategy => $params{"strategy"}
    );
my $result = $template->fill_in(HASH => \%vars);

# Append templatetail lines onto graph file
if (defined $result) {
    open(INTFILE, ">>", $paths{"apf_out_graph"});
    print INTFILE $result;
    close(INTFILE);
} else {
    die "Couldn't fill in template: $Text::Template::ERROR"
}

#  Populate templatetailFU template
$template = Text::Template->new(SOURCE => $paths{"apf_templatetailFU_loop"}, DELIMITERS => [ '(*{', '}*)' ])
or die "Couldn't construct template: $Text::Template::ERROR";
%vars =
    (
        FUNfile => $paths{"apf_out_FUN"},
        lmapstring => $lmapstring,
        userdefined => $userdefined
    );
$result = $template->fill_in(HASH => \%vars);

# Append templatetailFU lines onto graph file
if (defined $result) {
    open(INTFILE, ">>", $paths{"apf_out_graph"});
    print INTFILE $result;
    close(INTFILE);
} else {
    die "Couldn't fill in template: $Text::Template::ERROR"
}

######################################################################
if ($userdefined == 0) {    
    print "Calculating F and U\n";
} elsif ($userdefined == 1) {   
    print "making replacements in user functions\n";
}

system ("perl " . $paths{"apf_mathlaunch"} . " " . $paths{"apf_out_graph"} . " " . $paths{"apf_out_calcFU"} ) ==0
or die "Error - cannot launch " . $paths{"apf_mathlaunch"} . " with input file " . $paths{"apf_out_graph"} . "\n";

print "Success - functions written to " . $paths{"apf_out_FUN"} . "\n";

my $facflag=getinfo::factorizecheck($paths{"apf_out_calcFU"});
if ($facflag==1) {
    print "WARNING: parameter(s) z[i] can be factored into the list of exponents \n";
    print "or invariant(s) into the numerator function.\n";
}
print "\n";
