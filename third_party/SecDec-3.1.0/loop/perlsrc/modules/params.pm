#****
#  NAME
#    params.pm
#
#  USAGE
#  use params;
#
#  USES
#   paramfile specified by various perl scripts
#
#  USED BY
#  makeFU.pl, decomposeloop.pl,  subexploop.pl,
#  resultsloop.pl,  polenumerics.pl, preparenumerics.pl, makeint(C).pm
#
#  PURPOSE
#  creates a hash with the input parameters necessary for the perl scripts
#  to run correctly.
#  SEE ALSO
#  subexploop.pl, polenumerics.pl
#
#****
package params;

use strict;
use warnings;

use lib "loop/perlsrc/modules";
use dirform;
use Scalar::Util qw(looks_like_number);

# read param file
sub readparams {
    my $locparamfile = $_[0];
    my %params = ();
    my $mode=$_[1];

    if ($mode) { $params{"mode"} = $mode; } else { $params{"mode"}=0; } 

    open( EREAD, $locparamfile ) || die "cannot open $locparamfile";
    while (<EREAD>) {
        chomp;
        s/^\s+//;    # remove whitespace from start of line
        unless (/^#/ or /^\s*$/ ) {    # unless line starts with '#' or is blank
            if    (m/^outputdir=(.*)/i)       { $params{"outputdir"}      = dirform::strip_spaces($1) }
            elsif (m/^graph=(.*)/i)           { $params{"graph"}          = dirform::strip_spaces($1) }
            elsif (m/^epsord=(.*)/i)          { $params{"epsord"}         = dirform::strip_spaces($1) }
            elsif (m/^IBPflag=(.*)/i)         { $params{"IBPflag"}        = dirform::strip_spaces($1) }
            elsif (m/^compiler=(.*)/i)        { $params{"compiler"}       = dirform::strip_spaces($1) }
            elsif (m/^exeflag=(.*)/i)         { $params{"exe"}            = dirform::strip_spaces($1) }
            elsif (m/^clusterflag=(.*)/i)     { $params{"clusterflag"}    = dirform::strip_spaces($1) }
            elsif (m/^clusteroptscompile=(.*)/i)     { $params{"clusteroptscompile"}          = $1 }
            elsif (m/^clusteroptsrun=(.*)/i)     { $params{"clusteroptsrun"}          = $1 }
            elsif (m/^batchsystem=(.*)/i)     { $params{"batch"}          = dirform::strip_spaces($1) }
        # elsif (m/^pointname=(.*)/i)       { $params{"pointname"}      = dirform::strip_spaces($1) }
            elsif (m/^sobolpath=(.*)/i)       { $params{"sobolpath"}      = dirform::strip_spaces($1) }
            elsif (m/^cquadpath=(.*)/i)       { $params{"cquadpath"}      = dirform::strip_spaces($1) }
            elsif (m/^integrator=(.*)/i)      { $params{"integrator"}     = dirform::strip_spaces($1) }
            elsif (m/^basespath=(.*)/i)       { $params{"basespath"}      = dirform::strip_spaces($1) }
            elsif (m/^cubapath=(.*)/i)        { $params{"cubapath"}       = dirform::strip_spaces($1) }
            elsif (m/^cubacores=(.*)/i)       { $params{"cubacores"}      = dirform::strip_spaces($1) }
            elsif (m/^maxeval=(.*)/i)         { $params{"maxeval"}        = dirform::strip_spaces($1) }
            elsif (m/^mineval=(.*)/i)         { $params{"mineval"}        = dirform::strip_spaces($1) }
            elsif (m/^epsrel=(.*)/i)          { $params{"epsrel"}         = dirform::strip_spaces($1) }
            elsif (m/^epsabs=(.*)/i)          { $params{"epsabs"}         = dirform::strip_spaces($1) }
            elsif (m/^cubaflags=(.*)/i)       { $params{"cubaflags"}      = dirform::strip_spaces($1) }
            elsif (m/^nstart=(.*)/i)          { $params{"nstart"}         = dirform::strip_spaces($1) }
            elsif (m/^nincrease=(.*)/i)       { $params{"nincrease"}      = dirform::strip_spaces($1) }
            elsif (m/^nnew=(.*)/i)            { $params{"nnew"}           = dirform::strip_spaces($1) }
            elsif (m/^flatness=(.*)/i)        { $params{"flatness"}       = dirform::strip_spaces($1) }
            elsif (m/^key1=(.*)/i)            { $params{"key1"}           = dirform::strip_spaces($1) }
            elsif (m/^key2=(.*)/i)            { $params{"key2"}           = dirform::strip_spaces($1) }
            elsif (m/^key3=(.*)/i)            { $params{"key3"}           = dirform::strip_spaces($1) }
            elsif (m/^maxpass=(.*)/i)         { $params{"maxpass"}        = dirform::strip_spaces($1) }
            elsif (m/^border=(.*)/i)          { $params{"border"}         = dirform::strip_spaces($1) }
            elsif (m/^maxchisq=(.*)/i)        { $params{"maxchisq"}       = dirform::strip_spaces($1) }
            elsif (m/^mindeviation=(.*)/i)    { $params{"mindeviation"}   = dirform::strip_spaces($1) }
            elsif (m/^nextra=(.*)/i)          { $params{"nextra"}         = dirform::strip_spaces($1) }
            elsif (m/^key=(.*)/i)             { $params{"key"}            = dirform::strip_spaces($1) }
            elsif (m/^primarysectors=(.*)/i)  { $params{"Nlist"}          = dirform::strip_spaces($1) } # DO NOT USE, use $mathparams{"Nlist"}
            elsif (m/^multiplicities=(.*)/i)  { $params{"multlist"}       = dirform::strip_spaces($1) }
            elsif (m/^infinitesectors=(.*)/i) { $params{"nonstop"}        = dirform::strip_spaces($1) }
            elsif (m/^togetherflag=(.*)/i)    { $params{"together"}       = dirform::strip_spaces($1) }
        # elsif (m/^editor=(.*)/i)          { $params{"editor"}         = dirform::strip_spaces($1) }
            elsif (m/^grouping=(.*)/i)        { $params{"grouping"}       = dirform::strip_spaces($1)*1024 } #convert kilobytes to bytes, note that the output params.input will have grouping specified in bytes!
            elsif (m/^seed=(.*)/i)            { $params{"seed"}           = dirform::strip_spaces($1) }
#            elsif (m/^language=(.*)/i)        { $params{"language"}       = lc dirform::strip_spaces($1) }
            elsif (m/^contourdef=(.*)/i)      { $params{"contourdef"}     = ucfirst dirform::strip_spaces($1) }
            elsif (m/^lambda=(.*)/i)          { $params{"xlambda"}        = dirform::strip_spaces($1) }
            elsif (m/^optlamevals=(.*)/i)     { $params{"optlamevals"}    = dirform::strip_spaces($1) }
            elsif (m/^rescale=(.*)/i)         { $params{"rescaleflag"}    = dirform::strip_spaces($1) }
#            elsif (m/^cutconstruct=(.*)/i)    { $params{"cutconstruct"}   = dirform::strip_spaces($1) }
            elsif (m/^smalldefs=(.*)/i)       { $params{"oscillatory"}    = dirform::strip_spaces($1) }           
            elsif (m/^largedefs=(.*)/i)       { $params{"endpointflag"}   = dirform::strip_spaces($1) }           
            elsif (m/^nbmathsubkrnls=(.*)/i)  { $params{"nbmathsubkrnls"} = dirform::strip_spaces($1) }           # number of Mathematica subkernels to be used
        # elsif (m/^quadpacktype=(.*)/i)    { $params{"quadpacktype"}   = dirform::strip_spaces($1) }
            elsif (m/^xplot=(.*)/i)           { $params{"xplot"} = dirform::strip_spaces($1) }
            elsif (m/^strategy=(.*)/i)        { $params{"strategy"} = uc dirform::strip_spaces($1) }
            elsif (m/^CCargs=(.*)/i)          { $params{"CCargs"} = $1 } # arguments passed to C compiler for compiling numerics
            elsif (m/^NIntegrateOptions=(.*)/i)        { $params{"NIntegrateOptions"} = dirform::strip_spaces($1)} # options to be passed to Mathematica for NIntegrate
            elsif (m/^complexmasses=(.*)/i) { $params{"complexmasses"} = dirform::strip_spaces($1) }
            elsif (m/=/i) {
                print "Warning - invalid assignment $_ in $locparamfile\n";
            }
            else { print "Warning - invalid text $_ in $locparamfile\n" }
        }
    }
    close(EREAD);

    # validate input / set default parameters
    # Note:
    # unless ( $a ) { # code run if $a = undef, $a = 0, $a = "" }
    # unless ( defined $a ) { # code run if $a = undef }
    my $failstring = "";
    my $fails      = 0;

    # unless ( defined $params{"diry"} )       { $params{"diry"}       = "" }    # todo, use paths module for paths
    #   if ( $params{"diry"} =~ /^\// ) { # if subdir in paramfile begins with /
    #        print "Error - relative path 'subdir' should not begin with '/' in $locparamfile\n";
    #        exit 20;
    #    }
    unless ( defined $params{"outputdir"} ) { $params{"outputdir"} = "" }    # Note: use paths module for paths
    unless ( defined $params{"graph"} ) {
        $failstring = "$failstring, graph";
        $fails++;
    }
    unless ( looks_like_number $params{"epsord"} ) {
        $failstring = "$failstring, epsord";
        $fails++;
    }
    unless ( looks_like_number $params{"IBPflag"} )      { $params{"IBPflag"}      = 0 }
    unless ( $params{"compiler"} )                       { $params{"compiler"}     = "gcc" }
    unless ( looks_like_number $params{"exe"} )          { $params{"exe"}          = 3 }
    unless ( looks_like_number $params{"clusterflag"} )  { $params{"clusterflag"}  = 0 }
    unless ( defined $params{"clusteroptscompile"} )     { $params{"clusteroptscompile"}  = "" }
    unless ( defined $params{"clusteroptsrun"} )         { $params{"clusteroptsrun"}      = "" }
    unless ( looks_like_number $params{"batch"} )        { $params{"batch"}        = 0 }
    unless ( looks_like_number $params{"processlimit"} ) { $params{"processlimit"} = 200 }
    if     ( $params{"processlimit"} < 20 )              { $params{"processlimit"} = 20 }
    unless ( looks_like_number $params{"cputime"} )      { $params{"cputime"}      = 1000 }
#    unless ( $params{"pointname"} )                      { $params{"pointname"}    = "p" }
    unless ( looks_like_number $params{"integrator"} )   { $params{"integrator"}   = 3 }           # divonne
    unless ( defined $params{"basespath"} )                { $params{"basespath"}      = "" }          # default path stored in paths.pm
    unless ( defined $params{"cubapath"} )                 { $params{"cubapath"}       = "" }          # default path stored in paths.pm
    unless ( defined $params{"cquadpath"} )                { $params{"cquadpath"}      = "" }          # default path stored in paths.pm
    unless ( defined $params{"sobolpath"} )                { $params{"sobolpath"}      = "" }          # default path stored in paths.pm
    unless ( looks_like_number $params{"cubacores"} )      { $params{"cubacores"}      = $params{"clusterflag"} }    # see makeintC.pm
    unless ( defined $params{"maxeval"} )                  { $params{"maxeval"}        = 10000000 }    # see makeintC.pm
    unless ( defined $params{"mineval"} )                  { $params{"mineval"}        = 0 }           # see makeintC.pm
    unless ( defined $params{"epsrel"} )                   { $params{"epsrel"}         = "1.e-2" }     # see makeintC.pm
    unless ( defined $params{"epsabs"} )                   { $params{"epsabs"}         = "1.e-6" }     # see makeintC.pm
    unless ( defined $params{"cubaflags"} )                { $params{"cubaflags"}      = 2 }           # see makeintC.pm
    unless ( defined $params{"nstart"} )                   { $params{"nstart"}         = 100000 }      # see makeintC.pm
    unless ( defined $params{"nincrease"} )                { $params{"nincrease"}      = 10000 }       # see makeintC.pm
    unless ( defined $params{"nnew"} )                     { $params{"nnew"}           = 10000 }       # see makeintC.pm
    unless ( defined $params{"flatness"} )                 { $params{"flatness"}       = 1 }           # see makeintC.pm
    unless ( defined $params{"key1"} )                     { $params{"key1"}           = 1500 }        # see makeintC.pm
    unless ( defined $params{"key2"} )                     { $params{"key2"}           = 1 }           # see makeintC.pm
    unless ( defined $params{"key3"} )                     { $params{"key3"}           = 1 }           # see makeintC.pm
    unless ( defined $params{"maxpass"} )                  { $params{"maxpass"}        = 3 }           # see makeintC.pm
    unless ( defined $params{"border"} )                   { $params{"border"}         = "1.e-6" }     # see makeintC.pm
    unless ( defined $params{"maxchisq"} )                 { $params{"maxchisq"}       = "1.e0" }      # see makeintC.pm
    unless ( defined $params{"mindeviation"} )             { $params{"mindeviation"}   = ".15" }       # see makeintC.pm
    unless ( defined $params{"nextra"} )                   { $params{"nextra"}         = 0 }           # see makeintC.pm
    unless ( defined $params{"key"} )                      { $params{"key"}            = 7 }           # see makeintC.pm
    unless ( defined $params{"Nlist"} )                    { $params{"Nlist"}          = "" }
    unless ( defined $params{"multlist"} )                 { $params{"multlist"}       = "" }
    unless ( defined $params{"nonstop"} )                  { $params{"nonstop"}        = "" }
    unless ( looks_like_number $params{"together"} )       { $params{"together"}       = 0 }
#    unless ( $params{"editor"} )                           { $params{"editor"}         = "none" }
    unless ( looks_like_number $params{"grouping"} )       { $params{"grouping"}       = 2048000 }
    unless ( looks_like_number $params{"seed"} )           { $params{"seed"}           = 0 }           # see makeintC.pm
#    unless ( $params{"language"} )                         { $params{"language"}       = "cpp" }
    unless ( $params{"contourdef"} )                       { $params{"contourdef"}     = "False" }
    unless ( looks_like_number $params{"xlambda"} )        { $params{"xlambda"}        = "1.0" }
    unless ( looks_like_number $params{"optlamevals"} )    { $params{"optlamevals"}    = 4000 }        # see makeintC.pm
    unless ( looks_like_number $params{"rescaleflag"} )    { $params{"rescaleflag"}    = 0 }
#    unless ( looks_like_number $params{"cutconstruct"} )   { $params{"cutconstruct"}   = 0 }
    unless ( looks_like_number $params{"oscillatory"} )    { $params{"oscillatory"}    = 0 }
    unless ( looks_like_number $params{"endpointflag"} )   { $params{"endpointflag"}   = 0 }
    unless ( looks_like_number $params{"nbmathsubkrnls"} ) { $params{"nbmathsubkrnls"} = 0 }
#    unless ( defined $params{"quadpacktype"} )             { $params{"quadpacktype"}   = "cquad" }     # see makeintC.pm
    unless ( defined $params{"xplot"} )                    { $params{"xplot"} = "1"}
    unless ( defined $params{"strategy"} )                 { $params{"strategy"} = "X" }
    unless ( defined $params{"CCargs"})                    { $params{"CCargs"} = "-O" }
    unless ( defined $params{"NIntegrateOptions"} )        { $params{"NIntegrateOptions"} = 
	  'AccuracyGoal->3' }
    unless ( defined $params{"complexmasses"})             { $params{"complexmasses"} = 0 }

    # handle errors
    unless ( $params{"integrator"} > 0 && $params{"integrator"} < 6 ) {
        print "Error - input integrator assigned to invalid value in $locparamfile\n";
        print "Valid choices for integrator are: 1,2,3,4 or 5. (Default = 3)";
        exit 20;
    }
    $failstring =~ s/^, //;
    my $plural1 = "";
    my $plural2 = "was";
    if ( $fails > 1 ) { $plural1 = "s"; $plural2 = "were" }
    if ( $failstring ne "" ) {
        print "Error - essential input$plural1 $failstring $plural2 unassigned in $locparamfile\n";
        exit 20;
    }

    # set derived scalars
    if ( $params{"integrator"} == 5 ) {
        $params{"language_suffix"} = ".m";
    }
    else {
        $params{"language_suffix"} = ".cc";
    }

    # set derived arrays/hashes and store references in $params hash
    my @nonstop = split( /,/, $params{"nonstop"} );
    $params{"array_nonstop"} = \@nonstop;
    my @epsrel = split( /,/, $params{"epsrel"} );
    $params{"array_epsrel"} = \@epsrel;
    my @epsabs = split( /,/, $params{"epsabs"} );
    $params{"array_epsabs"} = \@epsabs;
    my @mineval = split( /,/, $params{"mineval"} );
    $params{"array_mineval"} = \@mineval;
    my @maxeval = split( /,/, $params{"maxeval"} );
    $params{"array_maxeval"} = \@maxeval;

    #vegas only
    my @nstart = split( /,/, $params{"nstart"} );
    $params{"array_nstart"} = \@nstart;
    my @nincrease = split( /,/, $params{"nincrease"} );
    $params{"array_nincrease"} = \@nincrease;

    #suave only
    my @nnew = split( /,/, $params{"nnew"} );
    $params{"array_nnew"} = \@nnew;
    my @flatness = split( /,/, $params{"flatness"} );
    $params{"array_flatness"} = \@flatness;

    #divonne only
    my @key1 = split( /,/, $params{"key1"} );
    $params{"array_key1"} = \@key1;
    my @key2 = split( /,/, $params{"key2"} );
    $params{"array_key2"} = \@key2;
    my @key3 = split( /,/, $params{"key3"} );
    $params{"array_key3"} = \@key3;
    my @maxpass = split( /,/, $params{"maxpass"} );
    $params{"array_maxpass"} = \@maxpass;
    my @border = split( /,/, $params{"border"} );
    $params{"array_border"} = \@border;
    my @maxchisq = split( /,/, $params{"maxchisq"} );
    $params{"array_maxchisq"} = \@maxchisq;
    my @mindeviation = split( /,/, $params{"mindeviation"} );
    $params{"array_mindeviation"} = \@mindeviation;
    my @nextra = split( /,/, $params{"nextra"} );
    $params{"array_nextra"} = \@nextra;

    #cuhre only
    my @key = split( /,/, $params{"key"} );
    $params{"array_key"} = \@key;

    my @xplot = split( /,/, $params{"xplot"} );
        my $numxplot = @xplot;
        for ( my $i = 0 ; $i < $numxplot ; $i++ ) {
            # shift because perl list element labelling starts at zero
            $xplot[$i] = $xplot[$i] - 1;
        }
    $params{"array_xplot"} = \@xplot;

    return %params;
}

# Updates integrator related path parameters if the integrator has dynamically changed (eg... the program has switched to cquad dynamically)
# stores a copy of the user's specified path for the dynamically selected integrator
sub updatedynamicintegrator {
    my $integrator = $_[0];
    my %params = %{ $_[1] };    # store input params hash
    
    if ( $integrator == 0 ) {
        $params{"integpath_dynamic"} = $params{"basespath"};
    }
    elsif ( $integrator < 5 ) {
        $params{"integpath_dynamic"} = $params{"cubapath"};
    }
    elsif ( $integrator == 5 ) {
        $params{"integpath_dynamic"} = "dummy"; # using Mathematica (only placeholder required)
    }
    elsif ( $integrator == 6 ) {
        $params{"integpath_dynamic"} = $params{"cquadpath"};
    }
    $params{"integrator_dynamic"} = $integrator;
    
    return %params;
}

sub readmathparams {
my $locmathfile=$_[0];
my %params = %{$_[1]}; # store params hash (should have been created using readparams)
my %mathparams = ();

$mathparams{"mode"}=$params{"mode"};

open (EREAD,$locmathfile) || die "cannot open $locmathfile";
while(<EREAD>) {
  chomp;
  s/^\s+//;
    if(m/^externallegs=(.*)/i){$mathparams{"externallegs"}=dirform::strip_spaces($1)
    }
    elsif(m/^prefactor=(.*)/i){$mathparams{"userprefac"}=dirform::strip_spaces($1)
    }
    elsif(m/^loops=(.*)/i){$mathparams{"loops"}=dirform::strip_spaces($1)
    }
    elsif(m/^propagators=(.*)/i){$mathparams{"Nn"}=dirform::strip_spaces($1)
    }
    elsif(m/^cutconstruct=(.*)/i){$mathparams{"cutconstruct"}=dirform::strip_spaces($1)
    }
    elsif(m/^tensorwithcutco=(.*)/i){$mathparams{"tensorwithcutco"}=dirform::strip_spaces($1)
    }
    elsif(m/^feynpars=(.*)/i){$mathparams{"feynpars"}=dirform::strip_spaces($1)
    }
    elsif(m/^deffeynpars=(.*)/i){$mathparams{"deffeynpars"}=dirform::strip_spaces($1)
    }
    elsif(m/^masslist=(.*)/i){$mathparams{"masslist"}=dirform::strip_spaces($1)
    }
    elsif(m/^lorentzlist=(.*)/i){$mathparams{"lorentzlist"}=dirform::strip_spaces($1)
    }
#    else {print "please specify ExternalMomenta, or number of external legs as \"externallegs=\" in mathematica file\n";}
#
}  
close (EREAD);


my $failstring = "";
my $fails      = 0;

# validate parameters
$mathparams{"userprefac"}=~s/\s//g; # strip spaces
    unless ( defined $mathparams{"userprefac"} ) {$failstring = "$failstring, userprefac";
        $fails++;
    }
if ( $mathparams{"mode"} == 1 ) {
    unless ( $mathparams{"deffeynpars"} ) {$failstring = "$failstring, deffeynpars";
        $fails++;
    } # should be True or False    
}
else {
    unless ( looks_like_number $mathparams{"externallegs"} ) {$failstring = "$failstring, externallegs";
        $fails++;
    }
    unless ( looks_like_number $mathparams{"loops"} ) {$failstring = "$failstring, loops";
        $fails++;
    }
    unless ( looks_like_number $mathparams{"Nn"} ) {$failstring = "$failstring, propagators";
        $fails++;
    }
    unless ( $mathparams{"cutconstruct"} ) {$failstring = "$failstring, cutconstruct";
        $fails++;
    } # should be True or False
     unless ( $mathparams{"tensorwithcutco"} ) {$failstring = "$failstring, tensorwithcutco";
        $fails++;
    } # should be True or False
}
    unless ( defined $mathparams{"masslist"} ) {$failstring = "$failstring, masslist";
        $fails++;
    }
    unless ( defined $mathparams{"lorentzlist"} ) {$failstring = "$failstring, lorentzlist";
        $fails++;
    }
    
    # handle errors
    $failstring =~ s/^, //;
    my $plural1 = "";
    my $plural2 = "was";
    if ( $fails > 1 ) { $plural1 = "s"; $plural2 = "were" }
    if ( $failstring ne "" ) {
        print "Error - could not read input$plural1 $failstring from $locmathfile\n";
        exit 20;
    }
if ( $mathparams{"mode"} == 1 ) {
    if ( $mathparams{"deffeynpars"} eq "False") {
        print "input error in templatefile. \n";
        print "To calculate user-defined functions, the number of Feynman\n";
	print "parameters must match the length of the exponent list.\n";
	print "Your number of Feynman parameters seems to be ";
	print $mathparams{"feynpars"};
	print "\n";
        exit 1;
    }
}
else {
    if ( $mathparams{"tensorwithcutco"} eq "True") {
        print "input error in templatefile. \n";
        print "To calculate tensor integrals, proplist must be defined in terms of loop momenta.\n";
        exit 1;
    }
}
    # issue warnings
    if ( looks_like_number $mathparams{"userprefac"} ) {
        if ($mathparams{"userprefac"} == 0 ) {
        print "Warning - detected userprefac as zero in $locmathfile\n";
        }
    }

    # set derived scalars
if ( $mathparams{"mode"} == 0 ) {
    unless ( $params{"feynpars"} ) { $mathparams{"feynpars"} = eval($mathparams{"Nn"} -1 ); }
}
if ( $mathparams{"mode"} == 1 ) {
# GH 28.5.15; for user defined mode: Nn corresponds to the number of functions, feynpars to the number of integration params
    unless ( $mathparams{"Nn"} ) { $mathparams{"Nn"} = eval($mathparams{"feynpars"}+1  ); }
    unless ( $mathparams{"loops"} ) { $mathparams{"loops"} = 0; }
    unless ( $mathparams{"cutconstruct"} ) { $mathparams{"cutconstruct"} = "False"; }
    unless ( $mathparams{"tensorwithcutco"} ) { $mathparams{"tensorwithcutco"} = "False"; }
}

    # set derived arrays
    my $premasslist = $mathparams{"masslist"};
    $premasslist=~s/{//;
    $premasslist=~s/}//;
    my @masslist = split( /,/, $premasslist);
    $mathparams{"array_masslist"} = \@masslist;
    my $prelorentzlist = $mathparams{"lorentzlist"};
    $prelorentzlist=~s/{//;
    $prelorentzlist=~s/}//;
    my @lorentzlist = split( /,/, $prelorentzlist);
    $mathparams{"array_lorentzlist"} = \@lorentzlist;
    $mathparams{"array_masslist"} = \@masslist;
    my @invariants=(@lorentzlist,@masslist);
    $mathparams{"array_invariants"} = \@invariants;
    
    # if user has defined Nlist, take their value
    my @Nlist          = split( /,/, $params{"Nlist"} );
    my @multiplicities = split( /,/, $params{"multlist"} );
    $mathparams{"indflag"} = 1;
    # else derive values for Nlist and multiplicities from Nn computed in mathparams
    unless (@Nlist) {    # no list of primary sectors which should be computed is given
        $mathparams{"indflag"} = 0;
        @Nlist = ( 1 .. $mathparams{"Nn"} );
        unless (@multiplicities) {
            @multiplicities = (1)x $mathparams{"Nn"};
        }
    }
    my $last = eval( @Nlist - 1 );
#    $mathparams{"Nmin"}                = $Nlist[0]; (SB): parameter is obsolete
    $mathparams{"Nmax"}                = $Nlist[$last];
    $mathparams{"array_Nlist"}         = \@Nlist;
    $mathparams{"array_multiplicites"} = \@multiplicities;
    my $el = 0;
    my $sec;
    my %hashmulti;
    foreach my $sec (@Nlist) {
#        if (@multiplicities) {
# changed by GH 28.4.16 such that for a very long list of userdef functions with multiplicity 1 only first element needs to be given
      if ($multiplicities[$el]) {
            $hashmulti{$sec} = $multiplicities[$el];
        }
        else {
            $hashmulti{$sec} = 1;
        }
        $el++;
    }
    $mathparams{"hash_multi"} = \%hashmulti;
    
    # handle derived errors
    if ( !@multiplicities ) { die "Multiplicities must be specified if a list of sectors is specified" }


return %mathparams;
}

#
#
# Special param functions for validating command line arguments
#
#

# filters array a keeping only elements in array b
# - warns if a contains elements not in b
sub filter {
    my @a = @{ $_[0]};
    my @b = @{$_[1]};
    
    my @c;
    my %b_hash = map { $_ => 1 } @b; # hash b (for easy searching)
    foreach my $elem ( @a ) {
        if ( exists( $b_hash{$elem} ) )
        {
            push(@c,$elem);
            #} else {
            #print "Warning - invalid input: " . $elem . "\n";
            #print "Valid input(s): \n" . join(', ', @b) . "\n";
        }
    }
    
    return @c;
}

1;

# end package header
