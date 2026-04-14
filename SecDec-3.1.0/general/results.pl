#
  #****s* SecDec/general/results.pl
  #  NAME
  #    results.pl
  #
  #  USAGE
  #  ./results.pl or from launch or finishnumerics.pl
  # 
  #  USES 
  #  $paramfile, header.pm, getinfo.pm, dirform.pm *x*.out in the leaf directories, 
  #
  #  USED BY 
  #  launch, finishnumerics.pl
  #  PURPOSE
  #  collects all the completed .out files and sums them appropriately
  #  to form an order by order result for the numerical point in question.
  #  If any necessary outputs are absent results.pl flags this up
  #    
  #  INPUTS
  #  $paramfile (default is param.input) read via module header
  #  @results = (result error timetaken) for each *x*.out file.
  #  parameters parsed via ARGV:
  #  dores: flag to indicate whether results.pl was called from launch or not.    
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
  #  to use a param.input file with a different name
  #  use option "-p paramfile" 
  #  to specify a different directory to work in
  #  use option "-d workingdirectory" 
  #  
  #  SEE ALSO
  #  launch, finishnumerics.pl
  #   
  #****
  #

use Getopt::Long;

GetOptions("parameter=s" => \$paramfile, "template=s"=>\$templatefile, "dirwork=s"=>\$workingdir, "xplot=s"=>\$xplot,"file=s"=>\$plotfile);
unless ($paramfile) { $paramfile = "param.input"; }
$wdstring="";
$wparamfile=$paramfile;
if($workingdir) { $workingdir=~s/\/$//;$wparamfile="$workingdir/$paramfile";$wdstring="-d=$workingdir " };

use lib "perlsrc";
use Fraction ':constants';
use header;
use getinfo;
use dirform;

my %hash_var=header::readparams($wparamfile);

$dirbase=`pwd`;
chomp $dirbase;
$subdir=$hash_var{"diry"};
$diry=dirform::norm("${dirbase}/$subdir");
$currentdir=$hash_var{"currentdir"};
$graph=$hash_var{"graph"};
$routine=$hash_var{"integrator"};

unless ($currentdir) {
    if($workingdir){
	if ($workingdir=~m/^\//){
	    $diry=dirform::norm("$workingdir/$subdir");
	    $currentdir="$diry/$graph";
	} else {
	    $subdir="$workingdir/$subdir";
	    $diry=dirform::norm("${dirbase}/$subdir");
	    $currentdir="$diry/$graph"
	}
    } else {
	$currentdir="$diry/$graph"
    }
}
$point=$hash_var{"pointname"};
unless ($point) {$point=""};
@oldreslog=glob "$currentdir/${point}results*log";
foreach $oldlogfile (@oldreslog){
 system("rm $oldlogfile")
};
$maxvar=getinfo::numvar("$currentdir/$graph.m");
$epsord=$hash_var{"epsord"};
$infofile="$currentdir/${graph}OUT.info";
$prefacord=getinfo::prefacord($infofile);
$texteditor=$hash_var{"editor"};
$exe=$hash_var{"exe"};
$clusterflag=$hash_var{"clusterflag"};
unless ($texteditor) {$texteditor="none"};
$dores=$ARGV[0];
$doresflag=1;
if ($dores eq "launch") {
 $doresflag=0;
 if ($clusterflag==0) {
  if ($exe==4) {
   if($indflag==0){$doresflag=1}
  }
 }
}
$valid=getinfo::validinput("$currentdir/${graph}Decomposition.log");
if($valid==0){
 if($dores eq "launch"){
  exit
 } else {
  die "Decomposition was not performed successfully\nPlease verify your inputs - undefined parameters detected\n"
 }
}
if($doresflag==0){
 exit
};

@comparlist=split(/,/,$hash_var{"symbconstants"});

my @comparvalsM=split(/,/,$hash_var{"pointvalues"});
my @comparvals=();

foreach $s (@comparvalsM) {
    chomp;
    $s=~s/[eE]([+-]?\d+)/*10**$1/g;
    $s=~s/[\^]([+-]?\d+)/**$1/g;
    $sE=eval($s);
    push(@comparvals,$sE);
}

if(@comparlist) {
 if(@comparvals) {
     $complen=@comparlist;
     $complen2=@comparvals;
     if($complen2<$complen){
	 if($dores ne "launch"){
	     die "Need to specify numerical values for parameters in $paramfile\n";
	 } else {
	     exit;
	 }
     } elsif($complen2>$complen) {
	 if($fromlaunch ne "launch") { print "Warning - number of parameters < number of values specified. Additional values ignored\n"; }
     }
 } else {
     if ($dores ne "launch"){
	 die "Need to specify numerical values for parameters in $paramfile\n";
     } else {
	 exit;
     }
 }
} else {
    if(@comparvals) {
	if($fromlaunch ne "launch") { print "Warning - number of parameters < number of values specified. Additional values ignored\n"; }
    }
}
if(@comparlist) {
    $assparstring="";
    $compnum=0;
    foreach $par (@comparlist) {
	$assparstring="$assparstring, $par=$comparvals[$compnum]";
	$compnum++;
    }
    $assparstring=~s/, //
}
$nan=0;
$regexdir=dirform::regex($currentdir);
$regexdir="$regexdir\\/";
$regexdirbase=dirform::regex($dirbase);
$regexdirbase="$regexdirbase\\/";
for ($ord=-$maxvar+$prefacord;$ord<=$epsord;$ord++) {
    $sum{$ord}=0;
    $errsum{$ord}=0;
    $timesum{$ord}=0;
    $timemax{$ord}=0;
    $errpmax{$ord}=0; #maximal error probability                                                                                            
#    $worked{$ord}="worked"; #dummy variable to check if error prob can be displayed properly
};
$subexptime=0;
$decotime=0;
$maxsub=0;
$maxdeco=0;
$bigerrcount=0;
$bigerrcount2=0;
$notdoneflag=0;
$infofile="$currentdir/${graph}OUT.info";
$declog="$currentdir/${graph}Decomposition.log";
$decotime=getinfo::decotime($declog);
$togetherflag=$hash_var{"together"};
@polelist=getinfo::poles($infofile);
if($togetherflag==0) {
 foreach (@polelist){
  $polestruct=$_;
  if ($polestruct=~/(\d+)l(\d+)h(\d+)/){$i=$1;$j=$2;$h=$3};
  if ($i+$j+$h>=-$epsord+$prefacord) {
   $logflag=0;
   $subexplog="$currentdir/$polestruct.log";
   if (-e $subexplog) {$logflag=1};
   if ($logflag==1) {
    $tsubexp=getinfo::subexptime($subexplog);
    $subexptime=$subexptime+$tsubexp;
    if($maxsub<$tsubexp){$maxsub=$tsubexp};
    $minpole=-$j-$i-$h;
    $poledir="$currentdir/$polestruct";
    @poleorders=getinfo::poleorders("$poledir/infofile");
    foreach $ord (@poleorders){
     if ($ord<=$epsord){
	 open (RESLOG,">>","$currentdir/${point}results$ord.log");
	 unless (-s RESLOG) {
	     print RESLOG "OUTPUT: $graph $point\n";
	     print RESLOG "point: $assparstring\n";
	     print RESLOG "# file name \t result real part (+- error) \t ";
	     print RESLOG "maximal error probability\n";
	 }
	 $thisdir="$poledir/epstothe$ord";
	 popresults();
	 close RESLOG;
     }
    }
   } else {
    print "Warning - pole structure $polestruct has not been executed.\n";
    print "Execute $currentdir/batch$polestruct,\nor submit $currentdir/job$polestruct to the batch system.\n"; 
    $notdoneflag=1;
   }
  }
 }
} else {
 $poledir="$currentdir/together";
 @poleorders=getinfo::poleorders("$poledir/infofile");
 $thismulti=1;
 foreach $ord (@poleorders){
  if ($timesum{$ord}==0){
   if ($ord<=$epsord){
    $thisdir="$poledir/epstothe$ord";
    popresults(1)
   }
  }
 }
 foreach $polestruct (@polelist){
  $tsubexp=getinfo::subexptime("$currentdir/$polestruct.log");
  $subexptime=$subexptime+$tsubexp;
  if($maxsub<$tsubexp){$maxsub=$tsubexp};
 }
}  
     
if ($bigerrcount+$bigerrcount2+$nan==0) {
 if ($notdoneflag==0) {
  open (ALLOUT,">","$currentdir/${graph}_${point}full.res");
  print ALLOUT "***********************************************\n";
  print ALLOUT "***OUTPUT: $graph $point ***************\n";
  print ALLOUT " point: $assparstring\n";
  print ALLOUT "***********************************************\n";
  print ALLOUT "\n";
  for ($ord=-$maxvar+$prefacord;$ord<=$epsord;$ord++) {
   if ($sum{$ord} != 0){
    $res=$sum{$ord};
    $err=sqrt $errsum{$ord};
    if ($notdoneflag==0) {
     open($outfile, ">", "$currentdir/${graph}_${point}epstothe$ord.res");
     print $outfile "***********************************************\n";
     print $outfile "***OUTPUT: $graph $point eps\^$ord coeff***\n";
     print ALLOUT "\n****** eps\^$ord coeff ******\n\n";
     print $outfile " point: $assparstring\n";
     print $outfile "***********************************************\n";
     print $outfile "\n";
     print $outfile "\n";
     print $outfile "result       =$res\n";
     print ALLOUT "result       =$res\n";
     print $outfile "error        =$err\n";
     print ALLOUT "error        =$err\n";
     if($togetherflag==0){
	 print $outfile "CPUtime (all eps^$ord subfunctions)  =$timesum{$ord}\n";
	 print ALLOUT "CPUtime (all eps^$ord subfunctions)  =$timesum{$ord}\n";
	 print $outfile "CPUtime (longest eps^$ord subfunction)  =$timemax{$ord}\n";
	 print ALLOUT "CPUtime (longest eps^$ord subfunction)  =$timemax{$ord}\n\n";
	 if ( $routine ) {
	     print $outfile "Max. probability in all eps^$ord subfunctions that stated error is underestimated =$maxerrpb{$ord}\n";
	     print ALLOUT  "Max. probability in all eps^$ord subfunctions that stated error is underestimated =$maxerrpb{$ord}\n";
	 } else {
	     print $outfile "Max. probability in all eps^$ord subfunctions that stated error is underestimated: not accessible with BASES.\n";
	     print ALLOUT  "Max. probability in all eps^$ord subfunctions that stated error is underestimated: not accessible with BASES.\n";
	 }
     } else {
	 print $outfile "CPUtime (numerical integration for eps^$ord)  =$timesum{$ord}\n";
	 print ALLOUT "CPUtime (numerical integration for eps^$ord)  =$timesum{$ord}\n";
	 if ( $routine ) {
	     print $outfile "Max. probability in eps^$ord that stated error is underestimated =$maxerrpb{$ord}\n";
	     print ALLOUT  "Max. probability in eps^$ord that stated error is underestimated =$maxerrpb{$ord}\n";
	 } else {
	     print $outfile "Max. probability in eps^$ord that stated error is underestimated: not accessible with BASES.\n";
	     print ALLOUT  "Max. probability in eps^$ord that stated error is underestimated: not accessible with BASES.\n";
	 }
     }
     close $outfile;
     if($plotfile){
	 $plotout="$currentdir/$plotfile$ord.gpdat";
	 open(PLOT,">>",$plotout);
	 print PLOT "      $xplot  $res $err";
	 #  if(language ne "fortran"){
	 #   print PLOT "  $imres  $imerr";
	 #  };
	 print PLOT "  $serntime\n";
	 close PLOT;
     }
    }
   }
  }
  print ALLOUT "***********************************************\n\n";
  print ALLOUT "Time taken for decomposition = $decotime secs\n\n";
  print ALLOUT "Total time for subtraction and eps expansion = $subexptime secs\n";
  unless($maxsub==$subexptime){print ALLOUT "Time taken for longest subtraction and eps expansion = $maxsub secs\n"};
  close ALLOUT;
   print "result written to $currentdir/${graph}_${point}full.res\n";
   print "\n";
  unless ($texteditor eq "none"){
   system("$texteditor $currentdir/${graph}_${point}full.res\&")
  }
  print "To remove intermediate files, execute the command $currentdir/makeclean\n";
 }
} else {
  if($nan>0){
   print "Please check values of symbolic parameters in $paramfile\n";
   exit
  }
  print "Error - some integrations not performed/incomplete.\n";
  if($bigerrcount>0){
   print "\nThe following results files were not found:\n\n";
   foreach $errst (@errlist){print "$errst\n"}
  }
  if($bigerrcount2>0){
   print "\nThe following results files were incomplete:\n\n";
   foreach $errst (@errlist2){print "$errst\n"}
  }
}





sub popresults {
 if(@_){$numintegrations=1;$poptogflag=1;}else{$numintegrations=getinfo::numint("$thisdir/${point}info")};
 $resdir=$thisdir;
 $resdir=~s/$regexdir//;
 for ($ii=1;$ii<=$numintegrations;$ii++){
  $resfile="$thisdir/${ii}x$point$ord.out";
  @results=getinfo::results($resfile);
  if ($results[0] eq "nofile") {
   $errlist[$bigerrcount]=$resfile;
   $bigerrcount++;
  } elsif ($results[0] eq "error") {
      print RESLOG "$resdir/${ii}x$point$ord.out     $results[0] (+- $results[1])     $results[3]\n"; #print result to resultslogfile 
      $errlist2[$bigerrcount2]=$resfile;
      $bigerrcount2++;
  } elsif( ($results[0] eq "NaN") || ($results[0] eq "nan")) {
      print "Integration $ii (of $numintegrations) in $thisdir resulted in NaN.\n";
      $nan++;
  } else {
      if($poptoflag){
	  $sum{$ord}=$results[0];
	  $num2=$results[1]*$results[1];
	  $errsum{$ord}=$num2;
	  $timesum{$ord}=$results[2];
      } else {
	  print RESLOG "$resdir/${ii}x$point$ord.out     $results[0] (+- $results[1])     $results[3]\n";
	  $sum{$ord}=$sum{$ord}+$results[0];
	  $num2=$results[1]*$results[1];
	  $errsum{$ord}=$errsum{$ord}+$num2;
	  $timesum{$ord}=$timesum{$ord}+$results[2];
      }
      if ($results[2]>$timemax{$ord}) {
	  $timemax{$ord}=$results[2]
      }
#      if ($results[3] ne "incomplete"){
      if ($results[3]>$errpmax{$ord}) {
	  $errpmax{$ord}=$results[3];
      }
#      } else {
#	  $worked{$ord}=$results[3]; #if getting maxerrorprob incomplete:worked is set to incomplete                                      \
#      }
#      if ( $worked{$ord} ne "incomplete" ) {
      if ( $errpmax{$ord} != 1 ) {
	  $maxerrpb{$ord}=$errpmax{$ord};
      } else { $maxerrpb{$ord}="$errpmax{$ord}\nReason: Integration had too few samples or result(s) were not found."; }
  }
 }
}
