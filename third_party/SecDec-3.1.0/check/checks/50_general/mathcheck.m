nmax=4;
intvars=Table[z[i],{i,nmax}];
factorlist={ {z[1],-2*eps},{z[2],-1-2*eps},{1- z[1],-eps},{1-z[2],-eps},
{z[3],1-2*eps},{1-z[3],-2*eps}, {z[4],-1/2-eps},{1-z[4],-1/2-eps}, 
{1- z[1]+z[1]*z[2],-eps},{1-beta*z[3]*(1- z[1]+z[1]*z[2]),-1+2*eps},
{(Sqrt[(1-z[1])*(1-z[2])]-Sqrt[1- z[1]+z[1]*z[2]])^2+4*z[4]*Sqrt[(1-z[1])*(1-z[2])*(1- z[1]+z[1]*z[2])],2*eps,n} };
splitlist={};   
Dim=4-2*eps;


 
