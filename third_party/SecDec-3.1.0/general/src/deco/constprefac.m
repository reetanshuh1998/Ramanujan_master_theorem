(*
#****m* SecDec/general/src/deco/constprefac.m
# NAME
#  constprefac.m
# USAGE
# called by subdir/graph.m
# PURPOSE
#  extracts prefactors not dependent on integration variables.
#****
*)


reprule[rr_]:=rr->0;

constcheck[cc_,iv_]:=Module[{ivrep,ct1,ctr},
ivrep=reprule/@iv;
ct1=cc[[1]];
If[MatchQ[(ct1/.ivrep),ct1],ctr={{1,1},cc},ctr={cc,{1,1}}];
Return[ctr]];

halflist[hla_,hlel_]:=hlel[[hla]];

nccfactorlist=constcheck[#,intvars]&/@factorlist;
factorlist=(halflist[1,#]&/@nccfactorlist)//.{A___,{1,1},B___}->{A,B};
constfl=(halflist[2,#]&/@nccfactorlist)//.{A___,{1,1},B___}->{A,B};
myconstpower[A_,B_,C___]:=Power[A,B];
constpre=Times@@(myconstpower@@##&/@constfl);
