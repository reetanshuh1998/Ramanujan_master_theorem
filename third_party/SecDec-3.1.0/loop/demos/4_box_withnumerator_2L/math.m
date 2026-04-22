momlist={k1,k2};

proplist={k1^2,(k1+p2)^2,(k1-p1)^2,(k1-k2)^2,(k2+p2)^2,(k2-p1)^2,(k2+p2+p3)^2,(k1+p3)^2};
numerator={1};
powerlist={1,1,1,1,1,1,1,-1};

ExternalMomenta={p1,p2,p3,p4};
externallegs=4;
prefactor=Gamma[1+eps]^2;
KinematicInvariants = {s,t};
Masses={};

ScalarProductRules = {
  SP[p1,p1]->0,
  SP[p2,p2]->0,
  SP[p3,p3]->0,
  SP[p4,p4]->0,
  SP[p1,p2]->s/2,
  SP[p2,p3]->t/2,
  SP[p1,p3]->-s/2-t/2
};

Dim=4-2*eps;

