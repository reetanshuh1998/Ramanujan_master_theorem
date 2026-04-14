#****
#
#  NAME
#  decomposeloop.pl
#
#  USAGE
#  perl decomposeloop.pl or ./launch
# 
#  USES 
#  $paramfile, header.pm, mathlaunch.pl
#
#  USED BY 
#  launch 
#      
#  PURPOSE
#  doing the iterated sector decomposition in Mathematica
#  uses a different decomposition strategy if infinite recursion occurs
#  the primary sectors for which a different strategy should be used 
#  must be given at the end of the $paramfile
#    
#  INPUTS
#  $paramfile (default is paramloop.input), read via module header
#  $mathfile (default is mathloop.m)
#    
#  RESULT    
#  -adds decomposition part to the file $currentdir/$graph.m 
#  -launches the decomposition and writes the results to 
#   $currentdir in the form of lists containing the 
#   parametric functions for each pole structure
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
use paths;
use params;
use getinfo;
use dirform;
use Cwd;
use Getopt::Long;

# Get command line parameters + secdec directory
my $paramfile = undef;
my $mathfile = undef;
my $kinemfile = undef;
my $workingdir = undef;
my $userdefined = 0;
GetOptions("parameter=s" => \$paramfile, "math=s"=>\$mathfile, "kinem=s"=>\$kinemfile, "dirwork=s"=>\$workingdir, 'userdefined=i' => \$userdefined);
my $secdecdir = getcwd(); # SecDec dir

print "- 3/8 decompose\n";

# Read paramfile + construct paths
my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

# Declare local path variables
$secdecdir=$paths{"ap_secdecdir"}; # warning - overwriting $secdecdir
my $wmathfile=$paths{"apf_mathfile"};
my $currentdir=$paths{"ap_outputdir"};
$workingdir=$paths{"ap_workingdir"}; # warning - overwriting $workingdir
my $decompdir=$paths{"ap_decomposition"};

# Declare local paramfile variables
my $graph=$params{"graph"};
my $contourdef=$params{"contourdef"};
my $rescaleflag=$params{"rescaleflag"};
my $ibpflag=$params{"IBPflag"};
my $nbmathkerns=$params{"nbmathsubkrnls"};
my $clusterflag=$params{"clusterflag"};
my $together=$params{"together"};
my $strategy=$params{"strategy"};
my @nonstoplist = @{$params{"array_nonstop"}};

# Declare local mathparamfile variables
my $cutconstruct=$hash_varmath{"cutconstruct"};
my $Nn=$hash_varmath{"Nn"};
my $loops=$hash_varmath{"loops"};

my $feynpars = $hash_varmath{"feynpars"};
my $externallegs=$hash_varmath{"externallegs"};
my $indflag=$hash_varmath{"indflag"};
#my $Nmin=$hash_varmath{"Nmin"}; (SB) no longer needed
my $Nmax=$hash_varmath{"Nmax"};
my @Nlist=@{$hash_varmath{"array_Nlist"}};

#
############## end of user defined input ############
#
# insert main path in math.m
#(SB): $itermax no longer needed
#my $itermax=1;

# ToDo: Handle $indflag==1
# if ( $indflag==1 ) { print "Sorry, indflag==1 is not currently supported"; exit 1; }
#if ($indflag==1){
# $itermax=@Nlist;
# open (ALLSEC,">" . $paths{"apf_out_decomposegraph"});
# print ALLSEC "echo \"results of the decomposition will be written to\"\n";
# print ALLSEC "echo \"$currentdir\"\n";
#}

#for (my $iti=0;$iti<$itermax;$iti++) {

    #ToDo: Handle $indflag==1
    # if user specified: set Nmax, Nmin to the $iti element of $Nlist
    #if($indflag==1){
    #    $Nmin=$Nlist[$iti];
    #    $Nmax=$Nmin
    #}
    
#     # if more than one sector AND primary sectors not user specified
#     #(SB:) no special cases needed here. SecAll is always ok.
     my $logex="SecAll";
# #    if ($Nmin==$Nmax) { # else, only one sector
# #        $logex="Sec$Nmin";
# #    }

    my $primlist=0;
    open (EREAD,"$wmathfile") || die "cannot open $wmathfile\n";
    open (ET,">",$paths{"apfp_out_graphdeco"} . $logex . ".m") || die "cannot open " . $paths{"apfp_out_graphdeco"} . $logex . ".m" . "\n";
    while(<EREAD>) {
	chomp;
	print ET "$_\n";
    }
    if ($userdefined == 0) {
	if($cutconstruct eq "True"){print ET "cutconstruct=True;\n"}else{print ET "cutconstruct=False;\n"}; # sj - no need to print this when we convert to the new math
    }
    close (EREAD);
    
    my $templatetail= $paths{"apf_templatetail_loop"};
    open (EREAD,"$templatetail") || die "cannot open $templatetail\n";
    while(<EREAD>) {
	chomp;
	s/userdefined=\(\*\{\$userdefined\}\*\)(.*)/userdefined=$userdefined;/;
	s/cutconstruct=\(\*\{\$cutconstruct\}\*\)(.*)//; # sj - must remove new cutconstruct line from new templatetail (hack)
	s/path\s*=\s*(.*)/path=\"$secdecdir\";/;
	s/normaliz\s*=\s*(.*)/normaliz=\"$paths{apf_normaliz}\";/;
	s/graphstring\s*=\s*(.*)/graphstring="$graph";/; # sj - changed this line to be compatible with new templatetail
	s/externallegs\s*=*\d*/externallegs=$externallegs/;
	s/loops\s*=*\d*/loops=$loops/;
	s/feynpars=\(\*\{\$feynpars\}\*\)(.*)/feynpars=$feynpars;/;
	#	s/currentdir\s*=\s*(.*)/currentdir=\"$currentdir\"/;
	s/currentdir\s*=\s*(.*)/currentdir=\"$decompdir\";/;
#	s/npmin\s*=\s*(\d.*)/npmin=${Nmin};/; (SB) no longer needed
	if ($userdefined == 0) {
	s/npmax\s*=\s*(.*)/npmax=${Nmax};/;
	}
	s/rescaleflag\s*=\s*\d*/rescaleflag=${rescaleflag}/;
	s/ibpflag\s*=\s*\d*/ibpflag=${ibpflag}/;
	s/nbkernels\s*=\s*\d*/nbkernels=${nbmathkerns}/;
	s/strategy\s*=\s*(.*)/strategy=\"${strategy}\"/;
	print ET "$_\n";
    }
    close (EREAD);
    #################################################################################################
    # Write the indflag to .m file so that SDroutines.m can access the information and write the 
    # correct OUT.info file also in case where user just wants to compute integral with only 1 sector
    print ET "\nindflag=${indflag};\n";
    # define list of masses and Lorentz-vector invariants for signcheck
    #################################################################################################
    print ET "\n";
    if ($userdefined == 1) {
	print ET "Remove[functionlist];\n";
    }
    print ET "Get[ToString[\"" . $paths{"apf_out_FUN"} . "\"]];\n";
    print ET "\n";
    print ET "prefac=1/prefactor;\n";
    if ($userdefined == 0) {
	print ET "Get[ToString[\"" . $paths{"apf_prepareinput"} . "\"]];\n";
	print ET "\n";
	print ET "If[MatchQ[F[z],0],\n";
	print ET "Print[\"Warning, F[z]=0, please verify your input\"];\n";
	print ET ",\n";
	print ET "signcheck=Join[{z[a_]->1/2},Table[masslist[[i]]->1,{i,Length[masslist]}],Table[lorentzlist[[i]]->-1,{i,Length[lorentzlist]}]];\n";
	print ET "If[(F[z]/.signcheck)<0,\n";
	if ($contourdef ne "True") {
	    print ET "Print[\"Warning: F[z] is not positive semi-definite, please verify your input\"];\n";
	}
# probably interesting information for some users, but does not lead to 
# any program stops when using contourdef=true 
#    print ET "If[Length[Union[Cases[F[z], ms[_] | ssp[_] | sp[__],{0,Infinity}]]]<=1,\n";
	print ET "If[Length[lorentzlist]+Length[masslist]<=1,\n";
	print ET "Print[\"Info: Your integrand seems to have a maximum of one\"];\n";
	print ET "Print[\"kinematic invariant and F[z] is not positive semi-definite.\"]; \n";
	print ET "Print[\"This produces unnecessary logarithms of a negative number.\"]; \n";
	print ET "Print[\"If not done so already, please factor the invariant out.\"]]];\n";
    } 
# probably interesting information for some users, but does not lead to 
# any program stop when using contourdef=true 
# note that MonomialList only exists in version >6
# MK: analytic continuation is needed for some one scale problems as well, e.g. B0(psq>0 ,0,0),
#     contour def could be avoided by correct treatment of overall factor (-psp -0I)^f(eps)
#     if ($userdefined == 0) {
# 	if  ($contourdef eq "True") {
# 	    print ET "If[\$VersionNumber>6,\n";
# 	    print ET "If[Length[MonomialList[F[z]]]==1,\n";
# 	    print ET "Print[\"Info: Function F[z] is a monomial, see file " . $paths{"apf_out_FUN"} . " \n";
# 	    print ET "in your graph directory. Contour deformation not strictly necessary. \"]]; \n";
# 	    print ET "];\n";
# 	}
#     }
#     print ET "(* prepare the input for decomposition *)\n";
#(SB) appears twice and should be needed only in the above case
#    print ET "\n";
#    print ET "Get[ToString[\"". $paths{"apf_prepareinput"} . "\"]];\n";
    print ET "\n";
    print ET "(* do the iterated decomposition *)\n";
    print ET "\n";
    my $qlist=join(",",@nonstoplist);
    print ET "qlist=\{$qlist\};\n";
    my $indlist=join(",",@Nlist);
    print ET "indlist=\{$indlist\};\n";
    print ET "Get[ToString[\"" . $paths{"apf_decomposition"} . "\"]];\n";
    print ET "\n";
    if ($userdefined == 0) {    
	print ET "];\n";  
    }
    close (ET);

#####################################################
# chdir("$secdecdir") || die "cannot change to directory $secdecdir\n"; # sj - should already be in secdecdir
#SBif ($indflag==0) {
     print "Performing sector decomposition using strategy ${strategy}\n";
     
     system ("perl " . $paths{"apf_mathlaunch"} .
     " " . $paths{"apfp_out_graphdeco"} . $logex . ".m" .
     " " . $paths{"apfp_out_graphdecomposition"} . $logex . ".log") ==0
     or die "Error - cannot launch " . $paths{"apf_mathlaunch"} . " with input file " . $paths{"apfp_out_graphdeco"} . $logex . ".m" . "\n";
     
     my $wflag=getinfo::signcheck($paths{"apfp_out_graphdecomposition"} . $logex . ".log");
     my $eflag=getinfo::decF0warning($paths{"apfp_out_graphdecomposition"} . $logex . ".log");
     my $mflag=getinfo::monomial($paths{"apfp_out_graphdecomposition"} . $logex . ".log");
     my $sflag=getinfo::onescale($paths{"apfp_out_graphdecomposition"} . $logex . ".log");

     if ($wflag==0) {
         #print "done\n";
     } elsif ($sflag==1 && $contourdef ne "True") {
	 print "Warning: F[z] is not positive semi-definite and \n";
	 print "has only one scale, compare " . $paths{"apf_out_FUN"} . " and the onshell-conditions. \n";
	 print "Please factor out the scale and restart.\n";
	 exit 10;
     }
#     } else {
#	 print "Warning: F[z] is not positive semi-definite! \n";
#	 print "SecDec will continue, but please verify your input, in particular the on-shell conditions and the FUN.m file.\n";
#     }
     
     if ($eflag!=0) {
	 print "Warning: F[z] is zero. \n";
	 print "Please check your input.\n";
	 exit 10;
     }
     if ($mflag==1 && $sflag==0) { #mflag can only be equal to 1 if contourdef=true
	 print "Info: F[z] is a monomial and is positive semi-definite,\n";
	 print "contour deformation is not strictly necessary.\n";
#mflag can only be equal to 1 if contourdef=true, 
#sflag can only be equal to 1 if signcheck failed
     } elsif ($mflag==1 && $sflag==1) { 
	 print "Info: F[z] is a monomial and not positive semi-definite, for more info see\n";
	 print $paths{"apfp_out_graphdecomposition"} . $logex . ".log" . ", \n";
	 print $paths{"apf_out_FUN"} . "\nand your onshell-conditions. \n";
	 print "It could be more efficient to factor out the sign of the scale \n";
	 print "and use contourdef=False in your $paramfile file.\n";
     }

     #ToDo: Handle $indflag != 0
     #} else {
     #open (SECLAUNCH,">",$paths{"apfp_out_launchgraph"} . $logex);
     #print SECLAUNCH "cd $secdecdir\n";
     #print SECLAUNCH "if [ ! \$1 ]\nthen\n";
     #print SECLAUNCH "echo \"results of the decomposition will be written to\"\n";
     #print SECLAUNCH "echo \"$currentdir\"\n";
     #print SECLAUNCH "echo \"Decomposing $logex\"\nfi\n";
     #print SECLAUNCH "perl " . $paths{"apf_mathlaunch"} .
     #" " . $paths{"apfp_out_graphdeco"} . $logex . ".m" .
     #" " . $paths{"apfp_out_graphdecomposition"} . $logex . ".log";
     #close (SECLAUNCH);
     ## system("chmod +x $paths{"apfp_out_launchgraph"} . $logex); # sj - removed
     #print ALLSEC "echo \"Decomposing $logex\"\n";
     #print ALLSEC $paths{"apfp_out_launchgraph"} . $logex . " 1\n";
     #}
#} # end for ($iti=0;$iti<$itermax;$iti++)

#ToDo: Handle $indflag==1
#if ($indflag==1){
# print ALLSEC "cd $secdecdir\n";
# print ALLSEC "perl " . $paths{"apf_subexploop"} . " -p $paramfile -d $workingdir\n";
# print ALLSEC "echo\necho\n";
# if($exe-$clusterflag==4){
# print ALLSEC "perl " . $paths{"apf_resultsloop"} . " -p $paramfile -d $workingdir\n";
# }elsif($exe==4){
#  print ALLSEC "echo \"When all jobs are completed, cd to \"\n";
#  print ALLSEC "echo \"$secdecdir\"\n";
#  print ALLSEC "echo \"and run resultsloop.pl -p $paramfile -d $workingdir\"\n";
# }else{
#  if($clusterflag==0){
#   print ALLSEC "echo \"to complete the calculation, cd to\"\n";
#   print ALLSEC "echo \"$secdecdir\"\n";
#   print ALLSEC "echo \"and run finishnumericsloop.pl -p $paramfile -d $workingdir\"\n";
#  }elsif($exe==0){
#   print ALLSEC "echo \"to complete the calculation, cd to\"\n";
#   print ALLSEC "echo \"$secdecdir\"\n";
#   print ALLSEC "echo \"and run finishnumericsloop.pl -p $paramfile -d $workingdir\"\n";
#  }else{
#   if($together==0){
#    print ALLSEC "echo \"to complete the calculation, wait for all jobs to finish, then cd to\"\n";
#    print ALLSEC "echo \"$secdecdir\"\n";
#    print ALLSEC "echo \"and run finishnumericsloop.pl -p $paramfile -d $workingdir\"\n";
#   }
#  }
# }
# close ALLSEC;
    
# system("chmod +x " . $paths{"apf_out_decomposegraph"});
# chmod 0744, $paths{"apf_out_decomposegraph"}; # add user execution permission (default is 644)
 
# print "To run the decomposition in series, type " . $paths{"apf_out_decomposegraph"} . "\n";
# print "To distribute decomposition over a number of cores, run the executables\n";
# print $paths{"apfp_out_launchgraph"} . "Sec*\n";
# print "after the decomposition is done, type\n";
# print "perl ". $paths{"apf_subexploop"} . " -p $paramfile -d $workingdir\n";
# print "(This is done automatically when run in series)\n";
# print "to collect the results, type ";
# print "perl " . $paths{"apf_resultsloop"} . " -p $paramfile -d $workingdir\n";

#}
my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath);

my $sectors = getinfo::allcount($infofile);
print "Decomposition produced ${sectors} sector(s) and found the following polestructs:\n";

my $itermax;
if($indflag==1 || $userdefined==1){
    $itermax=@Nlist;
} else {
    $itermax=1;
}
for (my $iter=0;$iter<$itermax;$iter++) {
    my $cursec=$Nlist[$iter];
    if ($userdefined==1) { 
	print "- in user function $cursec:\n"; 
    } elsif ($indflag==1) { 
	print "- in primary sector $cursec:\n"; 
    }

# print polestructs
# print (contributes) if the polestruct contributes to the epsorder specified in the param file
    my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);
    my @polestructs=(); my @cpolestructs=();
    if ($userdefined) {
	@polestructs=getinfo::polestructs($infofile,$userdefined);
	@cpolestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$userdefined);
    } else {
	@polestructs=getinfo::polestructs($infofile,$indflag);
	@cpolestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$indflag);
    }
my %polestructs_hash = ();
foreach my $polestruct ( @polestructs ) { # hash polestructs (with value 1)
    $polestructs_hash{$polestruct} = 1;
}
foreach my $polestruct ( @cpolestructs ) { # hash contributing polestructs (with value 2) overwriting original polestructs
    $polestructs_hash{$polestruct} = 2;
}
foreach my $key ( keys %polestructs_hash )
{
    print "* $key";
    if ( $polestructs_hash{$key} == 2 ) {
        print " (contributes)\n";
    } else {
        print "\n";
    }
}
} #end loop over sectors (if indflag set)
print "Success - decomposition complete\n\n"; 
#####################################################
