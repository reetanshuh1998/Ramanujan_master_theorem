momlist={k1};
proplist={{msq,{1,2}},{0,{2,3}},{0,{3,1}}};
ExternalMomenta={p1,p2,p3};
externallegs=3;
prefactor=((4*Pi)^eps*Gamma[1+eps]^2*Gamma[1-eps]^2*Gamma[1+2*eps]^2*Gamma[1+3*eps]*Gamma[1-3*eps]^2/Gamma[1-2*eps])^2;
KinematicInvariants = {psq};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->psq,
  SP[p2,p2]->0,
  SP[p3,p3]->0};

Dim=4-2*eps;
