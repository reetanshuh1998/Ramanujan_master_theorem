(*
  #****m* SecDec/general/src/subexp/ExpOpt.m
  #  NAME
  #    ExpOpt.m
  #
  #  USAGE
  #  loaded by formfortran.m
  # 
  #  USES 
  #  Format.m (for FortranAssign), Experimental` (for OptimizeExpression)
  #
  #  USED BY 
  #    
  #  formfortran.m
  #
  #  PURPOSE
  #  Takes an optimized expression from formfortran.m, and writes it in fortran syntax to the appropriate subdirectory.
  #    
  #  INPUTS
  #  from formfortran.m:   
  #  inlist: the optimized expression to be turned into fortran syntax
  #  varletter: the letter each intermediate expression in the optimization will be prefixed by
  #  funcname: the name of the function to be written
  #  outfile: where the file is to be written
  #  fortranstring1,2,3: strings with the necessary fortran syntax
  #  xstring: string with the necessary assignments for x (IBP only), in fortran format.
  #  
  #    
  #  RESULT
  #  the f*.f file is written in fortran syntax to the specified subdirectory
  #    
  #  SEE ALSO
  #  formfortran.m, Format.m
  #   
  #****
*)
(* load Sofroniou`s Format.m *)
Quiet[Needs["Experimental`"];Get[StringJoin[path,"src/util/","Format.m"]]];

fortassign[variablename_,variablevalue_]:=
(Write[outfile,FortranAssign[variablename,variablevalue]])

(*---------------START write Fortran files-------------------------------------*)
writeopt[inlist_,varletter_,funcname_,outfile_,helper_]:=
  Module[{li1,li2,count,le,helpstring,fu,repl},
	 OpenWrite[outfile];
	 WriteString[outfile, fortranstring1, funcname, fortranstring2[helper]];
	 If[ListQ[inlist]==True,
	    li2=inlist[[2]];
	    li1=inlist[[1]];
	    le=Length[li1];
	    count=1;
	    repl={};
	    Do[
	       varname=StringJoin[varletter,ToString[count]];
	       varval=(li2[[j,2]]/.repl);
	       fortassign[varname,varval];
	       (*Write[outfile,(FortranAssign[varname,varval])/.varname->StringJoin[varletter,ToString[count]]];*)
	       (*helpstring=StringJoin[varletter,ToString[count],ToString["="]];
		WriteString[outfile,"       "];
		WriteString[outfile,helpstring];
		Write[outfile,FortranForm[li2[[j,2]]]/.repl];*)
	       repl=Append[repl,li1[[j]]->ToExpression[StringJoin[varletter,ToString[count]]]];
	       count++
	       ,{j,le}];
	    fu=li2[[le+1]]/.repl;
	    Write[outfile,FortranAssign[funcname,fu, OptimizationSymbol -> z]];
	    ,(* else no optimization is done, inlist is not a list but can be 
	      an expression of a certain Length > 1 *)
	    fu=inlist;
	    Write[outfile,FortranAssign[funcname,fu,OptimizationSymbol -> z]];
	    ];
	 WriteString[outfile, fortranstring3];
	 Close[outfile];
	 ];

(*---------------START write C++ files-------------------------------------*)
(* Block needed by formContourC.m to write C++ files *)
writeoptC[inlist_,varletter_,funcname_,outfile_,statval_:0]:=
  Block[{aa,append,comp,Cst1,Cst5,costring,li1,li2,count,le,helpstring,fu,repl,wcount,vectorreplace,vrexp,fst,varname,varval,wwrite},
	cassign[cassargs__]:=(Write[fst,Quiet[CAssign[cassargs,AssignOptimize->False]]]);
	FORMATREPS=(#<>"("~~ShortestMatch[ar__]~~".)"->#<>"["~~ar~~"]")&/@{varletter,"es","esx","em","xvals","lrs"};
	FORMATREPS=Join[FORMATREPS,{"log"->"myLog"}];
	If[MatchQ[statval,0],append=0;comp=1,comp=0;If[MatchQ[statval,1],append=0,append=1]];
	If[MatchQ[comp,1],
	   costring="dcmplx";
	   Cst1=Cstring1;
	   Cst5=Cstring5[costring]<>Cstring7;
	   ,
	   costring="double";
	   Cst1=Cstring3;
	   Cst5=Cstring5[costring]
	   ];
	Cst2=funcname<>Cstring2<>Cstring4;
	If[
	   MatchQ[append,0]
	   ,
	   fst=OpenWrite[outfile];WriteString[fst,Cst1]; 
	   ,
	   fst=OpenAppend[outfile];WriteString[fst,costring<>" "]
	   ];
	WriteString[fst,Cst2];
	wwrite={};
	If[Quiet[ArrayQ[inlist[[1]]]==True],
	   li2=inlist[[2]];
	   li1=inlist[[1]];
	   le=Length[li1];
	   count=1;
	   repl={};
	   Do[
	      varname[count]=StringJoin[varletter,"[",ToString[count],"]"];
	      varval[count]=(li2[[j,2]]/.repl/.{Power[aa_,-1]->1./aa});
	      wwrite={wwrite,imcassign[varname[count],varval[count]]};
	      repl=Append[repl,li1[[j]]->ToExpression[varletter][count]];
	      (*WriteString[outfile,"double ", varletter];Write[outfile,count];*)
	      count++
	      ,{j,le}
	      ];
	   wcount=count-1;
	   WriteString[fst,Cstring4a[count,costring],Cst5];
	   wwrite=Flatten[wwrite];
	   wwrite=wwrite/.vectorreplace->vrexp;
	   #/.{imcassign->cassign}&/@wwrite;
	   fu=li2[[le+1]]/.repl;
	   Write[fst,Quiet[CAssign["FOUT",fu,AssignOptimize->False]]]
	   , (* else no optimization is done, inlist is not a list but can be 
	     an expression of a certain Length > 1 *)
	   fu=inlist;
	   If[MatchQ[comp,1],
	      WriteString[fst,"dcmplx FOUT;\n"],
	      WriteString[fst,"double FOUT;\n"]
	      ];
	   cassign["FOUT",fu/.Power[aa_,-1]->1./aa];
	   ];
	WriteString[fst, Cstring6];
	WriteString[fst,"(FOUT);\n}\n"];
	Close[fst]; 
	];
