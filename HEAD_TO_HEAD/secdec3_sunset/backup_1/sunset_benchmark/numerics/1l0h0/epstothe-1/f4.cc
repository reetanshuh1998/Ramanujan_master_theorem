#include "intfile.hh"

double P1l0h0f4(const double x[], double esx[], double em[], double lambda, double lrs[], double bi) {
double x0=x[0];
double x1=x[1];
double FOUT;
double y[2];
y[1]=em[0];
FOUT=pow(1.+x0,-3)*(y[1]+x0*y[1]);
return (FOUT);
}
