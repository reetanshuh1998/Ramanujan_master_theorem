(*
#****m* SecDec/general/src/deco/sqrtsimp.m
# NAME
#  sqrtsimp.m
# USAGE
#  <<sqrtsimp.m
# PURPOSE
#  contains routines used to simplify expressions containing square roots.
#****
*)


powreps={Power[Plus[Sqrt[A_],B__],C_]->mypowimp[Plus[Sqrt[A],B],C],
Power[Plus[D_ Sqrt[A_],B__],C_]->mypowimp[Plus[D Sqrt[A],B],C]};

mypow[A_,B_]:=Expand[A^B];

mysqrt[msqa_,msx_]:=Module[{at,sqv},
at={Simplify[msqa],1};
sqv=at//.{{aa_ bb_^2,cc_}->{aa,bb cc},{bb_^2,cc_}->{1,bb cc}};
assums=Flatten[(List[##>0,##<1])&/@msx];
If[MatchQ[sqv[[2]],1]==False,
 testvals=(#->1/2)&/@msx;
 testpos=sqv[[2]]/.testvals;
 If[NumberQ[testpos],
  If[testpos>0,sqv[[2]]Simplify[Sqrt[sqv[[1]]],assums],-sqv[[2]]Simplify[Sqrt[sqv[[1]]],assums]],
  Simplify[Sqrt[sqv[[2]]^2 sqv[[1]]],assums]],
 Simplify[Sqrt[at[[1]]],assums]]];

mysimp[fsim_,xsim_]:=Module[{ftemp},
ftemp=fsim;
If[MatchQ[(fsim/.Sqrt[A_]->1),fsim]==False,
ftemp=ftemp//.powreps;
ftemp=ftemp/.mypowimp->mypow;
ftemp=ftemp/.Sqrt[A_]->mysqrtimp[A,xsim];
ftemp=ftemp//.mysqrtimp[A1_,xsim]mysqrtimp[A2_,xsim]->mysqrtimp[A1 A2,xsim];
ftemp=ftemp//.mysqrtimp->mysqrt;
];
Return[ftemp]];
