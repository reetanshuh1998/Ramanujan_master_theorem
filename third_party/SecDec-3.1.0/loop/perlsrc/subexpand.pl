#
  #****s* SecDec/loop/subexpand.pl
  #  NAME
  #    runsubexp.pl
  #
  #  USAGE
  #  via secdec
  # 
  #  USES 
  #  subexp<polestructs>.m
  #
  #  USED BY 
  #  secdec
  #  
  #  PURPOSE
  #  runs subexp<polestructs>.m
  #
  #  INPUTS
  #  optional <polestruct>
  #    
  #  RESULT
  #
  #  OPTIONS
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
use Cwd;
use getinfo;
use Getopt::Long;

my $paramfile;
my $mathfile;
my $kinemfile;
my $workingdir;
my $userdefined = 0;
my @userpolestructs;
GetOptions("p|parameter=s" => \$paramfile, "math=s"=>\$mathfile,"kinem=s"=>\$kinemfile,  "dirwork=s"=>\$workingdir, "userdefined=i" => \$userdefined, "polestructs=s" => \@userpolestructs);
my $secdecdir = getcwd(); # SecDec dir

print "- 5/8 subexpand\n";

@userpolestructs = split(/,/,join(',',@userpolestructs)); # construct userpolestructs array

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

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

print "Subtraction/Expansion will be performed for the following polestructs";
    if ($userdefined ==1) {
	print " in user function ${cursec}:\n";
    } elsif ($indflag==1) { 
	print " in primary sector ${cursec}:\n"; 
    } else { print ":\n"; }
print "* " . join("\n* ",@selectedpolestructs) . "\n";

foreach my $polestruct ( @selectedpolestructs ) {

    print "Subtracting/Expanding polestruct $polestruct\n";
    if ($userdefined ==1) { 
	$polestruct="func${cursec}P$polestruct";
    } elsif ($indflag==1) {
	$polestruct="sec${cursec}P$polestruct";
    }    
    my $subexpf=$paths{"apfp_out_subandexpandpolestruct"} . $polestruct . ".m";
    my $subexplog= $paths{"apfp_out_batchpolelog"} . $polestruct . ".log";
    
    system ("perl " . $paths{"apf_mathlaunch"} . " " . $subexpf . " " . $subexplog ) ==0
    or die "Error - cannot launch " . $paths{"apf_mathlaunch"} . " with input file " . $subexpf . "\n";
    
}
} # end loop over primary sectors
print "Success - subtracted/expanded functions written to " . $paths{"ap_numerics"} . "\n\n";
