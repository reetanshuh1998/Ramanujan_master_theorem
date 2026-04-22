  #****p* SecDec/general/perlsrc/makesub.pm
  #  NAME
  #    makesub.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makesub
  # 
  #  USES 
  #  Arguements parsed by preparenumerics.pl
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
  #  point: name of numerical point being calculated
  #  graph: name of graph
  #  polestruct: [i]l[j]h[h] - i logarithmic poles, j linear poles, h higher poles
  #  processlimit: number of jobs to be allowed in the queue at one time
  #  numvar: number of independent variables.
  #  exe: specifies where the process should terminate
  #  scriptdir: where the necessary .pm files are to be found
  #  whichsystem: specifies the batch system to be used
  #  curdir: directory subfile.pl will be created in
  #  clusterflag: =1 if a batch system is used, 0 if run locally
  #    
  #  RESULT
  #  *subfile.pl written to the appropriate subdirectory 
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****

package makesub;

sub go {

my $filename=$_[0];
my $jj=$_[1];
my $point=$_[2];
if ($point eq "DEFAULT") {$point=""};
my $graph=$_[3];
my $polestruct=$_[4];
my $processlimit=$_[5];
my $numvar=$_[6];
my $exe=$_[7];
my $scriptdir=$_[8];
my $whichsystem=$_[9];
my $curdir=$_[10];
my $clusterflag=$_[11];
if(-e $filename) { system("rm -f $filename"); }
open(SUBFILE, ">","$filename") || die "cannot open $filename\n";
	
	if ($clusterflag==1){
	 print SUBFILE "use lib \"$scriptdir\";\n";
	 print SUBFILE "use launchjob;\n"
	}
	$shortdir="$graph/$polestruct/epstothe$jj";
	if ($exe!=3) {
	 print SUBFILE "system(\"perl ${point}make.pl\");\n"
	} else {
	 print SUBFILE "print \"Current directory: $shortdir\\n\";\n";
	}
	
	$forsf="${point}intfile\$ii.f";
	
	if ($clusterflag==0) {
	print SUBFILE "\$ii=1;\n";
	print SUBFILE "while (-e \"$forsf\"){\n";
	if ( $numvar >0 ) {
	    print SUBFILE "print \"doing numerical integrations in $shortdir\\n\";\n";
	} else {
	    print SUBFILE "print \"doing integration in $shortdir\\n\";\n";
	}
	print SUBFILE "\$exstat=`./${point}intfile\$ii.exe>${point}intfile\$ii.log;echo \\\$?`;\n";
	print SUBFILE "if(\$exstat==91){\n";
	print SUBFILE " print \"Error - integrand evaluates to NaN. Please check input in template file\\n\";\n";
	print SUBFILE " exit 91\n";
	print SUBFILE "} elsif(\$exstat==90){\n";
	print SUBFILE " print \"Error - integrand appears to be unintegrable (result is > 1E7, error is >10%).\\n\";\n";
	print SUBFILE " print \" Please check input in template file\\n\";\n";
	print SUBFILE " exit 90\n";
	print SUBFILE "} elsif (\$exstat==89){\n";
	print SUBFILE " print  \"Error - integration yields result > 10E+17\\n\";\n";
	print SUBFILE " exit 89\n";
	print SUBFILE "}\n";
	print SUBFILE "\$ii++\n";
	print SUBFILE "}\n";
	} else {
	 $jobfile=jobfile($polestruct,$jj,$point);
	 $fulljobfile="$curdir/$jobfile";
	  print SUBFILE "\$doneflag=0;\n";
	  print SUBFILE "\$done=0;\n";
	  print SUBFILE "\$maxlen=$processlimit;\n";
	  print SUBFILE "while (\$doneflag==0) {\n";
	  if ($whichsystem==0){
	   print SUBFILE "\$curlength=`qstat | perl -e '\\\$job=0;while (<>) { \\\$job++ };print \\\$job\'`;\n";
	  } else {
	   ####################################################################################################
	   ################## this needs to be changed to the syntax of your batch queue system ###############
	   ################## \$curlength should evaluate to the current number of processes ##################
	   ################## currently in the queue, either running or waiting. If you do not ################
	   ################## wish to implement this functionality, leave the code as it is below. ############
	   ################## this is equivalent to setting max number of jobs = infinity #####################
	   ####################################################################################################
	   print SUBFILE "\$curlength=1;\n";
	  }
	  print SUBFILE "if (\$curlength>0){\n";
	  print SUBFILE "\$queuespace=\$maxlen-\$curlength;\n";
	  print SUBFILE "if (\$queuespace<=0) {sleep 30};\n";
	  print SUBFILE "\$dothistime=int(\$queuespace/2);\n";
	  print SUBFILE "for (\$ii=\$done+1;\$ii<=\$dothistime+\$done;\$ii++) {\n";
	  print SUBFILE "if (-e \"$forsf\"){\n";
	  print SUBFILE "print \"Submitting $jobfile\\n\";\n";
	  print SUBFILE "launchjob::submit(\"$whichsystem\",\"$fulljobfile\");\n";
	  print SUBFILE "} else {\n";
	  print SUBFILE "\$doneflag=1;\n";
	  print SUBFILE "\$ii=\$dothistime+\$done\n";
	  print SUBFILE "}\n";
	  print SUBFILE "}\n";
	  print SUBFILE "\$done=\$dothistime+\$done;\n";
	  print SUBFILE "} else {\n";
	  print SUBFILE "sleep 30\n";
	  print SUBFILE "}\n";
	  print SUBFILE "}\n";
	}
	 
close SUBFILE
};

sub jobfile {
 my $polestruct=$_[0];
 my $jj=$_[1];
 my $point=$_[2];
 if ($point ne "") {
  $jobfilename="$polestruct.${point}.$jj.\$ii";
 } else {
  $jobfilename="$polestruct.$jj.\$ii";
 }
 return $jobfilename;
};
1;
