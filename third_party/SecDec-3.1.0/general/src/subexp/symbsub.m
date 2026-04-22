(*
  #****m* SecDec/general/src/subexp/symbsub.m
  #  NAME
  #    symbsub.m
  #
  #  USAGE
  #  is run from subandexpand*l*h*.m
  # 
  #  USES 
  #  integrandfunctionlist prepared by formindlist.m
  #
  #  USED BY 
  #    
  #  subandexpand*l*h*.m
  #
  #  PURPOSE
  #  performs the symbolic subtraction of the integrand to regulate
  #  singularities in epsilon
  #    
  #  INPUTS
  #  
  #  integrandfunctionlist from formindlist.m
  #  n:number of integration variables 
  #    
  #  RESULT
  #  The variables sizemu,epspower[mu],numcoeff[mu],set[mu] and exponents[mu,i]
  #  are calculated, corresponding to the subtracted integrand. The integrand is
  #  treated symbolically. If a variable has the exponent (a[i]+b[i]eps), the b are
  #  left symbolic, and the a are also left symbolic unless a<=-1. The subtracted integrand
  #  is represented by the arrays above, and to reconstitute the full (still symbolic) integrand,
  #  one would do Sum[numcoeff[mu]eps^epspower[mu]Product[z[i]^exponents[mu,i],{i,n}]*
  #  (settozero[symbolic function,set]),{mu,sizemu}], where set={{z[i1],j1},...{z[ik],jk}},
  #  and this represents the fact that the symbolic function is to be differentiated j1 times wrt z[i1]
  #  (j1 can only equal 0 for logarithmic poles, 0 or 1 for linear poles, ...), and then z[i1]->0
  #  These are then used by formfortran.m to create explict form of the integrand.
  #  
  #  SEE ALSO
  #  subandexpand*l*h*.m, formindlist.m, formfortran.m
  #   
  #****
 *)
symbolicsubtraction[ssexps_]:=
  Block[{tempcoeff,tempset,tempexponents,tempepspower},
	
	jexpmin=n;
	
  initialisetemplists:=Block[{txpd},
			     tempcoeff[1,jexp]=1;
			     tempset[1,jexp]={};
			     tempepspower[1,jexp]=0;
			     Do[
				If[txpd<jexp,initexpo=a[txpd]+b[txpd]*eps, initexpo=0];
				tempexponents[1,jexp,txpd]=initexpo
				,{txpd,n}
				];
			     maxmu[jexp]=1;
			     ];
	
  findjexp:=Block[{expolist},
		  expolist=Join[ssexps,{{-1}}];
		  jexp=1;
		  While[expolist[[jexp,1]]>-1,jexp++];
		  (*jexpmin=Min[jexpmin,jexp];*)
		  ];
	
  initialiseab:=Block[{at},
		      Clear[a,b];
		      Do[
			 at=ssexps[[iabk,1]];
			 If[at<=-1,a[iabk]=at]
			 ,
			 {iabk,n}
			 ];
		      ];
	
	
	
	makenewtempexponents[newexpo_,miflk_,mnewmu_,mnmu_]:=
	Block[{txd},
	      Do[
		 tempexponents[mnewmu,miflk+1,txd]=tempexponents[mnmu,miflk,txd]
		 ,{txd,n}
		 ];
	      tempexponents[mnewmu,miflk+1,miflk]=tempexponents[mnewmu,miflk+1,miflk]+newexpo;
	      ];
	
	(*newexpo will be 0, a[iflk] + b[iflk]*eps or a[iflk] + b[iflk]*eps + i*)
	
	makenewtempqtys[mniflk_,mmu_]:=
	Block[{mtplr,abei,mntq,mntqi},
	      Do[Do[
		    newmu++;
		    tempepspower[newmu,mniflk+1]=tempepspower[mmu,mniflk];
		    tempset[newmu,mniflk+1]=Append[tempset[mmu,mniflk],{z[mniflk],mntqi}];
		    
		    mtplr=tempcoeff[mmu,mniflk]*(mntqi!)^-1; 
		    abei=a[mniflk]+b[mniflk]*eps+mntqi;
		    If[
		       mntq==1
		       ,
		       tempcoeff[newmu,mniflk+1]=mtplr*(-1);
		       makenewtempexponents[abei,mniflk,newmu,mmu]
		       ,
		       If[
			  MatchQ[mntqi,-a[mniflk]-1]
			  ,
			  tempcoeff[newmu,mniflk+1]=mtplr*(b[mniflk]^-1);
			  tempepspower[newmu,mniflk+1]--
			  ,
			  tempcoeff[newmu,mniflk+1]=mtplr*((abei+1)^-1)
			  ];
		       makenewtempexponents[0,mniflk,newmu,mmu]
		       ]
		    
		    ,{mntqi,0,-a[mniflk]-1}
		    ]
		 ,{mntq,2}];
	      ];
	
	
	makenewtemplists[tiflk_]:=
	Block[{},
	      newmu=0;
	      Do[
		 makenewtempqtys[tiflk,mu];
		 newmu++;
		 tempepspower[newmu,tiflk+1]=tempepspower[mu,tiflk];
		 tempcoeff[newmu,tiflk+1]=tempcoeff[mu,tiflk];
		 tempset[newmu, tiflk+1]=tempset[mu,tiflk];
		 makenewtempexponents[a[tiflk]+b[tiflk]*eps,tiflk,newmu,mu];
		 ,{mu,maxmu[tiflk]}
		 ];
	      maxmu[tiflk+1]=newmu;
	      ];
	
	
  setfinallists:=Block[{expodo,mu},
		       Clear[epspower,numcoeff,set,exponents];
		       Do[
			  epspower[mu]=tempepspower[mu,n+1];
			  numcoeff[mu]=tempcoeff[mu,n+1];
			  set[mu]=tempset[mu,n+1];
			  Do[
			     exponents[mu,expodo]=tempexponents[mu,n+1,expodo]
			     ,{expodo,n}
			     ];
			  ,{mu,maxmu[n+1]}
			  ];
		       sizemu=maxmu[n+1];
		       ];
	
	makesymbolicintegrandlist=Block[{},
					initialiseab;
					findjexp;
					initialisetemplists;
					If[jexp<=n,
					   Do[
					      makenewtemplists[iflk]
					      ,
					      {iflk,jexp,n}
					      ];
					   setfinallists
					   ,
					   epspower[1]=0;
					   numcoeff[1]=1;
					   set[1]={};
					   Do[
					      exponents[1,expondok]=a[expondok]+b[expondok]*eps
					      ,
						{expondok,n}
					      ];
					   sizemu=1;
					   (*Print["no subtraction for this sector"]*)
					 ];
					];
	
	] (*end of symbolic subtraction*)
