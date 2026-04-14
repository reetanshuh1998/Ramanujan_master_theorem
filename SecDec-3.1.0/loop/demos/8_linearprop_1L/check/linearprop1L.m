(*equation A.27 in V. A. Smirnov, Evaluating Feynman integrals, Springer tracts in modern physics, 211 (Springer, Berlin, Heidelberg, 2004)*)

linprop[psq_, vsq_, l1_, l2_, l3_, epsord_] := 
 Series[(-1)^(-l1 - l2 - l3)*Gamma[-l1 - l3/2 - eps + 2]*
   Gamma[-l2 - l3/2 - eps + 2]*Gamma[l1 + l2 + l3/2 + eps - 2]*
   Gamma[l3/2]/(Gamma[-l1 - l2 - l3 - 2 eps + 4]*2*Gamma[l1]*
      Gamma[l2]*
      Gamma[l3]*(-psq - I*10^(-15))^(l1 + l2 + l3/2 + eps - 2)*(vsq - 
         I*10^(-15))^(l3/2)), {eps, 0, epsord}];

Print["p1"];
Print[linprop[2, 3, 1, 1, 1, 2] // N // Chop];
(*-(0. +2.01462 I)+(6.32913 -0.233558 I) eps+(0.733746 +1.64342 I) eps^2+O[eps]^3*)
Print["p2"];
Print[linprop[-2, -3, 1, 1, 1, 2] // N // Chop];
(*-(0. +2.01462 I)-(0. +0.233558 I) eps-(0. +8.29835 I) eps^2+O[eps]^3*)
Print["p3"];
Print[linprop[3, -2, 1, 1, 1, 2] // N // Chop];
(*2.01462-(0.583301 -6.32913 I) eps-(1.57252 +1.8325 I) eps^2+O[eps]^3*)
Print["p4"];
Print[linprop[-3, 2, 1, 1, 1, 2] // N // Chop];
(*-2.01462+0.583301 eps-8.36925 eps^2+O[eps]^3.*)

