  #****
  #  NAME
  #    makeintC.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makeintC
  # 
  #  USES 
  #
  #  $paramfile, $kinemfile, header.pm, arguments parsed from preparenumerics.pl
  #
  #  USED BY 
  #    
  #  preparenumerics.pl, writefiles.pm
  #
  #  PURPOSE
  #  writes the fortran files *intfile*.cc in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguments:
  #  filename:name and directory of the *intfile*.cc to be written
  #  minf: lowest individual function number to integrate
  #  maxf: highest individual function number to integrate
  #  prestring: prefix of the functions to be integrated
  #  jj:epsilon order
  #  kk:which integration file is to be written, specifies *intfile$kk.cc
  #  numvar: number of variables in integration
  #  maxpole: maximal pole for this pole structure (can be spurious)
  #  paramfile: file to read parameters from
  #  routine: which integrator can be used depends on the number of feynpars to integrate over. 
  #   This info is caught in polenumerics.pl and handed over to preparenumerics.pl.
  #  kinemfile: file where numerical values for kinematic invariants are defined
  #  mathparamfile: file where symbols for kinematic invariants are defined
  #
  #  parameters read from $paramfile:
  #  graph:name of graph
  #  point:name of numerical point being calculated
  #  @ncall:number of calls BASES uses
  #  @iter1:number of interations BASES uses for its first run
  #  @iter2:number of interations BASES uses for its second run
  #  @acc1:accuracy BASES aims for on its first run
  #  @acc2:accuracy BASES aims for on its second run
  #    
  #  RESULT
  #  new functions $[point]intfile$[kk].cc in the appropriate subdirectory graph/polestructure/epsilonorder/
  #    
  #  SEE ALSO
  #  preparenumerics.pl
  #   
  #****
use lib "loop/perlsrc/modules";
use getkinematics;

package makeintC;

sub go {
 my $minf=$_[0];
 my $maxf=$_[1];
 my $jj=$_[2];
 my $kk=$_[3];
 my $threshold=$_[4];
 my $numvar=$_[5];
 my $maxpole=$_[6];
 my $polestruct=$_[7];
    
 my $currentdir=$_[8];
 my $overallmaxpole=$_[9];
 my %params=%{$_[10]};
 my %paths=%{$_[11]};
 my %hash_varmath=%{$_[12]};

 my $filename= $currentdir. $paths{"rp_out_intfile"} . $kk . $params{"language_suffix"};
 my $prestring= "P$polestruct";
 my $integrator=$params{"integrator_dynamic"};
 my $graph=$params{"graph"};
 my $point=$params{"pointname"};
 my $seed=$params{"seed"};
 my $oscillatory=$params{"oscillatory"};
 my $endpointflag=$params{"endpointflag"};
 my $contourdef=$params{"contourdef"};
 my $rescaleflag=$params{"rescaleflag"};
 my $xlambda=$params{"xlambda"};
 my $evaloptlam=$params{"optlamevals"};
 my $externalegs=$params{"externalegs"};
 my $flags=$params{"cubaflags"};
 my $complexmasses=$params{"complexmasses"};

#####################################
#
my @masses=@{$hash_varmath{"array_masslist"}};
my @lorentz=@{$hash_varmath{"array_lorentzlist"}};
#
my $Nn=$hash_varmath{"Nn"};
my $feynpars=eval($Nn-1);
#
my $psqlen=@lorentz;
my $msqlen=@masses;
 $psqdefine="double esx[$psqlen];\n";
 $msqdefine="double em[$msqlen];\n";
 if($complexmasses==1) { $msqdefine=$msqdefine . "dcmplx em_c[$msqlen];\n"; }
 $bgstdefine="double maxinv;\n";
 #$lrsdefine="";for($i=1;$i<=$numvar;$i++){$lrsdefine="$lrsdefine,1.0"};$lrsdefine=~s/,//;
 #$lrsdefine="double lrs[$numvar]={$lrsdefine};\n";

###################################################
# my $k = $jj - $maxpole;
 my $k = $jj + $overallmaxpole;
# maxpole changed to -overallmaxpole by GH 18.9.15 in order to have 
# uniform epsrel etc values for each order in eps, regardless of the current pole structure

 if (getkinematics::is_int($xlambda)) { my $mylambda=getkinematics::to_float($xlambda,1); $xlambda="$mylambda"; }

############################################################################################
####### BEGIN validate values for integration routines ##################################
 @epsrel=@{$params{"array_epsrel"}};
 @epsabs=@{$params{"array_epsabs"}};
 @mineval=@{$params{"array_mineval"}};
 @maxeval=@{$params{"array_maxeval"}};
 #vegas only
 @nstart=@{$params{"array_nstart"}};
 @nincrease=@{$params{"array_nincrease"}};
 #suave only
 @nnew=@{$params{"array_nnew"}};
 @flatness=@{$params{"array_flatness"}};
 #divonne only
 @key1=@{$params{"array_key1"}};
 @key2=@{$params{"array_key2"}};
 @key3=@{$params{"array_key3"}};
 @maxpass=@{$params{"array_maxpass"}};
 @border=@{$params{"array_border"}};
 @maxchisq=@{$params{"array_maxchisq"}};
 @mindeviation=@{$params{"array_mindeviation"}};
 @nextra=@{$params{"array_nextra"}};
 #cuhre only
 @key=@{$params{"array_key"}};
 # quadpack only
 $quadtype = $params{"quadpacktype"};

 getkinematics::dtoe(@epsrel);
 unless($epsrel[$k]){$epsrel[$k]=$epsrel[-1]};
 if (getkinematics::is_int($epsrel[$k])) {
     $epsrel[$k]=getkinematics::to_float($epsrel[$k],1);
 }
 getkinematics::dtoe(@epsabs);
 unless($epsabs[$k]){$epsabs[$k]=$epsabs[-1]};
 if (getkinematics::is_int($epsabs[$k])) {
     $epsabs[$k]=getkinematics::to_float($epsabs[$k],1);
 }
 unless ($mineval[$k]){$mineval[$k]=$mineval[-1]};
 unless ($maxeval[$k]){$maxeval[$k]=$maxeval[-1]};
 if ($integrator==1) {#vegas
     unless($nstart[$k]){$nstart[$k]=$nstart[-1]};
     unless($nincrease[$k]){$nincrease[$k]=$nincrease[-1]};
 } elsif($integrator==2) {#suave
	 unless($nnew[$k]){$nnew[$k]=$nnew[-1]};
     getkinematics::dtoe(@flatness);
	 unless($flatness[$k]){$flatness[$k]=$flatness[-1]};
 } elsif($integrator==3) {#divonne
     unless($key1[$k]){$key1[$k]=$key1[-1]};
     unless($key2[$k]){$key2[$k]=$key2[-1]};
     unless($key3[$k]){$key3[$k]=$key3[-1]};
     unless($maxpass[$k]){$maxpass[$k]=$maxpass[-1]};
     getkinematics::dtoe(@border);
     unless($border[$k]) { $border[$k]=$border[-1] }
     if (getkinematics::is_int($border[$k])) {
	 $border[$k]=getkinematics::to_float($border[$k],1);
     }
     getkinematics::dtoe(@maxchisq);
     unless($maxchisq[$k]){$maxchisq[$k]=$maxchisq[-1]};
     if (getkinematics::is_int($maxchisq[$k])) {
	 $maxchisq[$k]=getkinematics::to_float($maxchisq[$k],1);
     }
     getkinematics::dtoe(@mindeviation);
     unless($mindeviation[$k]){$mindeviation[$k]=$mindeviation[-1]};
     if (getkinematics::is_int($mindeviation[$k])) {
	 $mindeviation[$k]=getkinematics::to_float($mindeviation[$k],1);
     }
     unless($nextra[$k]){$nextra[$k]=$nextra[-1]};
 } elsif($integrator==4) {#cuhre
     unless($key[$k]){$key[$k]=$key[-1]};
 }
####### END set default values ##############################################
 $callargs="(x,esx,em,lambda";
 if($complexmasses==1) {  $callargs="(x,esx,em_c,lambda"; }
 $callargs2="(xx,esx,em,lambda";
 $functioncall="";
 $ratiocall="";
 $modcall="";
 $signcall="";
 $argcall="";
 $taucall="";
 $numberoffunctions=0;
 for ($ii=$minf;$ii<=$maxf;$ii++) {
     $fvarname="f0[$numberoffunctions]=";
     $functioncall="$functioncall $fvarname${prestring}f$ii${callargs}[$numberoffunctions],lrs[$numberoffunctions],maxinv);\n";
     if($contourdef eq "True"){
	 $svarname="s0[$numberoffunctions]=";
	 $ratiocall="$ratiocall $fvarname${prestring}r$ii${callargs2}[$numberoffunctions],lrs[$numberoffunctions],maxinv);\n";
	 $modcall="$modcall $fvarname${prestring}m$ii${callargs2}test[$numberoffunctions][ipass],lrs[$numberoffunctions],maxinv);\n";
	 $signcall="$signcall $svarname${prestring}s$ii${callargs2}test[$numberoffunctions][ipass],lrs[$numberoffunctions],maxinv);\n";
	 $argcall="$argcall $fvarname${prestring}a$ii${callargs2}test[$numberoffunctions][ipass],lrs[$numberoffunctions],maxinv);\n";
	 for ($ij=1;$ij<=$numvar;$ij++) {
	     $jjm=$ij-1;
	     $taucall="$taucall f0[$numberoffunctions][$jjm]=${prestring}t${ii}t$ij${callargs2}[$numberoffunctions],lrs[$numberoffunctions],maxinv);\n";
	 }
     }
     #  $j=$ii-1;
     #  $functiondeclare="${functiondeclare}dcmplx ${function}f$ii$declareargs;\n";
     #  $lamcall="$lamcall $prelam$function$calllam s0[$j]=-1; else s0[$j]=1;\n";
     #  $imagfuncall="$imagfuncall f0[$numberoffunctions]=imag($function$callargs2);\n ";
     $numberoffunctions++;
 }
 ######### BEGIN definition correct complex logarithm treatment #########################
 $myLog="dcmplx myLog(dcmplx myarg) \{\n";
 $myLog="$myLog if (myarg.imag()==0.) myarg=dcmplx(myarg.real(),-0.0);\n";
 $myLog="$myLog return log(myarg);";
 $myLog="$myLog\n\}";
 ######### END definition correct complex logarithm treatment ############################
 ######### BEGIN function find bigger number #############################################
 $bigger="double bigger (double a\, double b) \{\n";
 $bigger="$bigger if \(abs\(a\) >= abs\(b\)\) return a; \n";
 $bigger="$bigger else return b;\n\}\n";
 ######### END function find bigger number ###############################################
 ######### BEGIN function myatof #########################################################
 $myatof=       'double myatof(char* str){'         . "\n";
 $myatof=$myatof . '  strtok(str,"/");'                . "\n";
 $myatof=$myatof . '  char* pch = strtok(NULL,"/");'   . "\n";
 $myatof=$myatof . '  if (pch==NULL){'                 . "\n";
 $myatof=$myatof . '    return atof(str);'             . "\n";
 $myatof=$myatof . '  }else{'                          . "\n";
 $myatof=$myatof . '    return atof(str)/atof(pch);'   . "\n";
 $myatof=$myatof . '  }'                               . "\n";
 $myatof=$myatof . '}'                                 . "\n";
 ######### END function myatof############################################################
 ######### BEGIN start program and get kinematics from command line input ################
#new alternative:
 $start = "\nint main (int argc, char **argv)\n";
 $start = "$start\{\n";
 if($complexmasses==1){
     $nbargcs = eval(2+$psqlen+2*$msqlen);
 }else{
     $nbargcs = eval(2+$psqlen+$msqlen); 
} #intfilecall + pointname + number of kinematic invariants esx, em

# $start = "$start  int i1, i2; \n";
 $start = "$start  if (argc == ${nbargcs}) \{\n";
 if($rescaleflag){
     if($complexmasses==1){
	 $start = "$start    maxinv = 0.;\n";
	 $start = "$start    for (int i1=0; i1<$psqlen; i1++) \{\n";
	 $start = "$start      esx[i1] = myatof(argv[i1+2]);\n";
	 $start = "$start      maxinv=abs(bigger(maxinv,esx[i1]));\n";
	 $start = "$start    \}\n";
	 $start = "$start    for (int i2=0; i2<$msqlen; i2++) \{\n";
	 $start=$start."      em[i2] = myatof(argv[2*i2+$psqlen+2]);\n";
	 $start=$start."      em_c[i2] = dcmplx(em[i2],myatof(argv[2*i2+1+$psqlen+2]));\n";
	 if ($contourdef eq "True"){
	   $start=$start."      if(em_c[i2].imag()>0.){\n";
	   $start=$start."        cout<<\"ERROR: Positive imaginary part of mass squared detected!\"<<endl\n";
	   $start=$start."            <<\"This is incompatible with the +i*eps prescription.\"<<endl;\n";
	   $start=$start."        return 0;\n";
	   $start=$start."      \}\n";
	 }
	 $start = "$start      maxinv=abs(bigger(maxinv,em[i2]));\n";
	 $start = "$start      maxinv=abs(bigger(maxinv,em_c[i2].imag()));\n";
	 $start = "$start    \}\n";
     }else{
	 $start = "$start    maxinv = 0.;\n";
	 $start = "$start    for (int i1=0; i1<$psqlen; i1++) \{\n";
	 $start = "$start      esx[i1] = myatof(argv[i1+2]);\n";
	 $start = "$start      maxinv=abs(bigger(maxinv,esx[i1]));\n";
	 $start = "$start    \}\n";
	 $start = "$start    for (int i2=0; i2<$msqlen; i2++) \{\n";
	 $start = "$start      em[i2] = myatof(argv[i2+$psqlen+2]);\n";
	 $start = "$start      maxinv=abs(bigger(maxinv,em[i2]));\n";
	 $start = "$start    \}\n";
     }
 }else{
     if($complexmasses==1){
	 $start=$start."    maxinv = 1.;\n";
	 $start=$start."    for(int i1=0; i1<$psqlen; i1++)\{ esx[i1] = myatof(argv[i1+2]); \}\n";
	 $start=$start."    for(int i2=0; i2<$msqlen; i2++)\{ \n";
	 $start=$start."      em[i2] = myatof(argv[2*i2+$psqlen+2]);\n";
	 $start=$start."      em_c[i2] = dcmplx(em[i2],myatof(argv[2*i2+1+$psqlen+2]));\n";
	 if ($contourdef eq "True"){
	   $start=$start."      if(em_c[i2].imag()>0.){\n";
	   $start=$start."        cout<<\"ERROR: Positive imaginary part of mass squared detected!\"<<endl\n";
	   $start=$start."            <<\"This is incompatible with the +i*eps prescription.\"<<endl;\n";
	   $start=$start."        return 0;\n";
	   $start=$start."      \}\n";
	 }
	 $start=$start."    \}\n";
     }else{
	 $start = "$start    maxinv = 1.;\n";
	 $start = "$start    for (int i1=0; i1<$psqlen; i1++) \{ esx[i1] = myatof(argv[i1+2]); \}\n";
	 $start = "$start    for (int i2=0; i2<$msqlen; i2++) \{ em[i2] = myatof(argv[i2+$psqlen+2]); \}\n";
     }
 }
 $start = "$start  \} else \{\n";
 $start = "$start     cout << \"command line input of kinematics wrong, argc=\"<< argc << endl;\n";
 $start = "$start     cout << \"expected \" << ${nbargcs} << \" arguments\" << endl;\n";
 $start = "$start     return 0; \n";
 $start = "$start  \}\n";
#end_new
 ######### END start program and get kinematics ##########################################
 ######### BEGIN contourdef declarations #################################################
 $contdefdecl = "double lambdamax[$numberoffunctions];\n"; #=\{0.0\};\n";
 $contdefdecl = "${contdefdecl}double taumax[$numberoffunctions][$numvar];\n";
 $contdefdecl = "${contdefdecl}double lambdatest[$numberoffunctions][10];\n";
 $contdefdecl = "${contdefdecl}double r[$numberoffunctions];\n"; #=\{0.0\};\n";
 $contdefdecl = "${contdefdecl}double m[$numberoffunctions][10];\n";
 $contdefdecl = "${contdefdecl}double a[$numberoffunctions][10];\n";
 $contdefdecl = "${contdefdecl}double mintest[$numberoffunctions];\n"; #=\{0.0\};\n";
 $contdefdecl = "${contdefdecl}double argtest[$numberoffunctions];\n"; #=\{0.0\};\n";
 $contdefdecl = "${contdefdecl}\n$myLog"; #complex logarithm only if integrand is also complex
 ######### END contourdef declarations ###################################################
 ######### BEGIN contourdef initializations ##############################################
 $contdefini = " for (int l=0; l<nrfunc;l++)\{ lambda[l]=$xlambda; lambdamax[l]=0.0; r[l]=0.0; mintest[l]=0.0;"; 
 $contdefini = "${contdefini}argtest[l]=100000.0;"; 
 $contdefini = "${contdefini} \}\n";
 $contdefini = "${contdefini} for (int l1=0;l1<nrfunc;l1++) \{";
 $contdefini = "${contdefini} for (int l2=0;l2<ndim;l2++) \{";
 $contdefini = "${contdefini} taumax[l1][l2]=0.0; \}\}\n";
 $contdefini = "${contdefini} for (int l1=0;l1<nrfunc;l1++) \{";
 $contdefini = "${contdefini} for (int l2=0;l2<10;l2++) \{";
 $contdefini = "${contdefini} m[l1][l2]=100000.0; a[l1][l2]=0.0; lambdatest[l1][l2]=0.0; \}\}\n";
 ######### END contourdef initializations ################################################
 ######### BEGIN write integration routine ###############################################
 if ($numvar<1) {
     # if integrand free of Feynman parameters, write alternative integration routine,
     # that doesn't use (as not needed) Monte Carlo integration 
     no_numerical_int("$filename",$numvar,$kk,$point,$jj,$contourdef,$complexmasses);
 } else {
     ######### BEGIN definition MONTE CARLO parameters ###################################
     @declarations=();
     my $cubacores = $params{"cubacores"};
     if ($cubacores != 0) {
      push(@declarations,"char nbcores[12]=\"CUBACORES=$cubacores\"");
      push(@declarations,"putenv (nbcores)");
     }
     push(@declarations,"time_t start, end");
     push(@declarations,"double time_used[2]");
     push(@declarations,"const int ndim = $numvar");
     push(@declarations,"const int ncomp=1");
     if ($integrator == 6 ) {
	 push(@declarations,"int MAXEVAL = 10000");
	 push(@declarations,"double integral, error");
	 push(@declarations,"size_t NEVAL");
     } else {
	 push(@declarations,"int NREGIONS, NEVAL, FAIL");
	 push(@declarations,"const int MAXEVAL = $maxeval[$k]");
	 push(@declarations,"double integral[ncomp], error[ncomp], prob[ncomp]");
     }
#    push(@declarations,"double ESTIM[2], SIGMA[2], CHI[2]");
     push(@declarations,"double PROB[2]");
     push(@declarations,"int run=1");
     push(@declarations,"int method = $integrator");
     push(@declarations,"const double EPSREL=$epsrel[$k]");
     push(@declarations,"const double EPSABS=$epsabs[$k]");
     push(@declarations,"const int FLAGS=$flags");
     push(@declarations,"const int SEED=$seed");
     push(@declarations,"const int MINEVAL=$mineval[$k]");
     push(@declarations,"const char *STATEFILE=\"\"");
     push(@declarations,"const int nvec=1");
#     push(@declarations,"void *spin=NULL");
     if($integrator==1){
	 push(@declarations,"const int NSTART=$nstart[$k]");
	 push(@declarations,"const int NINCREASE=$nincrease[$k]");
	 push(@declarations,"const int NBATCH=1000");
	 push(@declarations,"const int GRIDNO=0");
	 $integratorcall="Vegas(ndim, ncomp, Integrand, &run, nvec,
	 EPSREL, EPSABS, FLAGS, SEED, MINEVAL, MAXEVAL, NSTART, 
	 NINCREASE, NBATCH, GRIDNO, STATEFILE, NULL,  
	 &NEVAL, &FAIL, integral, error, prob);\n";
     }elsif($integrator==2){
	 push(@declarations,"const int NNEW=$nnew[$k]");
	 push(@declarations,"const int NMIN=".$nnew[$k]/100);
	 push(@declarations,"const double FLATNESS=$flatness[$k]");
	 $integratorcall="Suave(ndim, ncomp, Integrand, &run, nvec,
	 EPSREL, EPSABS, FLAGS, SEED, MINEVAL, 
         MAXEVAL, NNEW, NMIN, FLATNESS, STATEFILE, NULL,
	 &NREGIONS, &NEVAL, &FAIL, integral, error, prob);\n";
     }elsif($integrator==3){
	 push(@declarations,"const int KEY1=$key1[$k]");
	 push(@declarations,"const int KEY2=$key2[$k]");
	 push(@declarations,"const int KEY3=$key3[$k]");
	 push(@declarations,"const int MAXPASS=$maxpass[$k]");
	 push(@declarations,"const double BORDER=$border[$k]");
	 push(@declarations,"const double MAXCHISQ=$maxchisq[$k]");
	 push(@declarations,"const double MINDEVIATION=$mindeviation[$k]");
	 push(@declarations,"const int NGIVEN=0");
	 push(@declarations,"const int LDXGIVEN=ndim");
	 push(@declarations,"double XGIVEN[1]={0.0}");
	 push(@declarations,"const int NEXTRA=$nextra[$k]");
	 $integratorcall="Divonne(ndim, ncomp, Integrand, &run, nvec,
	 EPSREL, EPSABS, FLAGS, SEED,
	 MINEVAL, MAXEVAL, KEY1, KEY2, KEY3, MAXPASS,
	 BORDER, MAXCHISQ, MINDEVIATION,
	 NGIVEN, LDXGIVEN, XGIVEN, NEXTRA, NULL, STATEFILE, NULL,
	 &NREGIONS, &NEVAL, &FAIL, integral, error, prob);\n";
     }elsif($integrator==4){
	 push(@declarations,"const int KEY=$key[$k]");
	 $integratorcall="Cuhre(ndim, ncomp, Integrand, &run, nvec,
	 EPSREL, EPSABS, FLAGS, MINEVAL, MAXEVAL, KEY, STATEFILE, NULL,
	 &NREGIONS, &NEVAL, &FAIL, integral, error, prob);\n";
     }elsif($integrator==6){
	 $integratorcall="F.function = &fgsl;\n F.params = &run;\n";
	 # 0 and 1 are integration boundaries:
	 $integratorcall="${integratorcall}gsl_integration_cquad(&F, 0, 1, EPSABS, EPSREL, w, &integral, &error, &NEVAL);\n";
     }
     $decs=join(";\n ",@declarations);
     #########END MONTE CARLO parameters #######################################
     ######### BEGIN integration REAL part ###################################################
     if($integrator==6){
         $intreal = "gsl_integration_cquad_workspace \* w = gsl_integration_cquad_workspace_alloc (MAXEVAL);\n";
         $intreal = "${intreal}  gsl_function F;\n";
         $intreal = "${intreal} //REAL part: \n";
     }else{
         $intreal = "//REAL part: \n";
     }
     $intreal = "${intreal} start = time(NULL);\n";
     $intreal = "${intreal} $integratorcall";
     $intreal = "${intreal} end = time(NULL);\n";
     $intreal = "${intreal} time_used[0] = ((double) (end - start));\n";
     if ($integrator==6) {
	 $intreal = "${intreal} PROB[0]=0.0;\n";
	 $intreal = "${intreal} cout << \"neval = \" << NEVAL << endl;\n";
	 $intreal = "${intreal} cout << \"result = \" << integral << \"+/-\" << error << endl;\n";
	 $intreal = "${intreal} cout << \"error probability real part= \" << PROB[0] << endl;\n\n";

	 $intreal = "${intreal} stringstream concatname; // string as stream\n";
	 $intreal = "${intreal} concatname << \"${kk}x\" << argv[1] << \"${jj}.out\"; // write to string stream\n";
	 $intreal = "${intreal} string file_name = concatname.str(); // get string out of stream\n\n";
	 $intreal = "${intreal} results.open(file_name.c_str());\n";
	 $intreal = "${intreal} if (results.is_open())\n";
	 $intreal = "${intreal} {\n";
	 $intreal = "${intreal}   results << setprecision (10) << \"Real part:\\nresult = \" << integral << \"\\nerror = \";\n";
	 $intreal = "${intreal}   results << setprecision (10) << error << endl;\n";
	 $intreal = "${intreal}   results << setprecision (4) <<\"time = \" << time_used[0]<< \"\\nerrorprob = \" << PROB[0];\n";	 
     } else {
	 $intreal = "${intreal} PROB[0]=prob[0];\n";
	 $intreal = "${intreal} if ( abs(PROB[0]) >= 1.0 ) PROB[0]=1.0;\n";
	 if ( $integrator > 1 ) { $intreal = "${intreal} cout<< \"nregions = \" << NREGIONS << \"\\n\";\n"; }
	 $intreal = "${intreal} cout << \"neval = \" << NEVAL << endl;\n";
	 $intreal = "${intreal} cout << \"fail = \" << FAIL << endl;\n";
	 $intreal = "${intreal} cout << \"result = \" << integral[0] << \"+/-\" << error[0] << endl;\n";
	 $intreal = "${intreal} cout << \"error probability real part= \" << PROB[0] << endl;\n\n";
	 
	 $intreal = "${intreal} stringstream concatname; // string as stream\n";
	 $intreal = "${intreal} concatname << \"${kk}x\" << argv[1] << \"${jj}.out\"; // write to string stream\n";
	 $intreal = "${intreal} string file_name = concatname.str(); // get string out of stream\n\n";
	 $intreal = "${intreal} results.open(file_name.c_str());\n";
	 $intreal = "${intreal} if (results.is_open())\n";
	 $intreal = "${intreal} {\n";
	 $intreal = "${intreal}   results << setprecision (10) << \"Real part:\\nresult = \" << integral[0]<< \"\\nerror = \";\n";
	 $intreal = "${intreal}   results << setprecision (10) << error[0] << endl;\n";
	 $intreal = "${intreal}   results << setprecision (4) <<\"time = \" << time_used[0]<< \"\\nerrorprob = \" << PROB[0];\n";
     }
     ######### END integration REAL part #####################################################
     ######### BEGIN integration CONTOURDEF ##################################################
     $intcontdef = " //IMAGINARY part: \n";
     $intcontdef = "${intcontdef} run=2;\n\n"; 
     $intcontdef = "${intcontdef} start = time(NULL);\n";
     $intcontdef = "${intcontdef} $integratorcall";
     $intcontdef = "${intcontdef} end = time(NULL);\n";
     $intcontdef = "${intcontdef} time_used[1] = ((double) (end - start));\n";
     if ($integrator==6) {
	 $intcontdef = "${intcontdef} PROB[1] = 0.0;\n";
	 $intcontdef = "${intcontdef} cout << \"neval = \" << NEVAL << endl;\n";
	 $intcontdef = "${intcontdef} cout << \"result = \" << integral << \"+/-\" << error << endl;\n";
	 $intcontdef = "${intcontdef} cout << \"error probability imaginary part= \"<< PROB[1] << endl;\n\n";
#        $intcontdef = "${intcontdef} integral[0]=integral[0]-1.0;\n"; #Add +1 for imag. integrand
	 $intcontdef = "${intcontdef} results.open(file_name.c_str(), ios::app);\n";
	 $intcontdef = "${intcontdef} if ( results.is_open() )\n";
	 $intcontdef = "${intcontdef} {\n\n";
	 $intcontdef = "${intcontdef}   results << setprecision (10) << \"\\n\\nImaginary part:\\nresult = \" << integral << endl;\n"; 
	 $intcontdef = "${intcontdef}   results << setprecision (10) << \"error = \" << error << endl;\n";
     } else {
	 $intcontdef = "${intcontdef} PROB[1] = prob[0];\n";
	 $intcontdef = "${intcontdef} if ( abs(PROB[1]) >= 1.0 ) PROB[1]=1.0;\n";
	 if ($integrator>1) { $intcontdef = "${intcontdef} cout << \"nregions = \" << NREGIONS << \"\\n\";\n"; }
	 $intcontdef = "${intcontdef} cout << \"neval = \" << NEVAL << endl;\n";
	 $intcontdef = "${intcontdef} cout << \"fail = \"<< FAIL << endl;\n";
	 $intcontdef = "${intcontdef} cout << \"result = \" << integral[0] << \"+/-\" << error[0] << endl;\n";
	 $intcontdef = "${intcontdef} cout << \"error probability imaginary part= \"<< PROB[1] << endl;\n\n";
#        $intcontdef = "${intcontdef} integral[0]=integral[0]-1.0;\n"; #Add +1 for imag. integrand
	 $intcontdef = "${intcontdef} results.open(file_name.c_str(), ios::app);\n";
	 $intcontdef = "${intcontdef} if ( results.is_open() )\n";
	 $intcontdef = "${intcontdef} {\n\n";
	 $intcontdef = "${intcontdef}   results << setprecision (10) << \"\\n\\nImaginary part:\\nresult = \" << integral[0] << endl;\n";
	 $intcontdef = "${intcontdef}   results << setprecision (10) << \"error = \" << error[0] << endl;\n";
     }
     $intcontdef = "${intcontdef}   results << setprecision (4) << \"time = \" << time_used[1] << \"\\nerrorprob = \" << PROB[1];\n";
     $intcontdef = "${intcontdef}   results << setprecision (4) << \"\\n\\nTime (s) = \"<< time_used[0]+time_used[1] <<endl; \n";
     $intcontdef = "${intcontdef}   results << setprecision (4) << \"MaxErrorprob = \"<< bigger(PROB[0],PROB[1]) <<\"\\n\\n\"; \n";
#    $intcontdef = "${intcontdef}   results << \"Lambda chosen = \";\n   for (int i = 0; i < $numberoffunctions; i++ )";
#    $intcontdef = "${intcontdef} \{ results << lambda[i] << \",\"; \}\n";
#    $intcontdef = "${intcontdef}   results << \"\\n Max possible lambda (with regard to the input) = \";\n   for (int i = 0; i < $numberoffunctions; i++ )";
#    $intcontdef = "${intcontdef} \{ results << lambdamax[i] << \",\"; \}\n";
#    $intcontdef = "${intcontdef}   results << \"\\n max deformation per Feynman parameter: \";\n";
#    $intcontdef = "${intcontdef} for (int i = 0; i < $numvar; i++ )\n   \{\n";
#    $intcontdef = "${intcontdef}    results << \"\\n\tFeynpar \" << i << \"   \";\n";
#    $intcontdef = "${intcontdef}    for (int j=0; j<$numberoffunctions; j++) \{results <<";
#    $intcontdef = "${intcontdef} taumax[j][i] << \", resulting lambda: \"<< lrs[j][i]*lambda[j]; \}\n";
#    $intcontdef = "${intcontdef} \}\n"; 
#    $intcontdef = "${intcontdef}   results << \"\\n Min modulus found = \";\n";
     
     ######### END integration CONTOURDEF ####################################################
     ######### BEGIN snippet close results ###################################################
     $closeres = " \}\n"; #end if results.is_open()
     $closeres = "${closeres} results.close();\n";
     ######### END snippet close results #####################################################
     ######### BEGIN snippet signcheck evaluation  ###########################################
     $signeval = " run = 0;\n for (int i = 0; i < $numberoffunctions; i++ )";
     $signeval = "${signeval} \{ ";
     $signeval = "${signeval}if(mintest[i]==0) run++; \}\n";
     $signeval = "${signeval} if (run>0) \{\n   cout << \"\\nWarning: Analytic continuation failed. ";
     $signeval = "${signeval}Please verify your graph definition/ScalarProductRules.\"<<endl;\n";
     $signeval = "${signeval}   exit (EXIT_FAILURE);\n \}\n";
     $signeval = "${signeval} run = 1;\n";
     ######### END snippet signcheck evaluation  #############################################
     
     open(INTFILE, ">", "$filename");
     print INTFILE "#include \"intfile.hh\"\n";
     #     print INTFILE "#include \"${soboldir}sobol.hh\"\n";
     #if ($integrator==6) {
     #    print INTFILE "#include \<gsl\/gsl_integration.h\>\n";
     #}
     print INTFILE "double f[1];\n";
#     print INTFILE "$esdefine";
     print INTFILE "$psqdefine";
     print INTFILE "$msqdefine";
     print INTFILE "$bgstdefine";
#     print INTFILE "double ${comparstring};\n";
     print INTFILE "double lambda[$numberoffunctions];\n";
     print INTFILE "double lrs[$numberoffunctions][$numvar];\n";
     #############################################################
     # include contour deformation declarations if contourdef=true
     #############################################################
     if($contourdef eq "True") {
	 print INTFILE "$contdefdecl";
     }elsif($complexmasses==1) {
	 print INTFILE "\n$myLog";
     }
     print INTFILE "\n$bigger";
     print INTFILE "$myatof";
     print INTFILE "$start";
######without optimlambda
# print INTFILE "for (int i1=0; i1<$numberoffunctions;i1++)\{ for (int i2=0; i2<$numvar;i2++)\{ lrs[i1][i2]=1.;\} \}";
#######necessary
     print INTFILE " //Integrator parameters START\n"; 
     print INTFILE " $decs;\n";
     print INTFILE " //Integrator parameters END\n";
     print INTFILE " const int nrfunc=$numberoffunctions;\n";
     print INTFILE " ofstream results;\n";
     ############################################################
     # include contour deformation initialisations 
     # if contourdef=true   
     ############################################################
     if($contourdef eq "True") {
	 print INTFILE "$contdefini";
     }
     else
     {
	 print INTFILE " for (int l=0; l<nrfunc;l++)\{ lambda[l]=$xlambda; \}\n";
	 print INTFILE " for (int l1=0;l1<nrfunc;l1++) \{ for (int l2=0;l2<$numvar;l2++) \{";
	 print INTFILE " lrs[l1][l2]=1.0;\}\}\n";
     }

#     if ($integrator ==6 ) {
#	 $callmaxeval =" MAXEVAL = 10000;\n";
#     } else {
#	 $callmaxeval =" MAXEVAL = $maxeval[$k];\n";
#     }
     #######BEGIN real part Monte Carlo integration ##############
     ######### BEGIN choose REAL/IMAG integration ################
     # if threshold-statement is true, you are above threshold and
     # the contour deformation should kick in
     if ( ($contourdef eq "True") && ($threshold ne "none") ) {
	 print INTFILE " if ($threshold)\n \{ \n";
	 print INTFILE " int evalopt = $evaloptlam;\n";
	 print INTFILE " findoptlam ($feynpars, evalopt, nrfunc);\n";
	 print INTFILE "$signeval //Main integration\n";
#	 print INTFILE "$callmaxeval";
	 print INTFILE "$intreal";
	 print INTFILE "$closeres";
	 print INTFILE "$intcontdef";
	 print INTFILE "$closeres";
	 print INTFILE " \} else \{\n"; #else no contourdef
	 print INTFILE " for (int l=0; l<nrfunc;l++) \{ lambda[l]=1.e-6; \}\n";#very small lambda, lambda=0 could maybe lead to instabilities
	 print INTFILE "$intreal";
	 print INTFILE "   results << setprecision (10) << \"\\n\\nImaginary part:\\nresult = \" << 0.0 << endl;\n"; 
	 print INTFILE "   results << setprecision (10) << \"error = \" << 0.0 << endl;\n";
	 print INTFILE "   results << setprecision (4) << \"time = \" << 0.0 << \"\\nerrorprob = \" << 0;\n";
	 print INTFILE "   results << setprecision (4) << \"\\n\\nTime (s) = \"<< time_used[0] <<endl; \n";
	 print INTFILE "   results << setprecision (4) << \"MaxErrorprob = \"<< PROB[0] <<\"\\n\\n\"; \n";
	 print INTFILE "$closeres";
	 print INTFILE "\}\n";
     }
     elsif(($contourdef eq "True") || ($params{"complexmasses"} == 1)) {     
	 if ($contourdef eq "True") {
	 print INTFILE " int evalopt = $evaloptlam;\n";
	 print INTFILE " findoptlam ($feynpars, evalopt, nrfunc);\n";
	 print INTFILE "$signeval //Main integration\n";
	 }
#	 print INTFILE "$callmaxeval";
	 print INTFILE "$intreal";
	 print INTFILE "$closeres";
	 print INTFILE "$intcontdef";
	 print INTFILE "$closeres";
     }
     else {
#	 print INTFILE "$callmaxeval";
	 print INTFILE "$intreal";
# following two lines added 31.10.14 GH	 
	 print INTFILE "   results << setprecision (4) << \"\\n\\nTime (s) = \"<< time_used[0] <<endl; \n";
	 print INTFILE "   results << setprecision (4) << \"MaxErrorprob = \"<< PROB[0] <<\"\\n\\n\"; \n";
	 print INTFILE "$closeres";
     }
     ######### END choose REAL/IMAG integration ##################
     print INTFILE " return 0;\n";
     print INTFILE "\}\n";

     if(($contourdef eq "True") || ($params{"complexmasses"} == 1)) {     
############################################################################################################
################ BEGIN optimization of lambda in C++ file ##################################################
     if($contourdef eq "True") {
	 print INTFILE "\nint findoptlam (const int dim, int maxeval,const int nrcomp)\n\{\n";
	 print INTFILE " double ti[dim];\n";
	 print INTFILE " long long int seed;\n";
	 print INTFILE " long long int seed_in;\n";
	 print INTFILE " long long int seed_out;\n";
	 if ($endpointflag) 
	 {
	     print INTFILE " double taumin[nrcomp];\n";
	 }
	 print INTFILE " double taumax2[nrcomp];\n";
   
	 print INTFILE " seed = 0;\n";
	 print INTFILE " for (int j=0; j<maxeval; j++)\n";
	 print INTFILE " \{\n";
	 print INTFILE "   seed_in = seed;\n";
	 print INTFILE "   i8_sobol ( dim, &seed, ti );\n";
	 print INTFILE "   seed_out = seed;\n";
	 
	 print INTFILE "   Integrand4(ti, nrcomp);\n";
	 print INTFILE " \}\n";
	 print INTFILE " for (int i1=0;i1<nrcomp;i1++)\n \{\n";
	 
	 if ($endpointflag) 
	 {
	     print INTFILE "  taumin[i1]=10000.;\n";
	     print INTFILE "  taumax2[i1]=0.;\n";
	     print INTFILE "  for (int i2=0;i2<dim;i2++)\n  \{\n";
	     print INTFILE "   if (taumax[i1][i2]<taumin[i1]) \{ taumin[i1]=taumax[i1][i2]; \}\n";
	     print INTFILE "   if (taumax[i1][i2]>taumax2[i1]) \{ taumax2[i1]=taumax[i1][i2]; \}\n";
	     print INTFILE "  \}\n";
	     print INTFILE "  for (int i2=0; i2 < dim; i2++)\n  \{\n";
	     print INTFILE "   if ( (taumax[i1][i2] >= 1.) || (taumin[i1]==0.) ) \{ lrs[i1][i2]=taumax[i1][i2]; \} else \{ lrs[i1][i2]=taumax[i1][i2]/taumin[i1];\} \n";
	     #     print INTFILE "   lrs[i1][i2]=taumax[i1][i2]/taumin[i1];\n";
	 } else {
	     print INTFILE "  taumax2[i1]=0.;\n";
	     print INTFILE "  for (int i2=0;i2<dim;i2++)\n  \{\n";
	     print INTFILE "   if (taumax[i1][i2]>taumax2[i1]) \{ taumax2[i1]=taumax[i1][i2]; \}\n";
	     print INTFILE "  \}\n";
	     print INTFILE "  for (int i2=0; i2 < dim; i2++)\n  \{\n";
	     print INTFILE "   if ( taumax[i1][i2] <= 1. ) \{ lrs[i1][i2]=1.; \} else \{ lrs[i1][i2]=1./taumax[i1][i2]; \} \n";
	     # print INTFILE "   lrs[i1][i2]=1./taumax[i1][i2];\n";
	 }
	 print INTFILE "  \}\n \}\n";
	 
	 print INTFILE " seed = 0;\n";
	 print INTFILE " for (int j=0; j<maxeval; j++)\n";
	 print INTFILE " \{\n";
	 print INTFILE "   seed_in = seed;\n";
	 print INTFILE "   i8_sobol ( dim, &seed, ti );\n";
	 print INTFILE "   seed_out = seed;\n";
	 # ratio check
	 print INTFILE "   Integrand2(ti, nrcomp);\n \}\n";
	 print INTFILE " for ( int i=0; i<nrcomp; i++ )\n";
	 print INTFILE " \{\n  if ( r[i] < 0 )\n";
	 print INTFILE "  \{\n   if ( r[i] > -1.e-3 ) \{ if ( taumax2[i] < lambda[i]) \{ lambda[i] = taumax2[i];\} \} else \{ if ( 1./sqrt(-r[i]) < lambda[i]) \{ lambda[i] = 1./sqrt(-r[i]); \} \}\n  \}\n"; 
	 # print INTFILE "  \{\n   if ( r[i] > -1.e-3 ) \{ lambda[i] = taumax2[i]; \} else \{ lambda[i] = 1./sqrt(-r[i]); \}\n  \}\n";
	 print INTFILE "  lambdamax[i] = lambda[i];\n \}\n";
	 
	 print INTFILE " for (int i=0; i<10; i++)\n";
	 print INTFILE " \{\n  for (int j=0; j<nrcomp; j++)\n";
	 print INTFILE "  \{\n";
	 print INTFILE "   lambdatest[j][i]=lambdamax[j]*(double)(10-i)/10.0;\n"; #tested to be worse:*pow(0.01,i/10.); 
	 #     print INTFILE "   m[j][i]=100000.;\n";
	 print INTFILE "  \}\n";
	 print INTFILE " \}\n";
	 
	 print INTFILE " seed = 0;\n";
	 print INTFILE " for (int j=0; j<maxeval; j++)\n";
	 print INTFILE " \{\n";
	 print INTFILE "   seed_in = seed;\n";
	 print INTFILE "   i8_sobol ( dim, &seed, ti );\n";
	 print INTFILE "   seed_out = seed;\n";
	 # modulus check 
	 print INTFILE "   Integrand3(ti, nrcomp);\n";
	 print INTFILE " \}\n";
	 print INTFILE " for (int j=0; j < nrcomp; j++)\n";
	 print INTFILE " \{\n";
	 print INTFILE "  for (int i=0; i < 10; i++)\n";
	 print INTFILE "  \{\n";
	 print INTFILE "    if ( m[j][i] > mintest[j] ) \{ lambda[j]=lambdatest[j][i]; mintest[j]=m[j][i]; \}\n";
	 print INTFILE "  \}\n";
	 print INTFILE "   cout<<\"lambda[\"<<j<<\"] = \"<<lambda[j]<<endl;\n";
	 print INTFILE " \}\n";
	 
	 if ($oscillatory) 
	 {
	     print INTFILE " for (int j=0; j<nrcomp; j++)\n";
	     print INTFILE " \{\n  for (int i=0; i<10; i++)\n";
	     print INTFILE "  \{\n";
	     print INTFILE "   lambdatest[j][i]=lambda[j]*(double)(10-i)/10.0;\n"; #tested to be worse:*pow(0.01,(double)(i)/10.); \n"; 
	     print INTFILE "   a[j][i]=0.0;\n";
	     print INTFILE "  \}\n";
	     print INTFILE "  argtest[j]=100000.;\n";
	     print INTFILE " \}\n";
	     
	     print INTFILE " seed = 0;\n";
	     print INTFILE " for (int j=0; j<maxeval; j++)\n";
	     print INTFILE " \{\n";
	     print INTFILE "   seed_in = seed;\n";
	     print INTFILE "   i8_sobol ( dim, &seed, ti );\n";
	     print INTFILE "   seed_out = seed;\n";
	     
	     print INTFILE "   Integrand5(ti, nrcomp);\n";
	     print INTFILE " \}\n";
	     print INTFILE "  cout<<\"after check of complex argument:\"<<endl;\n";
	     print INTFILE " for (int j=0; j < nrcomp; j++)\n";
	     print INTFILE " \{\n";
	     print INTFILE "  for (int i=0; i < 10; i++)\n";
	     print INTFILE "  \{\n";
	     print INTFILE "    if ( a[j][i] < argtest[j] ) \{ lambda[j]=lambdatest[j][i]; argtest[j]=a[j][i]; \}\n";
	     print INTFILE "  \}\n";
	     print INTFILE "  cout<<\"lambda[\"<<j<<\"] = \"<<lambda[j]<<endl;\n";
	     print INTFILE " \}\n";
	 } 
	 print INTFILE " return 0;\n\}\n";
	 
	 if ($oscillatory) 
	 {
	     print INTFILE "\nint Integrand5 (const double xx[], const int ncomp)\n\{\n";
	     print INTFILE " double f0[$numberoffunctions];\n";
	     print INTFILE " for (int ipass=0; ipass<10; ipass++)\n \{\n";
	     print INTFILE "$argcall";
	     print INTFILE "  for (int i=0; i<ncomp; i++ )\n  \{\n";
	     print INTFILE "   if (f0[i] > a[i][ipass] ) \{ a[i][ipass] = f0[i];\}\n";
	     print INTFILE "  \}\n";
	     print INTFILE " \}\n";
	     print INTFILE " return 0;\n\}\n";
	 }
	 # individual lambda adjustments
	 print INTFILE "\nint Integrand4 (const double xx[],const int ncomp)\n";
	 print INTFILE "\{\n";
	 print INTFILE " double f0[$numberoffunctions][$numvar];\n";
	 print INTFILE "$taucall";
	 print INTFILE " for (int i1=0;i1<$numberoffunctions;i1++)\n";
	 print INTFILE " \{\n";
	 print INTFILE "  for (int i2=0;i2<$numvar;i2++)\n";
	 print INTFILE "  \{\n";
	 print INTFILE "   if (abs(f0[i1][i2])>taumax[i1][i2]){taumax[i1][i2]=abs(f0[i1][i2]);}\n";
	 print INTFILE "  \}\n";
	 print INTFILE " \}\n";
	 print INTFILE " return 0;\n\}\n";
	 # modulus check and sign check
	 print INTFILE "\nint Integrand3 (const double xx[], const int ncomp)\n\{\n";
	 print INTFILE " double f0[$numberoffunctions];\n";
	 print INTFILE " double s0[$numberoffunctions];\n";
	 print INTFILE " for (int ipass=0; ipass<10; ipass++)\n \{\n";
	 print INTFILE "$modcall";
	 print INTFILE "$signcall";
	 print INTFILE "  for (int i=0; i<ncomp; i++ )\n  \{\n";
	 print INTFILE "   if (f0[i] < m[i][ipass] ) \{ m[i][ipass] = f0[i];\}\n";
	 print INTFILE "   if (s0[i] > 0.0 ) \{ m[i][ipass]=0;\}\n";
	 print INTFILE "  \}\n";
	 print INTFILE " \}\n";
	 print INTFILE " return 0;\n\}\n";
	 
	 #print INTFILE "  if (f0[i] > m[i] ) \{ m[i] = f0[i]; lambda[i] = lambdamax[i]; \}\n \}\n return 0;\n\}\n";
	 print INTFILE "\nint Integrand2 (const double xx[], const int ncomp)\n\{\n double f0[$numberoffunctions];\n";
	 print INTFILE "$ratiocall";
	 print INTFILE " for ( int i=0; i<ncomp; i++ )\n \{\n";
	 print INTFILE "  if (f0[i] < r[i] ) \{ r[i] = f0[i]; \}\n \}\n return 0;\n\}\n";
      
##################### END optimization of lambda in C++ file ###############################################
############################################################################################################
##################### BEGIN sum evaluated functions in C++ file ############################################
     } # end if contourdef==True; the following code will also be written for complex masses
	 if ($integrator != 6) {
	     print INTFILE "\nint Integrand (const int *ndim, const double x[], const int *ncomp, double f[], void *userdata)\n";
	     print INTFILE "{\n";
	     print INTFILE " dcmplx f0[$numberoffunctions];\n";
	     print INTFILE "$functioncall";
	     print INTFILE " int ii =0;\n";
	     print INTFILE " if (*(int*)userdata == 1)\n \{\n";
	     print INTFILE " f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=real(f0[ii]);ii++; \}\n";
	     print INTFILE " \} else \{\n";
#            print INTFILE " f[0]=1.0;\n";
	     print INTFILE " f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=imag(f0[ii]);ii++; \}\n";
	     print INTFILE " \}\n";  
	     print INTFILE " return 0;\n";
	     print INTFILE "\}";
	 } else {
	     print INTFILE "\ndouble fgsl (double y, void * params)\n";
	     print INTFILE "{\n";
	     print INTFILE "const double * x= &y;\n";
	     print INTFILE " dcmplx f0[$numberoffunctions];\n";
	     print INTFILE "$functioncall";
	     print INTFILE " int ii =0;\n";
	     print INTFILE " if (*(int *)params == 1)\n \{\n";
	     print INTFILE " f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=real(f0[ii]);ii++; \}\n";
	     print INTFILE " \} else \{\n";
#            print INTFILE " f[0]=1.0;\n";
	     print INTFILE " f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=imag(f0[ii]);ii++; \}\n";
	     print INTFILE " \}\n";  
	     print INTFILE " return f[0];\n";
	     print INTFILE "\}";
	 }
     } else { #else: if contourdef=false, masses are real, and integral is not complex
	 if ($integrator != 6) {
	     print INTFILE "\nint Integrand (const int *ndim, const double x[], const int *ncomp, double f[], void *userdata)\n";
	     print INTFILE "{\n";
	     print INTFILE "  double f0[$numberoffunctions];\n";
	     print INTFILE " $functioncall";
	     print INTFILE "  int ii =0;\n";
	     print INTFILE "  f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=f0[ii];ii++; \}\n";
	     print INTFILE "  return 0;\n";
	     print INTFILE "\}";
	 } else { #else: if contourdef=false integral is not complex
	     print INTFILE "\ndouble fgsl (double y, void * params)\n";
	     print INTFILE "{\n";
	     print INTFILE "const double * x= &y;\n";
	     print INTFILE "  double f0[$numberoffunctions];\n";
	     print INTFILE " $functioncall";
	     print INTFILE "  int ii =0;\n";
	     print INTFILE "  f[0]=0.0;\n";
	     print INTFILE "  while (ii<$numberoffunctions) \{ f[0]+=f0[ii];ii++; \}\n";
	     print INTFILE "  return f[0];\n";
	     print INTFILE "\}";
	 }
     }
 
##################### END sum evaluated functions in C++ file ##############################################
     close INTFILE;
 }
############ END write integration routine #################################################################
############################################################################################################
};

sub no_numerical_int
{
    my $filename = $_[0];
    my $numvar = $_[1];
    my $kk = $_[2];
    my $point = $_[3];
    my $jj = $_[4];
    my $contourdef=$_[5];
    my $complexmasses=$_[6];
    
    open(INTFILE, ">", "$filename");
    print INTFILE "#include \"intfile.hh\"\n";
    print INTFILE "$psqdefine";
    print INTFILE "$msqdefine";
#    print INTFILE "${comparstring};\n";
    print INTFILE "$bgstdefine";
    #  print INTFILE "$lrsdefine";
    print INTFILE "double lambda[$numberoffunctions];\n";
    print INTFILE "double lrs[$numberoffunctions][$numvar];\n";
    if(($contourdef eq "True") || ($complexmasses == 1)) 
    {
	print INTFILE "\n$myLog";
    }
    print INTFILE "\n$bigger";
    print INTFILE "$myatof";
    print INTFILE "$start";
    print INTFILE " time_t start, end;\n";
    print INTFILE " double time_used[1], ESTIM[2], SIGMA[2], PROB[2];\n";
    print INTFILE " const int nrfunc=$numberoffunctions;\n";
    if (($contourdef eq "True") || ($complexmasses == 1)) 
    {
        print INTFILE " dcmplx f0[$numberoffunctions];\n";
	print INTFILE " double fimag=0.0;\n";
    } else {
	print INTFILE " double f0[$numberoffunctions];\n";
    }
    print INTFILE " double freal=0.0;\n";
    print INTFILE " int ii=0.0; \n";
    ######### BEGIN for compatibility with function definition in f*.cc ##################
    print INTFILE " const double x[1]={1.0};\n"; #dummy random number 
    print INTFILE " for (int l=0; l<nrfunc;l++)\{ lambda[l]=1.0; \}\n"; #dummy lambda
    print INTFILE " for (int l1=0;l1<nrfunc;l1++) \{ for (int l2=0;l2<$numvar;l2++) \{";
    print INTFILE " lrs[l1][l2]=1.0;\}\}\n";
    ######### END make compatible ########################################################

    print INTFILE " start = time(NULL);\n";

    ######### BEGIN compute function #####################################################
    print INTFILE "$functioncall";
    if(($contourdef eq "True") || ($complexmasses == 1)) {
	print INTFILE " while (ii<$numberoffunctions) \{ freal+=real(f0[ii]);ii++; \}\n";
	print INTFILE " ESTIM[0]=freal;\n";
	print INTFILE " SIGMA[0]=0.0;\n";
	print INTFILE " PROB[0]=0.0;\n";
	print INTFILE " ii=0.0; \n";
	print INTFILE " while (ii<$numberoffunctions) \{ fimag+=imag(f0[ii]);ii++; \}\n";
	print INTFILE " ESTIM[1]=fimag;\n";
	print INTFILE " SIGMA[1]=0.0;\n";
	print INTFILE " PROB[1]=0.0;\n";
    } else { 
	print INTFILE " while (ii<$numberoffunctions) \{ freal+=f0[ii];ii++; \}\n";
	print INTFILE " ESTIM[0]=freal;\n";
	print INTFILE " SIGMA[0]=0.0;\n";
	print INTFILE " PROB[0]=0.0;\n";
	print INTFILE " PROB[1]=PROB[0];\n"; 
    } 
    ######### END compute function #######################################################

    print INTFILE " end = time(NULL);\n";
    print INTFILE " time_used[0] = ((double) (end - start));\n";

    ######### BEGIN write output to file #################################################
    print INTFILE " ofstream results;\n";
    print INTFILE " stringstream concatname; // string as stream\n";
    print INTFILE " concatname << \"${kk}x\" << argv[1] << \"${jj}.out\"; // write to string stream\n";
    print INTFILE " string file_name = concatname.str(); // get string out of stream\n\n";

    print INTFILE " results.open(file_name.c_str());\n";
    print INTFILE " if (results.is_open())\n";
    print INTFILE "  {\n";
    print INTFILE "    results << setprecision (10) << \"Real part:\\nresult = \" <<ESTIM[0] << \"\\nerror = \" << SIGMA[0] << endl;\n";
    print INTFILE "    results << setprecision (4) << \"time = \" << time_used[0]/2. << \"\\nerrorprob = \" << PROB[0];\n";
    
    if(($contourdef eq "True") || ($complexmasses == 1)) {
	print INTFILE "    results << setprecision (10) << \"\\n\\nImaginary part:\\nresult = \" << ESTIM[1] << \"\\nerror = \" << SIGMA[1];\n";
	print INTFILE "    results << setprecision (4) << \"\\ntime = \" << time_used[0]/2. << \"\\nerrorprob = \" << PROB[1];\n";
    }
    
    print INTFILE "    results << setprecision (4) << \"\\n\\nTime (s) = \"<< time_used[0] << endl; \n";
    print INTFILE "    results << setprecision (4) << \"MaxErrorprob = \"<< bigger(PROB[0],PROB[1]) << endl;\n";
    print INTFILE "  \}\n";
    print INTFILE "  results.close();\n";
    ######### END write output to file ###################################################

    print INTFILE " return 0;\n";
    print INTFILE "\}";
    close INTFILE;
}

1; 

