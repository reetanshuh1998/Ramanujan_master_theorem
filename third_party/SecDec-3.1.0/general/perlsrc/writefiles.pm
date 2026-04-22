  #****p* SecDec/general/perlsrc/writefiles.pm
  #  NAME
  #    writefiles.pm
  #
  #  USAGE
  #  use writefiles
  # 
  #  USES 
  #  makeint.pm, makemake.pm, makesum.pm, makejob.pm, makemakerun.pm, makesum.pm
  #
  #  USED BY 
  #  preparenumerics.pm  
  #
  #  PURPOSE
  #  collects the subroutines which are used to write intermediate files into one place
  #    
  #  INPUTS
  #  various arguements for the subroutines called from preparenumerics.pl
  #
  #  RESULT
  #  subroutines can now be used by preparenumerics.pl
  #    
  #  SEE ALSO
  #  preparenumerics.pl, makeint.pm, makemake.pm, makesum.pm, makejob.pm, makemakerun.pm, makesum.pm
  #   
  #****
  #

use strict;
use lib "perlsrc";
use makeint;
use makemake;
use makesum;
use makejob;
use makemakerun;
use makesub;
package writefiles;

sub makeint {
makeint::go(@_)
};
sub makemake {
makemake::go(@_)
};
sub makesum {
makesum::go(@_)
};
sub makejob {
makejob::go(@_)
};
sub makemakerun {
makemakerun::go(@_)
};
sub makesub {
makesub::go(@_)
};
1;

