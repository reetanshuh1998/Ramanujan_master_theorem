expou=-1+2*eps;
expof=-1-eps;


functionlist = {
  {1, {0, 0}, 
   {{1 + z[1] + z[2], expou, A},
    {-(ssp[1]*z[1]) + ms[1]*(1 + z[1] + z[2]), expof, A}}, 1},
  {2, {-1-eps, 0}, 
   {{1 + z[1] + z[2], expou, A},
    {-(ssp[1]*z[2]) + ms[1]*(1 + z[1] + z[2]), expof, A}}, 1},
  {3, {-1-eps, 0}, 
   {{1 + z[1] + z[2], expou, A},
    {-ssp[1] + ms[1]*(1 + z[1] + z[2]), expof, A}}, 1}
};

ExternalMomenta={p1,p2,p3};
externallegs=3;
prefactor=-Gamma[1+eps];
KinematicInvariants = {ssp[1]};
Masses={ms[1]};

