(* example is a non-planar massive 2-loop box *)

momlist={k1,k2};

proplist={{msq,{1,5}},{msq,{2,6}},{Msq,{1,2}},{Msq,{3,5}},{msq,{3,6}},{msq,{4,6}},{Msq,{4,5}}};

numerator={1};

powerlist=Table[1,{i,Length[proplist]}];

Dim=4-2*eps;

prefactor=-Gamma[3+2*eps];

ExternalMomenta = {p1,p2,p3,p4};
externallegs=4;
KinematicInvariants = {s,t,u};
Masses={msq,Msq};

ScalarProductRules = {
  SP[p1,p1]->msq,
  SP[p2,p2]->msq,
  SP[p3,p3]->msq,
  SP[p4,p4]->msq,
  SP[p3,p2]->t/2-msq,
  SP[p1,p3]->-t/2-s/2+msq,
  SP[p1,p2]->s/2-msq,
  SP[p1,p4]->t/2-msq,SP[p2,p4]->-t/2-s/2+msq,SP[p3,p4]->s/2-msq};

 
