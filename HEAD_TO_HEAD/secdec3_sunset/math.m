(* SecDec 3 math.m for 2-loop massive sunset *)
momlist = {k1, k2};
proplist = {k1^2 - m1, k2^2 - m2, (k1+k2+p)^2 - m3};
powerlist = {1, 1, 1};
ExternalMomenta = {p};

KinematicInvariants = {psq, m1, m2, m3};

ScalarProductRules = {
  SP[p, p] -> psq
};
