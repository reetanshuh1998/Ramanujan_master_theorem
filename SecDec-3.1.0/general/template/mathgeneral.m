(* input for general parametric function, default is to assume singularities are at z[i]=0, 
    for singularities at z[i]=0 and z[i]=1 add variable label i to splitlist  *) 

(* give integration variables z_1,..,z_nmax as a list *)

nmax=   ;
intvars=Table[z[i],{i,nmax}];

splitlist={};   

(* give list of factors f[z[i]] and powers a[i] as  { {f[z], a[1]},.., {f[z], a[nmax]} }*)
(* note that parameters like beta can be left symbolic in the decomposition *)
(* numerical value only has to be specified in param.input or in kinem.input *)
(* optional: add flag to exclude some of the functions from the decomposition as third entry in the list like {f[z],a[j],n} where "n" means  exclude from the decomposition;
     NOTE that functions with powers > -1  will not be decomposed anyway;  *)

factorlist={ { , }, { , }, ... };

(* Dimension can be changed, but symbol for dimension (Dim) and epsilon (eps) must be the same *)

Dim=4-2*eps;


