  #****p* SecDec/general/perlsrc/makemakerun.pm
  #  NAME
  #    makemakerun.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makemakerun
  # 
  #  USES 
  #  Arguements passed by preparenumerics.pl
  #
  #  USED BY 
  #  preparenumerics.pl, writefiles.pm
  #    
  #  PURPOSE
  #  writes the file *make.pl in the appropriate subdirectory
  #    
  #  INPUTS
  #  arguements:
  #  filename: name of file to be written
  #  jj: order of epsilon
  #  point: name of numerical point being calculated
  #  polestruct: [i]l[j]h[h] - i logarithmic poles, j linear poles, h higher poles
  #    
  #  RESULT
  #  *make.pl written to the appropriate subdirectory 
  #    
  #  SEE ALSO
  #  preparenumerics.pl, writefiles.pm
  #   
  #****
package makemakerun;

sub go {
my $filename=$_[0];
my $jj=$_[1];
my $point=$_[2];
$point=~s/DEFAULT//;
my $polestruct=$_[3];
if(-e $filename){system("rm -f $filename")};
open(MAKEPL, ">","$filename") || die "cannot open $filename\n";
	print MAKEPL "\$ii=1;\n";
	print MAKEPL "while (-e \"${point}intfile\$ii.f\"){\n";
	print MAKEPL "print \"compiling $polestruct/epstothe$jj ...\\n\";\n";
	print MAKEPL "\$makecheck=system(\"make -s -j -f ${point}make\${ii}file\");\n";
	print MAKEPL "if (\$makecheck!=0) {\n";
	print MAKEPL " system(\"make -s -f ${point}make\${ii}file clean\");\n";
	print MAKEPL " system(\"make -s -j -f ${point}make\${ii}file\");\n";
	print MAKEPL "}\n";
	print MAKEPL "\$ii++;";
	print MAKEPL "}\n";
close MAKEPL;
};
1;
