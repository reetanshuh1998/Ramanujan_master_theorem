### subfile.pl.in --- template for subfile.pl

#print "Current directory: /home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/numerics/1l0h0/epstothe-1/\n";
$finstat=0;
open (KINEM,"<","../../../kinematics.input");
@kinlist=<KINEM>;
chomp(@kinlist);
my $nlines=0;
foreach (@kinlist) { if (!((/^#/)or(/^\s*$/))) {$nlines++;}}
print "Performing numerical integration for " . $nlines . " point(s)\n";
foreach $line (@kinlist){
  if (($line =~ /^#/)or($line =~ /^\s*$/)) {next};
  print "Integrating: ${line}\n";
  my @psl = split ' ',$line;
  # this defines @ps implicitly
  ($pointname,@ps)=@psl;
  my @p;
  foreach $s (@ps) {
      $s=~s/[eE]([+-]?\d+)/*10**$1/g; $s=~s/[\^]([+-]?\d+)/**$1/g; $sE=eval($s);
      if (is_int($sE)) { my $p=to_float($sE,1); push(@p,"$p"); } else { push(@p,"$sE"); }
  }
  unshift(@p,$pointname);
  $ii=1;
  $forsf= intfile . ${ii} . ".cc";
  while (-e "$forsf"){
      if(3 == 5){
	  $exstat=`perl /home/reet/Downloads/Ramanujan/SecDec-3.1.0/loop/perlsrc/mathlaunch.pl intfile$ii.m ${p[0]}intfile$ii.log @p;echo \$?`;
      }else{
	  $exstat=`./intfile$ii.exe @p >${p[0]}intfile$ii.log;echo \$?`;
	  if($exstat==91){
	      print "Error - integrand evaluates to NaN. Please check onshell replacements in template file,\n";
	      print "and definitions of invariants, masses etc. in parameter file\n";
	      exit 91
	  } elsif ($exstat==90){
	      print "Error - integration leads to a result over 1E+07, and error of over 10%.\n This suggests the integrand contains singularities.\n";
	      exit 90
      }
      }
      $ii++;
      $forsf= intfile . ${ii} . ".cc";
  }
}
close KINEM;

sub is_int ($) {
    return unless defined $_[0] && $_[0] ne ''; 
    return unless $_[0] =~ /^[+-]?\d+$/; return 1;
}
sub to_float ($;$) {
    return unless defined $_[0] && $_[0] ne '';
    my ($num) = $_[0] =~ /(([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?)/;
    return unless defined $num;
    my $type = $num =~ /e|E/ ? 'e' : 'f';
    sprintf "%.$_[1]$type", $num;
}
