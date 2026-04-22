(* ::Package:: *)

(*
  #****
  #  NAME
  #    formContourPC.m
  #
  #  USAGE
  #  is called by subandexpand*l*h*.m to complete the epsilon expansion, and write the C++ files f*.cc
  #  and g*.cc into the appropriate subdirectories using parallelization
  # 
  #  USES 
  #  parts.m, ExpOptP.m, 
  #
  #  USED BY 
  #    
  #  subandexpand*l*h*.m
  #
  #  PURPOSE
  #  completes the epsilon expansion, does the subtraction and contour deformation and writes the 
  #  C++ files f*.cc and g*.cc in the appropriate subdirectories using parallelization
  #    
  #  INPUTS
  #  from subandexpand*l*h*:
  #  n: number of propagators
  #  path, srcdir: where to load parts.m, ExpOptP.m from
  #  logi, lini, higheri: the number of logarithmic, linear and higher order poles respectively
  #  xvals[0]: corresponds to the lambda set by the user
  #
  #  originally from formindlist.m:
  #  integrandfunctionlist: contains the list of exponents of each variable, 
  #                         together with the number of functions
  #                         with the identical exponent structure
  #  exstore[*,*],fstore[*,*],ustore[*,*],nstore[*,*],degen[*,*]: 
  #       the exponents of u and f, function f, function u, numerator, number of degenerate 
  #       functions of each subsector (after decomposition and permutation of variables to 
  #       exploit symmetries of the problem), together with any information on
  #       degeneracies of these functions (eg if subsector A == subsector B upto a 
  #       permutations of variables)
  #   
  #  originally from symbsub.m:
  #  epspower[*]:the power of epsilon as a prefactor in piece * of the subtraction
  #  numcoeff[*]:the O(1) prefactor of the piece * of the subtraction
  #  dset[*]: if {x,a} were an element of dset[*], this indicates that the piece * of the subtraction is to 
  #   be differentiated 'a' times wrt x, and x is then to be set to zero
  #  exponents[*,**]: the exponent of variable z[**] in piece * of the subtraction
  #
  #  GLOBAL VARIABLES
  #  functioncounter[*]:counts the number of functions f and g for each order in epsilon
  #
  #  RESULT
  #  C++ functions f*.cc and g*.cc are written in the appropriate subdirectory corresponding to the given graph, 
  #  pole structure, order in epsilon, and, when IBP is used, the number of independent variables in f*.cc
  #
  #  SEE ALSO
  #  subandexpand*l*h*.m, formindlist.m, symbsub.m, parts.m, ExpOptP.m
  #   
  #****
  *)

SetAttributes[megaDo,HoldAll];
If[contourdef,
   Unprotect[Log];
   Log[a_] := myLog[a];
   ];
megaDo[arg_,it_]:=Module[{},If[nbkernels>0,ParallelDo[arg,it],Do[arg,it]]];

numberab[ni_]:=Block[{exps,numberi=0},
		     exps=integrandfunctionlist[[ni,1]];
		     Do[a[numberi]=exps[[numberi,1]];b[numberi]=exps[[numberi,2]],{numberi,feynpars}];
		      ];

funset[fsj_,fsk_,fsset_]:=
  (Fold[der,(fstore[fsj,fsk]^(exstore[fsj,fsk][[2]])*
	     ustore[fsj,fsk]^(exstore[fsj,fsk][[1]])*
	     nstore[fsj,fsk]),fsset]);

der[derfun_,derset_]:=
  (D[derfun,derset])/.derset[[1]]->0;

epsexpand[exprtoex_,ordertoex_,ordineps_:0] := 
  If[ordineps < 0
     ,
     Return[Table[((D[Expand[exprtoex*eps^-ordineps,eps],
			    {eps,epsdif}])/.eps->0)/epsdif!,
		  {epsdif,0,ordertoex-ordineps}]]
     ,
     Return[Table[((D[exprtoex,{eps,epsdif}])/.eps->0)/epsdif!,
                  {epsdif,0,ordertoex}]]
     ];

epsmulti[l1_,l2_,ordtom_]:=Table[Table[l1[[i]]l2[[j-i+1]],{i,j}],{j,ordtom+1}];

populateintlists[poplist_,poppow_]:=Block[{temppow},
					  temppow=poppow;
					  {integrand[temppow]={integrand[temppow],#},temppow++}&/@poplist;
					  ];

genTau[gtf_]:=Block[{i,taupre,taufun},
		    taupre[i_]:=xvals[0] lrs[i-1] z[i] (1-z[i]); 
		    taufun[i_]:=D[gtf,z[i]];
		    Do[eTau[i]=taupre[i]*taufun[i],{i,feynpars}];
		    Return[eTau]
		    ];

Deformation[deff_]:=Block[{a,OV,NV,JACMAT,detjac,defreps},
			  (*compute deformation of F by dF/dzi*)
			  TAU=genTau[deff]; 
			  (* If masses are complex, take only real part *)
			  If[complexmasses==1,
              		     Do[TAU[i]=TAU[i]/.emimag[a_]->0,{i,feynpars}];
			     ];
			  (*compute Jacobi determinant*)
			  OV=Table[z[i],{i,feynpars}];
			  NV=Table[nz[i]=z[i]-I TAU[i],{i,feynpars}];
			  JACMAT=Table[D[NV[[i]],OV[[j]]],{i,feynpars},{j,feynpars}];
                       If[Flatten[JACMAT]=={}, detjac=1,
			  (*following treatment necessary as too many superfluous 
			   factors of bi are kept when computing the determinant 
			   leading to numerical instabilities*)
			  If[rescaleflag==1,
			     detjac=Det[JACMAT/.bi->1];
			     If[complexmasses==1,
			      detjac=detjac /.{es[a_]->es[a]/bi} /.
			        {esx[a_]->esx[a]/bi} /.{emreal[a_]->emreal[a]/bi} 
				/.{emimag[a_]->emimag[a]/bi}
			      ,
			      detjac=detjac /.{es[a_]->es[a]/bi} /.
			        {esx[a_]->esx[a]/bi} /.{em[a_]->em[a]/bi}
			     ];
			     ,
			     detjac=Det[JACMAT];
			     ];
                         ]; (* end if JACMAT={} *)
			  (*prepare replacements for every Feynman parameter z[i]*)
			  defreps=Table[z[i]->z[i]-I TAU[i],{i,feynpars}]; 
			  Return[{detjac,defreps,TAU}]
			  ];

argexp[expr_]:=Block[{temp,dxarg=0,i,arg},
		     temp = modexp[expr];
		     arg = temp[[3]]/temp[[2]]/xvals[0];
		     (*Do[dxarg += Abs[D[arg,z[i]]],{i,feynpars}];*)
		     Return[arg]
		     ];

modexp[expr_]:=Block[{temp,smexpand,xv0,a,b,repa,impa},
		     xv0/:Power[xv0,a_]:=0/;OddQ[a];
		     xv0/:Power[xv0,a_]:=xvals[0]^a/;EvenQ[a];
		     smexpand=Collect[expr,xvals[0]];
		     temp=smexpand/.xvals[0]->xv0;
		     repa=temp//.{xv0->0, Complex[a_,0.]->a, Complex[0.,0.]->0};
		     impa=(smexpand-repa)//.{Complex[a_,b_]->b, Complex[0.,0.]->0};
		     Return[{repa^2+impa^2,repa,impa}]
		     ];

ratexp[expr_]:=
  Block[{a,b},
	If[MatchQ[(Coefficient[expr,xvals[0],1]/.Complex[a_,b_]->b),0],
	   Print["Function F[z] does not depend on lambda."];
	   Return[0]
	   ,
           Return[(Coefficient[expr,xvals[0],3]/.Complex[a_,b_]->b)/
                  (Coefficient[expr,xvals[0],1]/.Complex[a_,b_]->b)]];
	];

expon[exa_,exb_] := integrandfunctionlist[[exa,1,exb,1]] + integrandfunctionlist[[exa,1,exb,2]]*eps;
(***************** BEGIN FUNCTIONS for forming integrand and writing files **************************)

optimlambdafunC[gepsord_,functioncounter_,gcondeff_,gcondef3_]:=
  Block[{fexpanded,ratiotest,modtest,a,signtest,tautest,
	 argtest,ratioopt,modopt,signopt,argopt,tauopt,
	 goutfile,rfuncname,mfuncname,sfuncname,
	 tfuncname,afuncname,try,tt,he1},
	fexpanded=Expand[gcondeff,xvals[0]];
	(*debugfilename=StringJoin[direy,"/g",ToString[functioncounter[-2]],".m"];
	 Save[debugfilename,fexpanded];*)
       
	ratiotest=ratexp[fexpanded]/.{xvals[0]->lambda};
	{modtest,a,signtest}=modexp[fexpanded]/.{xvals[0]->lambda}; 
	tautest=gcondef3;
	
	(*Share[];*) (*comment out if forming of integrand should be faster*)

	If[complexmasses==1,ratiotest=ratiotest/.{emreal->em,emimag[_]->0}];
	try=OptimizeExpression[ratiotest, OptimizationSymbol -> y];
	tt =try/.{OptimizedExpression->Hold};
	he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
	ratioopt=ReleaseHold[he1];

	If[complexmasses==1,modtest=modtest/.{emreal->em,emimag[_]->0}];	
	try=OptimizeExpression[modtest, OptimizationSymbol -> y]; 
	tt =try/.{OptimizedExpression->Hold};
	he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
	modopt=ReleaseHold[he1];

	If[complexmasses==1,signtest=signtest/.{emreal->em,emimag[_]->0}];		
	try=OptimizeExpression[signtest, OptimizationSymbol -> y];
	tt =try/.{OptimizedExpression->Hold};
	he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};					
	signopt=ReleaseHold[he1];
	If[oscillatory==1,
	   argtest=argexp[fexpanded]/.xvals[0]->lambda;
	   If[complexmasses==1,argtest=argtest/.{emreal->em,emimag[_]->0}];
	   try=OptimizeExpression[argtest, OptimizationSymbol -> y];
	   tt =try/.{OptimizedExpression->Hold};
	   he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};					
	   argopt=ReleaseHold[he1];
	   ];
	
	Do[
	   If[complexmasses==1,tautest[i]=tautest[i]/.{emreal->em,emimag[_]->0}];
	   try=OptimizeExpression[tautest[i]/.{xvals[0]->1,lrs[i-1]->1}, OptimizationSymbol -> y];
	   tt =try/.{OptimizedExpression->Hold};
	   he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
	   tauopt[i]=ReleaseHold[he1];
	   ,
	   {i,feynpars}
	   ];
	
	direy=StringJoin[direyt,"/epstothe",ToString[gepsord]];
	If[FileNames[direy]=={},CreateDirectory[direy]];
	
	goutfile=StringJoin[direy,"/g",ToString[functioncounter],".cc"];
	
	rfuncname=StringJoin["P",polestring,"r",ToString[functioncounter]];
	mfuncname=StringJoin["P",polestring,"m",ToString[functioncounter]];
	sfuncname=StringJoin["P",polestring,"s",ToString[functioncounter]];
	afuncname=StringJoin["P",polestring,"a",ToString[functioncounter]];
	tfuncnamepre=StringJoin["P",polestring,"t",ToString[functioncounter],"t"];
	
	writeoptC[ratioopt,varletter,rfuncname,goutfile,1];
	writeoptC[modopt,varletter,mfuncname,goutfile,2];
	writeoptC[signopt,varletter,sfuncname,goutfile,2];
	If[oscillatory==1, writeoptC[argopt,varletter,afuncname,goutfile,2];];
	
	Do[
	   writeoptC[tauopt[i],varletter,tfuncnamepre<>ToString[i],goutfile,2];
	   ,{i,feynpars}];
	Clear[try,tt,he1]
	];

formnumericalintegrandC[explab_,epsordreq_]:=
 Block[{condef,condeff,condeffrem,condef3,condef3rem,counter,epsord,
 helper,oldfps,fprepl,prods,mufunct,expnumfact,
	 exorder,expnfeps,mu,expi,functionnumber,
	 neword,newepsordreq,epsFactInNum},
	numberab[explab];
	Clear[integrand];
	Do[ 
	   If[ MatchQ[degen[explab,functionnumber],0]==False
		,
		(*Get order of eps^-x in the numerator*)
		epsFactInNum = - Exponent[(nstore[explab,functionnumber])/.
					  {eps -> eps^-1},eps];
	       (*****BEGIN deformation of contour***********)
	       If[contourdef,
	       condef=Deformation[fstore[explab,functionnumber]]; (*Form deformation*)
	       (*Apply deformation to F,U and numerator:*)
	       (#[explab,functionnumber]=#[explab,functionnumber]/.condef[[2]])&/@{fstore,ustore,nstore}; 
	       prods=Product[(1-I TAU[i]/z[i])^expon[explab,i],{i,feynpars}];
	       (*Add Jacobi Determinant to numerator:*)
	       nstore[explab,functionnumber]=nstore[explab,functionnumber]*condef[[1]]*prods;
	       (*Print["nstore, explab ",explab,", functionnumber ",functionnumber,": ",nstore[explab,functionnumber]];*)
	       (***********************
		condeff and condef3 are dummy variables so that as little memory as possible needs to be shared during parallel computation
		***********************)
	       condeff=fstore[explab,functionnumber]; 	       
	       condef3=condef[[3]];
	       Clear[condef];
	       If[And[$VersionNumber==7,nbkernels>0],
		      SetSharedVariable[condeff,condef3];
		   ];
	       ]
	       (*****END deformation of contour***********)
	       (* maximal order of integrand: epsordreq+maxdegree *)
	       Do[integrand[inti]={},{inti,-minpole,epsordreq+maxdegree}];
	       (*****BEGIN subtraction******)
	       If[epsFactInNum > 0, newepsordreq=epsordreq-epsFactInNum, newepsordreq=epsordreq];
	       Do[If[epspower[mu] <= newepsordreq
		     ,
		     mufunct={degen[explab,functionnumber]*funset[explab,functionnumber,dset[mu]]}; 
		     (*Form subtraction terms where one parameter is set to zero after having taken the derivative*)	    
		     mufunct=mufunct/.{Power[0,a__]->0}; 
		     (*Simplify functions with terms of 0^(1+eps) to zeros*)		     
		     mufunct=mufunct//.List[a___,0,b___]->List[a,b];
		     (*tab=Table[exponents[mu,fp],{fp,feynpars}];
		       Print["tab=",tab];*)
		     expnumfact=Product[z[expi]^exponents[mu,expi],{expi,feynpars}]*numcoeff[mu];
		     exorder=epsordreq-epspower[mu];
		     mufunct=Function[xx,epsexpand[xx,exorder,epsFactInNum]]/@mufunct;
		     neword=exorder;
		     (* if numerator contains negative eps powers, there are 
			more coefficients in the mufunct series than only 
			exorder ones. Zeroth order must be counted as well, 
			therefore -1*)
		     If[And[MatchQ[mufunct,{}]==False,epsFactInNum < 0], 
			 neword=Length[mufunct[[1]]]-1;
			]; 
		     expnfeps=epsexpand[expnumfact,neword];
		     (* Multiply individual prefactor "expnumfact" 
			with the computed functions of 
			N*U^eU*F^eF "mufunct" to right order in eps *)
		     mufunct=Function[xx,epsmulti[expnfeps,xx,neword]]/@mufunct;
		     (****************************
		      Fill all terms after subtraction and eps expansion into 
		      integration list which is written into files in the next 
		      ParallelDo loop
		      ****************************)
		     (* the additional negative eps order, eps^-x, in numerator 
			terms from ibp results in the difference exorder-neword 
			to be unequal to zero *)
		     Function[xx,populateintlists[xx,epspower[mu]+exorder-neword]]/@mufunct;
		     ](* end if epspower[mu]<=epsordreq  *)
		  ,{mu,sizemu}];
	       Clear[mufunct,expnfeps];
	       (*****END subtraction******)
	       (*****BEGIN write f*.cc and g*.cc functions*******)
	       megaDo[
			  If[MatchQ[integrand[epsord],{}]==False
			     ,
			     functiontooptimize=Plus@@Flatten[integrand[epsord]];
 (*functiontooptimize=Simplify[functiontooptimize,TimeConstraint->3];*)
			     (*Print["functiontoopt=",functiontooptimize];*)
			     If[Or[MatchQ[functiontooptimize, 0], MatchQ[functiontooptimize, 0.]]==False
				,
				counter=++functioncounter[epsord];
				(*Check for nb of feynpars to integrate over and write it to infofile later, 
				 remap Feynman parameters if necessary*)
				 
				helper=Count[FreeQ[functiontooptimize,#]&/@Flatten[xilist],False];

				If[helper < feynpars,
				   oldfps = Flatten[Position[FreeQ[functiontooptimize,#]&/@Flatten[xilist],False]-1];
				   fprepl = Join[MapIndexed[ToExpression[StringJoin["x",ToString[#1]]] -> t[First[#2]] &, oldfps],
						 MapIndexed[ToExpression[StringJoin["x",ToString[#1]]] -> t[First[#2]+Length[oldfps]] &,Complement[Range[feynpars-1],oldfps]]];
				   Print["Replacements:",fprepl];
				   functiontooptimize = (functiontooptimize/.fprepl)/.{t->z};
				   condeffrem = (condeff/.fprepl)/.{t->z};
				   condef3rem = (condef3/.fprepl)/.{t->z};
				   ,
				   Print["No replacements done."];
				   condeffrem = condeff;
				   condef3rem = condef3;
				   ]; 

				If[helper>constantscounter[epsord], constantscounter[epsord]=helper];

 (* 
				maxfey[func_] := Max[Boole[Not[FreeQ[func,#]]&/@Flatten[xilist]]*Range[feynpars]];
				minfey[func_] := Min[Cases[Boole[FreeQ[func,#]&/@Flatten[xilist]]*Range[feynpars],
							   Except[0]]];
				maxf=maxfey[functiontooptimize];
				While[maxf > helper,
				      minf=minfey[functiontooptimize];
				      functiontooptimize=functiontooptimize/.
					{ToExpression[StringJoin["x",ToString[maxf-1]]] -> ToExpression[StringJoin["x",ToString[minf-1]]]};
				      maxf=maxfey[functiontooptimize];
				      ];

 *)

				direy=StringJoin[direyt,"/epstothe",ToString[epsord]];			
				If[FileNames[direy]=={},CreateDirectory[direy]];
				foutfile=StringJoin[direy,"/f",ToString[counter],".cc"];
				moutfile=StringJoin[direy,"/f",ToString[counter],".m"];
				ffuncname=StringJoin["P",polestring,"f",ToString[counter]];
				mfuncname=StringJoin["f",ToString[counter]];
				If[mathematicaflag==1, 
				   If[contourdef,
				      Do[lrs[i-1]=1,{i,feynpars}];
				      xvals[0]=1;
				   ];
				   mfuncstream=OpenWrite[moutfile];
				   WriteString[mfuncstream,mfuncname,"="];
				   Write[mfuncstream,functiontooptimize];
				   Close[mfuncstream];
				   ,
				   functiontooptimize=functiontooptimize/.{Complex[aC_,bC_]->aC+bC MYI,xvals[0]->lambda};
				   (******BEGIN Change of variables for endpoints*******)
				   If[And[endpointflag==1,contourdef],
				   
				      funcpart1=(functiontooptimize/.((#->#/2)&/@Flatten[xilist]))/2;
				      try=OptimizeExpression[funcpart1, OptimizationSymbol -> y];
				      tt =try/.{OptimizedExpression->Hold};
				      he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
				      expr=ReleaseHold[he1];
				      writeoptC[expr,varletter,ffuncname,foutfile];
				      optimlambdafunC[epsord,counter,condeffrem,condef3rem];
				      Clear[funcpart1];
				      
				      counter=++functioncounter[epsord];
				      foutfile=StringJoin[direy,"/f",ToString[counter],".cc"];
				      ffuncname=StringJoin["P",polestring,"f",ToString[counter]];
				      funcpart2=(functiontooptimize/.((#->1-#/2)&/@Flatten[xilist]))/2;
				      try=OptimizeExpression[funcpart2, OptimizationSymbol -> y];
				      tt =try/.{OptimizedExpression->Hold};
				      he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
				      expr=ReleaseHold[he1];
				      writeoptC[expr,varletter,ffuncname,foutfile];
				      optimlambdafunC[epsord,counter,condeffrem,condef3rem];
				      (*functiontooptimize=Plus@@{funcpart1,funcpart2}/2;*)
				      Clear[funcpart2]
				      ,
				      try=OptimizeExpression[functiontooptimize, OptimizationSymbol -> y];
				      tt =try/.{OptimizedExpression->Hold};
				      he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
				      expr=ReleaseHold[he1];
				      If[contourdef,
				         writeoptC[expr,varletter,ffuncname,foutfile];
					 optimlambdafunC[epsord,counter,condeffrem,condef3rem];
					 ,
					 If[complexmasses==1,
					    writeoptC[expr,varletter,ffuncname,foutfile],
					    writeoptC[expr,varletter,ffuncname,foutfile,1]
					    ];
					 ];
				      (*Save[moutfile,functiontooptimize];*)
				      (* moutfile introduced for debugging purposes only: Save[moutfile,functiontooptimize]; *)
				      
				      ];
				   ];
				Clear[functiontooptimize,try,tt,he1,expr];
				(******END Change of variables for endpoints*******)
				(* Print["after_share1",MemoryInUse[]];*)
				];
			     ]
			  ,{epsord,-minpole,epsordreq+mindegree}]
			  ];
 Clear[condeff,condef3,condeffrem,condef3rem]
	       (*****END write f*.cc and g*.cc functions*******)
	       ,{functionnumber,integrandfunctionlist[[explab,2]]}
	   ];
	Clear[a,b];
	];



(***************** END FUNCTIONS for forming integrand and writing files ****************************)
If[MatchQ[togetherflag,1],
   direy=StringJoin[outp,"/together"], (*directory with togetherflag=1*)
   direy=StringJoin[outp,"/",polestring]; (*directory for the output files*)
   direycount=0;
   direyt=direy;
   While[
	 FileNames[direyt]=!={}
	 ,
	 direycount++;
	 direyt=StringJoin[direy,ToString[direycount]]
	 ];
   If[direycount>0,RenameDirectory[direy,direyt]];(*puts old results into another directory, ~diagramname#, where the
						   largest # relates to the most recent folder*)
   ];
 Quiet[CreateDirectory[direy],{CreateDirectory::filex}]; (*Creates the directory to save the files to. Most recent directory is ~diagramname*)
direyt=direy;
(**********BEGIN find correct minimal pole in epsilon (e.g. if numerator propto eps) ***)
minpole = feynpars+1-jexp-mindegree;
If[-minpole>precisionrequired,
     Print["Warning: The order in epsilon you desire is too low for the integrand "];
     Print["you want to check. Revise 'epsord=' in your *.input file."];
];
(**********END find correct smallest order in epsilon (numerator propto eps) ***********)
varletter="y";

MyBlock[listvar_,listabbr_]:={listvar,listabbr};
(*Clear[x];*)
(**********BEGIN Translate z[i]s for C++-Files and write list for the later remapping***)
xilist={};
Do[
   z[changezi]=ToExpression[StringJoin["x",ToString[changezi-1]]];
   xilist = {xilist, z[changezi]}
   ,
   {changezi,feynpars}
];
(**********END Translate z[i]s *********************************************************)
(**********BEGIN Prepare invariants for C++ files **************************************)
(*replacements for the thresholds inserted by users are done in (N)SDroutines.m *)

If[complexmasses==1,
  ms[i_]:=emreal[i-1] + I*emimag[i-1],
  ms[i_]:=em[i-1]; (*defines the remapping of ms*)
];
ssp[i_]:=esx[i-1];(*and ssp*)
maxinv=bi; (*rename maxinv into short version bi abbreviated from _b_iggest _i_nvariant*)
xlambda=xvals[0];
(**********END Prepare invariants *******************************************************)
(****************** Strings for C++ functions **********************)
Cstring0=";";
Cstring1="#include \"intfile.hh\"\n";
Cstring3=Cstring1<>"\ndouble ";
Cstring1=Cstring1<>"\ndcmplx ";
If[complexmasses==1,
Cstring2[costr_]:="(const double x[], double esx[], "<>costr<>" em[], double lambda, double lrs[], double bi) {\n",
Cstring2[costr_]:="(const double x[], double esx[], double em[], double lambda, double lrs[], double bi) {\n"];
Cstring4=StringJoin@@("double x"<>#<>"=x["<>#<>"];\n"&/@Table[ToString[i],{i,0,feynpars-1}]);
Cstring4a[co_,costr_:"dcmplx"]:=costr<>" "<>varletter<>"["<>ToString[co]<>"];\n";
Cstring5[costr_:"dcmplx"]:=costr<>" FOUT;\n";
Cstring7="dcmplx MYI(0.,1.);\n";
Cstring6="return ";
(******************** END Strings ***********************************)
(******** START formnumerical integrand and write functions *********)
createoptimizedC:=
  Block[{tiepspow,numintegdo,infostream,readstr,read},
	Print["Memory in use before optimizing C++ functions = ",MemoryInUse[]];
	If[MatchQ[togetherflag,1],
	   If[mathematicaflag==1,suffix=".m",suffix=".cc"];
	   Do[
	      functioncounter[tiepspow]=0;constantscounter[tiepspow]=0;
	      fctcount=StringJoin[direy,"/epstothe",ToString[tiepspow],"/f",ToString[functioncounter[tiepspow]+1],suffix];
	      While[FileNames[fctcount]=!={},
		    functioncounter[tiepspow]++;
		    fctcount=StringJoin[direy,"/epstothe",ToString[tiepspow],"/f",ToString[functioncounter[tiepspow]+1],suffix];
		    ]
	      ,{tiepspow,-minpole,precisionrequired}]
	   ,
	   Do[ functioncounter[tiepspow]=0; constantscounter[tiepspow]=0, {tiepspow,-minpole,precisionrequired}];
	   ];
	Do[
	   formnumericalintegrandC[numintegdo,precisionrequired];
	   If[
	      Or[numintegdo<10,Mod[numintegdo,10]==0,numintegdo==Length[integrandfunctionlist]]
	      ,
	      Print["numericalintegrand ", numintegdo, " evaluated, Memory in use = ",MemoryInUse[]]
	      ];
	   ,{numintegdo,Length[integrandfunctionlist]}
	   ];
	While[functioncounter[-minpole]==0,minpole--];
	If[MatchQ[FileNames[StringJoin[direyt,"/infofile"]],{}],
	   infostream = OpenWrite[StringJoin[direyt,"/infofile"]];
	   Do[
	      Write[infostream, StringJoin[ToString[tiepspow],"functions = ",ToString[functioncounter[tiepspow]]]];
	      Write[infostream, StringJoin[ToString[tiepspow],"constants = ",ToString[constantscounter[tiepspow]]]]
	      ,{tiepspow,-minpole,precisionrequired}];
	   Close[infostream]
	   ,
	   readstr = OpenRead[StringJoin[direyt,"/infofile"]];
	   read = ReadList[readstr,{Character,Number,String}];
	   Close[readstr];

	   readsplit = Join[{Part[#,2]},StringSplit[Part[#, 3],{" ","\""}]] & /@ read;
	   absminpole = Min[Append[Part[#,2]&/@read,-minpole]];

	   func[n_]=0;
	   const[n_]=0;
	   Set[func[Part[#,1]],ToExpression[Part[#,4]]]&
	       /@Select[readsplit,MemberQ[#,"functions"]&];
	   Set[const[Part[#,1]],ToExpression[Part[#,4]]]&
	       /@Select[readsplit,MemberQ[#,"constants"]&];
	   Do[Set[func[tiepspow],functioncounter[tiepspow]];
	      Set[const[tiepspow],Max[const[tiepspow],constantscounter[tiepspow]]]
		 ,{tiepspow,-minpole,precisionrequired}];

	   infostream = OpenWrite[StringJoin[direyt,"/infofile"]];
	   Do[
	       Write[infostream, StringJoin[ToString[tiepspow],
	             "functions = ",ToString[func[tiepspow]]]];
	       Write[infostream, StringJoin[ToString[tiepspow],
	             "constants = ",ToString[const[tiepspow]]]]
	       ,{tiepspow,absminpole,precisionrequired}];
	   
	    Close[infostream];

	   ];
	];
(********** END formnumerical integrand and write functions *********)
SetSharedFunction[functioncounter,constantscounter];

If[And[$VersionNumber==7,nbkernels>0],
   SetSharedFunction[integrand,eTau,integrands,memcount,a,b];
   DistributeDefinitions[argexp,Cstring0,Cstring1,Cstring2,Cstring22,Cstring3,Cstring4,
			 Cstring4a,Cstring5,Cstring6,Cstring7,Deformation,degen,der,
			 direyt,dset,endpointflag,epsmulti,epspower,
			 exponents,feynpars,funset,genTau,integrandfunctionlist,
			 mathematicaflag,minpole,mindegree,maxdegree,
			 modexp,ms,n,numcoeff,optimlambdafunC,oscillatory,partsflag,
			 polestring,prestring,precisionrequired,ratexp,ssp,
			 varletter,writeoptC,writeM,xilist,z];
]

Print["Producing C++ functions"];
forttime=AbsoluteTiming[createoptimizedC;][[1]];
Print["C++ functions produced, time taken = ",forttime," seconds"];



