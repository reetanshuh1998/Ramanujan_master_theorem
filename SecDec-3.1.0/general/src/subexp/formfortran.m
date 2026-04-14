(*
  #****m* SecDec/general/src/subexp/formfortran.m
  #  NAME
  #    formfortran.m
  #
  #  USAGE
  #  is called by subandexpand*l*h*.m to complete the epsilon expansion, and write the fortran files f*.f
  #  into the appropriate subdirectories 
  # 
  #  USES 
  #  parts.m, ExpOpt.m, 
  #
  #  USED BY 
  #    
  #  subandexpand*l*h*.m
  #
  #  PURPOSE
  #  writes the fortran files f*.f in the appropriate subdirectories
  #    
  #  INPUTS
  #  from subandexpand*l*h*:
  #  n: number of integration variables
  #  path, srcdir: where to load parts.m, ExpOpt.m from
  #  logi, lini, higheri: the number of logarithmic, linear and higher order poles respectively
  #
  #  originally from formindlist.m:
  #  integrandfunctionlist: contains the list of exponents of each variable, together with the number of functions
  #  with the identical exponent structure
  #  store[*,*]: the functions associated with the integrandfunctionlist
  #   
  #  originally from symbsub.m:
  #  sizemu:the number of pieces the integrand is split into after subtraction.
  #  epspower[*]:the power of epsilon as a prefactor in piece * of the subtraction
  #  numcoeff[*]:the O(1) prefactor of the piece * of the subtraction
  #  set[*]: if {x,a} were an element of set[*], this indicates that the piece * of the subtraction is to 
  #   be differentiated 'a' times wrt x, and x is then to be set to zero
  #  exponents[*,**]: the exponent of variable z[**] in piece * of the subtraction
  #
  #
  #  RESULT
  #  using output from symbsub.m, creates explicit form of the integrands, performs IBP where desired,
  #  performs eps expansion to the required order, optimizes these expressions, and writes them to files
  #  f*.f in the appropriate subdirectory in fortran syntax, ready to be numerically integrated.
  #
  #  SEE ALSO
  #  subandexpand*l*h*.m, formindlist.m, symbsub.m, parts.m, ExpOpt.m, sqrtsimp.m
  #   
  #****
  *)
  
  
Get[StringJoin[path,"src/deco/sqrtsimp.m"]];
mygamma[a_+b_ eps]:=Module[{},
If[And[NumberQ[a],a<=0],1/(a+b eps) mygamma[a+1+b eps],Gamma[a+b eps]]];

mygamma[b_ eps]:=1/(b eps) Gamma[1+b eps];
mygamma[eps]:=1/eps Gamma[1+eps];
mygamma[a_+eps]:=If[And[NumberQ[a],a<=0],1/(a+eps)*
mygamma[a+1+eps],Gamma[a+eps]];

comptest[ca_,cb_]:=Module[{},
			  If[MatchQ[ca[[1]],cb[[1]]],True,
			     And[ca[[1]]>-1,cb[[1]]>-1]]];
sametest[sa_,sb_]:=Module[{tlist},
			  tlist=MapThread[comptest,{sa[[1]],sb[[1]]}];
			  tlist=Flatten[tlist/.True->{}];
			  If[MatchQ[tlist,{}],True,False]];


numberab[ni_]:=Module[{exps},
		      exps=integrandfunctionlist[[ni,1]];
		      Do[a[numberi]=exps[[numberi,1]];b[numberi]=exps[[numberi,2]],{numberi,n}];
		      ];
funset[fsj_,fsk_,fsset_]:=
  (Fold[der,(store[fsj,fsk])/.Gamma->mygamma,fsset]);


der[derfun_,derset_]:=
(D[derfun,derset])/.derset[[1]]->0;


epsexpand[exprtoex_,ordertoex_]:=Table[
 ((D[exprtoex,{eps,epsdif}])/.eps->0)/epsdif!
,
 {epsdif,0,ordertoex}
];

dummyexpand = ( ToExpression[#][[1]][a__]->
     ( Normal[Series[#[[1]][eps], {eps, 0, #[[2]]}]] /. 
       {Derivative[i_][#[[1]]][0] :> ToExpression[ToString[#[[1]]] <> "Deps" <> ToString[i]][a], 
        #[[1]][0] -> ToExpression[#[[1]]][a]}) 
   ) & /@ dummyEpsOrd;

epsmulti[l1_,l2_,ordtom_]:=Table[Table[
  l1[[i]]l2[[j-i+1]]
 ,
  {i,j}
 ]
,
 {j,ordtom+1}
];

addelement[ele_]:=Module[{},
 integrands[temppow]={integrands[temppow],ele};
 temppow++;
];
 

populateintlists[poplist_,poppow_]:=Module[{},
 temppow=poppow;
 addelement/@poplist;
];

formnumericalintegrand[explab_,epsordreq_,0]:=Module[{},
 numberab[explab];
 Clear[integrands];
 Do[integrands[inti]={},{inti,-minpole,epsordreq-ordcheck}];
 Do[
  If[
   epspower[mu]<=epsordreq-ordcheck
  ,
   mufunct=Table[
    mysimp[funset[explab,functionnumber,set[mu]],zlist]
   ,
    {functionnumber,integrandfunctionlist[[explab,2]]}
   ];
   mufunct=mufunct//.List[a__,0,b__]->List[a,b];
   expnumfact=Product[z[expi]^exponents[mu,expi],{expi,n}]numcoeff[mu];
   exorder=epsordreq-epspower[mu]-ordcheck;
   expnfeps=epsexpand[expnumfact,exorder];
   mufunct=Cancel[mufunct/.dummyexpand]; 
   mufunct=Function[xx,epsexpand[xx,exorder]]/@mufunct;
   mufunct=Function[xx,epsmulti[expnfeps,xx,exorder]]/@mufunct;
   Function[xx,populateintlists[xx,epspower[mu]]]/@mufunct;	
  ];
 ,
  {mu,sizemu}
 ];
 listel=1;
 Do[integrands[epsord]=Plus@@Flatten[integrands[epsord]],{epsord,-minpole,epsordreq-ordcheck}];
 Do[
    functiontooptimize=expandedimp[[listel]]/.{integimp->integrands,constimp->constepspre};
    listel++;
    If[MatchQ[functiontooptimize,0]==False,
       functioncounter[epsord]++;
 
       (*Check for nb of feynpars to integrate over and write it to infofile later, 
         remap Feynman parameters if necessary*)
       helper=Count[FreeQ[functiontooptimize,#]&/@Flatten[xilist],False];
       maxfey[func_] := Max[Boole[Not[FreeQ[func,#]]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]]];
       minfey[func_] := Min[Cases[Boole[FreeQ[func,#]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]],Except[0]]];
       maxf=maxfey[functiontooptimize];
	Print["Check for redundant integrations and order xi"];
       While[maxf > helper,
	Print["Highest index relevant integration x",maxf,", only ",helper," out of ",Length[Flatten[xilist]]," variables should be relevant."];
             minf=minfey[functiontooptimize];
	Print["Lowest index constant integration over x",minf," detected"];
	     functiontooptimize=functiontooptimize/.{ToExpression[StringJoin["x",ToString[maxf]]] -> ToExpression[StringJoin["x",ToString[minf]]]};
	Print["Swap integration variables x",maxf," and x",minf];
	     maxf=maxfey[functiontooptimize];
	Print["New highest index integration x",maxf];
	       ]
	Print["Integrations successfully ordered, only first ",helper," integrations needed"]
       If[helper>constantscounter[epsord],constantscounter[epsord]=helper];
       direy=StringJoin[direyt,"/epstothe",ToString[epsord]];
       If[FileNames[direy]=={},CreateDirectory[direy]];
       outfile=StringJoin[direy,"/f",ToString[functioncounter[epsord]],".f"];
       moutfile=StringJoin[direy,"/f",ToString[functioncounter[epsord]],".m"];
       (* write math functions to  debug *)
       (*Save[moutfile,functiontooptimize];*)
       funcname=StringJoin["P",polestring,"f",ToString[functioncounter[epsord]]];
       try=OptimizeExpression[functiontooptimize, OptimizationSymbol -> w];
       tt =try/.{OptimizedExpression->Hold};
       he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
       expr=ReleaseHold[he1];
       writeopt[expr,varletter,funcname,outfile,helper];
      ]
    ,
    {epsord,-minpole+ordcheck,epsordreq}
    ]; 
    Clear[a,b];
   ];
                    
(* if 3rd argument of formnumericalintegrand is equal to 1, this is the IBP option *)
Get[StringJoin[path,"src/subexp/","parts.m"]];
formnumericalintegrand[explab_,epsordreq_,1]:=Module[{},
numberab[explab];
Do[explicitintegrand[epspole]={};memcount[epspole]=0,{epspole,-minpole+ordcheck,epsordreq}];
Do[
	If[
		epspower[mu]<=epsordreq-ordcheck
	,
		mufunctpre=1;
		difficulty=0;
		varsset={};
		
		Do[
			expt=exponents[mu,mui]/.eps->0;
			exptifl=integrandfunctionlist[[explab,1,mui,1]];
			expdif=expt-exptifl;
			If[
				expt <0
			,
				mufunctpre=mufunctpre*z[mui]^expdif;
				inpa=integrandfunctionlist[[explab,1,mui,2]];
				difficulty=difficulty-exptifl;
				varsset=Append[varsset,{z[mui],inpa,exptifl}];
			,
				mufunctpre=mufunctpre*z[mui]^(exponents[mu,mui])
			]
		,
			{mui,n}
		];
		
		numtogroup=IntegerPart[200/(1+difficulty^2)]+1;
		
		mufunct=
		Table[
		 Sum[
		  mufunctpre*mysimp[funset[explab,functionnumber,set[mu]],zlist]
		 ,
		  {functionnumber,(tablei-1)*numtogroup+1,Min[tablei*numtogroup,integrandfunctionlist[[explab,2]]]}
		 ]
		,
		 {tablei,IntegerPart[integrandfunctionlist[[explab,2]]/numtogroup]+1}
		];

			
			
		Function[xx,ftofortran[xx,epspower[mu],numcoeff[mu]]]/@mufunct;
		
	   ];
	,
	{mu,sizemu}
   ];
						     
Do[
functiontooptimize=Plus@@(Flatten[explicitintegrand[fnepspole]]);
 If[MatchQ[functiontooptimize,0]==False,
  functioncounter[fnepspole]++;

  (*Check for nb of feynpars to integrate over and write it to infofile later, 
    remap Feynman parameters if necessary*)
   helper=Count[FreeQ[functiontooptimize,#]&/@Flatten[xilist],False];
   maxfey[func_] := Max[Boole[Not[FreeQ[func,#]]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]]];
   minfey[func_] := Min[Cases[Boole[FreeQ[func,#]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]],Except[0]]];
   maxf=maxfey[functiontooptimize];
	Print["Check for redundant integrations and order xi"];
       While[maxf > helper,
	Print["Highest index relevant integration x",maxf,", only ",helper," out of ",Length[Flatten[xilist]]," variables should be relevant."];
             minf=minfey[functiontooptimize];
	Print["Lowest index constant integration over x",minf];
	     functiontooptimize=functiontooptimize/.{ToExpression[StringJoin["x",ToString[maxf]]] -> ToExpression[StringJoin["x",ToString[minf]]]};
	Print["Swap integration variables x",maxf," and x",minf];
	     maxf=maxfey[functiontooptimize];
	Print["New highest index integration x",maxf];
	       ]
	Print["Integrations successfully ordered, only first ",helper," integrations needed"]
  If[helper>constantscounter[fnepspole],constantscounter[fnepspole]=helper]; 
  direy=StringJoin[direyt,"/epstothe",ToString[fnepspole]];
  If[FileNames[direy]=={},CreateDirectory[direy]];
  outfile = StringJoin[direy,"/f",ToString[functioncounter[fnepspole]],".f"];
  moutfile = StringJoin[direy,"/f",ToString[functioncounter[fnepspole]],".m"];
  funcname=StringJoin["P",polestring,"f",ToString[functioncounter[fnepspole]]];
  try=OptimizeExpression[functiontooptimize, OptimizationSymbol -> w];
  tt =try/.{OptimizedExpression->Hold};
  he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
  expr=ReleaseHold[he1];
  writeopt[expr,varletter,funcname,outfile,helper];
 (*Save[moutfile,functiontooptimize];*)
 ]
,
 {fnepspole,-minpole+ordcheck,epsordreq}
];
  
Clear[a,b];
];


ftofortran[ffort_,epsfort_,nfort_]:=(
				     mf=intparts[ffort,varsset,precisionrequired-epsfort];
				     If[
					And[ByteCount[mf]>=5000000,MatchQ[Head[ffort],Plus]]
					,
					lenff=Length[ffort];
					leno2=IntegerPart[lenff/2];
					
					newffort={Sum[ffort[[i]],{i,leno2}],Sum[ffort[[j]],{j,leno2+1,lenff}]};
					Function[xx,ftofortran[xx,epsfort,nfort]]/@newffort
					,
					mf=(mf/.ipsum->ipexplicitsum)*nfort;
					
					If[
					   MatchQ[mf,0]==False
					   ,
					   Clear[temporaryintegrand];
					   Do[
					      epsdif=fnepspole-epsfort;
					      temporaryintegrand[fnepspole]=(D[mf,{eps,epsdif}]/.eps->0)*(epsdif!)^-1
					      ,
						{fnepspole,epsfort,precisionrequired-ordcheck}
					      ];
					   temporaryintegrand[a_]:=0;
					   listel=minpole+epsfort+1;
					   
					   Do[
					      nextelement=expandedimp[[listel]]/.{integimp->temporaryintegrand,constimp->constepspre};
					      listel++;
					      nextmemcount=ByteCount[nextelement];
					      If[nextmemcount+memcount[fnepspole]>MEMCUTOFF,
						 functiontooptimize=Plus@@(Flatten[explicitintegrand[fnepspole]]);
						 explicitingetrand[fnepspole]={};
						 memcount[fnepspole]=0;
						 If[MatchQ[functiontooptimize,0]==False,
						    functioncounter[fnepspole]++;
                                                     (*Check for nb of feynpars to integrate over and write it to infofile later, 
                                                      remap Feynman parameters if necessary*)
                                                    helper=Count[FreeQ[functiontooptimize,#]&/@Flatten[xilist],False];
                                                    maxfey[func_] := Max[Boole[Not[FreeQ[func,#]]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]]];
                                                    minfey[func_] := Min[Cases[Boole[FreeQ[func,#]&/@Flatten[xilist]]*Range[Length[Flatten[xilist]]],Except[0]]];
                                                    maxf=maxfey[functiontooptimize];
							Print["Check for redundant integrations and order xi"];
							While[maxf > helper,
								Print["Highest index relevant integration x",maxf,", only ",helper," out of ",Length[Flatten[xilist]]," variables should be relevant."];
      							        minf=minfey[functiontooptimize];
								Print["Lowest index constant integration over x",minf];
								functiontooptimize=functiontooptimize/.{ToExpression[StringJoin["x",ToString[maxf]]] -> ToExpression[StringJoin["x",ToString[minf]]]};
								Print["Swap integration variables x",maxf," and x",minf];
								maxf=maxfey[functiontooptimize];
								Print["New highest index integration x",maxf];
							       ]
								Print["Integrations successfully ordered, only first ",helper," integrations needed"]
                                                    If[helper>constantscounter[fnepspole],constantscounter[fnepspole]=helper];
						    direy=StringJoin[direyt,"/epstothe",ToString[fnepspole]];
						    If[FileNames[direy]=={},CreateDirectory[direy]];
						    outfile=StringJoin[direy,"/f",ToString[functioncounter[fnepspole]],".f"];
						    moutfile = StringJoin[direy,"/f",ToString[functioncounter[fnepspole]],".m"];
						    funcname=StringJoin["P",polestring,"f",ToString[functioncounter[fnepspole]]];
						    try=OptimizeExpression[functiontooptimize, OptimizationSymbol -> w];
						    tt =try/.{OptimizedExpression->Hold};
						    he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
						    expr=ReleaseHold[he1];
						    writeopt[expr,varletter,funcname,outfile,helper];
                                                    (* Save[moutfile,functiontooptimize];*)
						    ]
						 ];
					      explicitintegrand[fnepspole]={explicitintegrand[fnepspole],nextelement};
					      memcount[fnepspole]=memcount[fnepspole]+nextmemcount;
					      ,
					      {fnepspole,epsfort+ordcheck,precisionrequired}
					      ]
					   ]
					]);
(****** DEFINITIONS *****************************************************************************)		

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
CreateDirectory[direy]; (*Creates the directory to save the files to. Most recent directory is ~diagramname*)
direyt=direy;
minpole = logi+lini+higheri;
varletter="w";
MyBlock[listvar_,listabbr_]:={listvar,listabbr};
(**********BEGIN Translate z[i]s for Fortran-Files and write list for the later remapping***)
xilist={};
Do[
   z[changezi]=ToExpression[StringJoin["x",ToString[changezi]]];
   xilist = {xilist, z[changezi]};
   ,
   {changezi,n}
];
(**********END Translate z[i]s *********************************************************)
zlist=Table[z[i],{i,n}];

fortranstring1="      double precision function ";
fortranstring0[helper_]:=StringJoin["(x)
      implicit double precision (a-h,o-z)
      integer ndi\n",dummystring,"\n      ",commonparamstring,"
      common/ndimen/ndi
      dimension x(",ToString[helper],")
"];

VarString[x_]:=StringJoin["      x",ToString[x]," = x(", ToString[x],")brk"];
tempfortstring[helper_]:=StringReplace[ToString[VarString/@Range[helper]],{"brk"->"\n",","->"","{"->" ","}"->""}]
fortranstring2[helper_]:= StringJoin[fortranstring0[helper], tempfortstring[helper]];
fortranstring3="
      return
      end";

(* inserted 30.11.14 GH *)
If[Length[integrandfunctionlist]>1,
diffexpos=Split[integrandfunctionlist,sametest],
diffexpos={integrandfunctionlist};
];

red[a_]:={a[[1,1]],Length[a]};
diff=red/@diffexpos;
runsneeded=Length[diff];
rmaxim=0;

constpre=constpre//.Gamma->mygamma;

If[FreeQ[constpre,eps],ordcheck=0;constepspre[0]=constpre;constepspre[AA_]:=0,
 ordcheck=Series[constpre,{eps,0,-10}][[4]];
 constpreser=Series[constpre,{eps,0,minpole+precisionrequired}];
 Do[
  constepspre[cep]=SeriesCoefficient[constpreser,cep]
 ,
  {cep,ordcheck,minpole+precisionrequired}
 ]
];
constimptab=Table[constimp[cep],{cep,ordcheck,minpole+precisionrequired}];
integimptab=Table[integimp[imt],{imt,-minpole,precisionrequired-ordcheck}];
expandedimp=Plus@@#&/@epsmulti[constimptab,integimptab,precisionrequired+minpole-ordcheck];

Do[functioncounter[tiepspow]=0;constantscounter[tiepspow]=0,{tiepspow,-minpole+ordcheck,precisionrequired}];


Print["Memory in use before optimizing = ",MemoryInUse[]];
createoptimizedfortran[cofrmin_,cofrmax_]:=
  Block[{},
	Do[
	   formnumericalintegrand[numintegdo,precisionrequired,partsflag];
	   If[
	      Or[numintegdo<10,Mod[numintegdo,10]==0,numintegdo==Length[integrandfunctionlist]]
	      ,
	      Print["numericalintegrand ", numintegdo, " evaluated, Memory in use = ",MemoryInUse[]]
	      ];
        ,{numintegdo,cofrmin,cofrmax}];
        infostream = OpenWrite[StringJoin[direyt,"/infofile"]];
	Do[
	   Write[infostream, StringJoin[ToString[tiepspow],"functions = ",
                 ToString[functioncounter[tiepspow]]]];
           Write[infostream, StringJoin[ToString[tiepspow],"constants = ",
                 ToString[constantscounter[tiepspow]]]]
	   ,{tiepspow,-minpole+ordcheck,precisionrequired}
	   ];
	Close[infostream];
	];
(*****************************************************************************************************)
Print["Producing fortran functions"];
forttime=AbsoluteTiming[Do[
		   symbolicsubtraction[diff[[rni,1]]];
		   rminim=rmaxim+1;
		   rmaxim=rmaxim+diff[[rni,2]];
		   createoptimizedfortran[rminim,rmaxim]
		   ,{rni,runsneeded}];
		][[1]];
Print["Fortran functions produced, time taken = ",forttime," seconds"];
