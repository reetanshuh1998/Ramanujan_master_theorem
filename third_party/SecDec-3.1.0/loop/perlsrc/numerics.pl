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
#use Data::Dumper;
use Getopt::Long;

my $paramfile;
my $mathfile;
my $kinemfile;
my $workingdir;
my $userdefined = 0;
my @userpolestructs;
my @userepsords;
GetOptions("p|parameter=s" => \$paramfile, "math=s"=>\$mathfile,"kinem=s"=>\$kinemfile,  "dirwork=s"=>\$workingdir, "userdefined=i" => \$userdefined, "polestructs=s" =>\@userpolestructs, "epsords=s" => \@userepsords);
my $secdecdir = getcwd(); # SecDec dir

print "- 7/8 numerics\n";

@userpolestructs = split(/,/,join(',',@userpolestructs)); # construct userpolestructs array
@userepsords = split(/,/,join(',',@userepsords)); # construct userpolestructs array

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

$workingdir = $paths{"ap_workingdir"};

# Note: the integrator used in the numerics may have been changed dynamically (the value below would then be incorrect)
# if we implement switching TO "nintegrate" then the below line would be incorrect
my $integrator=$params{"integrator"}; # warning this could be inaccurate

#my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath);
#my $threshold = getinfo::getthres($infofile); # prepare threshold inserted by user and stored in infofile, to be used in makeintC.pm

# iterate over individual sectors if applicable
my $indflag=$hash_varmath{"indflag"};
my @Nlist=@{$hash_varmath{"array_Nlist"}};
my $itermax;
my $infofile;
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
my @polestructs;
    if ($userdefined==1) {
	@polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$userdefined); # array of available numerical polestructs
    } else {
	@polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$indflag); # array of available numerical polestructs
    }
if ( @userpolestructs ) { # user has specified polestructs
    @selectedpolestructs= params::filter(\@userpolestructs,\@polestructs); # select valid polestructs from user input
} else { # user has not specified polestructs
    @selectedpolestructs=@polestructs;
}

foreach my $polestruct ( @selectedpolestructs ) {

    my $outinfo = paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec) . $paths{"rp_out_infofile"}; # created during subtraction and expansion
    
    # validate user input epsords
    my @selectedepsords;
    if ( @userepsords ) { # user has specified epsords
        my @epsords = getinfo::epsords($outinfo);  # array of available epsords
        @selectedepsords = params::filter(\@userepsords,\@epsords); # select valid epsords from user input
    } else {
        @selectedepsords = getinfo::epsords($outinfo);  # array of available epsords
    }
    
    foreach my $epsord ( @selectedepsords ) {
        
        my $functdir= paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec) . $paths{"rp_out_epstothe"} . $epsord . "/";

        if (-e "$functdir" . $paths{"rp_out_subfile"}) {
            # sj - perhaps using a true makefile is the best idea here?
		    if( $integrator!=5){
                system("cd $functdir; perl " . $paths{"rp_out_makef"}) == 0
                or die "Error - " . "could not launch " . $paths{"rp_out_makef"} . "\n";
		    }
		    system("cd $functdir; perl " . $paths{"rp_out_subfile"});
		    my $texcode=$?>>8;
		    unless($texcode==0) { exit $texcode; }
            
		} else {
            "Error - " . "$functdir" . $paths{"rp_out_subfile"} . " does not exist.\n";
        }

    }
    
}
} # end loop over primary sectors (if indflag is set)
print "Success - numerical integration complete\n\n";
