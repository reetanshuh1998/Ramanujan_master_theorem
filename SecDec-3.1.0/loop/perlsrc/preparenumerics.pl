#****
#  NAME
#    polenumerics.pl
#
#  USAGE
#
#  USES
#
#  USED BY
#
#  PURPOSE
#
#  INPUTS
#
#  RESULT
#
#  SEE ALSO
#
#
#****
#
use strict;
use warnings;

use lib "loop/perlsrc/modules";
use paths;
use params;
use getinfo;
use dirform;
use Cwd;
use List::Util qw(min);
use Getopt::Long;

my $paramfile;
my $mathfile;
my $kinemfile;
my $workingdir;
my $userdefined = 0;
my @userpolestructs;
my @userepsords;
GetOptions("p|parameter=s" => \$paramfile, "math=s"=>\$mathfile,"kinem=s"=>\$kinemfile,  "dirwork=s"=>\$workingdir, "userdefined=i" => \$userdefined, "polestructs=s" =>\@userpolestructs, "epsords=s" =>\@userepsords);
my $secdecdir = getcwd(); # SecDec dir

print "- 6/8 preparenumerics\n";

@userpolestructs = split(/,/,join(',',@userpolestructs)); # construct userpolestructs array
@userepsords = split(/,/,join(',',@userepsords)); # construct userpolestructs array

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

$workingdir = $paths{"ap_workingdir"};

# variables for prefactor file
my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath);
my $prefacdir = $paths{"apfp_out_prefacdir"};  # sj - warning, building directory
my $prefacfile = $prefacdir . $paths{"rp_out_prefac"}; # "prefac$$.m";
my $prefacdump = $prefacdir . $paths{"rp_out_prefacdump"};
my $prefacord=getinfo::prefacord($infofile);
my $dim=getinfo::dim($paths{"apf_out_graph"});
my $defaultpre=getinfo::prefac($infofile);
$defaultpre=~s/\(/openbracket/g;
$defaultpre=~s/\)/closebracket/g;
my $minpole; # counter for minimum pole appearing in polestructs beloning to one sector/function
my $overallminpole; # counter for the minimum pole appearing in any polestruct
my $overallmaxpole=getinfo::overallmaxpole($infofile);
# maxlogpole is the absolute value of the overall logarithmic pole order


# iterate over individual sectors if applicable
my $indflag=$hash_varmath{"indflag"};
my @Nlist=@{$hash_varmath{"array_Nlist"}};
my $itermax;
if($indflag==1 || $userdefined==1){
    $itermax=@Nlist;
} else {
    $itermax=1;
}
for (my $iter=0;$iter<$itermax;$iter++) {
    my $cursec=$Nlist[$iter];
    $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);

# prepare threshold inserted by user and stored in infofile, to be used in makeintC.pm
    my $threshold = getinfo::getthres($infofile);
    
    #
    # TODO: Validate the user input, specifically, they may request epsorders/polestructs that do not exist!
    #
    
    # validate user input polestructs
    my @selectedpolestructs;
    my @polestructs=();
    if ($userdefined) {
	@polestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$userdefined);  # array of available polestructs
    } else {
    	@polestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$indflag); 
    } 
    if ( @userpolestructs ) { # user has specified polestructs
        @selectedpolestructs= params::filter(\@userpolestructs,\@polestructs); # select valid polestructs from user input
    } else { # user has not specified polestructs
        @selectedpolestructs=@polestructs;
    }
    
    # iterate over contributing polestructs and find minimum pole
    my @degrees;
    foreach my $polestruct ( @polestructs ) {
        # my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath); tz - read in already above
        # Compute the minimum order of eps which appears in the integral (including eps in the numerator)
        # Used to shift the acurracy targets/cuba parameters given in the input file
        # so that the correct numerical accuracy is reached for each epsilon order in the results file
        my $mindegree=getinfo::mindegree($infofile); # lowest eps order in the numerator
        my ($i,$j,$h) = getinfo::polestructpoles($polestruct); # -i-j-h is the naive order of the polestruct
        push(@degrees,-$i-$j-$h+$mindegree);
    }
    $minpole= min(@degrees);
    if ( defined($overallminpole) ) {
        $overallminpole = min($overallminpole,$minpole);
    } else {
        $overallminpole = $minpole;
    }
    
    # iterate over numeric polestructs
    my @npolestructs = getinfo::numericpolestructs(\%paths,\%params,$infofile);
    if ($params{"together"} != 1 ) { # if together == 1 then prepare numerics for the "together" polestruct
        @npolestructs = params::filter(\@npolestructs,\@selectedpolestructs);
    }
    foreach my $polestruct ( @npolestructs ) {
        
        my $outinfo = paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec)
        . $paths{"rp_out_infofile"}; # created during subtraction and expansion
        
        # validate user input epsords
        my @selectedepsords;
        if ( @userepsords ) { # user has specified epsords
            my @epsords = getinfo::epsords($outinfo);  # array of available epsords
            @selectedepsords = params::filter(\@userepsords,\@epsords); # select valid epsords from user input
        } else {
            @selectedepsords = getinfo::epsords($outinfo);  # array of available epsords
        }

        foreach my $epsord ( @selectedepsords ) {
            
            # Number of feynman parameters in the integral
            my $numvar=getinfo::nbconsts($outinfo,$epsord); # if ($helpvar < 2) {$numvar=$helpvar;} # old version
            
            print "Numerics prepared for: ";
	    if ($userdefined==1) { 
		print "user function " . $cursec .", "; 
	    } elsif ($indflag==1) { 
		print "primary sector " . $cursec .", "; 
	    }
            print "polestruct " . $polestruct . ", epsord " . $epsord . " [Found: " . $numvar . " Feynman parameter(s)]" . "\n";
            #print "minpole " . $minpole . "\n";
            #print "threshold " . $threshold . "\n";
            #print "\n";
            
            $epsord=~s/-/m/;
            $minpole=~s/-/m/;
            system("perl " . $paths{"apf_polenumerics"} . " $epsord $numvar $minpole $polestruct $threshold $cursec $overallmaxpole -p=$paramfile -m=$mathfile -k=$kinemfile -d=$workingdir -u=$userdefined");
            $epsord=~s/m/-/; # note that $epsord is an alias to @locepsords[x] so changing it affects this array!
            $minpole=~s/m/-/;
            if ( $? != 0 ) {
                print "Error - failed to prepare numerics for polestruct $polestruct, epsord $epsord\n";
                exit 1;
            }
        } # end loop over epsorders
    } # end loop over polestructures
} # end iteration over individual sectors

# generate prefactor
if (!defined($overallminpole)) { # often happens if epsord requested is lower than the integral's minimum pole
    die "Error - overallminpole is undefined: check requested epsord is not too low";
}
my @prefacargs=($defaultpre,$prefacord,$prefacdir,
$params{"epsord"},$hash_varmath{"loops"},$dim,
$hash_varmath{"Nn"},$prefacfile,$overallminpole,
$userdefined);
system("cp " . $paths{"apf_mathfile"} . " $prefacfile") ==0
or die "Error - cannot copy " . $prefacfile . "\n";
system("perl " . $paths{"apf_prefactor"} . " @prefacargs;") ==0
or die "Error - cannot launch " . $paths{"apf_prefactor"} . "\n";
system("perl " . $paths{"apf_mathlaunch"} . " $prefacfile $prefacdump") ==0
or die "Error - cannot launch " . $paths{"apf_mathlaunch"} . " with input file " . $prefacfile . "\n";

print "Success - numerics prepared\n\n";
