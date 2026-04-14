(* example is a massive 2-loop box contributing to Bhabha scattering  *)	 
momlist={k,l};
proplist={{0,{1,2}},{m,{2,5}},{m,{5,3}},{0,{3,4}},{m,{4,6}},{m,{6,1}},{0,{5,6}}};
(*
proplist = {k^2,((k-p1)^2-m),((k+p2)^2-m),(k-l)^2,((l-p1)^2-m),((l+p2)^2-m),(l+p2+p3)^2};
*)
powerlist=Table[1,{i,1,Length[proplist]}];  
prefactor=Gamma[1+eps]^2;
ExternalMomenta = {p1,p2,p3,p4};
(*externallegs=4;*)
KinematicInvariants = {s,t,u};
Masses={m};
ScalarProductRules = {
  SP[p1,p1]->m,
  SP[p2,p2]->m,
  SP[p3,p3]->m,
  SP[p4,p4]->m,
  SP[p3,p2]->t/2-m,
  SP[p1,p3]->u/2-m,
  SP[p1,p2]->s/2-m,
  SP[p1,p4]->t/2-m,
  SP[p2,p4]->u/2-m,
  SP[p3,p4]->s/2-m
};
