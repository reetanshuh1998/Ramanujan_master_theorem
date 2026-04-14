  #****
  #  NAME
  #    getinfo.pm
  #
  #  USAGE
  #  use getinfo 
  # 
  #  USES 
  #  various filenames parsed to its subroutines
  #
  #  USED BY 
  #  is called by finishnumericsloop.pl, finishnumericsuserdefined.pl, justnumericsloop.pl, justnumericsuserdefined.pl, 
  #  multinumerics*.pl, resultsloop.pl, resultsuserdefined.pl, subexploop.pl, subexpuserdefined.pl 
  #  via getinfo::routinename(filename)
  #  
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
  #  finishnumericsloop.pl, finishnumericsuserdefined.pl, justnumericsloop.pl, justnumericsuserdefined.pl, resultsloop.pl, 
  #  resultsuserdefined.pl, subexploop.pl, subexpuserdefined.pl, *Decomposition.log, [i]l[j]h[h].log, *x*.out, graph.m, 
  #  graphOUT.info
  #   
  #****
use strict;
use warnings;

use dirform;

package getinfo;

# returns the epsorder to which we should be working internally (for subexpand)
sub internalepsorder {
    my %paths  = %{ $_[0] };
    my %params = %{ $_[1] };
    my $infofile = $_[2];
    
    my $iepsord=$params{"epsord"};
    my $prefacord=getinfo::prefacord($infofile);
    my $mindegree=getinfo::mindegree($infofile);
    
    #if ( $prefacord<0 ){ $iepsord=$iepsord-$prefacord; } # sj - do we need <0 ?
    #if ( $mindegree<0 ){ $iepsord=$iepsord-$mindegree; } # sj - do we need <0 ?
    $iepsord=$iepsord-$prefacord;
    $iepsord=$iepsord-$mindegree;
    
    #print "internalepsorder\n";
    #print "epsord " . $params{"epsord"} . "\n";
    #print "iepsord " . $iepsord . "\n";
    #print "prefacord " . $prefacord . "\n";
    #print "mindegree " . $mindegree . "\n";
    #print "\n";
    
    return $iepsord;
}

# returns a list of polestructs which exist after numerics
# Either
# - contribpolestructs
# - together
sub numericpolestructs {
    my %paths  = %{ $_[0] };
    my %params = %{ $_[1] };
    my $infofile = $_[2];
    my $indflag = $_[3]; #optional

    my @npolestructs;
    
    if ( $params{"together"} == 1 ) {
        push(@npolestructs,"together");
    } else {
	if ($params{"mode"}==1) {
	    @npolestructs = reverse getinfo::contribpolestructs(\%paths,\%params,$infofile,$params{"mode"});
	} else {
	    @npolestructs = reverse getinfo::contribpolestructs(\%paths,\%params,$infofile,$indflag);
	}
    }
    
    return @npolestructs;
}

# returns a list of polestructs which contribute to the internal epsorder
sub contribpolestructs {
    my %paths  = %{ $_[0] };
    my %params = %{ $_[1] };
    my $infofile = $_[2];
    my $indflag = $_[3]; #optional
    
    my $iepsord=getinfo::internalepsorder(\%paths,\%params,$infofile);
    my @polestructs=getinfo::polestructs($infofile,$indflag);
    
    my @cpolestructs;
    foreach my $polestruct ( @polestructs) {
        my ($i,$j,$h) = getinfo::polestructpoles($polestruct);
        
        # if numerator contains negative orders in epsilon, these must be added
        # (if order is negative, corresponds to subtraction) to the minpole $minp
        my $mindegree=getinfo::mindegree($infofile);
        my $minp=-$i-$j-$h+$mindegree;
        
        #if ($i+$j+$h>=-$iepsord) { # sj - should be $minp <= $epsord ?
        if ($minp <= $iepsord) { # sj - should this be iepsord or epsord? should minp have mindegree added to it?
            unshift(@cpolestructs,$polestruct);
        }
    }
    return @cpolestructs;
}

# Returns an array of polestructs from (decompose) infofile
sub polestructs {
    my $infofile=$_[0];
    my $indflag=$_[1]; #optional
    my @polestructs=();
    if ( -e $infofile) {
        open (INFO,"<",$infofile);
        while (my $line = <INFO>){
            chomp $line;
	    if($indflag){
		$line =~ s/polesP(\d*l\d*h\d*) = (\d*)//g; # search for polesP<polestruct> = int
		if (($1)&&($2!=0)) { # check that int != 0
		    push(@polestructs,$1);
		}
	    }else{
		$line =~ s/polesP(\d*l\d*h\d*) = //g; # search for polesP<polestruct>
		if ($1) {
		    push(@polestructs,$1);
		}
	    }
        }
        close INFO;
        return @polestructs
    } else {
        die "Decompose infofile " . $infofile . " does not exist";
    }
}


# Returns a list of poles from a polestruct
sub polestructpoles {
    my $polestruct=$_[0];
    my @poles = $polestruct=~/(\d+)l(\d+)h(\d+)/; # <i>l<j>h<h>
    if ( @poles != 3) {
        die "Inadmissible polestruct encountered: " . $polestruct . "\n";
    }
    return ($poles[0],$poles[1],$poles[2]);
}

# Returns a list of eps orders from (subexpand) infofile
sub epsords {
    my $infofile=$_[0];
    my @epsords=();
    if ( -e $infofile ) {
        open (INFO,"<",$infofile);
        while (my $line = <INFO>){
            chomp $line;
            $line =~ s/(-*\d*)functions = (\d*)//g; # search for <epsord>functions =
            if ($2) {
                if ($2 >0) { # more than 0 functions of that order
                    push(@epsords,$1);
                }
            }
        }
        close INFO;
        return @epsords
    } else {
        die "Infofile " . $infofile . " does not exist";
    }
}

##################################################################
# get the total number of sectors found in decomposition
##################################################################
sub allcount {
    my $infofile=$_[0];
    my $allcount;
    open (INFO,"<",$infofile);
    while(<INFO>) {
        chomp;
        if($_=~s/allcount = (.+)//){ $allcount=$1; }
    }
    close INFO;
    return $allcount
}

###################################################
# get groupcount number on the fly for usage with
# multinumerics*.pl
###################################################
sub getgroup {
    my $infofile=$_[0];
    my $group;
    open (INFO,"<",$infofile);
    while(<INFO>) {
	chomp;
	if($_=~s/Number of integrations = (.+)//){ $group=$1; } 
    }
    close INFO;
    return $group
}

###########################################################
# get information which functions f*.cc or f*.f
# at certain epsorder are independent of Feynman parameters
###########################################################
sub nbconsts {
    my $infofile=$_[0];
    my $ord=$_[1];
    my $nbconst;
    open (INFO,"<",$infofile);
    while(<INFO>) {
	chomp;
	if($_=~s/"${ord}constants = (.+)"//){ $nbconst=$1; } 
    }
    close INFO;
    return $nbconst
}

##################################################################
# get the minimal degree in epsilon computed during the analytical
# step in Mathematica and written to the .info file. This is only
# crucial in case the numerator contains additional orders in 
# epsilon.
##################################################################
sub mindegree {
    my $infofile=$_[0];
    my $mindeg;
    open (INFO,"<",$infofile);
    while(<INFO>) {
	chomp;
	if($_=~s/mindegree = (.+)//){ $mindeg=$1; } 
    }
    close INFO;
    return $mindeg
}

##################################################################
# get the maximal degree in epsilon computed during the analytical
# step in Mathematica and written to the .info file. This is only
# crucial in case the numerator contains additional orders in 
# epsilon.
##################################################################
sub maxdegree {
    my $infofile=$_[0];
    my $maxdeg;
    open (INFO,"<",$infofile);
    while(<INFO>) {
	chomp;
	if($_=~s/maxdegree = (.+)//){ $maxdeg=$1; } 
    }
    close INFO;
    return $maxdeg
}

sub overallmaxpole {
my $infofile=$_[0];
    my $overallmaxpole;
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/^overallmaxpole.*=(.+)//){$overallmaxpole=$1;$overallmaxpole=~s/ //g}; 
 }
close INFO;
return $overallmaxpole
}

sub prefacord {
my $infofile=$_[0];
    my $prefacord;
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/^prefacord =(.+)//){$prefacord=$1;$prefacord=~s/ //g}; 
 }
close INFO;
return $prefacord
}

   
sub prefac {
my $infofile=$_[0];
    my $defaultpre;
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/^prefac =(.+)//){$defaultpre=$1;$defaultpre=~s/ //g};
 }
close INFO;
return $defaultpre
}

# Returns a list of expu and expf from infofile
# expu = exponent of U
# expf = exponent of F
# - Removes whitespace
# - Replaces / with \/
#sub expfu {
#my $infofile=$_[0];
#    my $expu;
#    my $expf;
#open (INFO,"<",$infofile);
# while (<INFO>){
#  chomp;
#     if ($_=~s/expoU =(.+)//){$expu=$1;$expu=~s/ //g;$expu=~s/\//\\\//g;};
#     if ($_=~s/expoF =(.+)//){$expf=$1;$expf=~s/ //g;$expf=~s/\//\\\//g;};
# }
#close INFO;
#return ($expu,$expf)
#}

sub lengthprimseclist {
my $infofile=$_[0];
    my $lengthprimseclist;
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/^lengthprimseclist =(.+)//){$lengthprimseclist=$1;$lengthprimseclist=~s/ //g};
 }
close INFO;
return $lengthprimseclist
}


sub dim {
my $graphfile=$_[0];
    my $dim;
open (GRAPH,"<",$graphfile);
 while (<GRAPH>){
  chomp;
  if ($_=~s/(?<!\(\*)Dim=(.+)//){$dim=$1;$dim=~s/ //g;$dim=~s/\]?;//g;last};
 }
close GRAPH;
if($dim eq "4-2eps]"){$dim="4-2*eps"}
return $dim
}

sub numint {
my $infofile=$_[0];
my $numint=0;
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
    my $r1="error";my $r2="error";my $r3="error";my $r4="incomplete";
    my $exist=0;
    if(-e $resfile){$exist=1};
    if($exist){
	open (RES,"<",$resfile); 
	while (<RES>){
	    chomp;
	    if ($_=~s/result\s+=\s*(-*\w+\.*\w*\+*-*\w*)//){$r1=$1};
	    if ($_=~s/error\s+=\s+(\w+\.*\w*\+*-*\w*)//){$r2=$1};
	    if ($_=~s/Time \(s\) =\s+(\w+\.*\w*\+*-*\w*)//){$r3=$1};
	    if ($_=~s/MaxErrorprob\s+=\s+(\w+\.*\w*\+*-*\w*)//){$r4=$1};
	}
	close RES;
	if( ($r1 eq "NaN") || ($r1 eq "nan") ) {
	    return $r1;
	} else {
	    return ($r1,$r2,$r3,$r4);
	}
    } else {
	return "nofile";
    }
}

sub resultsCmplx {
    my $resfile=$_[0];
    my $r1="error";my $r2="error";my $r3="error";my $r4="error";my $r5="error"; my $r6="incomplete"; my $r7="incomplete";
    my $exist=0;
    if(-e $resfile){$exist=1};
    if($exist){
	open (RES,"<",$resfile); 
	while (<RES>){
	    chomp;
	    if ($_=~s/result\s+=\s*(-*\w+\.*\w*\+*-*\w*)//){if($r1 eq "error"){$r1=$1}else{$r3=$1}};
	    if ($_=~s/error\s+=\s+(\w+\.*\w*\+*-*\w*)//){if($r2 eq "error"){$r2=$1}else{$r4=$1}};
	    if ($_=~s/Time \(s\) =\s+(\w+\.*\w*\+*-*\w*)//){$r5=$1};
	    if ($_=~s/errorprob\s+=\s+(\w+\.*\w*\+*-*\w*)//){if($r6 eq "incomplete"){$r6=$1}else{$r7=$1}};
	}
	close RES;
	if($r1 eq "nan"){
	    return $r1;
	} else {
	    return ($r1,$r2,$r3,$r4,$r5,$r6,$r7);
	}
    } else {
	return "nofile";
    }
}

sub decotime {
my $logfile=$_[0];
    my $decotime;
open (LOG,"<",$logfile);
 while (<LOG>){
  chomp;
  if (~/Time taken to do the decomposition: (.+) secs/){$decotime=$1}
 }
close LOG;
return $decotime
}

sub subexptime {
my $logfile=$_[0];
my $subexptime;
open (LOG,"<",$logfile);
 while (<LOG>){
  chomp;
  if (~/Total time taken to produce .+ files: (.+) secs/){$subexptime=$1}
 }
close LOG;
return $subexptime
}

# returns 1 if logfile contains warning that parameters can 
# be factored out, see makeFU.pl for more info 
sub factorizecheck {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 my $flag=0;
 while (<LOG>){
  chomp;
  if($_=~/factored into/){$flag=1}
 }
close LOG;
return $flag
}

# returns 1 if logfile contains warning after signcheck failed.
# see decomposeloop.pl for more info 
sub signcheck {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 my $flag=0;
 while (<LOG>){
  chomp;
  if($_=~/semi\-definite/){$flag=1}
 }
close LOG;
return $flag
}

# returns 1 if logfile contains warning that F[z] is zero
# see decomposeloop.pl for more info 
sub decF0warning {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 my $flag=0;
 while (<LOG>){
  chomp;
  if($_=~/Warning, F\[z\]\=0/){$flag=1}
 }
close LOG;
return $flag
}

# returns 1 if logfile contains warning after F[z] turned
# out to be a monomial. See decomposeloop.pl for more info 
sub monomial {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 my $flag=0;
 while (<LOG>){
  chomp;
  if($_=~/monomial/){$flag=1}
 }
close LOG;
return $flag
}

# returns 1 if logfile states that F[z] has just one
# scale. See decomposeloop.pl for more info 
sub onescale {
my $logfile=$_[0];
open (LOG,"<",$logfile);
 my $flag=0;
 while (<LOG>){
  chomp;
  if($_=~/scale/){$flag=1}
 }
close LOG;
return $flag
}

#######################################
# returns threshold inserted into the 
# templatefile by the user
sub getthres {
my $infofile=$_[0];
    my $thresh;
open (INFO,"<",$infofile);
 while (<INFO>){
  chomp;
  if ($_=~s/^threshold =(.+)//){$thresh=$1;$thresh=~s/ //g};
 }
close INFO;
$thresh=~s/em\((\d)\)/em\[$1\]/g;
$thresh=~s/es\((\d)\)/es\[$1\]/g;
$thresh=~s/esx\((\d)\)/esx\[$1\]/g;

$thresh=~s/\*\^/e/g;
$thresh=~s/\(/\\(/g;
$thresh=~s/\)/\\)/g;
$thresh=~s/\[/\\[/g;
$thresh=~s/\]/\\]/g;
$thresh=~s/\*/\\*/g;
$thresh=~s/\//\\\//g;
$thresh=~s/\+/\\+/g;
$thresh=~s/\-/\\-/g;
$thresh=~s/\>/\\>/g;
$thresh=~s/\</\\</g;
$thresh=~s/\=/\\=/g;

return $thresh
}

1;
