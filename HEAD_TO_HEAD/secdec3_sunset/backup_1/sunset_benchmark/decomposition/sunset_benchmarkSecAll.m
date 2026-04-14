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
cutconstruct=False;
(* Populated by makeFU.pl and decomposeloop.pl *)
(*
   Contains variables:
   $cutconstruct
   $dirbase
   $graph
   $externallegs=1
   $loops=2
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
   npmax=3;
   , 
   npmax=3;
   ];
lengthprimseclist=npmax; (* MK: if powerlist is not defined, npmax will be set by decomposeloop.pl *)


(* path to main secdec directory tree *)
path="/home/reet/Downloads/Ramanujan/SecDec-3.1.0/";
normaliz="/home/reet/Downloads/Ramanujan/SecDec-3.1.0/src/normaliz";


graphstring="sunset_benchmark";
currentdir="/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/decomposition/";


externallegs=1(*{$externallegs}*);

rescaleflag=0(*{$rescaleflag}*);
ibpflag=0(*{$ibpflag}*);
nbkernels=0(*{$nbofkernels}*);

strategy="X"

If[userdefined==0, 
   loops=2(*{$loops}*);
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
      (*xl=loops=2;*)
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

indflag=0;

Get[ToString["/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/FU/FUN.m"]];

prefac=1/prefactor;
Get[ToString["/home/reet/Downloads/Ramanujan/SecDec-3.1.0/loop/src/math/deco/prepareinput.m"]];

If[MatchQ[F[z],0],
Print["Warning, F[z]=0, please verify your input"];
,
signcheck=Join[{z[a_]->1/2},Table[masslist[[i]]->1,{i,Length[masslist]}],Table[lorentzlist[[i]]->-1,{i,Length[lorentzlist]}]];
If[(F[z]/.signcheck)<0,
Print["Warning: F[z] is not positive semi-definite, please verify your input"];
If[Length[lorentzlist]+Length[masslist]<=1,
Print["Info: Your integrand seems to have a maximum of one"];
Print["kinematic invariant and F[z] is not positive semi-definite."]; 
Print["This produces unnecessary logarithms of a negative number."]; 
Print["If not done so already, please factor the invariant out."]]];

(* do the iterated decomposition *)

qlist={};
indlist={1,2,3};
Get[ToString["/home/reet/Downloads/Ramanujan/SecDec-3.1.0/loop/src/math/deco/decomposition.m"]];

];
Exit[Length[DeleteCases[Map[MessageList, Range[$Line - 1]],{}|HoldPattern[MessageList[_]]]]];
