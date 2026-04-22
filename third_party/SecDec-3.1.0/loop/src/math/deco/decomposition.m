(*
#****
# NAME
#  decomposition.m
# USAGE
#  called from subdir/graph/graph.m, via decomposeloop.pl
# PURPOSE
#  performs the primary and the iterated sector decomposition.
#  when infinite iteration is anticipated, a pre-decomposition
#  is performed using sdiQ to avoid this.
# RESULT
# [graph]sec*P*l*h*.out, graph*OUT.info written to subdir/graph, 
# SEE ALSO
#  primarySD.m, SDroutines.m, sdiQ.m
#****
*)

(* in Mathematica version >=8, decimal * 0 =0.(as decimal), whereas decimal * 0 = 0 (as
integer) for versions <8  *)

If[$VersionNumber>=8,                                                    
   Unprotect[MatchQ];                                                             
   MatchQ[aa_,0]:=MatchQ[N[aa],N[0]];                                          
   Protect[MatchQ]
   ];  

(*qlist is the list of sectors needing pre-decomposition to stop infinite recursion*)

Remove[primseclist];
(* does the actual sector decomposition *)

If[userdefined==0,
   Get[StringJoin[path,ToString["loop/src/math/deco/primarySD.m"]]];
   Get[StringJoin[path,ToString["loop/src/math/deco/SDroutines.m"]]]
   ,
   Get[StringJoin[path,ToString["loop/src/math/deco/NSDroutines.m"]]];
   ];
(*
 mandmin=Table[Table[sp[i,j]->-sp[i,j],{j,i+1,externallegs}],{i,externallegs-1}]//Flatten;
 extmassmin=Table[ssp[i]->-ssp[i],{i,externallegs}];
 invarminusreps=Join[mandmin,extmassmin,{sp[i_,j_,k_]->-sp[i,j,k]}];
 *)

decotime =
  AbsoluteTiming[
		 If[And[userdefined==0,MatchQ[Nu[z],0]],
		    Print["Numerator is zero."];
		    makeoutputzeronum
		    , (*else*)
		    If[userdefined==0,
		       FF[z]=Expand[F[z]];
		       UU[z]=Expand[U[z]];
		       (* NNu[z]=Expand[Nu[z]]; *)
		       NNu[z]=Nu[z];
		       ];
		    
		    If[strategy=="G2",
		       Get[StringJoin[path,ToString["loop/src/math/deco/geomethod2.m"]]];
		       decomposedsectors=Geomethod2`Geosecdec2[{npmax,NNu[z],UU[z],FF[z]}];
		       (*primseclist={{npmax}};*)
		       primseclist={#} & /@ Range[npmax];
		       ,
		       If[userdefined==0,
			  primlist=Complement[Intersection[Table[np,{np,1,Length[powerlist]}],
							   indlist],qlist];
			  qlist=Intersection[qlist,indlist];
			  primseclist=primarysec[#,FF[z],UU[z],NNu[z],loops]&/@primlist;
			  If[MatchQ[qlist,{}]==False,
			     Get[StringJoin[path,ToString["loop/src/math/deco/sdiQ.m"]]];
			     qprimseclist=primarysec[#,FF[z],UU[z],NNu[z],loops]&/@qlist;
			     qseclist=(Sequence@@sdiQ[#])&/@qprimseclist;
			     primseclist={Sequence@@qseclist,Sequence@@primseclist}
			     ];
			  ,
			  (*First search for position of the functions in functionlist 
			   which need sdiQnoprim called in qlist:*)
			  qlist=Flatten[Position[functionlist[[#,1]]&/@Table[np,
			    {np,1,Length[functionlist]}],#]&/@qlist];
			  (*Find the position of the functions desired by indlist*)
			  indlist=Flatten[Position[functionlist[[#,1]]&/@Table[np,
			    {np,1,Length[functionlist]}],#]&/@indlist];
			  qlist=Intersection[qlist,indlist];
			  (*Then take complement of these found positions to get normal 
			   decomposition for functions not listed in qlist*)
			  primlist=Complement[Intersection[Table[np,
			    {np,1,Length[functionlist]}],indlist],qlist];
			  pprimseclist=functionlist[[#]]&/@primlist;
			  
			  If[MatchQ[qlist,{}]==False,
			     (*load package which decomposes squared Feynman parameters first*)
			     Get[StringJoin[path,ToString["loop/src/math/deco/sdiQnoprim.m"]]];
			     qprimseclist=functionlist[[#]]&/@qlist;
			     qseclist=(Sequence@@sdiQ[#])&/@qprimseclist;
			     primseclist={Sequence@@qseclist,Sequence@@pprimseclist}
			     ,
			     primseclist=pprimseclist;
			     ];
			  ];
		       (*Save["primsec.m",primseclist];*)
		       If[MatchQ[splitlist,{}]==False,
			  Get[StringJoin[path,ToString["loop/src/math/deco/split.m"]]];
			  (*Go through all sectors in primseclist to remap Feynman 
			   parameter t[j] where the j is given by an entry in the 
			   splitlist. If t[j] occurs in a sector do a remapping,
			  else do nothing but preserve the list structure, that is
			   the level in the list*)
			  Do[
			     primseclist=Flatten[If[MemberQ[#,t[splitlist[[i]]],Infinity],
						    split[#,splitlist[[i]],Nn],{#}] &/@primseclist,1];
			     ,{i,Length[splitlist]}
			     ];
			  ];
		       If[userdefined==0,
			  If[strategy=="G1", 
			     Get[StringJoin[path,ToString["loop/src/math/deco/geomethod1.m"]]];
			     decomposedsectors=Geomethod`Geosecdec[primseclist];
			     , 
			     decomposedsectors=IteratedSDpack`IteratedSD[primseclist];
			     ]
			  ,
			  decomposedsectors=IteratedNSDpack`IteratedNSD[primseclist];
			  ];
		       ];

		    (* map to list structure needed for ibp procedure and beyond *)
		    decomposedsectors=({#[[1]],#[[2]],#[[3,1,1]],#[[3,2,1]],
					#[[4]],{#[[3,1,2]],#[[3,2,2]]}//.
					{XU->Global`expoU,XF->Global`expoF}}) &/@ decomposedsectors;

		    If[ibpflag > 0,
		       ibptime =
		       AbsoluteTiming[
				      Get[StringJoin[path,ToString["loop/src/math/deco/ibp.m"]]];
				      Print["Initial number of functions: ",
					    Dimensions[decomposedsectors]];
				      decomposedsectors = IBP`ibp[decomposedsectors];
				      Print["Final number of functions: ",
					    Dimensions[decomposedsectors]];
				      makeibpoutput[newsectors];
				      ][[1]];
		       
		       Print["\n"];
		       Print["Time taken for application of integration by parts: ",ibptime," secs"]
		       ,
		       Print["No integration by parts performed."];
		       ];
		    makeoutput;
		    ];
		 ];
Print["\n"];
Print["Time taken to do the decomposition: ",decotime[[1]]," secs"];

