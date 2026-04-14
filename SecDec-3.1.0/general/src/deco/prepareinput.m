(*
#****m* SecDec/general/src/deco/prepareinput.m
# NAME
#  prepareinput.m
# USAGE
#  called by subdir/graph/graph.m, run by decompose.pl
# SYNOPSIS
# extracts terms which factorise already and fills lists with factorising exponents
# PURPOSE
#  prepares necessary lists  for use in the decomposition
# SEE ALSO
#  decomposition.m, decompose.pl
#****
*)
(* prepare input for  secdec *)



(* extracts terms which factorize already and fills lists with factorizing exponents  *)

collecteps[zvec_,fuinput_,ynlist_]:=Module[{i,j,l,Nvars,Nfus,locvars,
                                   varlist,oneminusvarlist,integrand,
                                   fus,fuexpos,newintegrand,newintegrandpre,
				   varexpos,oneminusvarexpos,min,catflags,catflag,
				   depth,outlist},
			   
			  
Nvars=Length[zvec];
Nfus=Length[fuinput];
integrand=fuinput;
varlist=zvec;
oneminusvarlist=Table[1-varlist[[l]],{l,Nvars}];
depth=1; 

fuexpos=Table[integrand[[i,2]],{i,Nfus}];
fus=Table[integrand[[i,1]],{i,Nfus}];

(* extract expos from factorizing part of integrand *)

varexpos=Table[0,{i,Nvars}];
oneminusvarexpos=Table[0,{i,Nvars}];

(* internally always call variables x *)
locvars=Table[x[i],{i,Nvars}];
zvec=locvars;

(* check for decomposeflag removed 30.11.14, monomials need to be factored out in any case *)        

newintegrand=integrand;
Do[
   Do[ 
   	If[integrand[[k,1]]==varlist[[l]], varexpos[[l]]=varexpos[[l]]+integrand[[k,2]];
       newintegrand =ReplacePart[newintegrand,{1,1},k]
       ];
        If[integrand[[k,1]]==oneminusvarlist[[l]],
	 oneminusvarexpos[[l]]=oneminusvarexpos[[l]]+integrand[[k,2]];
           newintegrand =ReplacePart[newintegrand,{1,1},k]
	  ];
			If[integrand[[k,1]]==-oneminusvarlist[[l]],
	 oneminusvarexpos[[l]]=oneminusvarexpos[[l]]+integrand[[k,2]];
           newintegrand =ReplacePart[newintegrand,{-1,1},k]
	  ];
     ,{k,Nfus}]
,{l,Nvars}];

(*newintegrand=Product[Power[newintegrand[[k,1]],newintegrand[[k,2]]],{k,Nfus}];*)
Do[
min[k]=newintegrand[[k,1]]/.Table[varlist[[i]]->0,{i,Nvars}];
If[(min[k]==0 && MatchQ[decomposeflags[[k]],y]), catflag[k]=B, catflag[k]=A,catflag[k]=A]; 
,{k,Nfus}];
catflags=Table[catflag[k],{k,Nfus}];


outlist={depth,{{{1},varexpos,varlist,oneminusvarexpos,oneminusvarlist,newintegrand,catflags}}};
(* list in position 2 will get more elements (each of Length 7) in each iteration *)

(* debug: 
Print["outlist=",outlist]; *)

Return[outlist];

]; (* close Module *)

(* if element1 and element2 are the same, add the exponents and combine the basis into one list element *)
simplists[sA___,el1_,sB___,el2_,sC___]:=(
simplists[sA,{el1[[1]],el1[[2]]+el2[[2]],el1[[3]]},sB,sC]/;MatchQ[el1[[1]],el2[[1]]]);

(* if basis is 1, drop the element *)
simplists[sA___,{1,sB__},sC___]:=simplists[sA,sC];
(* line below inserted 30.11.14 GH *)
simplists[]:={{{1,1}},{A}};
simplists[sA__]:=Module[{},
sAt={sA};
{Table[{sAt[[i,1]],sAt[[i,2]]},{i,Length[sAt]}],Table[sAt[[i,3]],{i,Length[sAt]}]}
];

simplifylists[integrand_,flags_]:=simplists@@(Flatten/@(MapThread[List,{integrand,flags}]));


reformtodeco[seca_]:=Module[{l1,l2,l3,l4,l5,t1,t2},
l1=seca[[2]];l2=seca[[3]];l3=seca[[4]];l4=seca[[5]];
t1=seca[[6]];t2=seca[[7]];
l5=MapThread[Append,{t1,t2}];
Return[{l1,null,l3,l4,l5}]];

