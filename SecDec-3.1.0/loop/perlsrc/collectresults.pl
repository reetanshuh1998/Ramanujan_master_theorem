#
#****s* SecDec/loop/collectresults.pl
#
#  NAME
#  collectresults.pl
#
#  USAGE
#  perl collectresults.pl 
# 
#  PURPOSE
#  collects results for multiple points
#    
#  INPUTS
#  
#    
#  RESULT    
#  
#  OPTIONS
#
# 
#****
use strict;
use warnings;

use lib "loop/perlsrc/modules";
use paths;
use params;
use getinfo;
use getkinematics;
use Cwd;
use Getopt::Long;

my $paramfile;
my $mathfile;
my $kinemfile;
my $workingdir;
my $userdefined = 0;
GetOptions("parameter=s" => \$paramfile, "math=s"=>\$mathfile, "kinem=s"=>\$kinemfile, "dirwork=s"=>\$workingdir, 'userdefined=i' => \$userdefined);
my $secdecdir = getcwd(); # SecDec dir

print "- 8/8 collectresults\n";

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);

#
# sj - warning
# sj - perhaps we should check here that the number of invariants the user has in the math file matches that of the kinemfile?
#

############## to produce *.gpdat files for plotting ##############
# xplot is usually a 1 element list containing the number of the column in kinem.input which
# corresponds to the invariant which will be the label on the x-axis of the plot
my @xplot=@{$params{"array_xplot"}};
####################################################################

my %hash_varkinem=getkinematics::readmultikinem($paths{"apf_out_kinemfile"});
my $linenumbers=$hash_varkinem{"lines"};

if($hash_varkinem{"points"}) 
{ 
    my @points=split(/;/,$hash_varkinem{"points"}); # get list of kinematic points calculated
    my $totpoints=@points;
    
    my @blanklines=split(/;/,$hash_varkinem{"blanklines"});
    
    # sj - perhaps we can add a blank line to the gnuplot file for each blank line in the kinemfile?
	
    print "Collecting results for $totpoints points\n";
    my @kinematics=();
    foreach my $point (@points) {
        
        $point=~s/^\./0\./; # if points are specified as ".xxx" prepend the missing zero "0.xxx"
	   
        # invars should be the values for the kinematic invariants defined in a line of kinem.input
	    my @invars=split(/\s/,$point);
        
        my $pn=shift(@invars); # store point name separately to invariants
        my $pnwithblanks = $pn;
       
        # sj - consider making pointstring an array
        my $pointstring=join("SPACE",@invars); # string of kinematic invariants
        if ($pointstring eq "")
        {
            $pointstring = "1"; # hack so that pointstring is not empty when no invariants are present
        }
        $pointstring=~s/-/m/g;

	    print "Collecting results for $pn... ";
	    
        my $xplotval="";
        my $nblanks=shift(@blanklines);
        foreach my $i (1..$nblanks) { $xplotval = "\n" . $xplotval;}
        if ( @invars) {
            foreach my $xpi (@xplot){
                $xplotval=$xplotval . "$invars[$xpi] ";
            }
        }
	    $xplotval="\"$xplotval\"";
	    $xplotval=~s/-/m/g;
        
        system("perl " . $paths{"apf_results"} . " $pointstring $pn $xplotval -p=$paramfile -m=$mathfile -k=$kinemfile -d=$workingdir -u=$userdefined");
	    if($?) { die "Not all integrations for point $pn performed yet or *.input file no longer existing."; }
    } # end foreach point
}

print "Success - collection of results complete\n\n";
