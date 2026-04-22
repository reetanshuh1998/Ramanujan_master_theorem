(*
  #****t* SecDec/general/src/subexp/subandexpand.m
  #  NAME
  #    subandexpand.m
  #
  #  USAGE
  #  is used as a template for secdec/subdir/graph/subandexpand*l*h*.m
  #  These subandexpand*l*h* take the sector decomposed integrand, and runs the
  #  subtraction and epsilon expansion, then writes the f*.f files to be
  #  numerically integrated. 
  # 
  #  USES 
  #
  #  ${graph}*P*l*h*.out, formindlist.m, symbsub.m, ExpOpt.m, formfortran.m
  #
  #  USED BY 
  #    
  #  subexp.pl
  #
  #  PURPOSE
  #  to take the sector decomposition output, and produce f*.f files for the 
  #  numerical integration
  #    
  #  INPUTS
  #  
  #  inserted by subexp.pl:
  #  path: directory of secdec
  #  input decomposition: reads a list of files ${graph}P*l*h*.out containing
  #  the output of the decomposition
  #  n: number of integration variables
  #  logi: the number of logarithmic poles in this pole structure
  #  lini: the number of linear poles in this pole structure
  #  higheri: the number of higher order poles in this pole structure
  #  partsflag: whether IBP is to be used
  #  precisionrequired: order of epsilon required for result
  #  diagramname: name of the diagram
  #  subdir: subdirectory where output is placed
  #  srcdir: directory of source code
  #
  #  variables:
  #  dieflag: is set to 1 by formindlist.m if there are no poles with this given structure
  #  time: time taken for this part of the calculation
  #    
  #  RESULT
  #  
  #  f*.f functions upto the required order are created in the appropriate directory
  #  
  #  SEE ALSO
  #  subexp.pl, formindlist.m, symbsub.m, formfortran.m
  #   
  #****
*)  
(* in Mathematica version >=8, decimal * 0 =0.(as decimal), whereas decimal * 0 = 0 (as
integer) for versions <8  *)

If[$VersionNumber>=8, 
   Unprotect[MatchQ];
   MatchQ[0,0.]:=MatchQ[N[0],N[0.]];                                          
   Protect[MatchQ];
   ];

time=AbsoluteTiming[
Dim=;
outp=;
path=;
inputdecomposition
n=;
feynpars=;
logi=;
lini=;
higheri=;
partsflag=;
language=;
contourdef=;
xlambda=;
oscillatory=;
endpointflag=;

precisionrequired=;
diagramname=;
subdir=;
srcdir=;

commonparamstring=;
dummys={};
dummyorder={};
dummyEpsOrd=Transpose[{dummys,dummyorder}];
dummynamesFull=Flatten[Table[If[i>0,ToString[#[[1]]]<>"Deps"<>ToString[i],ToString[#[[1]]]],{i,0,#[[2]]}]& /@dummyEpsOrd];
dummystring="      double precision "<>ToString[#]<>"\n"&/@dummynamesFull;
dummystring=StringJoin@@dummystring;
polestring=StringJoin[ToString[logi],"l",ToString[lini],"h",ToString[higheri]];

$HistoryLength=0;
Get[StringJoin[outp,"/prefactor.m"]];
Get[StringJoin[path,srcdir,"formindlist.m"]]; (*forms integrandfunctionlist, together with fstore,ustore,nstore and degen*)


If[dieflag==0
   ,
   Get[StringJoin[path,srcdir,"symbsub.m"]]; (*performs the symbolic subtraction*)
   If[$VersionNumber>=7,Get[StringJoin[path,srcdir,"ExpOpt.m"]],Get[StringJoin[path,srcdir,"ExpOpt.m"]]]; (*routines necessary for optimisation + fortranisation*)
   If[contourdef,
      If[$VersionNumber>=7,Get[StringJoin[path,srcdir,"formContourC.m"]],Get[StringJoin[path,srcdir,"formContourC.m"]]]
      , (* else no contour deformation *)
      If[MatchQ[language,Cpp],
	 If[$VersionNumber>=7,Get[StringJoin[path,srcdir,"formC.m"]],Get[StringJoin[path,srcdir,"formC.m"]]]
	 ,
	 If[$VersionNumber>=7,Get[StringJoin[path,srcdir,"formfortran.m"]],Get[StringJoin[path,srcdir,"formfortran.m"]]];
	 ] (* end if language=C *)
      ] (* end if contourdef *)
   ,(*else if dieflag==1*)
   Print["no poles of this type"]
   ];
	    ][[1]];

If[Or[MatchQ[language,Cpp],contourdef],langstring="C++",langstring="fortran"];
Print["Total time taken to produce "<>langstring<>" files: ",time," secs"];
