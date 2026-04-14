(*
TODO: replace a,b, with alocal,blocal 
#
#****m* SecDec/general/src/deco/SDroutines.m
# NAME
#  SDroutines.m
# USAGE
#  called from decomposition.m
# PURPOSE
#  Contains routines to perform iterated SD, and to output files created by
#  decomposition.m
# FUNCTIONS
# for the decomposition:
#  countvars[cvf,cfv]: finds the maximum power of a set of variables cfv 
#   in a function cvf.
#  findpossset[fexpr]: finds all minimal sets (wrt length) of the
#   integration variables which nullify a function fexpr.
#   returns these sets, together with an integer which
#   is the maximum power of these integration variables in the function.
#  howmanynullify[posset,integrands]: counts the number of integrands
#   a given set posset nullifies.
#  findbestset[integrands,n]: finds the 'best' set which nullifies 
#   function n from the list of integrands.
#   'best' is the set which nullifies the most integrands,
#   and has the lowest maximum power of integration variables in 
#   integrand n
#  paralleldecompose[allsecs]: maps 'decompose' onto each sector in allsecs,
#   uses parallel processing where available/appropriate. allsecs is a lists
#   of sectors to be decomposed. Returns a list of fully decomposed sectors.
#  exdecompose[esec,set,varnum]: performs the explicit replacements needed
#   for decomposition. Factorizes the integrands and recalculates the
#   exponents of the integration variables. Returns a sector which may
#   require further decomposition.
#  factorizeintegrand[{integ,expo,flag},tt,var]: pulls out any factors of
#   tt[var] in int, recalculates the exponent of tt[var] and returns  
#   {factorized int, expo, new flag}. flag/new flag = A or B.
#  decompose[dsec]: Checks whether dsec needs decomposition. If not (ie all
#   flags = A), returns {dsec}. Otherwise the set of variables to decompose
#   is selected by findbestset, and exdecompose is mapped onto this set.
#   newsecs is the list of transformed sectors, and then this list of sectors
#   is further decomposed by paralleldecompose[newsecs]. when this process
#   terminates, decompose returns a list of fully decomposed sectors.
#  
# for preparing and writing output:
#  polecheck[expos]: classifies a a list of exponents by number of logarithmic,
#   linear and higher poles.
#  makesectoroutput[sector]: classifies a sector by its pole structure.
#   increments the counter polecount[polestruct] for this classification,
#   and adds a pointer to sector in a list seclist[polestruct] linked to
#   this classification. If polestruct is the first of this structure,
#   it is added to the list structlist of observed pole structures.
#  writeoutput[polestruct]: Updates the values of maxpoles where applicable.
#   the list of pointers is used to form the final
#   list of sectors for this polestruct to write for output. The output is 
#   written to the appropriate [integral]P[polestruct].out. The information
#   on number of sectors with this pole structure is
#   added to the string poleinfostring
#  writeinfo: writes the necessary information to file [integral]OUT.info.
#   this info includes number of integration variables nmax, total number of
#   sectors produced allcount, maximum poles maxlogpole,
#   maxlinpole, maxhpole, and the order of the constant prefactor prefacord.
#   the constant prefactor constpre is written to the file prefactor.m
#  makeoutput: calculates the total number of sectors, performs makesecoutput
#   to each sector, reformats the sectors to be in the desired output format,
#   sorts the structlist into order of complexity, performs writeoutput for each
#   pole structure, then performs writeinfo.
#  
# 
#****
*)
Unprotect[Cancel];
Cancel[a_/b_]:=Cancel[#/b]&/@a/;MatchQ[Head[a],Plus]&&(MatchQ[Head[b],Plus]==False)
Protect[Cancel];
inpar=False;
If[$VersionNumber<7,Parallelize[AA_]:=AA,Quiet[LaunchKernels];dds:=DistributeDefinitions["Global`"]];
allvars=Table[x[i],{i,nmax}];
allreps=Table[x[i]->0,{i,nmax}];
allrepsubs=Subsets[allreps,{2,nmax}];

countvars[cvf_,cfv_]:=Module[{IND,restvars,fcheck},
 restvars=Complement[allvars,cfv];
 fcheck=((cvf/.((x[#]->1)&/@restvars))/.((x[#]->IND)&/@cfv))//Expand;
 Return[{Exponent[fcheck,IND],cfv}]]

findpossset[fexpr_]:=Module[{minnumvars,minsets,possets},
 minnumvars=nmax;
 findminsets[fe_,fr_]:=If[And[Length[fr]<=minnumvars,MatchQ[fe/.fr,0]],
  minnumvars=Length[fr];fr,null];
 minsets=(findminsets[fexpr,#]&/@allrepsubs)//.{AA___,null,BB___}->{AA,BB};
 minsets=minsets/.(x[a_]->0)->a;
 possets=countvars[fexpr,#]&/@minsets;
 Return[possets]]

nullify[set_,{aa__,A}]:=0;
nullify[set_,{func_,expo_,B}]:=If[MatchQ[(func/.((x[#]->0)&/@set)),0],1,0]

howmanynullify[posset_,integrands_]:=Module[{set,nulcount},
 set=posset[[2]];
 nulcount=Plus@@(nullify[set,#]&/@integrands);
 Return[{nulcount,Sequence@@posset}]]

findbestset[integrands_,n_]:=Module[{possets,bestset},
 possets=findpossset[integrands[[n,1]]];
 possets=howmanynullify[#,integrands]&/@possets;
  possets=Sort[possets,If[#1[[1]]>#2[[1]],True,If[#1[[1]]<#2[[1]],False,#1[[2]]<#2[[2]]]]&];
   bestset=possets[[1,3]];
 Return[bestset]];

paralleldecompose[allsecs_]:=(inpar=True;dds;ParallelMap[(Sequence@@decompose[#])&,allsecs])/;
$VersionNumber>=7&&Length[allsecs]>1&&inpar==False;

paralleldecompose[allsecs_]:=(Sequence@@decompose[#])&/@allsecs

decompose[dsec_]:=Module[{integrands,needs,needssd,n,nt,newsecs,possets,bestset},
  integrands=dsec[[5]];
  needs[{a_,b_,A}]:=False;needs[B_]:=True;
 needssd=needs/@integrands;
 n=0;nt=0;
 (If[MatchQ[n,0],nt++;If[#,n=nt]])&/@needssd;
  If[MatchQ[n,0],Return[{dsec}],
  bestset=findbestset[integrands,n];
  newsecs=exdecompose[dsec,bestset,#]&/@bestset;
    newsecs=paralleldecompose[newsecs];
  Return[newsecs]
 ]
]

factorizeintegrand[{a__,A},BB__]:={a,A};
factorizeintegrand[int_,tt_,var_]:=int/;MatchQ[int[[1]]/.tt[var]->0,0]==False;
factorizeintegrand[int_,tt_,var_] := 
  Block[{integ,expo,sqrtterms,assum},
	 integ=int[[1]];
	 expo=int[[2]];
	 factoredexp=factoredexp+expo;
	 If[FreeQ[integ,Sqrt[__]]==False,
	    (* split integrand into part containing square 
	     roots, and a part containing the rest *)
	    sqrtterms = integ[[#]] &/@ DeleteDuplicates[(#[[1]]&/@Position[integ,Sqrt[__],Infinity])];
	    integ = Cancel[(integ - Plus@@sqrtterms)/tt[var]];
	    (* define assumptions for integration parameters to simplify sqrts *)
	    assum = DeleteDuplicates[Thread[Cases[sqrtterms, tt[_], Infinity] >= 0]];
	    (* divide by tt[var] and simplify *)
	    sqrtterms = Plus @@ 
	    ((FullSimplify[FullSimplify[#, TimeConstraint->3]/tt[var],
			   Assumptions -> assum, 
			   TimeConstraint -> 3])&/@sqrtterms);
	    If[And[MatchQ[(integ/.tt[a_]->0) != 0, True], 
		   MatchQ[(integ/.tt[a_]->0) == -(sqrtterms/.tt[a_]->0),True]]
	       ,
	       integ = integ + sqrtterms;
	       Return[{integ,expo,A}]
	       ,
	       integ = integ + sqrtterms;
	       ]
	    ,
	    integ = Cancel[integ/tt[var]]
	    ];
	 If[MatchQ[integ/.tt[a_]->0,0],
	    Return[factorizeintegrand[{integ,expo,B},tt,var]],
	    Return[{integ,expo,A}]];
	 ]; 





exdecompose[esec_,set_,varnum_]:=Module[{t,tsec,tset,newintegrands,
	tempexpos,newvars,newoneminusexpos,newoneminusvars,
	expofrommeasure,expofromjac,output},
 tsec=esec/.(x[a_]->t[a]);
  tset=Complement[set,{varnum}];
  tsec=tsec/.((t[#]->t[#]t[varnum])&/@tset);
 factoredexp=0;
  newintegrands=factorizeintegrand[#,t,varnum]&/@tsec[[5]];
  tempexpos=tsec[[1]];
 newvars=tsec[[2]];
 newoneminusexpos=tsec[[3]];
 newoneminusvars=tsec[[4]];
 expofrommeasure=Sum[If[MemberQ[set,i],tempexpos[[i]],0],{i,nmax}];
 expofromjac=Length[tset];
 tempexpos[[varnum]]=factoredexp+expofrommeasure+expofromjac//Simplify;
 newexpos=tempexpos;
 output={newexpos,newvars,newoneminusexpos,newoneminusvars,newintegrands}/.t[a_]->x[a]
];



polecheck[expos_]:=Module[{log,lin,high},
 log=0;lin=0;high=0;
 If[#<-2,high++,If[#<-1,lin++,If[#==-1,log++]]]&/@(expos/.eps->0);
 Return[{log,lin,high}]];

seccount=0;structlist={};overallmaxpolelist={};

makesecoutput[sector_]:=Module[{polestruct},
 seccount++;
 polestruct=polecheck[sector[[1]]];
 locmaxpole=Sum[polestruct[[i]],{i,Length[polestruct]}];
 overallmaxpolelist=Append[overallmaxpolelist,locmaxpole];
 If[NumberQ[polecount[polestruct]],polecount[polestruct]++,
  polecount[polestruct]=1;structlist=Append[structlist,polestruct];seclist[polestruct]={}];
 seclist[polestruct]={seclist[polestruct],impsec[seccount]}];
 
 htlt[l1_,l2_]:=If[l1[[3]]>l2[[3]],True,If[l1[[3]]<l2[[3]],False,
  If[l1[[2]]>l2[[2]],True,If[l1[[2]]<l2[[2]],False,l1[[1]]>l2[[1]]]]]];
 
writeoutput[polestruct_]:=Module[{sl,pls,plstring,outfile,symbG},
 maxpoles=MapThread[If[#1>#2,#1,#2]&,{polestruct,maxpoles}];
 overallmaxpole=Max[overallmaxpolelist];
 Quiet[sl=(seclist[polestruct]//Flatten)/.impsec[aa_]->decomposedsectors[[aa]]];
 pls=ToString/@polestruct;
 plstring="P"<>pls[[1]]<>"l"<>pls[[2]]<>"h"<>pls[[3]];
 outfile=currentdir<>integralname<>plstring<>".out";
 symbG=plstring<>"=";
 OpenWrite[outfile];
 WriteString[outfile,symbG];
 Write[outfile, sl];
 Close[outfile];
 poleinfostring=poleinfostring<>"poles"<>plstring<>" = "<>ToString[polecount[polestruct]]<>"\n";
]
 
writeinfo:=Module[{},
 poleinfo=currentdir<>integralname<>"OUT.info";
 prefacinfo=currentdir<>"prefactor.m";
 OpenWrite[poleinfo];
 WriteString[poleinfo,poleinfostring];
 Close[poleinfo];
 prefacord=If[FreeQ[constpre,eps],0,Series[constpre,{eps,0,-10}][[4]]];
 maxlogpole=maxpoles[[1]];maxlinpole=maxpoles[[2]];maxhpole=maxpoles[[3]];
 Save[poleinfo,nmax,allcount,maxlogpole,maxlinpole,maxhpole,prefacord,overallmaxpole];
 OpenWrite[prefacinfo];Close[prefacinfo];
 Save[prefacinfo,constpre];
];
 
 
 
makeoutput:=Module[{},
 allcount=Length[decomposedsectors];
 makesecoutput/@decomposedsectors;
 maxpoles={0,0,0};
 structlist=Sort[structlist,htlt];
 poleinfostring="";
 writeoutput/@structlist;
 writeinfo; 
]
 
 








