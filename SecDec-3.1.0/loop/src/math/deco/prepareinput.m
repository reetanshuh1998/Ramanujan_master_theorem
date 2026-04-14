(*
#****m* SecDec/loop/src/deco/prepareinput.m
# NAME
#  prepareinput.m
# USAGE
#  called by subdir/graph/graph.m, run by decomposeloop.pl and decomposeuserdefined.pl
# PURPOSE
#  prepares necessary global variables for use in the decomposition
# NOTE
# Nn, loops, Dim are global, defined in graph.m; rank is determined in calcFU.m
# SEE ALSO
#  decomposition.m, decomposeloop.pl, decomposeuserdefined.pl
#****
*)
(* prepare input for  secdec *)
 
npower=Length[powerlist];
If[npower=!=Nn,
    Print["Warning, number of propagators should be equal to number of propagator powers"]
 ];

sumpow=Sum[powerlist[[ii]],{ii,Nn}];
If[cutconstruct==True,
	zeropositions=Position[powerlist, 0] ;
	powerlist=Delete[powerlist,zeropositions];
	Nn=Nn-Length[zeropositions];
];
gamdeno=Product[Gamma[powerlist[[ii]]], {ii,Nn}];
(* define exponents of F and U and prefactor *)

expoU=Simplify[sumpow-rank-(loops+1)*Dim/2];
expoF=Simplify[loops*Dim/2-sumpow];

(* compute generic prefactor *)
If[invprops && cutconstruct != True,
  argGa=Simplify[-loops*Dim/2+sumpow+Plus@@nonpospowerlist],
  argGa=-expoF];
If[MatchQ[argGa/.{eps->0}, _Integer?NonPositive], prefacpole=1, prefacpole=0];

prefac=prefac*(-1)^Simplify[(sumpow)/.eps->0]*Gamma[argGa]/gamdeno;

(* If FUN.m exists and Nu[z] is a known function, factor out the common 
 denominator of the numerator if possible *)

If[MatchQ[Head[Nu[z]],Nu]==False,
   prefac=prefac/(Denominator[Nu[z]]/.{_z->1});
   newNom=Nu[z]*(Denominator[Nu[z]]/.{_z->1});
   (*Clear definition of Nu in FUN.m to be able to assign new numerator to Nu[z]*)
   Clear[Nu];
   Nu[z]=newNom;
   ];

(* Check if a factor of eps^n can be factorized from the numerator *)
If[MatchQ[Head[Nu[z]],Nu]==False,
   (*epsFact=Times@@Select[FactorTermsList[Nu[z],eps], Or[MatchQ[#,eps],MatchQ[#,eps^n_]]&];*)
   epsFact=eps^(-Exponent[Nu[z]/.{eps -> eps^-1},eps]);
   prefac=prefac*epsFact;
   newNom=Nu[z]/epsFact;
   (*Clear definition of Nu in FUN.m to be able to assign new numerator to Nu[z]*)
   Clear[Nu];
   Nu[z]=newNom;
   ];
