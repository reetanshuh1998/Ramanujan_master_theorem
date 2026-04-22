#
  #****s* SecDec/loop/subexploop.pl
  #  NAME
  #    subexploop.pl
  #
  #  USAGE
  #  ./launch or perl subexploop.pl
  # 
  #  USES 
  #  $paramfile, header.pm, makejob.pm, launchjob.pm, getinfo.pm, dirform.pm
  #  as templates: subandexpand.m, batch 
  #
  #  USED BY 
  #  launch
  #  
  #  PURPOSE
  #  prepares the intermediate files subandexpand*l*h*.m, batch*l*h*, and where
  #  applicable job*l*h*. 
  #
  #  NEW in version 3: submission of the job files is decoupled from subexp, done by 
  #                    multinumerics, therefore info on kinematics is NOT needed in subexploop
  #
  #  INPUTS
  #  $paramfile (default is paramloop.input) read via module header
  #  parameters parsed via ARGV:
  #  fromlaunch: a flag to indicate whether subexploop.pl was run by launch, or from
  #  the terminal.
  #    
  #  RESULT
  #  intermediate files made. Depending on values of $exe and $clusterflag, the
  #  subtraction, eps expansion and creation of f*.f files is run or submitted.
  #  executable makeclean is created, which when run will remove all unneeded
  #  intermediate files.
  #  OPTIONS
  #  to use a parameter file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #    
  #  SEE ALSO
  #  launch, batch, subandexpand.m, cleanup.pl, makejob.pm, launchjob.pm, getinfo.pm
  #   
  #****
  #
use strict;
use warnings;

use lib "loop/perlsrc/modules";
use paths;
use params;
use makejob;
use getinfo;
use dirform;
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

print "- 4/8 preparesubexpand\n";

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

$workingdir = $paths{"ap_workingdir"};

my $indflag=$hash_varmath{"indflag"};
my @Nlist=@{$hash_varmath{"array_Nlist"}};

#my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath);

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
    my @polestructs=();
    if ($userdefined) {
	@polestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$userdefined);  # array of available polestructs
    } else {
    	@polestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,$indflag);
    }
    
    foreach my $polestruct (@polestructs) {
        preparesubandexpand(\%paths,\%hash_varmath,\%params,$polestruct,$iter);
    } # next in polestruct
    
} #next sector where applicable

print "Success - subtraction/expansion files written to " . $paths{"ap_subexp"} . "\n\n";

# sj - todo, handle together flag
#if($togetherflag==1) {
#    if($params{"exe"}>1){
#        @ordlist=();
#        for($i=$epsord;$i>=$minmin;$i--){
#            $it=$i;
#            $it=~s/-/m/;
#            push(@ordlist,$it)
#        }
#        system("perl " . $paths{"apf_dotogetherC"} . " -p=$paramfile -m=$mathfile -k=$kinemfile -d=$workingdir $exe @ordlist");
#    }
#} # end if togeetherflag=1

########################################################################################

sub preparesubandexpand {
    my %paths  = %{ $_[0] };
    my %mathparams = %{ $_[1] };
    my %params = %{ $_[2] };
    my $polestruct = $_[3];
    my $iter = $_[4];
    
    my $dim=getinfo::dim($paths{"apf_out_graph"});
    my $polestructdir=$paths{"apfp_out_polestruct"};
    my $dirbase = $paths{"ap_secdecdir"};
    my $rescaleflag=$params{"rescaleflag"};
    my $contourdef=$params{"contourdef"};
    my $oscillatory=$params{"oscillatory"};
    my $nbmathkerns=$params{"nbmathsubkrnls"};
    my $graph=$params{"graph"};
    my $togetherflag=$params{"together"};
    my $integrator=$params{"integrator"};
    #my $endpointflag=$params{"endpointflag"}; # no remapping (SB, June 04 2012) by fixing endpointflag=0
    my $complexmasses=$params{"complexmasses"};

    # read from mathparamfile:
    my $Nn=$hash_varmath{"Nn"};
    my $feynpars=$hash_varmath{"feynpars"};
    my $externallegs=$hash_varmath{"externallegs"};
    my $xlambda=$params{"xlambda"};
    
    my $graphdeco=$paths{"apfp_out_graphdeco"};
    my $srcdir= $paths{"ap_loopsubexp"};
    
    my $cursec=$Nlist[$iter];
    my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);
    my $lengthprimseclist=getinfo::lengthprimseclist($infofile);
    if ($userdefined==1) { 
	$polestruct="func${cursec}P$polestruct";
    } elsif ($indflag==1) {
	$polestruct="sec${cursec}P$polestruct";
    }
    my $outputfile = $paths{"apfp_out_subandexpandpolestruct"} . "$polestruct.m";
    my ($i,$j,$h) = getinfo::polestructpoles($polestruct);
    my $mindegree=getinfo::mindegree($infofile);
    my $maxdegree=getinfo::maxdegree($infofile);
    my $epsord = getinfo::internalepsorder(\%paths,\%params,$infofile);
        
    my $secstring="";
    if ($userdefined==1) {
	$secstring="user function $cursec, ";
    } elsif ($indflag!=0) {
	$secstring="primary sector $cursec, ";
    }
    print "Creating subexp files for ${secstring}polestruct ${polestruct}: $i logarithmic pole(s), $j linear pole(s), $h higher pole(s)\n";
    
    # load decomposition files
    my $filestr;
    if ($indflag==1 || $userdefined==1){
         $filestr="<<${graphdeco}$polestruct.out;\n";        
    } else {
        $filestr="";
        for (my $k=1;$k<=$Nn;$k++) {
        $filestr="$filestr<<${graphdeco}sec${k}P${i}l${j}h${h}.out;\n"            
        }
    }
    $filestr="${filestr}lengthprimseclist=$lengthprimseclist;\n";
    
    
    my $indcode="";
    if($indflag==1 || $userdefined==1) { $indcode="indsec=$cursec;" };
    
    open (EREAD,$paths{"apf_subandexpand"}) || die "cannot open " . $paths{"apf_subandexpand"} . "\n";
    open (OUTF,">",$outputfile) || die "cannot open " . $outputfile . "\n";
    
    while(<EREAD>) {
        chomp;
        # regex replacements
        s/Dim=/Dim=$dim/;
	if ($userdefined==1) {
	    s/outp=/outp=\"$polestructdir\/func${cursec}\"/;
	} elsif ($indflag==1) {
	    s/outp=/outp=\"$polestructdir\/sec${cursec}\"/;
	}else{
	    s/outp=/outp=\"$polestructdir\"/;
	}
        s/path=/path=\"$dirbase\"/;
        s/inputdecomposition/$filestr/;
        s/n=/n=$Nn/;
        s/feynpars=/feynpars=$feynpars/;
        s/logi=/logi=$i/;
        s/lini=/lini=$j/;
        s/higheri=/higheri=$h/;
        s/mindegree=/mindegree=$mindegree/;
        s/maxdegree=/maxdegree=$maxdegree/;
#        s/partsflag=/partsflag=$partsflag/;
        s/rescaleflag=/rescaleflag=$rescaleflag/;
        s/extlegs=/extlegs=$externallegs/;
        s/contourdef=/contourdef=$contourdef/;
        s/xlambda=/xlambda=$xlambda/;
        s/oscillatory=/oscillatory=$oscillatory/;
        # no remapping (SB, June 04 2012) by fixing endpointflag=0:
        s/endpointflag=/endpointflag=0/;
	# SB (Aug 20th '15): the ";" after nbkernels 
	#     is needed to evade a successful 
	#     pattern match in line 103 of the 
	#     subandexpand.m template 
        s/nbkernels=;/nbkernels=$nbmathkerns;/;
#        s/expu=/expu=$expu/;
#	s/expf=/expf=\-\($expf\)/;
	s/precisionrequired=/precisionrequired=$epsord/;
        s/diagramname=/diagramname=\"$graph\"/;
        s/srcdir=/srcdir=\"$srcdir\"/;
	if ($userdefined==1) {
	    s/prestring=/prestring=\"func\"/;
        } else {
	    s/prestring=/prestring=\"sec\"/;
	}
        s/individual sector/$indcode/;

        if ( $togetherflag ==1 ) { 
            #s/togetherflag=0/togetherflag=1\; polestring=\"\"/; # sj - do not want to blank polestring
            s/togetherflag=0/togetherflag=1; polestring=\"together\"/; # sj - is it safe to replace polestring with polestruct in any case?
        }
        if ($integrator == 5) { # using mathematica
            s/mathematicaflag=0/mathematicaflag=1/;
        }
        if ($complexmasses == 1) { # support complex masses
            s/complexmasses=0/complexmasses=1/;
        }

        print OUTF "$_\n";
    }
    close (OUTF);
    close (EREAD);
}
