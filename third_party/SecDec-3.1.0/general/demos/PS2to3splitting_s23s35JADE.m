(* input for s^2/(s23 s35) integrated over PS2to3 with jet
measurement function 'JADE' *) 

(* give integration variables z_1,..,z_n as a list *)

nmax=4;

intvars=Table[z[i],{i,nmax}];

factorlist={ {z[1],-1-eps},{z[2],-1-eps},{1- z[1],-eps},{1-z[2],-eps},{z[3],-1-2*eps},{1-z[3],1-2*eps}, {z[4],-1/2-eps},{1-z[4],-1/2-eps}, 
{1-z[3]+z[3]*z[2],-1+2*eps},{JADE[z[1],z[2],z[3]],1}};

(* list of labels of variables which can lead to a singularity at zero AND one
    (integration will be split at 1/2 and remapped to unit interval)    *)
    
splitlist={3};   

     
(* Dim can be changed, but symbol for epsilon must be the same *)
Dim=4-2*eps;


