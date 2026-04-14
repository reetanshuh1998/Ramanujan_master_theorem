use strict;
use warnings;

use lib "loop/perlsrc/modules";
use Text::Template;

package makeintmath;

sub go {
 my $minfuncno=$_[0];
 my $maxfuncno=$_[1];
 my $epsord=$_[2];
 my $groupnumber=$_[3];
 my $numvar=$_[4];
 my $currentdir=$_[5];
 my %params = %{$_[6]};
 my %paths = %{$_[7]};
 my %varmath= %{$_[8]};

# Load template for NIntegrate file
 my $template = Text::Template->new(SOURCE => $paths{"apf_intfileM"},
				    DELIMITERS => [ '(*{', '}*)' ])
          or die "Couldn't construct template: $Text::Template::ERROR";

 my %vars = (dir => "$currentdir",
	     minfuncno => $minfuncno,
	     maxfuncno => $maxfuncno,
	     epsord => $epsord,
	     groupnumber => $groupnumber,
	     paths => \%paths,
	     params => \%params,
	     varmath => \%varmath,
	     numvar => $numvar,
    );

# Fill in template and write intfile
 my $result = $template->fill_in(HASH => \%vars);
 my $filename = $currentdir. $paths{"rp_out_intfile"} . $groupnumber . $params{"language_suffix"};
 if (defined $result) {
     open(INTFILE, ">", "$filename");
     print INTFILE $result;
     close(INTFILE);
 } else {
     die "Couldn't fill in template: $Text::Template::ERROR"
 }

};

1;
