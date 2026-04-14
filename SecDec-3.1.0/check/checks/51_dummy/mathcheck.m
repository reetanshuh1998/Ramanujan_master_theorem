nmax=4;

intvars=Table[z[i],{i,nmax}];


factorlist={{z[1]+z[2],-2-2eps},{z[3],-1-4eps},{dum1[z[1],z[2],z[3],z[4]] ,1+eps},
{dum2[z[2],z[4]],2-6eps},{cut[z[3]],1}};
    
splitlist={};   

Dim=4-2*eps;


