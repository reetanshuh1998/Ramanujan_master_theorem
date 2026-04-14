
(* example is a 3-loop vertex diagram, for definition and analytical result see e.g.  hep-ph/0607185 *)
(* NOTE: A61 below is with power 1+3eps for propagator 1 *)

momlist={k,r,q};
proplist={k^2,(k+p1+p2)^2,(r-k)^2,(r+p1)^2,(k-q)^2,(q+p1)^2};
numerator={1};

powerlist={1+3*eps,1,1,1,1,1};

Dim=4-2*eps;

prefactor=1/Gamma[1-eps]^3;

ExternalMomenta = {p1,p2,p3};

KinematicInvariants = {s};
Masses={};

ScalarProductRules = {
  SP[p1,p1]->0,
  SP[p2,p2]->0,
  SP[p3,p3]->s,
  SP[p3,p2]->-s/2,
  SP[p1,p3]->-s/2,
  SP[p1,p2]->s/2};


 
