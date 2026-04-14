  #****p* SecDec/general/perlsrc/getinfo.pm
  #  NAME
  #    getinfo.pm
  #
  #  USAGE
  #  is called by finishnumerics.pl, justnumerics.pl, results.pl, subexp.pl via getinfo::routinename(filename) 
  # 
  #  USES 
  #  various filenames parsed to its subroutines
  #
  #  PURPOSE
  #  collects the subroutines which are used to read various pieces of information from output/intermediate files
  #    
  #  INPUTS
  #  arguments:
  #  infofile/logfile/graphfile/resfile: name of file where required information is held
  #
  #  RESULT
  #  the required piece of information is return from the subroutine
  #    
  #  SEE ALSO
  #  finishnumerics.pl, justnumerics.pl, results.pl, subexp.pl
  #  *Decomposition.log, [i]l[j]h[h].log, *x*.out, graph.m, graphOUT.info
  #   
  #****
  #


package getinfo;



sub poles {
my $infofile=$_[0];
my @infolist=();
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  $a=$_;
  if ($a=~s/polesP(\d*l\d*h\d*) = //g){
   $t=$1;
   $a=~s/,//g;
   $a=~s/}//;
   $a=~s/{//;
   $a=~s/ //g;
   if($a>0){
    push(@infolist,$t)
   }
  }
 }
close INFO;
return @infolist
}

sub poleorders{
my $infofile=$_[0];
my @infolist=();
open (INFO,"<",$infofile);
 while(<INFO>) {
  chomp;
  if($_=~s/"(.+)functions = (.+)"//){
   if ($2 >0){push(@infolist,$1)}
  } 
 }
close INFO;
return @infolist
}

####### BEGIN ###################################################
# get information which functions f*.cc or f*.f
# at certain epsorder are independent of Feynman parameters
sub nbconsts {
    my $infofile=$_[0];
    my $ord=$_[1];
    open (INFO,"<",$infofile);
    while(<INFO>) {
	chomp;
	if($_=~s/"${ord}constants = (.+)"//){ $nbconst=$1; } 
    }
    close INFO;
    return $nbconst
}
####### END ######################################################

sub overallmaxpole {
my $infofile=$_[0];
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/overallmaxpole.*=(.+)//){$overallmaxpole=$1;$overallmaxpole=~s/ //g}; 
 }
close INFO;
return $overallmaxpole
}

sub prefacord {
my $infofile=$_[0];
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/prefacord.*=(.+)//){$prefacord=$1;$prefacord=~s/ //g}; 
 }
close INFO;
return $prefacord
}

   
sub prefac {
my $infofile=$_[0];
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/normalprefac=(.+)//){$defaultpre=$1;$defaultpre=~s/ //g};
 }
close INFO;
return $defaultpre
}

sub dim {
my $graphfile=$_[0];
open (GRAPH,"<",$graphfile);
 while (<GRAPH>){
  chomp;
  if ($_=~s/(?<!\(\*)Dim=(.+)//){$dim=$1;$dim=~s/ //g;$dim=~s/;//g};
 }
close GRAPH;
if($dim eq "4-2eps]"){$dim="4-2*eps"}
return $dim
}

sub numvar {
my $graphfile=$_[0];
open (GRAPH,"<",$graphfile);
 while (<GRAPH>){
  chomp;
  if ($_=~s/nmax=(.+)//){$numvar=$1;$numvar=~s/ //g;$numvar=~s/;//g};
 }
close GRAPH;
return $numvar
}

sub numint {
my $infofile=$_[0];
open (INFO,"<",$infofile);
 while(<INFO>){
  chomp;
  if ($_=~s/Number of integrations = (.+)//){$numint=$1}
 }
close INFO;
return $numint
}

sub results {
    my $resfile=$_[0];
    $r1="error";$r2="error";$r3="error";$r4="incomplete";
    $exist=0;
    if (-e $resfile) { $exist=1 };
    if ($exist) {
	open (RES,"<",$resfile); 
	while (<RES>){
	    chomp;
	    if ($_=~s/result\s+=\s*(-*\w+\.*\w*\+*-*\w*)//){$r1=$1};
	    if ($_=~s/error\s+=\s+(\w+\.*\w*\+*-*\w*)//){$r2=$1};
            if ($_=~s/CPUtime \(s\) =\s+(\w+\.*\w*\+*-*\w*)//){$r3=$1};
            if ($_=~s/MaxErrorprob\s+=\s+(\w+\.*\w*\+*-*\w*)//){$r4=$1};
	}
	close RES;
	if( ($r1 eq "NaN") || ($r1 eq "nan") ) {
#            $r1=~s/NaN/error/;
	    return $r1;
        } else {
            return ($r1,$r2,$r3,$r4);
	}
    } else {
	return "nofile";
    }
}


sub decotime {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 while (<LOG>){
  chomp;
  if (~/Time taken to do the decomposition: (.+) secs/){$decotime=$1}
 }
close LOG;
return $decotime
}

sub validinput {
my $logfile=$_[0];
$valid=1;
open (LOG,"<",$logfile);
 while(<LOG>){
  chomp;
  if($_=~/Please verify your input/){$valid=0}
 }
close LOG;
return $valid
}
sub regulatedsingularity{
my $logfile=$_[0];
$reg=1;
open (LOG,"<",$logfile);
 while(<LOG>){
  chomp;
  if($_=~/Error - some singularities not regulated/){$reg=0}
 }
close LOG;
return $reg
}

sub subexptime {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 while (<LOG>){
  chomp;
  if (~/Total time taken to produce fortran files: (.+) secs/){$subexptime=$1}
 }
close LOG;
return $subexptime
}

1;
