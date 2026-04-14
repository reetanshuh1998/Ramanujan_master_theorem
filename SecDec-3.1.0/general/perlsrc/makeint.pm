  #****p* SecDec/general/perlsrc/makeint.pm
  #  NAME
  #    makeint.pm
  #
  #  USAGE
  #  is called from preparenumerics.pl via writefiles::makeint
  # 
  #  USES 
  #
  #  $paramfile, header.pm, arguements parsed from preparenumerics.pl
  #
  #  USED BY 
  #    
  #  preparenumerics.pl, writefiles.pm
  #
  #  PURPOSE
  #  writes the fortran files *intfile*.f in the appropriate subdirectory
  #    
  #  INPUTS
  #  
  #  arguments:
  #  filename:name and directory of the *intfile*.f to be written
  #  jj:epsilon order
  #  kk:which integration file is to be written, specifies *intfile$kk.f
  #  numvar: number of integration variables
  #  maxpole: maximal pole for this pole structure (can be spurious)
  #  paramfile: file to read parameters from
  #  integrand:name of function to integrate
  #
  #  parameters read from $paramfile:
  #  graph:name of graph
  #  point:name of numerical point being calculated
  #  @stupoint:array of mandelstam variables
  #  @psq:array of values of external momenta^2
  #  @msq:array of propagator masses
  #  @ncall:number of calls BASES uses
  #  @iter1:number of interations BASES uses for its first run
  #  @iter2:number of interations BASES uses for its second run
  #  @acc1:accuracy BASES aims for on its first run
  #  @acc2:accuracy BASES aims for on its second run
  #  cuba parameters - see Cuba-4.1/Cuba.pdf
  #  externalegs:number of external legs for the process
  #
  #  
  #    
  #  RESULT
  #  new functions *sf*.f in the appropriate subdirectory graph/polestructure/epsilonorder/(number of independent variables/)
  #    
  #  SEE ALSO
  #  preparenumerics.pl
  #   
  #****
  ##@ARGV=filename,order,number to group,number of group,number of variables,maxpole(can be spurious)##
use lib "perlsrc";
use Fraction ':constants';
use header;
package makeint;

sub go {
my $filename=$_[0];
my $jj=$_[1];
my $kk=$_[2];
my $numvar=$_[3];
my $maxpole=$_[4];
my $paramfile=$_[5];
my $integrand=$_[6];
my $routine=$_[7];
my $overallmaxpole=$_[8];
unless ($routine) { $routine=0 };
    
my %hash_var=header::readparams($paramfile);

my $graph=$hash_var{"graph"};
my $point=$hash_var{"pointname"};
####correct routine defined in preparenumerics.pl ##
#e.g. Divonne and Cuhre can only do integrations 
#with more than 1 Feynman parameter
#my $routine=$hash_var{"integrator"};
####################################################
my $seed=$hash_var{"seed"};
my $k = $jj + $overallmaxpole;
# maxpole changed to -overallmaxpole by GH 18.9.15 in order to have 
# uniform epsrel etc values for each order in eps, regardless of the current pole structure
if($routine==0){#bases
    @ncall = split(/,/,$hash_var{"ncall"});
    @iter1 = split(/,/,$hash_var{"iter1"});
    @iter2 = split(/,/,$hash_var{"iter2"});
    @acc1 = split(/,/,$hash_var{"acc1"});
    @acc2 = split(/,/,$hash_var{"acc2"});
    unless($ncall[$k]){$ncall[$k]=2500000};
    unless($acc1[$k]){$acc1[$k]="0.1d0"};
    unless($acc2[$k]){$acc2[$k]="0.1d0"};
    unless($iter1[$k]){$iter1[$k]=12};
    unless($iter2[$k]){$iter2[$k]=12};
} else {
    @epsrel=split(/,/,$hash_var{"epsrel"});
    unless($epsrel[$k]){$epsrel[$k]="1d-3"};
    @epsabs=split(/,/,$hash_var{"epsabs"});
    unless($epsabs[$k]){$epsabs[$k]="1d-12"};
    $flags=$hash_var{"cubaflags"};
    if ($flags ne "0"){unless($flags){$flags=2}};
    @mineval=split(/,/,$hash_var{"mineval"});
    unless ($mineval[$k]){$mineval[$k]=0};
    @maxeval=split(/,/,$hash_var{"maxeval"});
    unless ($maxeval[$k]){$maxeval[$k]=100000000};
    if ($routine==1) {#vegas
	@nstart=split(/,/,$hash_var{"nstart"});
	unless($nstart[$k]){$nstart[$k]=1000000};
	@nincrease=split(/,/,$hash_var{"nincrease"});
	unless($nincrease[$k]){$nincrease[$k]=500000};
    } elsif ($routine==2) {#suave
	@nnew=split(/,/,$hash_var{"nnew"});
	unless($nnew[$k]) {$nnew[$k]=1000000};
	@flatness=split(/,/,$hash_var{"flatness"});
	unless($flatness[$k]) { $flatness[$k]="1d0" };
    } elsif ($routine==3) {#divonne
	@key1=split(/,/,$hash_var{"key1"});
	unless($key1[$k]){$key1[$k]=1500};
	@key2=split(/,/,$hash_var{"key2"});
	unless($key2[$k]){$key2[$k]=1};
	@key3=split(/,/,$hash_var{"key3"});
	unless($key3[$k]){$key3[$k]=1};
	@maxpass=split(/,/,$hash_var{"maxpass"});
	unless($maxpass[$k]){$maxpass[$k]=5};
	@border=split(/,/,$hash_var{"border"});
	if($border[$k] ne "0") {
	    unless($border[$k]){ $border[$k]="1D-8" }};
	@maxchisq=split(/,/,$hash_var{"maxchisq"});
	unless($maxchisq[$k]){$maxchisq[$k]="1d0"};
	@mindeviation=split(/,/,$hash_var{"mindeviation"});
	unless($mindeviation[$k]){$mindeviation[$k]=".25d0"};
	@nextra=split(/,/,$hash_var{"nextra"});
	unless($nextra[$k]){$nextra[$k]=0};
    } elsif ($routine==4) {#cuhre
	@key=split(/,/,$hash_var{"key"});
	unless($key[$k]){$key[$k]=7};
    }
}  

@comparlist=split(/,/,$hash_var{"symbconstants"});

my @comparvalsM=split(/,/,$hash_var{"pointvalues"});
my @comparvals=();

foreach $s (@comparvalsM) {
    chomp;
    $s=~s/[eE]([+-]?\d+)/*10**$1/g;
    $s=~s/[\^]([+-]?\d+)/**$1/g;
    $sE=eval($s);
    push(@comparvals,$sE);
}

if(@comparlist) {
    $comparstring="common/params/";
    foreach $par (@comparlist) {
	$comparstring="$comparstring,$par"
    }
    $comparstring=~s/\/,/\//g;
    $assparstring="";
    $compnum=0;
    foreach $par (@comparlist) {
	if($comparvals[$compnum]){
	    $assparstring="$assparstring      $par = $comparvals[$compnum]\n"
	}
	$compnum++
    }
}

if(-e $filename){system("rm -f $filename")};


open(INTFILE, ">", "$filename");
		
print INTFILE "c         eps\^$jj coefficient of $graph \n";
print INTFILE "c      \n";
print INTFILE "      program G${graph}\n";
print INTFILE "      implicit double precision (a-h,o-z)\n";
print INTFILE "      character(*) OUTFILE\n";
print INTFILE "      integer ndi\n";
print INTFILE "      parameter (MXDIM=50,  \n";
print INTFILE "     & OUTFILE='${kk}x${point}$jj\.out')\n";
if ($routine==0) {
    print INTFILE "      external $integrand\n";
    print INTFILE "      integer t1(3),t2\n";
} else {
    print INTFILE "      external integrand\n";
    print INTFILE "      double precision $integrand\n";
}
print INTFILE "      dimension xch($numvar)\n";
print INTFILE "      common /ndimen/ndi\n";
print INTFILE "      $comparstring\n";

if ( $numvar>0 ) { 
    if($routine==0) {
	print INTFILE "c      \n";
	print INTFILE "c     common blocks needed by BASES:\n";
	print INTFILE "c        \n";
	print INTFILE "      common /BPARM1/ XL(MXDIM),XU(MXDIM),NDIM,NWILD,IG(MXDIM),NCALL\n";
	print INTFILE "      common /BPARM2/ ACC1,ACC2,ITMX1,ITMX2\n";
	print INTFILE "      common /USERSEED/iseed\n";
	print INTFILE "c        \n";
	print INTFILE "c        \n";
    } else {
	print INTFILE "      integer ndim, ncomp, mineval, maxeval, flags, seed\n";
	print INTFILE "      double precision epsrel, epsabs,cput1,cput2,cput,userdata\n";
	print INTFILE "      parameter (ndim = $numvar)\n";
	print INTFILE "      parameter (seed = 0)\n";
	print INTFILE "      parameter (userdata = 0)\n";
	print INTFILE "      parameter (ncomp = 1)\n";
	print INTFILE "      parameter (epsrel = $epsrel[$k])\n";
	print INTFILE "      parameter (epsabs = $epsabs[$k])\n";
	print INTFILE "      parameter (flags = $flags)\n";
	print INTFILE "      parameter (mineval = $mineval[$k])\n";
	print INTFILE "      parameter (maxeval = $maxeval[$k])\n";
	unless ($routine==1) {
	    print INTFILE "      integer nregions\n";
	};
 	print INTFILE "      integer neval,fail\n";
	print INTFILE "      double precision integral(ncomp),error(ncomp),prob(ncomp)\n";
	print INTFILE "      character*(*) statefile\n";
	print INTFILE "      parameter (statefile = \"\")\n";
	if ($routine==1) {
	    print INTFILE "      integer nstart,nincrease,nbatch,gridno\n";
	    print INTFILE "      parameter (nstart = $nstart[$k])\n";
	    print INTFILE "      parameter (nincrease = $nincrease[$k])\n";
	    print INTFILE "      parameter (nbatch = 1000)\n";
	    print INTFILE "      parameter (gridno = 0)\n";
	} elsif ($routine==2) {
	    print INTFILE "      integer nnew\n";
	    print INTFILE "      double precision flatness\n";
	    print INTFILE "      parameter (nnew=$nnew[$k])\n";
	    print INTFILE "      parameter (nmin=".($nnew[$k]/100).")\n";
	    print INTFILE "      parameter (flatness=$flatness[$k])\n";
	} elsif ($routine==3) {
	    print INTFILE "      integer key1,key2,key3,maxpass,nxgiven,ldxgiven,nextra\n";
	    print INTFILE "      double precision border,maxchisq,mindeviation\n";
	    print INTFILE "      parameter (key1=$key1[$k])\n";
	    print INTFILE "      parameter (key2=$key2[$k])\n";
	    print INTFILE "      parameter (key3=$key3[$k])\n";
	    print INTFILE "      parameter (maxpass=$maxpass[$k])\n";
	    print INTFILE "      parameter (ngiven=0)\n";
	    print INTFILE "      parameter (ldxgiven=ndim)\n";
	    print INTFILE "      parameter (nextra=$nextra[$k])\n";
	    print INTFILE "      parameter (border=$border[$k])\n";
	    print INTFILE "      parameter (maxchisq=$maxchisq[$k])\n";
	    print INTFILE "      parameter (mindeviation=$mindeviation[$k])\n";
	} else {
	    print INTFILE "      integer key\n";
	    print INTFILE "      parameter (key=$key[$k])\n";
	}
    }
    print INTFILE "      ndi = $numvar\n";
} #end if numvar>0
print INTFILE "c        \n";
print INTFILE "$assparstring";
print INTFILE "c        \n";
print INTFILE "      open (10,file=OUTFILE,status='unknown') \n";
if ( $numvar>1 ) { 
    print INTFILE "      do k=1,ndi\n";
    print INTFILE "       xch(k)=1d-1\n";
    print INTFILE "      enddo\n";
} else {  
    print INTFILE "      xch=0.1d0\n"; 
} 
print INTFILE "      xcr=$integrand(xch)\n";
print INTFILE "      if (xcr .ne. xcr) then\n";
print INTFILE "       write(10,100) 'result = ',xcr\n";
print INTFILE "       call exit(91)\n";
print INTFILE "      endif\n";
if ( $numvar>0 ) {
    if ($routine==0) {
	print INTFILE "c        \n";
	print INTFILE "c        \n";
	print INTFILE "c        \n";
	if ($seed) {
	    print INTFILE "      call itime(t1)\n";
	    print INTFILE "      iseed=t1(1)*t1(2)*t1(3)\n";
	} else {
	    print INTFILE "      iseed=12345\n";
	}
	print INTFILE "      call BSINIT \n"; 
	print INTFILE "      NDIM=ndi\n";
	print INTFILE "      do k=1,NDIM\n";
	print INTFILE "      XL(k)=0.d0\n";
	print INTFILE "      XU(k)=1.d0\n";
	print INTFILE "      IG(k)=1\n";
	print INTFILE "      enddo\n";
	print INTFILE "      NWILD=ndi\n";
	print INTFILE "      NCALL=$ncall[$k]\n";
 	print INTFILE "      ACC1 =$acc1[$k]\n";
 	print INTFILE "      ACC2 =$acc2[$k]\n";
 	print INTFILE "      ITMX1=$iter1[$k]\n";
 	print INTFILE "      ITMX2=$iter2[$k]\n";
 	print INTFILE "c         \n";              
 	print INTFILE "c          \n";  
 	print INTFILE "      call BASES($integrand,ESTIM,SIGMA,CTIME,IT1,IT2)  \n";
	print INTFILE "c        \n";   
	print INTFILE "      write(10,100) 'result       =',ESTIM \n";
	print INTFILE "      write(10,100) 'error        =',SIGMA\n";
	print INTFILE "      write(10,102) 'CPUtime (s) =',CTIME\n";
	print INTFILE "      write(10,*) 'MaxErrorprob = not accessible'\n";
	print INTFILE "      write(10,*)   \n";
	print INTFILE "      close (10)\n";
	print INTFILE "c        \n";
	print INTFILE "      if (ESTIM .ne. ESTIM) then\n";
	print INTFILE "       call exit(91)\n";
	print INTFILE "      endif\n";
	print INTFILE "      if (SIGMA .ne. 0d0) then\n";
	print INTFILE "       errdec=ESTIM/(1d2 *SIGMA)\n";
	print INTFILE "       if (errdec .lt. 1d-1) then\n";
	print INTFILE "        if (ESTIM .gt. 1d7) then\n";
	print INTFILE "         call exit(90)\n";
	print INTFILE "        endif\n";
	print INTFILE "       endif\n";
	print INTFILE "      endif\n";
	print INTFILE "      if (ESTIM .gt. 1d17) then\n";
	print INTFILE "       call exit(89)\n";
	print INTFILE "      endif\n";
    } else {
	print INTFILE "      call cpu_time(cput1)\n";
	if ($routine==1) {
	    print INTFILE "      call vegas(ndim, ncomp, integrand, userdata,1,\n";
	    print INTFILE "     & epsrel, epsabs, flags, seed, mineval, maxeval,\n";
	    print INTFILE "     & nstart, nincrease, nbatch, gridno, statefile,-1,\n";
	    print INTFILE "     & neval, fail, integral, error, prob)\n";
	} elsif($routine==2) {
	    print INTFILE "      call suave(ndim, ncomp, integrand,userdata,1,\n";
	    print INTFILE "     & epsrel, epsabs, flags, seed,mineval, maxeval,\n";
	    print INTFILE "     & nnew, nmin, flatness, statefile,-1,\n";
	    print INTFILE "     & nregions, neval, fail, integral, error, prob)\n";
	} elsif($routine==3) {
	    print INTFILE "      call divonne(ndim, ncomp, integrand,userdata,1,\n";
	    print INTFILE "     & epsrel, epsabs, flags, seed,mineval, maxeval,\n";
	    print INTFILE "     & key1, key2, key3, maxpass,\n";
	    print INTFILE "     & border, maxchisq, mindeviation,\n";
	    print INTFILE "     & ngiven, ldxgiven, 0, nextra, 0, statefile,-1,\n";
	    print INTFILE "     & nregions, neval, fail, integral, error, prob)\n";
	} else {
	    print INTFILE "      call cuhre(ndim, ncomp, integrand,userdata,1,\n";
	    print INTFILE "     & epsrel, epsabs, flags, mineval, maxeval,\n";
	    print INTFILE "     & key, statefile,-1,\n";
	    print INTFILE "     & nregions, neval, fail, integral, error, prob)\n";
	}
	print INTFILE "      call cpu_time(cput2)\n";
	print INTFILE "      cput=cput2-cput1\n";
	unless ( $routine==1 ) { print INTFILE "      write(*,*) \"nregions = \",nregions\n" };
	print INTFILE "      write(*,*) \"neval = \",neval\n";
	print INTFILE "      write(*,*) \"fail = \",fail\n";
	print INTFILE "      write(*,102) \"error probability = \",prob(1) \n";
	print INTFILE "      write(10,100) 'result = ',integral(1) \n";
	print INTFILE "      write(10,100) 'error = ',error(1)\n";
	print INTFILE "      write(10,102) 'CPUtime (s) = ',cput\n";
	print INTFILE "      if (abs(prob(1)) .gt. 1) then\n";
	print INTFILE "       write(10,102) 'MaxErrorprob = ',1d0\n";
	print INTFILE "      else\n";
	print INTFILE "       write(10,102) 'MaxErrorprob = ',prob(1)\n";
	print INTFILE "      endif\n";
	print INTFILE "      write(10,*)   \n";
	print INTFILE "c        \n";
	print INTFILE "      close (10)\n";
	print INTFILE "      if (integral(1) .ne. integral(1)) then\n";
	print INTFILE "       call exit(91)\n";
	print INTFILE "      endif\n";
	print INTFILE "      if (error(1) .ne. 0d0) then\n";
	print INTFILE "       errdec=integral(1)/(1d2 *error(1))\n";
	print INTFILE "       if (errdec .lt. 1d-1) then\n";
	print INTFILE "        if (integral(1) .gt. 1d7) then\n";
	print INTFILE "         call exit(90)\n";
	print INTFILE "        endif\n";
	print INTFILE "       endif\n";
	print INTFILE "      endif\n";
	print INTFILE "      if (integral(1) .gt. 1d17) then\n";
	print INTFILE "       call exit(89)\n";
	print INTFILE "      endif\n";
    }
} #end if $numvar>0 
else { 
    print INTFILE "c        \n";                                      
    print INTFILE "      ESTIM=$integrand(xch)\n";
    print INTFILE "      SIGMA=0d0 \n"; 
    print INTFILE "      CTIME=0d0 \n";    
    print INTFILE "c        \n";
    print INTFILE "      write(10,100) 'result = ',ESTIM \n";
    print INTFILE "      write(10,100) 'error = ',SIGMA\n";
    print INTFILE "      write(10,102) 'CPUtime (s) = ',CTIME\n";
    print INTFILE "      write(10,*) 'MaxErrorprob = ',0.d0\n";
    print INTFILE "      write(10,*)   \n";   
    print INTFILE "c        \n";     
    print INTFILE "      close (10)\n";
    print INTFILE "      if (ESTIM .ne. ESTIM) then\n";
    print INTFILE "       call exit(91)\n";  
    print INTFILE "      endif\n";   
    print INTFILE "      if (ESTIM .gt. 1d17) then\n";
    print INTFILE "       call exit(89)\n"; 
    print INTFILE "      endif\n";   
}
print INTFILE " 100  format(1x,a,e30.10) \n";
print INTFILE " 101  format(1x,a,f8.4)\n";
print INTFILE " 102  format(1x,a,e16.4)\n";
print INTFILE "      end\n";
if ( $routine>0 && $numvar>0 ) {
    print INTFILE "      integer function integrand(ndim, xx, ncomp, ff)\n";
    print INTFILE "      integer ndim,ncomp\n";
    print INTFILE "      double precision xx(ndim), ff(ncomp)\n";
    print INTFILE "      double precision $integrand\n";
    print INTFILE "      ff(1)=$integrand(xx)\n";
    print INTFILE "      integrand = 1\n";
    print INTFILE "      end\n";
}
close INTFILE;
};
1;
