momlist={k};
proplist={k^2,(k+p)^2};
numerator={1}; 
ExternalMomenta={p};
externallegs=2;
prefactor=-Gamma[1+eps];
KinematicInvariants = {psq};
Masses={};
ScalarProductRules = {
  SP[p,p]->psq};
Dim=4-2*eps;
