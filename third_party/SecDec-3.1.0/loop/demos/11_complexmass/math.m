(*example: 1L  pentagon with complex masses *)

momlist={k};
numerator={1};

proplist={{m1s,{1,2}},{m2s,{2,3}},{m3s,{3,4}},{0,{4,5}},{0,{5,1}}};



powerlist=Table[1,{i,Length[proplist]}];

prefactor=Gamma[1+eps]*Gamma[1-eps]^2/Gamma[1-2*eps];

ExternalMomenta = {p1,p2,p3,p4,p5};
externallegs=5;
KinematicInvariants = {s12,s23,s34,s45,s51};
Masses={m1s,m2s,m3s};

ScalarProductRules = {
  SP[p1,p1]->0,
  SP[p2,p2]->0,
  SP[p3,p3]->0,
  SP[p4,p4]->0,
  SP[p5,p5]->0,
  SP[p1,p2]->s12/2,
  SP[p1,p3]->(s45-s12-s23)/2,
  SP[p1,p4]->(s23-s51-s45)/2,
  SP[p1,p5]->s51/2,
  SP[p2,p3]->s23/2,
  SP[p2,p4]->(-s23-s34+s51)/2,
  SP[p2,p5]->(s34-s12-s51)/2,
  SP[p3,p4]->s34/2,
  SP[p3,p5]->(s12-s34-s45)/2,
  SP[p4,p5]->s45/2
};
