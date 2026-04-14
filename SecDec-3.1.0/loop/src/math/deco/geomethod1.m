(* ::Package:: *)

BeginPackage["Geomethod`"]

Geosecdec::usage=
	"Implementation of the sector decomposition method of Kaneko and Ueda (arXiv:0908.2897)"

Begin["`Private`"]

(*shifts parameter indices for lists in loop representation 
 Example: {t[2],t[3],t[4]}->{t[1],t[2],t[3]}*)
convloop[l_List]:=Block[{temp},
temp=l;
For[i=1,i<=Length[temp],i++,
temp[[i]][[3]]=temp[[i]][[3]]/.Table[If[j>=i,Global`t[j]->Global`t[j-1],Global`t[j]->Global`t[j]],{j,1,Length[temp[[1]][[2]]]}];
temp[[i]][[4]]=temp[[i]][[4]]/.Table[If[j>=i,Global`t[j]->Global`t[j-1],Global`t[j]->Global`t[j]],{j,1,Length[temp[[1]][[2]]]}];
temp[[i]][[2]]=Delete[Append[temp[[i]][[2]],0],temp[[i]][[1]]];
];
Return[temp]
];

(*Builds up list of exponent-vectors for primary sector n*)
geominput[l_List, n_Integer]:=Block[{u,f,npar,temp},
npar=Length[l[[1]][[2]]]-1;
u=Transpose[Table[Exponent[MonomialList[l[[n]][[3]][[1]][[1]],Table[Global`t[i],{i,1,npar}]],Global`t[i]],{i,1,npar}]];
f=Transpose[Table[Exponent[MonomialList[l[[n]][[3]][[2]][[1]],Table[Global`t[i],{i,1,npar}]],Global`t[i]],{i,1,npar}]];
temp=Select[Select[Table[DeleteCases[Union[Delete[Table[f[[k]]-f[[i]],{k,1,Length[f]}],i],Delete[Table[u[[k]]-u[[j]],{k,1,Length[u]}],j],Table[UnitVector[npar,m],{m,1,npar}]],a_/;VectorQ[a,#>0&]],{i,1,Length[f]},{j,1,Length[u]}]//Flatten[#,1]&,FreeQ[VectorQ[#,#<=0&]&/@#,True]& ],Length[#]==Length[DeleteDuplicates[#,#1==-#2&]]&];
Return[temp]
];

(*calls normaliz to calculate simplical cone of exponent vectors*)
normalizrun[l_List]:=Block[{temp,tril,npar,filename},
npar=Length[l[[1]]];
filename=StringJoin[Global`currentdir,"/",ToString[Unique["conenorm"]]];
Export[ToString[StringForm["`1`.in",filename]],Join[{Length[l]},{Length[l[[1]]]},l,{"hyperplanes"}],"Table"];
Run[StringForm["`1` -T `2`.in >/dev/null 2>&1",Global`normaliz,filename]];
temp=Import[ToString[StringForm["`1`.tgn",filename]],"Table"];
Which[temp[[1]][[1]]<npar,temp=Null,temp[[1]][[1]]==npar,temp=Drop[temp,2],temp[[1]][[1]]>npar,tril=Drop[Drop[Import[ToString[StringForm["`1`.tri",filename]],"Table"],2],None,-1];temp=Table[Drop[temp,2][[tril[[j]]]],{j,1,tril//Length}]];
Run[StringForm["rm -rf `1`.in `1`.out `1`.tri `1`.tgn `1`.inv",filename]];
Return[temp]
];

(*finds transformation matrices for all sectors/simplices in primary sector n*)
bases[l_List,n_Integer]:=Block[{geol,temp},
geol=geominput[l,n];
temp=DeleteCases[Table[normalizrun[geol[[i]]],{i,1,geol//Length}],Null];
Return[Level[temp,{-3}]]
];

(*performs transformation (using transformation matrices from bases (lb)) to the new basis and factors
 out variables in sector m of primary sector n*)
subst[l_List,lb_List,n_Integer,m_Integer]:=Block[{expl,u,ue,f,fe,num,nume},
u=l[[n]][[3]][[1]][[1]]/.Table[Global`t[j]->Product[Global`t[k]^(lb[[m]][[k]][[j]]),{k,1,Length[lb[[1]]]}],{j,1,Length[lb[[1]]]}]//FactorList;
ue=Select[u,Head[#[[1]]]==Global`t&];
u=Complement[u,ue];
u=Expand[Product[u[[j]][[1]]^u[[j]][[2]],{j,1,u//Length}]];
f=l[[n]][[3]][[2]][[1]]/.Table[Global`t[j]->Product[Global`t[k]^(lb[[m]][[k]][[j]]),{k,1,Length[lb[[1]]]}],{j,1,Length[lb[[1]]]}]//FactorList;
fe=Select[f,Head[#[[1]]]==Global`t&];
f=Complement[f,fe];
f=Expand[Product[f[[j]][[1]]^f[[j]][[2]],{j,1,f//Length}]];

num=l[[n]][[4]]/.Table[Global`t[j]->Product[Global`t[k]^(lb[[m]][[k]][[j]]),{k,1,Length[lb[[1]]]}],{j,1,Length[lb[[1]]]}]//FactorList;
nume=Select[num,Head[#[[1]]]==Global`t&];
num=Complement[num,nume];
num=Expand[Product[num[[j]][[1]]^num[[j]][[2]],{j,1,num//Length}]];

expl=Append[Table[Sum[l[[n]][[2]][[j]]*lb[[m]][[i]][[j]],{j,1,Length[l[[n]][[2]]]-1}],{i,1,Length[l[[n]][[2]]]-1}],0];
For[i=1,i<=Length[ue],i++,expl[[ue[[i]][[1]][[1]]]]=expl[[ue[[i]][[1]][[1]]]]+XU*ue[[i]][[2]]];
For[i=1,i<=Length[fe],i++,expl[[fe[[i]][[1]][[1]]]]=expl[[fe[[i]][[1]][[1]]]]+XF*fe[[i]][[2]]];
For[i=1,i<=Length[nume],i++,expl[[nume[[i]][[1]][[1]]]]=expl[[nume[[i]][[1]][[1]]]]+nume[[i]][[2]]];
(*include Jacobi-determinant*)
expl=Expand[Append[Table[expl[[i]]+Sum[lb[[m]][[i]][[j]],{j,1,lb[[m]][[i]]//Length}]-1,{i,1,Length[expl]-1}],Last[expl]]//.{XU->Global`expoU,Global`XU->Global`expoU,XF->Global`expoF,Global`XF->Global`expoF}];
Return[{n,expl,{{u,XU,A},{f,XF,A}}//.{XU->Global`XU, A->Global`A,XF->Global`XF},Abs[Det[lb[[m]]]]*num}]
];

(*Loops over sectors in primary sector n*)
res[l_List,n_Integer]:=Block[{basis},
basis=bases[l,n];
Table[subst[l,basis,n,i],{i,1,Length[basis]}]//Return
];
	
(*recover loop form of secdec Feynman parameters*)
convloopreverse[l_List]:=Block[{temp},
temp=l;
For[i=1,i<=Length[temp],i++,
temp[[i]][[3]]=temp[[i]][[3]]/.Table[If[j>=temp[[i]][[1]],Global`t[j]->Global`t[j+1],Global`t[j]->Global`t[j]],{j,1,Length[temp[[1]][[2]]]}];
temp[[i]][[4]]=temp[[i]][[4]]/.Table[If[j>=temp[[i]][[1]],Global`t[j]->Global`t[j+1],Global`t[j]->Global`t[j]],{j,1,Length[temp[[1]][[2]]]}];
temp[[i]][[2]]=Insert[Drop[temp[[i]][[2]],-1],0,temp[[i]][[1]]];
];
Return[temp]
];

(*Loops over primary sectors*)
Geosecdec[l_List]:=Block[{temp,in},
If[Length[l]==1,
Return[l/.{Global`B->Global`A}]
,
in=convloop[l];
temp=Flatten[ParallelTable[res[in,n],{n,1,Length[l[[1]][[2]]]}],1];
Return[convloopreverse[temp]]
]]

End[]
EndPackage[]



