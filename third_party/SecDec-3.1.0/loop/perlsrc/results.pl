  #****
  #  NAME
  #    resultsloop.pl
  #
  #  USAGE
  #  perl resultsloop.pl, or from launch or finishnumericsloop.pl
  # 
  #  USES 
  #  $paramfile, header.pm, getinfo.pm, *x*.out in the leaf directories,
  #  prefactor.pl, mathlaunch.pl  
  #
  #  USED BY 
  #  launch, finishnumericsloop.pl
  #
  #  PURPOSE
  #  when necessary it generates the numerical prefactor to be used.
  #  collects all the completed .out files and sums them appropriately
  #  to form an order by order result for the numerical point in question.
  #  If any necessary outputs are absent, resultsloop.pl alerts the user by
  #  printing the location of expected output files to the terminal.
  #    
  #  INPUTS
  #  $paramfile (default is paramloop.input) read via module header
  #  @results = (result error timetaken) for each *x*.out file.
  #  parameters parsed via ARGV:
  #  dores: flag to indicate whether resultsloop.pl was called from launch or not.    
  #  
  #  RESULT
  #  if no results are missing:
  #  writes the results to files subdir/graph/graph_[point]epstothe*.res,
  #  and subdir/graph/graph_[point]full.res;
  #  files graph/[point]results*.log are also created for each order in epsilon, which lists
  #  all intermediate results, together with their numerical errors.
  #  when a text editor is specified in paramfile, this is used to display the results.
  #  if results are missing or incomplete, a list of these files is printed to the terminal.
  #
  #  OPTIONS
  #  to use a parameter file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #  
  #  SEE ALSO
  #  launch, finishnumericsloop.pl
  #   
  #****
  #
#use strict;
#use warnings;

use lib "loop/perlsrc/modules";
use paths;
use params;
use getinfo;
use dirform;
use Data::Dumper;
use getkinematics;
use Cwd;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

$point=$ARGV[0];
$point=~s/m/-/g;
$pointscalculated=$ARGV[1];
$xplot=$ARGV[2];
$xplot=~s/m/-/g;

my $paramfile;
my $mathfile;
my $kinemfile;
my $workingdir;
my $userdefined = 0;
GetOptions("parameter=s" => \$paramfile, "math=s"=>\$mathfile, "kinem=s"=>\$kinemfile, "dirwork=s"=>\$workingdir, "userdefined=i" => \$userdefined);
my $secdecdir = getcwd(); # SecDec dir

my %paths = paths::getpaths($secdecdir,$workingdir,$paramfile,$mathfile,$kinemfile);
my %params = params::readparams($paths{"apf_paramfile"},$userdefined);
%paths = paths::updatepaths(\%paths,\%params);
my $mathparamfile=$paths{"apf_out_mathparamfile"};
my %hash_varmath=params::readmathparams($mathparamfile,\%params);

my $currentdir= $paths{"ap_outputdir"};
my $wkinemfile=$paths{"apf_kinemfile"};

my $Nn=$hash_varmath{"Nn"};
my $feynpars = $hash_varmath{"feynpars"};
my $loops=$hash_varmath{"loops"};
#my $externallegs=$hash_varmath{"externallegs"};
my $userprefac=$hash_varmath{"userprefac"};
#my @invariants=@{$hash_varmath{"array_invariants"}};
my @masslist=@{$hash_varmath{"array_masslist"}};
my @lorentzlist=@{$hash_varmath{"array_lorentzlist"}};
my @Nlist=@{$hash_varmath{"array_Nlist"}};
my %hashmulti=%{$hash_varmath{"hash_multi"}};
my $indflag=$hash_varmath{"indflag"};

my $graph=$params{"graph"};
my $epsord=$params{"epsord"};
#$language=$params{"language"};
my $rescaleflag=$params{"rescaleflag"};
my $together=$params{"together"};
my $integrator=$params{"integrator"};
my $contourdef=$params{"contourdef"};
my $complexres="False";
if(($contourdef eq "True") || ($params{"complexmasses"} == 1)) { $complexres = "True"; }
#my $texteditor=$params{"editor"};
my $clusterflag=$params{"clusterflag"};
my $prefactor=$params{"prefactor"};

# my $indflag=$hash_varmath{"indflag"};

##############################################################
my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath);

my $prefacord=getinfo::prefacord($infofile);
#$epsord=$epsord-$prefacord;
#$mindegree=getinfo::mindegree($infofile);

#####################################
#my %hash_valueskinem = getkinematics::readmultikinem($kinemfile);
my @values=split(/SPACE/,$point);
#foreach $v (@values) {print "value=$v\n";}
my %hash_kinem = ();
my $i=0;
foreach my $s (@lorentzlist) {
    $hash_kinem{"$s"}={value => $values[$i], order => $i};
    $i++
}
if($params{"complexmasses"}==1){
    foreach my $s (@masslist) {
	$hash_kinem{"$s"}={value => sprintf("%g%+gI",$values[$i],$values[$i+1]), order => $i};
	$i++; $i++
    }
}else{
    foreach my $s (@masslist) {
	$hash_kinem{"$s"}={value => $values[$i], order => $i};
	$i++
    }
}

$point=$pointscalculated; # note that we redefine $point here!
################################################################################
my $dim=getinfo::dim($paths{"apf_out_graph"});
my $nan=0;
my $gmin=0;
if($indflag==1 || $userdefined==1){
    $itermax=@Nlist;
} else {
    $itermax=1;
}
for ($iter=0;$iter<$itermax;$iter++) {
	my $cursec=$Nlist[$iter];
	my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);
	my @polestructs;
	if ($userdefined==1) {
		@polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$userdefined); # array of available numerical polestructs
	} else {
		@polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$indflag); # array of available numerical polestructs
	}
	foreach my $polestruct (@polestructs) {
	     $poledir=paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec);
             $outinfo = $poledir . $paths{"rp_out_infofile"};
		my @epsorders=getinfo::epsords($outinfo);
		foreach $ord (@epsorders) {
			if($ord<$gmin){$gmin=$ord};
		}
	}
}

# zero hashes/scalars
# sj - can this not be done when we actually need their values?

#my $ini = $gmin;
#if ($userdefined==1) {
#    $ini=-$feynpars+$prefacord;
#} else {
#    $ini=-2*$loops;
#}
for (my $ord=$gmin;$ord<=$epsord-$prefacord;$ord++) { # sj - what should order run from and to?
     $sum{$ord}=0;
     $imsum{$ord}=0;
     $errsum{$ord}=0;
     $imerrsum{$ord}=0;
     $epspre{$ord}=0; #sb: otherwise not defined
     $timesum{$ord}=0;
     $timemax{$ord}=0;
     $errpmaxRE{$ord}=0; #maximal error probability
     $errpmaxIM{$ord}=0; #maximal error probability
     $tottime{$ord}=0; #total time for each order in eps
     $totalt=0;
 };


my $subexptime=0;
my  $decotime=0;
my  $maxsub=0;
my  $maxdeco=0;
my  $bigerrcount=0;
my  $bigerrcount2=0;
my  $notdoneflag=0;

#  print "itermax $itermax\n";
#  print "Nlist @Nlist\n";
#  print "indflag $indflag\n";
# loop over primary sectors/ contributing polestructs/ epsords, construct reslog file

 for ($iter=0;$iter<$itermax;$iter++) {
     my $cursec=$Nlist[$iter];

     my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);
     my $declog = paths::decomposelog(\%paths,\%hash_varmath,$cursec);
     
     $tdec=getinfo::decotime($declog);
     $decotime=$decotime+$tdec;
     
     if($tdec>$maxdeco){$maxdeco=$tdec};
     my @polestructs;
     if ($userdefined==1) {
	 @polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$userdefined); # array of available numerical polestructs
     } else {
	 @polestructs=getinfo::numericpolestructs(\%paths,\%params,$infofile,$indflag); # array of available numerical polestructs
     }

	 foreach my $polestruct (@polestructs) {
	     $poledir=paths::polestruct(\%paths,\%params,\%hash_varmath,$polestruct,$cursec);
	     $thismulti=$hashmulti{$cursec};
             $outinfo = $poledir . $paths{"rp_out_infofile"};

             my @epsorders=getinfo::epsords($outinfo);
	     			 foreach $ord (@epsorders) {
                 $reslogf = $paths{"apfp_out_reslog"} . $point . $paths{"rp_out_reslog"} . $ord . ".log";
                     open (RESLOG,">>",$reslogf);
				 unless (-s RESLOG) {
				     print RESLOG "# file name \t result real part (+- error) \t ";
				     if ($complexres eq "True") {
					 print RESLOG "result imaginary part (+- error) \t";
				     }
				     print RESLOG "error underestimation in real/imag (max. prob.) \n";
				 }
                 $thisdir= $poledir . $paths{"rp_out_epstothe"} . $ord . "/";
				 popresults();
				 close RESLOG;
			 }
 }
}


 if ($bigerrcount+$bigerrcount2+$nan==0) {
     if ($notdoneflag==0) {
     	 $ii=$prefacord; # GH: changed 26.1.15 # sj - what about mindegree?
	 $complex=0;
#	 $diforderflag=0;
#	 if ($prefacord<0){$diforderflag=-$prefacord}
         #$prefacf = $paths{"apfp_out_prefacdir"} . $point . $paths{"rp_out_prefacdir"} . $ii;
         $prefacf = $paths{"apfp_out_prefacdir"} . $ii;
	     while (-e $prefacf) {
		 open(EPSPRE,"<",$prefacf);
		 @inlist=<EPSPRE>;
		 $ett=$inlist[0];
		 chomp $ett;
	  if (looks_like_number($ett) ) {
		 @et=split(/\*\^/,$ett);
		 if($et[1]) {
		     $full=$et[0]*(10**$et[1]);
		     $epspre{$ii}=$full;
		 } else {
		     $epspre{$ii}=$et[0];
		 };
		 if ( $epspre{$ii} =~ /I/ ) { $complex++; }
		 close EPSPRE;
		 $ii++;
         $prefacf = $paths{"apfp_out_prefacdir"} . $ii;
	     }
     else {print "\n";print "Error: your prefactor does not look like a number!\n"; 
           print "prefactor=$ett\n"; exit 3}
     if ($complex >0) { print "Warning: Your prefactor is complex.\n"; }
	       }


                  #	 }
#         $expansionorder=$epsord+$prefacord;
     $resfullf= $paths{"apfp_out_resfull"} . "_" . $point . $paths{"rp_out_resfull"}; # sj - warning, building path
	 open (ALLOUT,">",$resfullf);
	 print ALLOUT "***********************************************\n";
	 print ALLOUT "***OUTPUT: $graph ***************\n";
	 print ALLOUT "point: $point \n";
	 for my $k (sort { $hash_kinem{$a}{order} <=> $hash_kinem{$b}{order} } keys %hash_kinem) {
	     print ALLOUT "$k = $hash_kinem{$k}{value}\n";
	 }
#    	 print ALLOUT "\n";
	 print ALLOUT "prefactor = $userprefac\n";
#	 if ($diforderflag) {
#	     $numord=$epsord+$diforderflag;
#	     print ALLOUT "NB: Prefactor is singular, so the order of the expansion below is eps^$epsord\n"
#	 }
	 print ALLOUT "***********************************************\n";
	 print ALLOUT "\n";
	 for ($ord=$gmin+$prefacord;$ord<=$epsord;$ord++) {
	     $res=0;$err=0;$imres=0;$imerr=0;
#	     for ($jj=$ord+1;$jj>=-2*$loops;$jj--) { #sb: doesn't work for userdefined setup
	     for ($jj=$ord-$prefacord;$jj>=$gmin;$jj--) {
		 $res=$res+$sum{$jj}*$epspre{$ord-$jj};
		 $imres=$imres+$imsum{$jj}*$epspre{$ord-$jj};
		 $err=$err+($errsum{$jj})*($epspre{$ord-$jj}*$epspre{$ord-$jj});
		 $imerr=$imerr+($imerrsum{$jj})*($epspre{$ord-$jj}*$epspre{$ord-$jj});
		 }
# GH 26.1.15: changes below to be checked 
	     # if($prefacord<0) {
# tz: no distinction necessary
	     	 $serntime=$timesum{$ord-$prefacord};
	     	 $totime=$tottime{$ord-$prefacord};
	     	 $maxntime=$timemax{$ord-$prefacord};
	     	 $maxerrpbRE=$errpmaxRE{$ord-$prefacord};
	     	 $maxerrpbIM=$errpmaxIM{$ord-$prefacord};
	     # }
	     # else {
		 # $serntime=$timesum{$ord};
		 # $totime=$tottime{$ord};
		 # $maxntime=$timemax{$ord};
		 # $maxerrpbRE=$errpmaxRE{$ord};
		 # $maxerrpbIM=$errpmaxIM{$ord};
	     # }
	     $err=sqrt $err;$imerr=sqrt $imerr;
#	     }
	     if ($maxerrpbRE == 1 ) { $maxerrpbRE.="\nReason: Integration had too few samples to reach desired accuracy or result(s) were not found."; }
		 if ($maxerrpbIM == 1 ) { $maxerrpbIM.="\nReason: Integration had too few samples to reach desired accuracy or result(s) were not found."; }

#    if ($err>0){
	     if ($notdoneflag==0) {
         $resfullepsf= $paths{"apfp_out_respart"} . "_" . $point . $paths{"rp_out_epstothe"} . $ord . ".res"; # sj - warning, building path
		 open($outfile, ">", $resfullepsf);
		 print $outfile "***********************************************\n";
		 print $outfile "***OUTPUT: $graph $point eps\^$ord coeff***\n";
		 print ALLOUT "\n****** eps\^$ord coeff ******\n\n";
#		 print $outfile "point: \n";
#                 while ( my ($key, $value) = each(%hash_kinem) ) {
#                 print ALLOUT "$key=$value ";
#                 }
#    	         print ALLOUT "\n";
		 print $outfile "prefactor=$userprefac\n";
		 print $outfile "***********************************************\n";
		 print $outfile "\n";
		 print $outfile "\n";
		 print $outfile "result       =$res\n";
		 print ALLOUT "result       =$res\n";
		 if ($complexres eq "True") {
		     if ($imres>=0) {$pstring="+";} else {$pstring="";};
		     print $outfile "             $pstring$imres I\n";
		     print ALLOUT "             $pstring$imres I\n";
		 };
	         if($integrator==5){
		   print $outfile "error        =n.a.\n";
		   print ALLOUT "error        =n.a.\n";
		 }else{
		   print $outfile "error        =$err\n";
		   print ALLOUT "error        =$err\n";
	           if ($complexres eq "True") {
		     print $outfile "             + $imerr I\n";
		     print ALLOUT "             + $imerr I\n";
                   };
		 };
		 if($together==0) {
		     print $outfile "Time (all eps^$ord subfunctions)  =$serntime s\n";
		     print ALLOUT "Time (all eps^$ord subfunctions)  =$serntime s\n";
		     print $outfile "Time (longest eps^$ord subfunction)  =$maxntime s\n";
		     print ALLOUT "Time (longest eps^$ord subfunction)  =$maxntime s\n\n";
		     if ( $integrator ) {
                         my $temp;
                         if ($complexres eq "True") { $temp=" of real part"};
                         print $outfile "Max. probability in all eps^$ord subfunctions that stated error$temp is underestimated =     $maxerrpbRE\n";
                         print ALLOUT   "Max. probability in all eps^$ord subfunctions that stated error$temp is underestimated =     $maxerrpbRE\n";
                         if ($complexres eq "True") {
                           print $outfile "Max. probability in all eps^$ord subfunctions that stated error of imaginary part is underestimated =$maxerrpbIM\n";
                           print ALLOUT   "Max. probability in all eps^$ord subfunctions that stated error of imaginary part is underestimated =$maxerrpbIM\n";
                         }
                     } else {
                         print $outfile "Max. probability in all eps^$ord subfunctions that stated error is underestimated: not accessible with BASES.\n";
                         print ALLOUT  "Max. probability in all eps^$ord subfunctions that stated error is underestimated: not accessible with BASES.\n";
                     }
		 } else {
		     print $outfile "Time (numerical integration for eps^$ord)  =$serntime s\n";
		     print ALLOUT "Time (numerical integration for eps^$ord)  =$serntime s\n";
		     if ( $integrator ) {
                         my $temp;
                         if ($complexres eq "True") {$temp=" of real part"};
                         print $outfile "Max. probability in eps^$ord that stated error$temp is underestimated =$maxerrpbRE\n";
                         print ALLOUT   "Max. probability in eps^$ord that stated error$temp is underestimated =$maxerrpbRE\n";
                         if ($complexres eq "True") {
                           print $outfile "Max. probability in eps^$ord that stated error of imaginary part is underestimated =$maxerrpbIM\n";
                           print ALLOUT   "Max. probability in eps^$ord that stated error of imaginary part is underestimated =$maxerrpbIM\n";
                         }
                     } else {
                         print $outfile "Max. probability in eps^$ord that stated error is underestimated: not accessible with BASES.\n";
                         print ALLOUT  "Max. probability in eps^$ord that stated error is underestimated: not accessible with BASES.\n";
                     }
		 }
		 close $outfile;
             #if ($plotfile) {
		     $plotout=$paths{"apfp_out_plotfile"} . $ord . ".gpdat";
		     open(PLOT,">>",$plotout);
		     print PLOT "$xplot  $res $err";
		     if ($complexres eq "True") {
			 print PLOT "  $imres  $imerr";
		     }
#		     print PLOT "  $serntime\n";
		     print PLOT "  $totime\n";
		     close PLOT;
             #}
	     }
	     
#    }
     	 }
	 print ALLOUT "***********************************************\n\n";
	 if($indflag==0 || $userdefined==0) {
	     print ALLOUT "Time taken for decomposition = $decotime secs\n\n";
	 } else {
	     print ALLOUT "Total time taken for decomposition = $decotime secs\n";
	     print ALLOUT "Time taken for longest decomposition = $maxdeco secs\n\n";
	 }
	 
# time subexp 
	 for ($iter=0;$iter<$itermax;$iter++) {
	    my $cursec=$Nlist[$iter];
	    my $infofile = paths::decomposeinfo(\%paths,\%hash_varmath,$cursec);
	    
	    my @polestructs;
	    @polestructs=getinfo::contribpolestructs(\%paths,\%params,$infofile,($indflag==1)||($userdefined==1));
	    foreach my $polestruct (@polestructs) {
	     
		if ($userdefined==1) {
		    $polestruct="func${cursec}P$polestruct";
		} elsif ($indflag==1){
		    $polestruct="sec${cursec}P$polestruct";
# 		 $subexplog=$paths{"apfp_out_batchpolelog"} . "sec${cursec}P$polestruct" . ".log";
		}#else{
		$subexplog=$paths{"apfp_out_batchpolelog"} . $polestruct . ".log";
# 	     }
	      $tsubexp=getinfo::subexptime($subexplog);
	      $subexptime=$subexptime+$tsubexp;
		
	      print ALLOUT "Time for subtraction and eps expansion of pole structure $polestruct = $tsubexp secs\n";
	    }
	 }
	 print ALLOUT "\nTotal time for subtraction and eps expansion = $subexptime secs\n";
	 close ALLOUT;
	 print "output written to $resfullf\n";
#	 unless ($texteditor eq "none"){
#	     system("$texteditor $resfullf\&");
#	 }
     }
 } else {
     if($nan>0) {
	 print "Please check onshell conditions and invariants in template/parameter files\n";
	 exit
     }
     print "Error - some integrations not performed/incomplete.\n";
     
     # print a list of results files not found
     if($bigerrcount>0) {
	 print "\nThe following results files were not found:\n\n";
         foreach $errst (@errlist) { print "$errst\n";}
     }
     if($bigerrcount2>0) {
	 print "\nThe following results files were incomplete:\n\n";
	     foreach $errst (@errlist2) { print "$errst\n";}
     }
 }

# sj - warning popresults accesses the global namespace for many varaibles!
sub popresults {
# if statement obsolete because grouping also considered when using togetherflag=1:
#    if(@_){$numintegrations=1;} else {$numintegrations=getinfo::numint("$thisdir/${point}info");}
# sb: the following lines are nowhere needed in the code
#    if (@_ == 2) {
#	$numintegrations = 0; 
#	$sum{$ord} = 0;
#	$imsum{$ord} = 0;
#	$timemax{$ord} = 0;
#	$timesum{$ord} = 0;
#	$errsum{$ord} = 0;
#	$imerrsum{$ord} = 0;
#	$errpmaxRE{$ord} = 0;
#	$errpmaxIM{$ord} = 0;
 #   } else {
        #$resdir=$thisdir;
        #$resdir=~s/$regexdir//;
	$numintegrations=getinfo::numint($thisdir . $paths{"rp_out_filespointinfo"});
	for ($ii=1;$ii<=$numintegrations;$ii++) {
	    $resfile=$thisdir . "${ii}x$point$ord.out"; # sj - warning, building path
	    if($complexres ne "True") {
		#collect purely real results (fortran or cpp w/o contourdef)
		@results=getinfo::results($resfile);
#		
#		foreach $res (@results) {print "res=$res\n";};
		if ($results[0] eq "nofile") {  #if file doesn't exist
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- nofile)    nofile\n";	#print result to resultslogfile
		    $errlist[$bigerrcount]=$resfile;
		    $errlistredo[$bigerrcount]="$thisdir:${point}" . $paths{"rp_out_intfile"} . "$ii.exe"; # sj - warning, hardcoded
		    $bigerrcount++;
		} elsif ($results[0] eq "error") {  #if part of the result is missing in result file
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- $results[1])    $results[3]\n";	#print result to resultslogfile
		    $errlist2[$bigerrcount2]=$resfile;
		    $errlistredo2[$bigerrcount2]="$thisdir:${point}" . $paths{"rp_out_intfile"} . "$ii.exe"; # sj - warning, hardcoded
		    $bigerrcount2++;
		} elsif ( ($results[0] eq "NaN") || ($results[0] eq "nan") ) {
		    print "Integration $ii (of $numintegrations) in $thisdir resulted in NaN.\n";
		    $nan++;
		} else {
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- $results[1])    $results[3]\n";
		    $sum{$ord}=$sum{$ord}+$results[0]*$thismulti;
		    #$interresults=$interresults+$results[0];
		    $num2=$results[1]*$results[1]*$thismulti*$thismulti;
		    $errsum{$ord}=$errsum{$ord}+$num2;
		    $timesum{$ord}=$timesum{$ord}+$results[2];
#             changed by GH 11.1.2016; totalt should not be added cumulatively for each sub-integration contributing to ord
		    $tottime{$ord}=$timesum{$ord};
#		    $totalt=$tottime{$ord};
		    if ($results[2]>$timemax{$ord}) {
			$timemax{$ord}=$results[2];
		    }
		    if ($results[3]>$errpmaxRE{$ord}) {
			$errpmaxRE{$ord}=$results[3];
		    }
#		} else {
#		    $worked{$ord}=$results[3]; #if getting maxerrorprob incomplete:worked is set to "incomplete"                                             
#		}
		}
	    } else { #if contourdef=True
		@results=getinfo::resultsCmplx($resfile); #collect complex results
		if ($results[0] eq "nofile") {   #if file doesn't exist
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- nofile) + (nofile (+- nofile))I    nofile\n"; #print result to resultslogfile
		    $errlist[$bigerrcount]=$resfile;
		    $errlistredo[$bigerrcount]="$thisdir:${point}" . $paths{"rp_out_intfile"} . "$ii.exe"; # sj - warning, hardcoded
		    $bigerrcount++;
		} elsif ( ($results[0] eq "error") || ($results[2] eq "error") ) {  #if part of the result is missing in result file
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- $results[1]) + ($results[2] (+- $results[3]))I    $results[5]\n"; #print result to resultslogfile
		    $errlist2[$bigerrcount2]=$resfile;
		    $errlistredo2[$bigerrcount2]="$thisdir:${point}" . $paths{"rp_out_intfile"} . "$ii.exe"; # sj - warning, hardcoded
		    $bigerrcount2++;
		} elsif ( ($results[0] eq "nan") || ($results[2] eq "nan") ) {
		    print "Integration $ii (of $numintegrations) in $thisdir resulted in nan.\n";
		    $nan++;
		} else {
		    print RESLOG $thisdir . "${ii}x$point$ord.out     $results[0] (+- $results[1]) + ($results[2] (+- $results[3]))I    $results[5]\n";
		    my $REr=$results[0];my $REer=$results[1];
		    my $IMr=$results[2];my $IMer=$results[3];
		    $sum{$ord}=$sum{$ord}+$REr*$thismulti;
		    $imsum{$ord}=$imsum{$ord}+$IMr*$thismulti;
		    #$interresults=$interresults+$results[0];
		    $num=$REer*$REer*$thismulti*$thismulti;
		    $errsum{$ord}=$errsum{$ord}+$num;
		    $num2=$IMer*$IMer*$thismulti*$thismulti;
		    $imerrsum{$ord}=$imerrsum{$ord}+$num2;
		    $timesum{$ord}=$timesum{$ord}+$results[4];
#		    $tottime{$ord}=$timesum{$ord}+$totalt;
#             changed by GH 11.1.2016; totalt should not be added cumulatively for each sub-integration contributing to ord
		    $tottime{$ord}=$timesum{$ord};
#		    $totalt=$tottime{$ord}+$totalt; 
		    #
		    if ($results[4]>$timemax{$ord}) {
			$timemax{$ord}=$results[4];
		    }
		    if ($results[5]>$errpmaxRE{$ord}) {
			$errpmaxRE{$ord}=$results[5];
		    }
		    if ($results[6]>$errpmaxIM{$ord}) {
			$errpmaxIM{$ord}=$results[6];
		    }
		    
		} # end if ($results[0] eq "nofile")
	    } # end if($complexres ne "True") 
	} # end loop over numintegrations
  #  } end if (@_ == 2) {
}
    
