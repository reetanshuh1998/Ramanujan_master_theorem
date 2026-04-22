momlist={k1};
proplist={{msq,{1,2}},{0,{2,3}},{0,{3,1}}};
ExternalMomenta={p1,p2,p3};
externallegs=3;
prefactor=-Gamma[1+eps];
KinematicInvariants = {psq};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->psq,
  SP[p2,p2]->0,
  SP[p3,p3]->0};

Dim=4-2*eps;
