#ifndef _chead_h
#define _chead_h
#include <math.h>
#include <complex>
#include <fstream>
#include <time.h>
#include <iostream>
#include <cstdlib>
#include <iomanip>
#include "../../../../../../SecDec-3.1.0/src/Cuba-4.1/cuba.h"
#include <string.h>
using namespace std;
double P1l0h0f1(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
double P1l0h0f2(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
double P1l0h0f3(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
double P1l0h0f4(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
double P1l0h0f5(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
double P1l0h0f6(const double x[],double esx[],double em[],double lambda, double lrs[], double bi);
     int Integrand (const int *ndim, const double x[], const int *ncomp, double f[], void *userdata);
#endif
