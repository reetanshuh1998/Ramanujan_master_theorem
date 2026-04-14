(* input for s35 integrated over PS2to3a *) 

(* give integration variables z_1,..,z_n as a list *)

nmax=4;

intvars=Table[z[i],{i,nmax}];

(* give list of factors f[z[i]] and powers a[i] as  { {f[z], a[1]},.., {f[z], a[nmax]} }*)
(* optional: add flag to exclude some of the functions from the decomposition as third entry 
    in the list like {f[z],a[j],n} where "n" means  exclude from the decomposition;
     NOTE that functions with powers > -1  will not be decomposed anyway;
  *)


(* note that constants can be left symbolic in the decomposition *)

factorlist={ {z[1],-1-eps},{z[2],-1-eps},{1- z[1],-eps},{1-z[2],-eps},{z[3],-1-2*eps},{1-z[3],1-2*eps}, {z[4],-1/2-eps},{1-z[4],-1/2-eps}, 
{1-z[3]+z[3]*z[2],-1+2*eps} };

(* list of labels of variables which can lead to a singularity at zero AND one
    (integration will be split at 1/2 and remapped to unit interval)    *)
    
splitlist={3};   

     
(* Dim can be changed, but symbol for epsilon must be the same *)
Dim=4-2*eps;


