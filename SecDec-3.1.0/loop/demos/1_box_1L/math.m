momlist={k1};
proplist={{msq,{1,2}},{0,{2,3}},{0,{3,4}},{0,{4,1}}};
powerlist={1,1,1,1};  
Dim=4-2*eps;
prefactor=Gamma[1-eps]^2*Gamma[1+eps]/Gamma[1-2*eps];
ExternalMomenta = {p1,p2,p3,p4};
externallegs=4;
KinematicInvariants = {s,t,s1};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->s1,
  SP[p2,p2]->0,
  SP[p3,p3]->0,
  SP[p3,p2]->t/2,
  SP[p1,p3]->-t/2-s/2,
  SP[p1,p2]->s/2-s1/2,
  SP[p4,p4]->0,SP[p1,p4]->t/2-s1/2,SP[p2,p4]->s1/2-t/2-s/2,SP[p3,p4]->s/2};
