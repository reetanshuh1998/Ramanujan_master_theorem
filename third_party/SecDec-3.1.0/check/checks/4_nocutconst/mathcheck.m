momlist={k1,k2};
proplist={k1^2,(k1+p1)^2-msq,(k1-k2)^2, (k2+p1)^2-msq,k2^2};
ExternalMomenta={p1};
numerator={1}; 
externallegs=2;
prefactor=1;
KinematicInvariants = {psq};
Masses={msq};
ScalarProductRules = {
  SP[p1,p1]->psq}
Dim=4-2*eps;
