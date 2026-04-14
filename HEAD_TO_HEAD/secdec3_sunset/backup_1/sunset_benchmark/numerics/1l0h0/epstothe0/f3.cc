#include "intfile.hh"

double P1l0h0f3(const double x[], double esx[], double em[], double lambda, double lrs[], double bi) {
double x0=x[0];
double x1=x[1];
double FOUT;
double y[11];
y[1]=em[2];
y[2]=1./x1;
y[3]=em[0];
y[4]=em[1];
y[5]=x0*x0;
y[6]=x1*x1;
y[7]=x0*y[1];
y[8]=1.+x0;
y[9]=pow(y[8],-3);
y[10]=y[1]+y[7];
FOUT=pow(1.+x0+x0*x1,-3)*y[2]*(-(psq*x0*x1)+y[1]+x0*x1*y[1]+x1*y[3]+x0*x1*y[\
3]+x0*x1*y[4]+x1*y[4]*y[5]+x0*y[3]*y[6]+y[4]*y[5]*y[6]+y[7])+3.*log(y[8])*y\
[9]*y[10]-2.*log(y[10])*y[9]*y[10]-y[2]*y[9]*y[10];
return (FOUT);
}
