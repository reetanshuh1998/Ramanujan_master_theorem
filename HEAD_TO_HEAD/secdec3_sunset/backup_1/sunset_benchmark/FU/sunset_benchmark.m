AppendTo[$Messages,"stderr"];
(* SecDec 3 math.m for 2-loop massive sunset *)
momlist = {k1, k2};
proplist = {k1^2 - m1, k2^2 - m2, (k1+k2+p)^2 - m3};
powerlist = {1, 1, 1};
ExternalMomenta = {p};
Masses = {m1, m2, m3};
ScalarProductRules = {
  SP[p, p] -> psq,
  SP[k1, k1] -> k1sq,
  SP[k1, p] -> k1p,
  SP[k2, k2] -> k2sq,
  SP[k2, p] -> k2p,
  SP[k1, k2] -> k1k2
};
(* Populated by makeFU.pl and decomposeloop.pl *)
(*
   Contains variables:
   $cutconstruct
   $dirbase
   $graph
   $externallegs
   $loops
   $currentdir
   $normaliz
   $userdefined
   $feynpars
   $rescaleflag
   $ibpflag
   $nbofkernels
   $strategy
*)

(* ********* inserted after end of user input ************* *)

userdefined=0;
 
If[Not[ValueQ[Dim]], Dim=4-2*eps];
If[Not[ValueQ[threshold]], threshold=none];
If[Not[MatchQ[Head[splitlist],List]], splitlist={}];
If[Not[ValueQ[numerator]], numerator = {1}];

If[userdefined==0,
   cutconstruct=False;
   
   (* Filter out non-positive propagator powers *)
   nonpospositions = Position[powerlist, _Integer?NonPositive,1];
   nonnegpositions = Position[powerlist, _Integer?Negative,1];

   If[nonnegpositions!={},invprops=True,invprops=False];
   
   If[invprops && cutconstruct != True,
      nonpospowerlist = Extract[powerlist, nonpospositions];
      nonposproplist = Extract[proplist, nonpospositions];
      powerlist = Delete[powerlist,nonpospositions];
      proplist = Delete[proplist,nonpospositions];
      ]
   ,
   If[MatchQ[functionlist,{}],
      Print["Warning: No user functions for iterated sector decomposition\n"]; 
      Print["defined in templatefile. Verify your input."];
      ];
   ];


(* the following will be adjusted by perl script decomposeloop.pl according to input given in param.input *)


(* primary sectors to be calculated:  selection is via param.input) *)
If[userdefined==0, 
   npmax=Length[powerlist]
   , 
   npmax=Length[functionlist]
   ];
lengthprimseclist=npmax; (* MK: if powerlist is not defined, npmax will be set by decomposeloop.pl *)


(* path to main secdec directory tree *)
path="/home/reet/Downloads/Ramanujan/SecDec-3.1.0/";
normaliz="/home/reet/Downloads/Ramanujan/SecDec-3.1.0/src/normaliz";


graphstring="sunset_benchmark";
currentdir="/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/";


externallegs=1;

rescaleflag=0;
ibpflag=0;
nbkernels=0;

strategy=X;

If[userdefined==0, 
   loops=2;
   (*  calculate F and U  *)
   Get[StringJoin[path,ToString["loop/src/math/util/miscel.m"]]];
   If[cutconstruct==False,
      xl=Length[momlist];
      Nn=Length[proplist];
      If[Not[ListQ[powerlist]],powerlist=Table[1,{ii,Nn}]];
      proplist=Flatten[MapThread[recast,{proplist,powerlist}]];
      Nn=Length[proplist];
      powerlist=Flatten[recast2/@powerlist];
      ,
      (*xl=loops;*)
      Nn=Length[proplist];
      If[Not[ListQ[powerlist]],powerlist=Table[1,{ii,Nn}]];
      ];
   sumpow=Sum[powerlist[[ii]],{ii,Nn}];
   feynpars=Nn-1;
   , (* else userdefined: *)
   feynpars=2;
   Nn=feynpars+1; (* added by GH 28.5.15 as Nn is needed by split routine *)
   ];

Get[StringJoin[path,ToString["loop/src/math/deco/calcFU.m"]]]; (* sj - should we move this line into templatetailFU ? *)
(* Populated by makeFU.pl *)
(*
   Contains variables:
   $FUNfile
   $lmapstring
   $userdefined
*)

userdefined=0;

If[userdefined==0,
   If[cutconstruct,
      fun=calcFUcut[proplist,externallegs,loops,numerator,ScalarProductRules];
      zeropositions=Position[powerlist, 0,1] ;
      If[zeropositions != {},
         fun=fun/. ((z[#] -> 0) & /@ (zeropositions//Flatten))/.MapThread[z[#1] -> z[#2] &, {Complement[Range[Length[powerlist]], (zeropositions//Flatten)], Range[Length[powerlist] - Length[zeropositions]]}];
	 powerlist=Delete[powerlist,zeropositions];
      ],
      If[invprops,
	 fun=calcFU[momlist,Join[proplist,nonposproplist],Join[powerlist,nonpospowerlist],numerator,ScalarProductRules,invprops],
	 fun=calcFU[momlist,proplist,powerlist,numerator,ScalarProductRules,invprops]]];
   U[z_]:=fun[[1]];
   F[z_]:=fun[[2]];
   Nu[z_]:=Product[z[i]^Simplify[powerlist[[i]]-1], {i,Length[powerlist]}]*fun[[3]];
   rank=fun[[4]];
   If[F[z]==0, Print["Warning, function F is zero, please check your on-shell conditions"]]
   ,
   fun=calcUserFunc[functionlist,ScalarProductRules,feynpars];
   facu=Max[Length[FactorList[functionlist[[#,3,1,1]]]]&/@Range[Length[functionlist]]];
   facf=Max[Length[FactorList[functionlist[[#,3,2,1]]]]&/@Range[Length[functionlist]]];
   If[Or[facu>2,facf>2], 
      Print["Warning, parameter(s) z[i] can\n"]; 
      Print["be factored into the list of exponents or\n"];
      Print["invariant(s) into the numerator."];
      ];
   ];

 funfile=ToString["/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/FU/FUN.m"];
 OpenWrite[funfile];
If[userdefined==0,
   WriteString[funfile,"U[z_]:="];
   Write[funfile,U[z]];
   WriteString[funfile,"\n"];
   WriteString[funfile,"F[z_]:="];
   Write[funfile,F[z]];
   WriteString[funfile,"\n"];
   WriteString[funfile,"Nu[z_]:="];
   Write[funfile,Nu[z]];
   WriteString[funfile,"\n"];
   WriteString[funfile,"rank="];
   Write[funfile,rank]
   ,
   WriteString[funfile,"functionlist ="];
   Write[funfile,fun];
   ];
 WriteString[funfile,"\n"];
 WriteString[funfile,"(* renaming of kinematic invariants to standard names: ms[i] for mass squared, "];
 WriteString[funfile,"ssp[i] for Lorentz invariants: *)\n"];
 WriteString[funfile,"replacements={ m1 -> ms[1], m2 -> ms[2], m3 -> ms[3] }; \n"];
 Close[funfile];

(* Scaleless check *)
(* If[userdefined==0,
   calcFU::scaleless="Integral is scaleless (0 in Dimensional Regularization)";
   If[scaleless[U,F,Nn], Message[calcFU::scaleless]];
]; *) (* Disabled as Nn computed incorrectly when using cutconstruct and 0 in powerlist *)


Exit[Length[DeleteCases[Map[MessageList, Range[$Line - 1]],{}|HoldPattern[MessageList[_]]]]];
