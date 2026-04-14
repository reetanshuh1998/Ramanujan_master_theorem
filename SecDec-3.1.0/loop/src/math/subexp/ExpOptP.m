(*
  #****
  #  NAME
  #    ExpOpt.m
  #
  #  USAGE
  #  loaded by formPfortran.m, formPC.m or formContourPC.m
  # 
  #  USES 
  #  Format.m (for FortranAssign), Experimental` (for OptimizeExpression)
  #
  #  USED BY 
  #    
  #  formPfortran.m, formPC.m or formContourPC.m
  #
  #  PURPOSE
  #  Takes an optimized expression from formPfortran.m, formPC.m or formContourPC.m, and writes it in fortran/C++ syntax to the appropriate subdirectory.
  #    
  #  INPUTS
  #  from formPfortran.m, formPC.m or formContourPC.m:   
  #  inlist: the optimized expression to be turned into fortran/C++ syntax
  #  varletter: the letter each intermediate expression in the optimization will be prefixed by
  #  funcname: the name of the function to be written
  #  outfile: where the file is to be written
  #  fortranstring1,2,3: strings with the necessary fortran syntax
  #  xstring: string with the necessary assignments for x (IBP only), in fortran format.
  #  Cstrings: strings with the necessary C++ syntax
  #  path: where to load parts.m, ExpOpt.m from
  #    
  #  RESULT
  #  the f*.f (or with contour deformation f*.cc and g*.cc) file is written in fortran/C++ syntax to the specified subdirectory
  #    
  #  SEE ALSO
  #  formPfortran.m, formPC.m or formContourPC.m and Format.m
  #   
  #****
*)
(*load Sofroniou`s Format.m *)


Remove[subs,d];
Quiet[Needs["Experimental`"];Evaluate[Get[StringJoin[path,"loop/src/math/util/","Format.m"]]]];
If[nbkernels>0,
	DistributeDefinitions[path];
	Quiet[ParallelNeeds["Experimental`"];ParallelEvaluate[Get[StringJoin[path,"loop/src/math/util/","Format.m"]]]];
];

(*---------------START write C++ files-------------------------------------*)
(* Block needed by formPC.m and formContourPC.m to write C++ files *)
writeoptC[inlist_,varletter_,funcname_,outfile_,statval_:0]:=
  Block[{aa,append,comp,Cst1,Cst2,Cst5,costring,li1,li2,count,le,helpstring,fu,repl,wcount,vectorreplace,vrexp,fst,varname,varval,wwrite},
	cassign[cassargs__]:=(Write[fst,Quiet[CAssign[cassargs,AssignOptimize->False]]]);
	FORMATREPS=(#<>"("~~ShortestMatch[ar__]~~".)"->#<>"["~~ar~~"]")&/@{varletter,"es","esx","em","xvals","lrs"};
	If[MatchQ[statval,0],append=0;comp=1,comp=0;If[MatchQ[statval,1],append=0,append=1]];
	If[MatchQ[comp,1],
	   costring="dcmplx";
	   Cst1=Cstring1;
	   Cst5=Cstring5[costring]<>Cstring7;
	   FORMATREPS=Join[FORMATREPS,{"log"->"myLog"}];
	   FORMATREPS=Join[FORMATREPS,{"emreal"<>"("~~ShortestMatch[ar__]~~".)"
	                               ->"em"<>"["~~ar~~"].real()"}];
	   FORMATREPS=Join[FORMATREPS,{"emimag"<>"("~~ShortestMatch[ar__]~~".)"
	                               ->"em"<>"["~~ar~~"].imag()"}];
	   ,
	   costring="double";
	   Cst1=Cstring3;
	   Cst5=Cstring5[costring];
	   ];
	Cst2=funcname<>Cstring2[costring]<>Cstring4;
	If[
	   MatchQ[append,0]
	   ,
	   fst=OpenWrite[outfile];WriteString[fst,Cst1]; 
	   ,
	   fst=OpenAppend[outfile];WriteString[fst,costring<>" "]
	   ];
	WriteString[fst,Cst2,Cst5];
	wwrite={};
	If[Quiet[ArrayQ[inlist[[1]]]==True],
	   li2=inlist[[2]];
	   li1=inlist[[1]];
	   le=Length[li1];
	   count=1;
	   repl={};
	   Do[
	      varname[count]=StringJoin[varletter,"[",ToString[count],"]"];
	      (*	varname=StringJoin[varletter,ToString[count]];*)
	      varval[count]=(li2[[j,2]]/.repl/.{Power[aa_,-1]->1./aa});
	      wwrite={wwrite,imcassign[varname[count],varval[count]]};
	      repl=Append[repl,li1[[j]]->ToExpression[varletter][count]];
	      (*WriteString[outfile,"double ", varletter];
	       Write[outfile,count];*)
	      count++
	      ,{j,le}
	      ];
	   wcount=count-1;
	   WriteString[fst,Cstring4a[count,costring]];
	   wwrite=Flatten[wwrite];
	   wwrite=wwrite/.vectorreplace->vrexp;
	   #/.{imcassign->cassign}&/@wwrite;
	   fu=li2[[le+1]]/.repl;
	   Write[fst,Quiet[CAssign["FOUT",fu,AssignOptimize->False]]]
	   , (* else no optimization is done, inlist is not a list but can be 
	     an expression of a certain Length > 1 *)
	   fu=inlist;
	   (*
	   If[MatchQ[comp,1],
	      WriteString[fst,"dcmplx FOUT;\n"],
	      WriteString[fst,"double FOUT;\n"]
	      ];
	    *)
	   cassign["FOUT",fu/.Power[aa_,-1]->1./aa];
	   ];
	WriteString[fst, Cstring6];
	WriteString[fst,"(FOUT);\n}\n"];
	Close[fst]; 
	];
