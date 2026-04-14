#include "intfile.hh"

double P1l0h0f3(const double x[], double esx[], double em[], double lambda, double lrs[], double bi) {
double x0=x[0];
double x1=x[1];
double FOUT;
double y[27];
y[1]=esx[3];
y[2]=1./x1;
y[3]=esx[1];
y[4]=esx[2];
y[5]=x0*x0;
y[6]=x1*x1;
y[7]=x0*y[1];
y[8]=log(x1);
y[9]=1.+x0;
y[10]=pow(y[9],-3);
y[11]=y[1]+y[7];
y[12]=log(y[9]);
y[13]=log(y[11]);
y[14]=x0*x1;
y[15]=1.+x0+y[14];
y[16]=pow(y[15],-3);
y[17]=esx[0];
y[18]=-(x0*x1*y[17]);
y[19]=x1*y[3];
y[20]=x0*x1*y[3];
y[21]=x0*y[3]*y[6];
y[22]=x0*x1*y[4];
y[23]=x1*y[4]*y[5];
y[24]=y[4]*y[5]*y[6];
y[25]=x0*x1*y[1];
y[26]=y[1]+y[7]+y[18]+y[19]+y[20]+y[21]+y[22]+y[23]+y[24]+y[25];
FOUT=-(y[2]*y[8]*y[10]*y[11])-y[2]*(3.*y[10]*y[11]*y[12]-2.*y[10]*y[11]*y[13\
])+0.5*(9.*pow(y[12],2)*y[10]*y[11]+4.*pow(y[13],2)*y[10]*y[11]-12.*y[10]*y\
[11]*y[12]*y[13])+y[2]*y[8]*y[16]*y[26]+y[2]*(3.*log(y[15])*y[16]*y[26]-2.*\
log(y[26])*y[16]*y[26]);
return (FOUT);
}
