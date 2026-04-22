momlist={k1,k2};
proplist={(k1+p1)^2,(k1-k2)^2, k2^2,(k2+p1)^2};
powerlist={1,1,1,-1};
ExternalMomenta={p1};
externallegs=2;
prefactor=-Gamma[1+eps];
KinematicInvariants = {psq};
Masses={};
ScalarProductRules = {
  SP[p1,p1]->psq};
Dim=4-2*eps;
