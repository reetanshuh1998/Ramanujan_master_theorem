#
#****s* SecDec/general/multinumerics.pl
#
#  NAME
#  multinumerics.pl
#
#  USAGE
#  ./multinumerics.pl 
# 
#  PURPOSE
#  Automates the calculation of multiple numeric points for a given integrand
#    
#  INPUTS
#  multiparameter file (default is multiparam.input)
#    
#  RESULT    
#  -produces an input file for each specific point 
#  -runs/submits to a batch system the numerical integration for each point 
#  
#  OPTIONS
#  to use a multiparam file with a different name
#  use option "-p multiparamfile" 
#  to specify a different directory to work in
#  use option "-d workingdirectory" 
#  to collect results files (only required when run on the batch system), run with
#   arguement "1"
#  to remove all derived paramfiles, run with the arguement "2", eg
#   ./multinumerics -d demos/ -p multi.input 2
#
# 
#****
use Getopt::Long;
use Tie::File;

GetOptions("parameter=s" => \$multiparam, "dirwork=s"=>\$workingdir);
unless ($multiparam) { $multiparam = "multiparam.input"; }
$mparam=$multiparam;
if($workingdir){
 $workingdir=~s/\/$//;
 $mparam="$workingdir/$multiparam";
 $absdir=1;
}
unless($workingdir){$workingdir=`pwd`;chomp $workingdir}

use lib "perlsrc";
use header;
use getinfo;
use dirform;

my %hash_var=readmultiparams($mparam);
$paramfile=$hash_var{"paramfile"};
$linenumbers=$hash_var{"lines"};
$prefix=$hash_var{"pointname"};
unless($prefix){$prefix="np"};
#print "number of arrays =$linenumbers\n";
@minvals=split(/,/,$hash_var{"minvals"});
@maxvals=split(/,/,$hash_var{"maxvals"});
@stepvals=split(/,/,$hash_var{"stepvals"});
$xplot=$hash_var{"xplot"};
if($xplot){$plotting=1;$xplot=$xplot-1};
$flag=$ARGV[0];
$pointscalculated=0;
if(@minvals && @maxvals && @stepvals){
 $numparams=@minvals;
 $totpoints=1;
 for($i=0;$i<$numparams;$i++){
  $minv=$minvals[$i];
  @tvals=($minv);
  $step=$stepvals[$i];
  $maxv=$maxvals[$i];
  for($j=$minv+$step;$j<$maxv;$j=$j+$step){
   push(@tvals,$j)
  };
  if($maxv>$minv){push(@tvals,$maxv)};
  $nvals[$i]=@tvals;
  $totpoints=$totpoints*$nvals[$i];
  push(@vals,[@tvals]);
 }
 if($flag==2){
  print "removing intermediate parameter files...\n";
 }elsif($flag==1){
  print "$totpoints points to collect results for...\n";
 }else{
  print "$totpoints points to calculate\n";
  system("perl -pi -e 's/^editor=.+/editor=none/g' $workingdir/$paramfile");
 }
 for($k=0;$k<$totpoints;$k++){
  $kt=$k;
  $tstring="values=";
  for($i=0;$i<$numparams;$i++){
   $ktt=$kt%$nvals[$i];
   $tstring="$tstring,$vals[$i][$ktt]";
   if($plotting){if($i==$xplot){$xplotstring="-x $vals[$xplot][$ktt] -f $prefix"}};
   $kt=($kt-$ktt)/$nvals[$i];
  }
  $tstring=~s/,//;
 # $pointname=$tstring;
 # $pointname=~s/values=/pointname=np/;
 # $pointname=~s/,/_/g;
 # $pn=$pointname;
 # $pn=~s/pointname=//;
  $pointscalculated++;
  $pn="$prefix$pointscalculated";
  $pointname="pointname=$pn";
  if($flag==1){
   print "collecting results for $pn...\n";
   `perl results.pl -d $workingdir -p $pn$paramfile $xplotstring`;
  }elsif($flag==2){
   `rm $workingdir/$pn$paramfile`
  }else{
   system("cp $workingdir/$paramfile $workingdir/$pn$paramfile");
   system("perl -pi -e 's/^values=.+/$tstring/g' $workingdir/$pn$paramfile");
   system("perl -pi -e 's/^pointname=.+/$pointname/g' $workingdir/$pn$paramfile");
   print "working on numeric point $pn...\n";
   `perl justnumerics.pl -d $workingdir -p $pn$paramfile $xplotstring`;
  }
 }
 $pointscalculated=$totpoints;
}



if($hash_var{"points"}){
 @points=split(/;/,$hash_var{"points"});
 system("perl -pi -e 's/^editor=.+/editor=none/g' $workingdir/$paramfile");
 $totpoints=@points;
 unless($linenumbers){$linenumbers=$totpoints};
 if($linenumbers<$totpoints){$totpoints=$linenumbers};
  if($flag==2){
  print "removing intermediate parameter files...\n";
 }elsif($flag==1){
  print "$totpoints points to collect results for...\n";
 }else{
  print "$totpoints points to calculate\n";
  system("perl -pi -e 's/^editor=.+/editor=none/g' $workingdir/$paramfile");
 }
 $counter=0; 
  foreach $point (@points){
  if($counter<$totpoints){
   $counter++;
   $pointscalculated++;
   $point=~s/^\./0\./;
   #$pointname="pointname=$prefix$point";
   $pointname="pointname=$prefix$pointscalculated";
   if($plotting){
    @tpoint=split(/,/,$point);
    $xplotstring="-x $tpoint[$xplot] -f $prefix"
   }
   $pointvals="values=$point";
#   $pointname=~s/,/_/g;
   $pn=$pointname;
   $pn=~s/pointname=//;
   if($flag==1){
    print "collecting results for $pn...\n";
    `perl results.pl -d $workingdir -p $pn$paramfile $xplotstring`;
   }elsif($flag==2){
    `rm $workingdir/$pn$paramfile`
   }else{
    system("cp $workingdir/$paramfile $workingdir/$pn$paramfile");
    system("perl -pi -e 's/^values=.+/$pointvals/g' $workingdir/$pn$paramfile");
    system("perl -pi -e 's/^pointname=.+/$pointname/g' $workingdir/$pn$paramfile");
    print "working on numeric point $pn...\n";
    `perl justnumerics.pl -d $workingdir -p $pn$paramfile $xplotstring`;
   }
  }
 }
}

if($hash_var{"values"}){
 @values=split(/;/,$hash_var{"values"});
 $numparams=@values;
 $totpoints=1;
 @vals=();
 for($i=0;$i<$numparams;$i++){
  @tvals=split(/,/,$values[$i]);
  $nvals[$i]=@tvals;
  $totpoints=$totpoints*$nvals[$i];
  push(@vals,[@tvals]);
 }
 if($flag==2){
  print "removing intermediate parameter files...\n";
 }elsif($flag==1){
  print "$totpoints points to collect results for...\n";
 }else{
  print "$totpoints points to calculate\n";
  system("perl -pi -e 's/^editor=.+/editor=none/g' $workingdir/$paramfile");
 }
 for($k=0;$k<$totpoints;$k++){
  $kt=$k;
  $tstring="values=";
  for($i=0;$i<$numparams;$i++){
   $ktt=$kt%$nvals[$i];
   $tstring="$tstring,$vals[$i][$ktt]";
   if($plotting){if($i==$xplot){$xplotstring="-x $vals[$xplot][$ktt] -f $prefix"}};
   $kt=($kt-$ktt)/$nvals[$i];
  }
  $tstring=~s/,//;
#  $pointname=$tstring;
#  $pointname=~s/values=/pointname=np/;
#  $pointname=~s/,/_/g;
#  $pn=$pointname;
#  $pn=~s/pointname=//;
  $pointscalculated++;
  $pn="$prefix$pointscalculated";
  $pointname="pointname=$pn";
  if($flag==1){
   print "collecting results for $pn...\n";
   `perl results.pl -d $workingdir -p $pn$paramfile $xplotstring`;
  }elsif($flag==2){
   `rm $workingdir/$pn$paramfile`
  }else{
   system("cp $workingdir/$paramfile $workingdir/$pn$paramfile");
   system("perl -pi -e 's/^values=.+/$tstring/g' $workingdir/$pn$paramfile");
   system("perl -pi -e 's/^pointname=.+/$pointname/g' $workingdir/$pn$paramfile");   print "working on numeric point $pn...\n";
   `perl justnumerics.pl -d $workingdir -p $pn$paramfile $xplotstring`;
  }
 }
}




sub readmultiparams {
my $locparamfile=$_[0];

# remove empty lines from multiparamfile
my $file = $locparamfile;
tie my @notemptylines,'Tie::File',$file or die $!;
@notemptylines = grep{$_ !~ /^\s*$/}@notemptylines;
untie @notemptylines;

my $lines=0;
my %hash_varloc = ();
my @array_loc1=();
my @array_loc2=();
open (EREAD,$locparamfile) || die "cannot open $locparamfile";
while(<EREAD>) {
    chomp;
    s/^\s+//;
    unless (/^#/) {
	s/\s+//g; 
	if(m/^paramfile=(.*)/i){$hash_varloc{"paramfile"}=$1;
	}elsif(/^lines=\s*(\d+)/){$hash_varloc{"lines"}=$1;
	}elsif(m/^minvals=(.*)/i){$hash_varloc{"minvals"}=$1;
	}elsif(m/^maxvals=(.*)/i){$hash_varloc{"maxvals"}=$1;
	}elsif(m/^stepvals=(.*)/i){$hash_varloc{"stepvals"}=$1;
	}elsif(m/^xplot=(.*)/i){$hash_varloc{"xplot"}=$1;
	}elsif(m/^values.*=(.*)/i){push (@array_loc2,$1);
	}elsif(m/^pointname=(.*)/i){$hash_varloc{"pointname"}=$1;
	}elsif(m/=/i){print "Warning - invalid assignment $_ in $locparamfile\n";
	}else{push (@array_loc1,$_);}
    }
}
if(@array_loc1){$hash_varloc{"points"}=join(';',@array_loc1)};
if(@array_loc2){$hash_varloc{"values"}=join(';',@array_loc2)};
return %hash_varloc;
}

 
