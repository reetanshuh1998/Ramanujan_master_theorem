  #****p* SecDec/general/perlsrc/launchjob.pm
  #  NAME
  #    launchjob.pm
  #
  #  USAGE
  #  is called by subexp.pl, justnumerics.pl, polenumerics.pl, finishnumerics.pl, *subfile.pl
  # 
  #  USES 
  #  arguements parsed to submit
  #
  #  USED BY 
  #  subexp.pl, justnumerics.pl, polenumerics.pl, finishnumerics.pl, *subfile.pl
  #
  #  PURPOSE
  #  Uses appropriate syntax to submit a job to the desired batch system 
  #    
  #  INPUTS
  #  arguments:
  #  whichsystem: specifies which batch system is to be used
  #  jobfile: name of file to be submitted
  #
  #  RESULT
  #  subroutines can now be used by preparenumerics.pl
  #    
  #  SEE ALSO
  #  subexp.pl, justnumerics.pl, polenumerics.pl, finishnumerics.pl, *subfile.pl
  #****
  #

use strict;
package launchjob;

sub submit {
my $whichsystem=$_[0];
my $jobfile=$_[1];
if ($whichsystem==0){
submitdefault($jobfile)
} else {
submituserdefined($jobfile)
}
};

sub submitdefault {
my $jobfile=$_[0];
system("qsub -z $jobfile")
};


sub submituserdefined {
my $jobfile=$_[0];
##################################################
######### insert your own syntax here ############
##################################################
};
1;
