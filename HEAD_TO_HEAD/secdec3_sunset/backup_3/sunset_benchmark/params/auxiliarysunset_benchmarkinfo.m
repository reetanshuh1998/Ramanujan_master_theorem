AppendTo[$Messages,"stderr"];
(* SecDec 3 math.m for 2-loop massive sunset *)
momlist = {k1, k2};
proplist = {k1^2 - m1, k2^2 - m2, (k1+k2+p)^2 - m3};
powerlist = {1, 1, 1};
ExternalMomenta = {p};

KinematicInvariants = {psq, m1, m2, m3};

ScalarProductRules = {
  SP[p, p] -> psq
};
(* Populated by makeparams.pl *)
(*
   Contains variables:
   $mathparamfile
   $userdefined
*)

userdefined=0;

If[userdefined==0,

   loopmom = False;
   Do[If[FreeQ[numerator, momlist[[i]]] == False, loopmom = True], {i,Length[momlist]}];
   
   cutconstruct = False;
   If[FreeQ[proplist[[1]], List] == False, cutconstruct = True];
   
   (* note that cutconstruct only works for numerator=1 => check if
    proplist contains a sub-list, if yes, assume cutconstruct=1 and issue
    a warning *)
   
   tensorwithcutco = False;
   If[(cutconstruct && loopmom), tensorwithcutco = True;
      Print["Error: for tensor integrals the integrand\n"];
      Print["definition must contain the list of propagators explicitly"];
      ];
   
   loops = Length[momlist];
   props = Length[proplist];
   
   If[!ValueQ[powerlist], powerlist = Table[1, {props}]];
   
   intpowers = powerlist /. {eps -> 0};
   epspowers = Cancel[(powerlist - intpowers)/eps];
   posprops = Count[Map[Positive, intpowers], True];
   (* catch powers which are of the form a*eps *)
   
   epsprops = Map[Positive, Abs[epspowers]];
   pureepsprops = 0;
   Do[If[intpowers[[i]] == 0 && epsprops[[i]] == True, 
	 pureepsprops++], {i, Length[powerlist]}];
   denoprops = posprops + pureepsprops;
   ];
   
If[Head[ExternalMomenta]==List,
   If[NumberQ[externallegs]==False, externallegs=Length[ExternalMomenta]];
   ];
   
If[userdefined==1,
   deffeynpars = False;
   feynparscheck1=Max[Length[#[[2]]]&/@functionlist];
   feynparscheck2=Max[Delete[#,0]&/@DeleteDuplicates@Cases[functionlist,_z,Infinity]];
   If[feynparscheck1==feynparscheck2,
      deffeynpars = True,
      deffeynpars = False;
      Print["Error: length of the list of exponents must\n"];
      Print["match the number of Feynman parameters\n"];
      Print["appearing in your functions.\n"];
      ];
   feynpars=feynparscheck2;
   ];
masslist = {};
lorentzlist = {};
Do[lorentzlist = Append[lorentzlist, KinematicInvariants[[i]]], {i, Length[KinematicInvariants]}];

Do[
  (*If[(StringMatchQ[ToString[KinematicInvariants[[i]]],StartOfString~~
  "m"~~__]==True ||StringMatchQ[ToString[KinematicInvariants[[i]]],
  "m"]==True),*)
   
   masslist = Append[masslist, Masses[[i]]], {i, Length[Masses]}];
  (*Print["masslist=",masslist];*)
  
  infofile = ToString["/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/params/sunset_benchmarkparaminfo.m"];
  OpenWrite[infofile];
  WriteString[infofile, "externallegs=", externallegs,"\n"];
  If[userdefined==0,
     WriteString[infofile, "loops=", loops,"\n"];
     WriteString[infofile, "propagators=", denoprops,"\n"];
     WriteString[infofile, "\n"];
     WriteString[infofile, "cutconstruct=", cutconstruct,"\n"];
     WriteString[infofile, "tensorwithcutco=", tensorwithcutco,"\n"];
     WriteString[infofile, "\n"];
     ];
  If[userdefined==1,
     WriteString[infofile, "deffeynpars=",deffeynpars,"\n"];
     WriteString[infofile, "feynpars=", feynpars,"\n"];
     ]
  WriteString[infofile, "masslist=", masslist,"\n"];
  WriteString[infofile, "lorentzlist=", lorentzlist,"\n"];
  WriteString[infofile, "\n"];
  WriteString[infofile, "prefactor=", prefactor//InputForm,"\n"];
  Close[infofile];
Exit[Length[DeleteCases[Map[MessageList, Range[$Line - 1]],{}|HoldPattern[MessageList[_]]]]];
