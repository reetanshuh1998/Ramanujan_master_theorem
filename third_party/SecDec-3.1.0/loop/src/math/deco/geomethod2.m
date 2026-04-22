(* ::Package:: *)

BeginPackage["Geomethod2`"]

Geosecdec2::usage=
	"Geometric Sector Decomposition"

Geosecdec2[in_List]:=result[in];

Begin["`Private`"]

tovertices[l_List]:=Module[{parlist,temp,templ},
parlist=Global`z/@Range[l[[1]]-1];
templ=l;
templ[[2]]=templ[[2]]*Product[Global`z[i]^(1-Global`powerlist[[i]]),{i,1,Length[Global`powerlist]}];
temp=Transpose[GroebnerBasis`DistributedTermsList[#//.{Global`z[templ[[1]]]->1},parlist][[1]]]&/@Drop[templ,1];
Return[temp]]

minkowskisum[l_List]:=Block[{temp},
temp=Cases[Tally@(Total[#]&/@Tuples[l[[All,1]]]),{_,1}][[All,1]];
Return[temp]]

normalizrun[l_List]:=Block[{npar,rays,conelist,filename},
npar=Length[l[[1]]];
filename=StringJoin[Global`currentdir,"/",ToString[Unique["polynorm"]]];
(*export list of points, running normaliz gives equations for facets (rays)*)
Export[ToString[StringForm["`1`.in",filename]],Join[{Length[l]},{npar},l,{"polytope"}],"Table"];
Run[StringForm["`1` -s -a `2`.in >/dev/null 2>&1",Global`normaliz,filename]];
rays=Import[ToString[StringForm["`1`.cst",filename]],"Table"];
conelist = Drop[Import[ToString[StringForm["`1`.ext",filename]], "Table"], 2, -1];
Run[StringForm["rm -rf `1`.in `1`.out `1`.cst `1`.inv `1`.esp `1`.ext" ,filename]];
(*sort rays by weight*)
rays=SortBy[rays[[3;;rays[[1]][[1]]+2]],Total[Abs[#[[1;;-2]]]]&];
(*find rays incident to points*)
conelist=(Position[#,0]//Flatten)&/@(ArrayFlatten@{{conelist,List/@ConstantArray[1,conelist//Length]}}.Transpose[rays]);
rays=Drop[rays,0,-1];
(*triangulate cones with # of rays > npar, do we need a check for # of rays < npar?*)
filename=StringJoin[Global`currentdir,"/",ToString[Unique["conenorm"]]];
conelist=If[Length[#]>npar,
Export[ToString[StringForm["`1`.in",filename]],Join[{Length[#]},{npar},rays[[#]],{"integral_closure"}],"Table"];
Run[StringForm["`1` --T `2`.in >/dev/null 2>&1",Global`normaliz,filename]];
Drop[Drop[Import[ToString[StringForm["`1`.tri",filename]],"Table"],0,-1],2]/.Inner[Rule,Range[Length[#]],#,List]
,#]&/@conelist;
Run[StringForm["rm -rf  `1`.in `1`.inv `1`.out `1`.tgn `1`.tri",filename]];
Return[{rays,Level[conelist,{-2}]}];
]

subst[poly_List,basis_List] := Block[{mat,mats,jacobi,min,func,expolist,secmat,powerl},
mat=#[[1]].Transpose[basis[[1]]]&/@poly;
powerl=Drop[(Global`powerlist-1),-1].Transpose[basis[[1]]];
jacobi=(Total[#]-1)&/@basis[[1]];
min=Map[Function[x,Min[#]&/@Transpose[x]],mat];
mats=MapThread[Function[{x,y},(#-y)&/@x],{mat,min}];
expolist=MapThread[#1+#2+#3+#4*Global`expoU+#5*Global`expoF&,Cases[{jacobi,powerl,min},__?VectorQ,-2]]//Expand;
				   DistributeDefinitions[mats,expolist];

If[And[$VersionNumber>6,Global`nbkernels>0],
   LaunchKernels[Global`nbkernels];
   Return[ParallelMap[Function[x,
       secmat=mats[[All,All,x]];
func=Table[Sum[poly[[k]][[2]][[i]]*Product[Global`t[j]^secmat[[k]][[i]][[j]],{j,1,Length[secmat[[k]][[1]]]}],{i,1,Length[secmat[[k]]]}],{k,1,Length[secmat]}];
{Length[basis[[2]][[1]]]+1,Append[expolist[[x]],0],
{{func[[2]],Global`XU,Global`A},{func[[3]],Global`XF,Global`A}},Abs[Det[basis[[1]][[x]]]]*func[[1]]
}],basis[[2]]]]
   ,
   Return[Map[Function[x,
       secmat=mats[[All,All,x]];
func=Table[Sum[poly[[k]][[2]][[i]]*Product[Global`t[j]^secmat[[k]][[i]][[j]],{j,1,Length[secmat[[k]][[1]]]}],{i,1,Length[secmat[[k]]]}],{k,1,Length[secmat]}];
{Length[basis[[2]][[1]]]+1,Append[expolist[[x]],0],
{{func[[2]],Global`XU,Global`A},{func[[3]],Global`XF,Global`A}},Abs[Det[basis[[1]][[x]]]]*func[[1]]
								  }],basis[[2]]]];
   ];
]

result[l_List] :=
 Block[{vertices, fan},
       If[l[[1]]==1,
	  Return[{{1,{0},{{l[[3]],Global`XU,Global`A},{l[[4]],Global`XF,Global`A}},l[[2]]}}/.{Global`z[1]->1}]
	  ,
	  vertices=tovertices[l];
	  fan=normalizrun[minkowskisum[vertices]];
	  Return[subst[vertices,fan]];
	  ];
       ];

End[];
EndPackage[];
