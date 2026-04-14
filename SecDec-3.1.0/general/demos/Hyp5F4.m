(* input for general parametric function, default is to assume singularities are at z=0 *) 

(* give integration variables z_1,..,z_n as a list *)

nmax=4;

intvars=Table[z[i],{i,nmax}];

a1= eps;
a2=-eps;
a3=-3eps;
a4=-5eps;
a5=-7eps;
b1=2*eps;
b2=4*eps;
b3=6*eps;
b4=8*eps;


factorlist={ {Gamma[a2], -1}, {Gamma[a3], -1}, {Gamma[a4], -1},{Gamma[a5], -1}, 
 {Gamma[b1], 1}, {Gamma[b2], 1}, {Gamma[b3], 1}, {Gamma[b4], 1}, 
 {Gamma[-a2 + b1], -1}, {Gamma[-a3 + b2], -1}, {Gamma[-a4 + b3], -1}, {Gamma[-a5 + b4], -1},
 {1 - z[1], -1 - a5 + b4},  {z[1], -1 + a5}, 
 {1 - z[2], -1 - a4 + b3}, {z[2], -1 + a4}, 
 {1 - z[3], -1 - a3 + b2}, {z[3], -1 + a3}, 
 {1 - z[4], -1 - a2 + b1}, {z[4], -1 + a2}, 
 {1 - beta*z[1]*z[2]*z[3]*z[4], -a1}};


splitlist={1,2,3,4};   


Dim=4-2*eps;



