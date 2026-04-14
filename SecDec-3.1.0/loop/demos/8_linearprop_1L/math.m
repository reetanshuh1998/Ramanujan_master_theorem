(* example is a 1-loop integral with one linear propagator *)	 
momlist={k};
(* Here +I*delta is assumed for every propagator*)
proplist={(k)^2,(-k+p)^2,2*k*v};
powerlist=Table[1,{i,1,Length[proplist]}];  
prefactor=1;
ExternalMomenta = {p,v};
externallegs=2;
KinematicInvariants = {psq,vsq};
Masses={};
ScalarProductRules = {
  SP[p,p]->psq,
  SP[v,v]->vsq,
  SP[p,v]->0
};
