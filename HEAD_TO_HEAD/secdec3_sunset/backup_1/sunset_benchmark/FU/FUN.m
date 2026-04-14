U[z_]:=z[2]*z[3] + z[1]*(z[2] + z[3])

F[z_]:=ms[2]*z[2]^2*z[3] + ms[3]*z[2]*z[3]^2 + ms[1]*z[1]^2*(z[2] + z[3]) + 
 z[1]*(ms[2]*z[2]^2 + (-psq + ms[1] + ms[2] + ms[3])*z[2]*z[3] + ms[3]*z[3]^2)

Nu[z_]:=1

rank=0

(* renaming of kinematic invariants to standard names: ms[i] for mass squared, ssp[i] for Lorentz invariants: *)
replacements={ m1 -> ms[1], m2 -> ms[2], m3 -> ms[3] }; 
