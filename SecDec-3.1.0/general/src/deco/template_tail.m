
(* ********* inserted after end of user input ************* *)

(* check if input can be factored further *)
Do[
checkfac=FactorList[factorlist[[i,1]]];
lcheck=Length[checkfac];
Do[checkfac[[jj,2]]=factorlist[[i,2]]*checkfac[[jj,2]],{jj,lcheck}];
If[lcheck>2,
factorlist=Flatten[ReplacePart[factorlist,{i}->checkfac],1];
]
,{i,Length[factorlist]}];

allowedsymbols={};
dummyfunctions={};

allowedr=(#->0.555)&/@allowedsymbols;
dummyr=(#[___]->0.88)&/@dummyfunctions;
intvarsr=(#->0.2)&/@intvars;

validcheckreps=Join[intvarsr,allowedr,dummyr,{eps->0.01}];

inputcheck=N[Product[factorlist[[i,1]]^factorlist[[i,2]],{i,Length[factorlist]}]/.validcheckreps];

validflag=True;
If[NumberQ[inputcheck]==False,
Print["Please verify your input - undefined parameters detected"];
validflag=False];

If[validflag==True,
path=Directory[];

integralname=ToString[int];

currentdir=OutputDir;

fordeco[fdl_]:=If[And[Length[fdl]==3,fdl[[3]]==n],n,y];
facform[ffl_]:={ffl[[1]],ffl[[2]]};

Get[StringJoin[path,ToString["src/deco/constprefac.m"]]];
(*removes overall constant prefactors from factorlist, these are now 'constpre'*)


decomposeflags=fordeco/@factorlist;
factorlist=facform/@factorlist;
(*Print["factorlist=",factorlist];*)



(* the following will be adjusted by perl script decompose.pl according to input given in param.input *)






(* **********  sector decomposition   **************** *)

(* prepare the input for decomposition *)

Get[StringJoin[path,ToString["src/deco/prepareinput.m"]]];
Get[StringJoin[path,ToString["src/deco/split.m"]]];

Nn=Length[intvars];

todeco=collecteps[intvars,factorlist,decomposeflags];

lsplit=Length[splitlist];
If[lsplit>0,
  Do[
  tt={};
  tlist=todeco[[2]];
  lt=Length[tlist];
  Do[
    tt=Join[tt,split[tlist[[k]],splitlist[[i]]]];
 ,{k,lt}]; 
  todeco={Length[tt],tt};
  ,{i,lsplit}];
]; (* endif lsplit>0 *)
Do[
 tint=todeco[[2,i,6]];
 tflags=todeco[[2,i,7]];
 newif=simplifylists[tint,tflags];
 todeco[[2,i,6]]=newif[[1]];
 todeco[[2,i,7]]=newif[[2]]
,
 {i,todeco[[1]]}
];
newtodeco=reformtodeco/@todeco[[2]];

(* do the iterated decomposition *)

Get[path<>"src/deco/decomposition.m"];


];
