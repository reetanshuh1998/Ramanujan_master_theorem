  #****
  #  NAME
  #    getkinematics.pm
  #
  #  USAGE
  #  use getkinematics 
  # 
  #  USES 
  #  kinematic point and kinematic invariants parsed from kinem.input file
  #
  #  USED BY 
  #  is called by preparenumerics.pl, resultsloop.pl, resultsuserdefined.pl, subexploop.pl, subexpuserdefined.pl  
  #  via getkinematics::routinename(filename)
  #  
  #
  #  PURPOSE
  #  brings all information specific to a certain kinematic set together in a form needed for integration
  #    
  #  INPUTS
  #  getkin:
  #  arguments are symbols for invariants, values for invariants, rescaleflag
  #
  #  RESULT
  #  getkin: 
  #    
  #  SEE ALSO
  #  preparenumerics.pl, resultsloop.pl, 
  #  resultsuserdefined.pl, subexploop.pl, subexpuserdefined.pl 
  #   
  #****
package getkinematics;

use lib "loop/perlsrc/modules";
use dirform;

# new in version 3.0
# originally from multinumericsloop.pl
sub readmultikinem {
my $lockinemfile=$_[0];

# remove empty lines from kinem.input
#my $file = $lockinemfile;
#tie my @notemptylines,'Tie::File',$file or die $!;
#@notemptylines = grep{$_ !~ /^\s*$/}@notemptylines;
#untie @notemptylines;
#(/^#/ /) and 
my $lines=0;
my %hash_varloc = ();
my @array_loc1=();
my @array_blankl=();
my $blanklines=0;
# arrayloc1 contains the lines defining the kinematic points as list elements
open (EREAD,"<".$lockinemfile) || die "cannot open $lockinemfile";
while(<EREAD>) {
    chomp;
    unless ((/^#/)) {
      if (/^\s*$/) {
	$blanklines++; 
      }
      else {
	s/\s+/ /g; 
        push (@array_loc1,dirform::trim($_));
        push (@array_blankl,$blanklines); 
	$lines++;
	$blanklines=0;
      }
    }
}
close EREAD;
if(@array_loc1) { 
$hash_varloc{"points"}=join(';',@array_loc1);
$hash_varloc{"lines"}=$lines;
$hash_varloc{"blanklines"}=join(';',@array_blankl);
#print "number of kinematic points to calculate: $lines\n";
#foreach $el (@array_loc1) {print "el in multinumericsloop=$el\n"; }
}
return %hash_varloc;
}

##########################################################

# Find biggest invariant for rescaling ####
sub findmaxinv {
    my @invariants = @{$_[0]};
    my @kinvalues = @{$_[1]};
    my $locrescaleflag=$_[2];
    my $maxinv = "1.0"; #biggest invariant default
    if ($locrescaleflag) {
	$maxinv=abs biggest(@kinvalues);
	if (is_int($maxinv)) {
	    $p=to_float($maxinv,1);
	    $maxinv=$p;
	}
    }
#    print "maxinv=$maxinv\n";
    return (${maxinv});
}

## only called in userdefined; half done changes; will become obsolete in version 3
sub getkin {
    my @invariants = @{$_[0]};
    my @values = @{$_[1]};
    my $rescaleflag=$_[2];
    my @kinvalues=();
    my $maxinv = "1.0"; #biggest invariant
    #########################################
    # prepare kinematics
    #########################################
    foreach $s (@values) {
	chomp;
	$s=~s/[eE]([+-]?\d+)/*10**$1/g;
	$s=~s/[\^]([+-]?\d+)/**$1/g;
	$sE=eval($s);
	$sE="${sE}";
	push(@kinvalues,$sE);
    }
   # turn all integer numbers into decimal numbers 
    # and store them in a whitespace separated list
#    
   my @allinvariants=separatemasses(@invariants); 
   my @vectorinvariants=@{$allinvariants[0]};   
#    foreach $s (@vectorinvariants) {print "here vectorinvaraints, s=$s\n";} 
   my @masses=@{$allinvariants[1]}; 
#    foreach $s (@masses) {print "here masses, m=$s\n";} 
    my %lorentzhash=hashvalslorentz(@invariants,@values);
    my %masshash=hashvalsmasses(@invariants,@values); 
    my $psqlen =@vectorinvariants; 
    my @ps;
    if ($psqlen){
#	foreach $s (values(%lorentzhash)) {
        for ($i=0;$i<$psqlen;$i++) {
	# be careful, this does not preserve ordering
	$s=$values[$i];
#	foreach $s (@values) {
#	print "sgetkin=$s\n";
	    if (is_int($s)) {
		my $p=to_float($s,1);
		push(@ps,"$p");
	    } else { push(@ps,$s); }
	}
	$psqdefine=join(" ",@ps);
   } else { $psqlen=1; $psqdefine="0.0"; }
    my $msqlen =@masses; my @ms;
    if ($msqlen) { 
#	foreach $s (values(%masshash)) {
        for ($i=$psqlen;$i<$psqlen+$msqlen;$i++) {
	# be careful, this does not preserve orderingf
	$s=$values[$i];
#	print "mgetkin=$s\n";
	    if (is_int($s)) {
		my $m=to_float($s,1);
		push(@ms,"$m");	 
	    } else { push(@ms,$s); }
	}
	$msqdefine=join(" ",@ms);
    } else { $msqlen=1; $msqdefine="0.0"; }
#    
    #### Find biggest invariant for rescaling ####
    if ($rescaleflag) {
	$maxinv=abs biggest(@kinvalues);
	my $p;
	if (is_int($maxinv)) {
	    $p=to_float($maxinv,1);
	    $maxinv="$p";
	}
    }
    return (${maxinv},${psqdefine},${msqdefine});
}

### should be obsolete in version 3; unify treatment of kinematics if integrator math is used
sub getkinformath {
    my @invariants = @{$_[0]};
    my @values = @{$_[1]};
    my $rescaleflag=$_[2];
    my @kinvalues=();
    my $maxinv = "1.0"; #biggest invariant
    foreach $s (@values) {
	chomp;
	$s=~s/[eE]([+-]?\d+)/*10**$1/g;
	$s=~s/[\^]([+-]?\d+)/**$1/g;
	$sE=eval($s);
	$sE="${sE}";
	push(@kinvalues,$sE);
    }
    my $valueslen =@kinvalues; my @ms;
    if ($valueslen) { 
	foreach $s (@kinvalues) {
	    if (is_int($s)) {
		my $m=to_float($s,1);
		push(@ms,"$m");	 
	    } else { push(@ms,$s); }
	}
	$kinvaldefine=join(" ",@ms);
    } else { $valueslen=1; $valuesdefine="0.0"; }
    ########################################
    # Find biggest invariant for rescaling 
    ########################################
    if ($rescaleflag) {
#	$maxinv=abs biggest(@stupoint,@psq,@msq);
	$maxinv=abs biggest(@kinvalues);
	my $p;
	if (is_int($maxinv)) {
	    $p=to_float($maxinv,1);
	    $p=eval($p);
	    $maxinv="$p";
	}
    }
    $maxinv="maxinv=$maxinv";
#    $kininvars="$esdefine;$psqdefine;$msqdefine;$valuesdefine;$maxinv;\n";
    $kininvars="$maxinv;$valuesdefine;\n";
    return $kininvars;
}


sub is_int ($) {
    return unless defined $_[0] && $_[0] ne '';
    return unless $_[0] =~ /^[+-]?\d+$/;
    return 1;
}
sub to_float ($;$) {
    return unless defined $_[0] && $_[0] ne '';
    my ($num) = $_[0] =~ /(([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?)/;
    return unless defined $num;
    my $type = $num =~ /e|E/ ? 'e' : 'f';
#    $_[1] ||= DEF_PRECISION;
    sprintf "%.$_[1]$type", $num;
}
sub dtoe {
    foreach $el (@_){
	$el=~s/[d|D]/e/g
    }
}
sub biggest {
 my $big=0;
 my $pos=-1;
 for(my $count=0;$count<@_;$count++){
     if(abs $_[$count]> abs $big){$pos=$count;$big=$_[$count]}
 }
 return $big
};
1;
