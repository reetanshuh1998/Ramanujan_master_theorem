nmax=4;

intvars=Table[z[i],{i,nmax}];

(*dum1[a_,b_,c_,d_]:=a^2 + b^3 +c^4 +d^5 + 4 a b c d +2 -a^2 b^3 c^4 d^5
dum2[a_,b_]:=a^2 + b^2 +beta^2 + 4 a b - Sqrt[a b beta]
*)

factorlist={{z[1]+z[2],-2-2eps},{z[3],-1-4eps},{dum1[z[1],z[2],z[3],z[4]] ,1+eps},
{dum2[z[2],z[4]],2-6eps},{cut[z[3]],1}};
    
splitlist={};   

Dim=4-2*eps;


