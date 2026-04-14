U[z_]:=z[2]*z[3] + z[1]*(z[2] + z[3])

F[z_]:=ssp[3]*z[2]^2*z[3] + ssp[4]*z[2]*z[3]^2 + ssp[2]*z[1]^2*(z[2] + z[3]) + 
 z[1]*(ssp[3]*z[2]^2 + (-ssp[1] + ssp[2] + ssp[3] + ssp[4])*z[2]*z[3] + 
   ssp[4]*z[3]^2)

Nu[z_]:=1

rank=0

(* renaming of kinematic invariants to standard names: ms[i] for mass squared, ssp[i] for Lorentz invariants: *)
replacements={ psq -> ssp[1], m1 -> ssp[2], m2 -> ssp[3], m3 -> ssp[4] }; 
