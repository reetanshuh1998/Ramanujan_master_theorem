  #****
  #  NAME
  #    makejob.pm
  #
  #  USAGE
  #  is called from polenumerics.pl via makejob::go
  # 
  #  USES 
  #
  #  arguments parsed to makejob::go 
  #
  #  USED BY 
  #  preparenumerics.pl
  #
  #  PURPOSE
  #  writes the job submission file in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguments:
  #  whichsystem: specifies which batch system is to be used
  #  filename:name and directory of the job submission file to be written
  #  ...
  #    
  #  RESULT
  #  new job submission file in the appropriate subdirectory
  #    
  #  SEE ALSO
  #  polenumerics.pl                                    
  #   
  #****
use strict;
use warnings;
package makejob;
sub go {
my %paths=%{$_[0]};
my %params=%{$_[1]};
my $currentdir=$_[2];
my $polestruct=$_[3];
my $jj=$_[4];
my $groupcount=$_[5];
my @fmax=@{$_[6]};
my $jobfilename="submit${polestruct}.${jj}";
my $makescript="runmake.sh";
my $runscript="runjob.sh";
my $whichsystem=$params{"batch"};
my %templ_vars = (
    paths => \%paths,
    params => \%params,
    currentdir => $currentdir,
    filename =>  $jobfilename,
    groupcount => $groupcount,
    fmax => \@fmax
);
if ($whichsystem==0) {
    my $template = Text::Template->new(SOURCE => $paths{"apf_submitpbs"}, DELIMITERS => [qw(<% %>)])
        or die "Couldn't construct template: $Text::Template::ERROR";

    my $filled_templ = $template->fill_in(HASH => \%templ_vars);
    open(JOBFILE, ">", $paths{"ap_out_cluster"} . $jobfilename);
    print JOBFILE $filled_templ;
    close JOBFILE;
} elsif ($whichsystem==1) {
unless (-e  $paths{"apf_out_condorkinem"}) {
    my $templatecompile = Text::Template->new(SOURCE => $paths{"apf_condorkinem"}, DELIMITERS => [qw(<% %>)])
        or die "Couldn't construct template: $Text::Template::ERROR";
    open(JOBFILE, ">", $paths{"apf_out_condorkinem"});
    print JOBFILE $templatecompile->fill_in(HASH => \%templ_vars);
    close JOBFILE;
    system("chmod +x " . $paths{"apf_out_condorkinem"}) ==0
        or die "Error - cannot make script " . $paths{"apf_out_condorkinem"} . " executable. \n";
}
unless (-e  $paths{"apf_out_condorcompile"}) {
    my $templatecompile = Text::Template->new(SOURCE => $paths{"apf_condorcompile"}, DELIMITERS => [qw(<% %>)])
        or die "Couldn't construct template: $Text::Template::ERROR";
    open(JOBFILE, ">", $paths{"apf_out_condorcompile"});
    print JOBFILE $templatecompile->fill_in(HASH => \%templ_vars);
    close JOBFILE;
}
unless (-e $paths{"apf_out_condorrunin"}) {
    my $templaterun = Text::Template->new(SOURCE => $paths{"apf_condorrun"}, DELIMITERS => [qw(<% %>)])
        or die "Couldn't construct template: $Text::Template::ERROR";
    open(JOBFILE, ">", $paths{"apf_out_condorrunin"});
    print JOBFILE $templaterun->fill_in(HASH => \%templ_vars);
    close JOBFILE;
}
    my $templatedag = Text::Template->new(SOURCE => $paths{"apf_condordag"}, DELIMITERS => [qw(<% %>)])
        or die "Couldn't construct template: $Text::Template::ERROR";
    open(JOBFILE, ">", $paths{"ap_out_cluster"} . $jobfilename . "condor.dag");
    print JOBFILE $templatedag->fill_in(HASH => \%templ_vars);
    close JOBFILE;
} elsif ($whichsystem==2) {
    my $templatesubmit = Text::Template->new(SOURCE => $paths{"apf_submitlsf"}, DELIMITERS => [qw(<% %>)])       
       or die "Couldn't construct template: $Text::Template::ERROR";
    my $templatemake = Text::Template->new(SOURCE => $paths{"apf_runmakelsf"}, DELIMITERS => [qw(<% %>)])
       or die "Couldn't construct template: $Text::Template::ERROR";
    my $templateint = Text::Template->new(SOURCE => $paths{"apf_runjoblsf"}, DELIMITERS => [qw(<% %>)])
       or die "Couldn't construct template: $Text::Template::ERROR";

    my $filled_templsubmit = $templatesubmit->fill_in(HASH => \%templ_vars);
    my $filled_templmake = $templatemake->fill_in(HASH => \%templ_vars);
    my $filled_templint = $templateint->fill_in(HASH => \%templ_vars);
    open(JOBFILE, ">", $paths{"ap_out_cluster"} . $jobfilename);
    print JOBFILE $filled_templsubmit;
    close JOBFILE;
#    open(JOBMFILE, ">", $paths{"ap_out_cluster"} . $makescript);
    open(JOBMFILE, ">", $paths{"apfp_out_polestruct"} . $polestruct . "/". $paths{"rp_out_epstothe"} . ${jj} ."/". $makescript);
    print JOBMFILE $filled_templmake;
    close JOBMFILE;
#    open(JOBIFILE, ">", $paths{"ap_out_cluster"} . $runscript);
    open(JOBIFILE, ">", $paths{"apfp_out_polestruct"} . $polestruct . "/". $paths{"rp_out_epstothe"} . ${jj}. "/". $runscript);
    print JOBIFILE $filled_templint;
    close JOBIFILE;
    system("chmod +x " . $paths{"apfp_out_polestruct"} . $polestruct . "/". $paths{"rp_out_epstothe"} . ${jj} ."/".  $makescript) ==0
        or die "Error - cannot make script $makescript executable. \n";
    system("chmod +x " . $paths{"apfp_out_polestruct"} . $polestruct . "/". $paths{"rp_out_epstothe"} . ${jj} ."/".  $runscript) ==0
        or die "Error - cannot make script $runscript executable. \n";
} else {

}
};

1;
