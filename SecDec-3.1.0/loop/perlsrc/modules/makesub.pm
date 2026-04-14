  #****
  #  NAME
  #    makesub.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makesub
  # 
  #  USES 
  #  Arguments parsed by preparenumerics.pl
  #
  #  USED BY 
  #  preparenumerics.pl, writefiles.pm
  #    
  #  PURPOSE
  #  writes the fortran file *subfile.pl in the appropriate subdirectory
  #    
  #  INPUTS
  #  arguements
  #  filename: name of file to be written
  #  jj: order of epsilon
  #  graph: name of graph
  #  polestruct: [i]l[j]h[h] or sec*P[i]l[j]h[h], i logarithmic poles, j linear poles, h higher poles
  #  processlimit: number of jobs to be allowed in the queue at one time
  #  exe: specifies where the process should terminate
  #  scriptdir: where the necessary .pm files are to be found
  #  whichsystem: specifies the batch system to be used
  #  currentdir: path of the subfile.pl being created
  #  clusterflag: =1 if a batch system is used, 0 if run locally
  #    
  #  RESULT
  #  *subfile.pl written to the appropriate subdirectory 
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****
use strict;
use warnings;

use File::Spec;
use Text::Template;

package makesub;

sub go {

my $currentdir=$_[0]; # directory in which to place subfile
my %params = %{$_[1]};
my %paths = %{$_[2]};

my $filename = $currentdir . $paths{"rp_out_subfile"};
my $graph=$params{"graph"};

# Load template for subfile
my $template = Text::Template->new(SOURCE => $paths{"apf_subfile"},
				   DELIMITERS => [ '{[{', '}]}' ])
    or die "Couldn't construct template: $Text::Template::ERROR";

my %templ_vars = (currentdir => $currentdir,
		  paths => \%paths,
		  params => \%params,
    );

my $filled_templ = $template->fill_in(HASH => \%templ_vars);

# write filled template to subfile.pl
open(SUBFILE, ">","$filename") || die "cannot open $filename\n";
print SUBFILE $filled_templ;
close SUBFILE
}

1;
