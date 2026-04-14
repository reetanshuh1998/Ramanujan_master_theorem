#include "intfile.hh"
double f[1];
double esx[0];
double em[3];
double maxinv;
double lambda[6];
double lrs[6][2];

double bigger (double a, double b) {
 if (abs(a) >= abs(b)) return a; 
 else return b;
}
double myatof(char* str){
  strtok(str,"/");
  char* pch = strtok(NULL,"/");
  if (pch==NULL){
    return atof(str);
  }else{
    return atof(str)/atof(pch);
  }
}

int main (int argc, char **argv)
{
  if (argc == 5) {
    maxinv = 1.;
    for (int i1=0; i1<0; i1++) { esx[i1] = myatof(argv[i1+2]); }
    for (int i2=0; i2<3; i2++) { em[i2] = myatof(argv[i2+0+2]); }
  } else {
     cout << "command line input of kinematics wrong, argc="<< argc << endl;
     cout << "expected " << 5 << " arguments" << endl;
     return 0; 
  }
 //Integrator parameters START
 time_t start, end;
 double time_used[2];
 const int ndim = 2;
 const int ncomp=1;
 int NREGIONS, NEVAL, FAIL;
 const int MAXEVAL = 500000;
 double integral[ncomp], error[ncomp], prob[ncomp];
 double PROB[2];
 int run=1;
 int method = 3;
 const double EPSREL=1.e-2;
 const double EPSABS=1.e-6;
 const int FLAGS=2;
 const int SEED=0;
 const int MINEVAL=0;
 const char *STATEFILE="";
 const int nvec=1;
 const int KEY1=1500;
 const int KEY2=1;
 const int KEY3=1;
 const int MAXPASS=3;
 const double BORDER=1.e-6;
 const double MAXCHISQ=1.e0;
 const double MINDEVIATION=.15;
 const int NGIVEN=0;
 const int LDXGIVEN=ndim;
 double XGIVEN[1]={0.0};
 const int NEXTRA=0;
 //Integrator parameters END
 const int nrfunc=6;
 ofstream results;
 for (int l=0; l<nrfunc;l++){ lambda[l]=1.0; }
 for (int l1=0;l1<nrfunc;l1++) { for (int l2=0;l2<2;l2++) { lrs[l1][l2]=1.0;}}
//REAL part: 
 start = time(NULL);
 Divonne(ndim, ncomp, Integrand, &run, nvec,
	 EPSREL, EPSABS, FLAGS, SEED,
	 MINEVAL, MAXEVAL, KEY1, KEY2, KEY3, MAXPASS,
	 BORDER, MAXCHISQ, MINDEVIATION,
	 NGIVEN, LDXGIVEN, XGIVEN, NEXTRA, NULL, STATEFILE, NULL,
	 &NREGIONS, &NEVAL, &FAIL, integral, error, prob);
 end = time(NULL);
 time_used[0] = ((double) (end - start));
 PROB[0]=prob[0];
 if ( abs(PROB[0]) >= 1.0 ) PROB[0]=1.0;
 cout<< "nregions = " << NREGIONS << "\n";
 cout << "neval = " << NEVAL << endl;
 cout << "fail = " << FAIL << endl;
 cout << "result = " << integral[0] << "+/-" << error[0] << endl;
 cout << "error probability real part= " << PROB[0] << endl;

 stringstream concatname; // string as stream
 concatname << "1x" << argv[1] << "1.out"; // write to string stream
 string file_name = concatname.str(); // get string out of stream

 results.open(file_name.c_str());
 if (results.is_open())
 {
   results << setprecision (10) << "Real part:\nresult = " << integral[0]<< "\nerror = ";
   results << setprecision (10) << error[0] << endl;
   results << setprecision (4) <<"time = " << time_used[0]<< "\nerrorprob = " << PROB[0];
   results << setprecision (4) << "\n\nTime (s) = "<< time_used[0] <<endl; 
   results << setprecision (4) << "MaxErrorprob = "<< PROB[0] <<"\n\n"; 
 }
 results.close();
 return 0;
}

int Integrand (const int *ndim, const double x[], const int *ncomp, double f[], void *userdata)
{
  double f0[6];
  f0[0]=P1l0h0f1(x,esx,em,lambda[0],lrs[0],maxinv);
 f0[1]=P1l0h0f2(x,esx,em,lambda[1],lrs[1],maxinv);
 f0[2]=P1l0h0f3(x,esx,em,lambda[2],lrs[2],maxinv);
 f0[3]=P1l0h0f4(x,esx,em,lambda[3],lrs[3],maxinv);
 f0[4]=P1l0h0f5(x,esx,em,lambda[4],lrs[4],maxinv);
 f0[5]=P1l0h0f6(x,esx,em,lambda[5],lrs[5],maxinv);
  int ii =0;
  f[0]=0.0;
  while (ii<6) { f[0]+=f0[ii];ii++; }
  return 0;
}