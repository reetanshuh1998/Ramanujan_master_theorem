(*
  #****
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
  #  ${graph}sec*P*l*h*.out, formindlist.m, symbsub.m, ExpOpt.m, formC.m, formContourC.m, formPC.m, 
  #  formContourPC.m
  #
  #  USED BY 
  #    
  #  subexploop.pl, subexpgeneral.pl
  #
  #  PURPOSE
  #  to take the sector decomposition output, and produce f*.f (or with contour 
  #  deformation f*.cc and g*.cc) files for the numerical integration, for 
  #  Mathematica versions 7 and higher parallelization is used
  #    
  #  INPUTS
  #  
  #  inserted by subexploop.pl, resp. subexpgeneral.pl:
  #  path: directory of secdec
  #  input decomposition: reads a list of files ${graph}sec*P*l*h*.out containing
  #  the output of the decomposition
  #  n: number of propagators
  #  logi: the number of logarithmic poles in this pole structure
  #  lini: the number of linear poles in this pole structure
  #  higheri: the number of higher order poles in this pole structure
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
  #  subexploop.pl, subexpgeneral.pl, formindlist.m, symbsub.m, formfortran.m
  #   
  #****
*)  
(* in Mathematica version >=8, decimal * 0 =0.(as decimal), whereas decimal * 0 = 0 (as integer) for versions <8  *)

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
mindegree=;
maxdegree=;
(* language=; *)
rescaleflag=;
extlegs=;
contourdef=;
xlambda=;
oscillatory=;
endpointflag=;
nbkernels=;
mathematicaflag=0;
complexmasses=0;

precisionrequired=;
diagramname=;
(* subdir=; *)
srcdir=;
prestring=;

individual sector

polestring=StringJoin[ToString[logi],"l",ToString[lini],"h",ToString[higheri]];

$HistoryLength=0;
Get[StringJoin[srcdir,"formindlist.m"]]; (*forms integrandfunctionlist, together with fstore,ustore,nstore and degen*)

(* note that formindlist still needs the polestring above, so replacement of togetherflag and polestring needs to be
   done afterwards *)

togetherflag=0;

If[$VersionNumber<=6,nbkernels=0];
If[nbkernels>0,LaunchKernels[nbkernels]];


If[
   dieflag==0
   ,
   (*performs the symbolic subtraction:*) 
   Get[StringJoin[srcdir,"symbsub.m"]]; 
   (*routines necessary for optimisation + fortranisation:*)
   Get[StringJoin[srcdir,"ExpOptP.m"]]
   If[And[contourdef,MatchQ[prestring,"sec"],(expf/.eps->0.1)<0],Print["Deformation of integration contour not strictly necessary"]];
   Get[StringJoin[srcdir,"formContourPC.m"]]
   ,
   Print["no poles of this type"]
   ];
	    ][[1]];
langstring="C++";
Print["Total time taken to produce "<>langstring<>" files: ",time," secs"];

