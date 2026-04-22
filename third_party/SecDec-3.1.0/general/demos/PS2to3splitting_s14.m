(* input for s14 integrated over PS2to3 *) 

(* give integration variables z_1,..,z_n as a list *)

nmax=4;

intvars=Table[z[i],{i,nmax}];

(* give list of factors f[z[i]] and powers a[i] as  { {f[z], a[1]},.., {f[z], a[nmax]} }*)
(* optional: add flag to exclude some of the functions from the decomposition as third entry 
    in the list like {f[z],a[j],n} where "n" means  exclude from the decomposition;
     NOTE that functions with powers > -1  will not be decomposed anyway;
  *)


(* note that constants can be left symbolic in the decomposition *)

factorlist={ {z[1],-2*eps},{z[2],-1-2*eps},{1- z[1],-eps},{1-z[2],-eps},
{z[3],1-2*eps},{1-z[3],-2*eps}, {z[4],-1/2-eps},{1-z[4],-1/2-eps}, 
{1- z[1]+z[1]*z[2],-eps},{1-beta*z[3]*(1- z[1]+z[1]*z[2]),-1+2*eps},
{(Sqrt[(1-z[1])*(1-z[2])]-Sqrt[1- z[1]+z[1]*z[2]])^2+4*z[4]*Sqrt[(1-z[1])*(1-z[2])*(1- z[1]+z[1]*z[2])],2*eps,n} };

(* list of labels of variables which can lead to a singularity at zero AND one
    (integration will be split at 1/2 and remapped to unit interval)    *)
    
splitlist={};   

     
(* Dimension can be changed, but symbol for epsilon must remain the same *)
Dim=4-2*eps;


 
