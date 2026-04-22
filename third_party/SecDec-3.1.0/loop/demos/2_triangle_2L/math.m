(* example is 2-loop three-point function called P126 *)	 

momlist={k1,k2};
proplist={{msq,{3,4}},{msq,{4,5}},{msq,{3,5}},{0,{1,2}},{0,{4,1}},{0,{2,5}}};


prefactor=-Exp[-2 EulerGamma*eps];

ExternalMomenta = {p1,p2,p3};

KinematicInvariants = {s};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->0,
  SP[p2,p2]->0,
  SP[p3,p3]->s,
  SP[p1,p2]->s/2,
  SP[p2,p3]->-s/2,
  SP[p1,p3]->-s/2};

 
