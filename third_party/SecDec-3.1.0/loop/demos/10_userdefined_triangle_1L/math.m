prefactor=1;

KinematicInvariants = {s};
Masses={msq};

expou=-1+2*eps;
expof=-1-eps;

U[z_] := z[1] + z[2] + z[3];
F[z_] := z[3]*(-s*z[2] + msq*(z[1] + z[2] + z[3]));

functionlist = {
  {1, {-1-eps, 0}, 
   {{(U[z]/.z[1]->1)/.z[3]->z[1], expou, A}, 
    {(-s*z[2] + msq*(1 + z[1] + z[2])), expof, A}}, 1}, 
  {2, {0,-1-eps}, 
   {{(U[z]/.z[2]->1)/.z[3]->z[2], expou, A},  
    {-s + msq*(1 + z[1] + z[2]), expof, A}}, 1}, 
  {3, {0, 0}, 
   {{U[z]/.z[3]->1, expou, A}, 
    {F[z]/.z[3]->1, expof, A}}, 1}
};
