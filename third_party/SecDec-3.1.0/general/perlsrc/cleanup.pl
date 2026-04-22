  #****s* SecDec/general/perlsrc/cleanup.pl
  #  NAME
  #    cleanup.pl
  #
  #  USAGE
  #  ./makeclean
  # 
  #  USES  
  #
  #  USED BY 
  #  makeclean
  #
  #  PURPOSE
  #  removes all unneeded intermediate files
  #    
  #  INPUTS
  #  
  #  parameters parsed from makeclean via ARGV:
  #  dirbase: the polestructure subdirectory to be cleaned 
  #  allflag: specifies whether all files are to be removed
  #  fullflag: when a full clean is specified, this flag states whether
  #  it is the polestructure subdirectories, or the graph directory, to be cleaned
  #    
  #  RESULT
  #  intermediate files removed  
  #  SEE ALSO
  #  makeclean (created by subexp.pl, justnumerics.pl)
  #   
  #****
  
unless($ARGV[0]){die "No arguements given to cleanup.pl\n"};
$dirbase="$ARGV[0]/*";
$fullflag=$ARGV[1];
$allflag=$ARGV[2];
if($allflag eq "all"){
 if($fullflag eq "fullclean"){
  if($ARGV[0]=~m/(\w+)$/){$graph=$1};
  @files=qw(*l*h*.log *P*l*h*.out *epspre* batch* job* prefactor.* *results*log);
  foreach $filetype (@files) {
   @filelist=glob "$ARGV[0]/$filetype";
   $numfiles=@filelist;
   if ($numfiles>0) {
    system("rm @filelist")
   }
  }
  @files=qw(*Decomposition* .m Sec*.m *.info *epstothe*.res);
  foreach $filetype (@files) {
   @filelist=glob "$ARGV[0]/${graph}$filetype";
   foreach $file (@filelist){
    if(-e $file){system("rm $file")}
   }
  }
  if(-d "$ARGV[0]/together"){system("rm -r $ARGV[0]/together")};
 } else {
  @dirs=glob "$ARGV[0]*/";
  $numdirs=@dirs;
  if($numdirs>0){system("rm -r @dirs")}
 }
} else {
 if ($fullflag eq "fullclean"){exit};
 @files=qw(*sf*.f *.exe *.o *.pl *make*file *l*h*.* *intfile*.f);
 $len=@files;
 for ($ii=0;$ii<$len;$ii++) {
  @filelist=glob "$dirbase/$files[$ii]";
  $numfiles=@filelist;
  if ($numfiles>0) {
   system("rm @filelist")
  }
 }
}
