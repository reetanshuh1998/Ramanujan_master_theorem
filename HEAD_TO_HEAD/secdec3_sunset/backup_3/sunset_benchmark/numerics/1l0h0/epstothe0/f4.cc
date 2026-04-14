#include "intfile.hh"

double P1l0h0f4(const double x[], double esx[], double em[], double lambda, double lrs[], double bi) {
double x0=x[0];
double x1=x[1];
double FOUT;
double y[11];
y[1]=esx[1];
y[2]=1./x1;
y[3]=x0*y[1];
y[4]=esx[2];
y[5]=x0*x0;
y[6]=esx[3];
y[7]=x1*x1;
y[8]=1.+x0;
y[9]=pow(y[8],-3);
y[10]=y[1]+y[3];
FOUT=pow(1.+x0+x0*x1,-3)*y[2]*(-(x0*x1*esx[0])+y[1]+x0*x1*y[1]+y[3]+x0*x1*y[\
4]+x1*y[4]*y[5]+x1*y[6]+x0*x1*y[6]+y[4]*y[5]*y[7]+x0*y[6]*y[7])+3.*log(y[8]\
)*y[9]*y[10]-2.*log(y[10])*y[9]*y[10]-y[2]*y[9]*y[10];
return (FOUT);
}
