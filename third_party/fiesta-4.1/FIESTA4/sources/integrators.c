#include "integrators.h"

#include <string.h>

typedef struct paramsArrayStruct{
   char *name;
   char *fmt;
   void *addr;
}paramsArrayStruct_t;

#define FMT_F "%lf"
#define FMT_E "%lE"
#define FMT_I "%lld"

#ifndef COMPLEX
#define NDIM 1
#else
#define NDIM 2
#endif

static paramsArrayStruct_t *integratorParams[MAX_INTEGRATOR];

int registerIntegrator(integrator_t theIntegrator, char *name, paramsArrayStruct_t *params)
{
   if(g_topIntegrator >= MAX_INTEGRATOR)
      return -1;
   g_integratorNamesArray[g_topIntegrator]=malloc(strlen(name)+1);
   strcpy(g_integratorNamesArray[g_topIntegrator],name);
   integratorParams[g_topIntegrator]=params;
   g_integratorArray[g_topIntegrator++]=theIntegrator;
   return 0;
}/*registerIntegrator*/

/*********** CUBA: ***************************/
/*note, #include<cuba.h> is contained in "integrators.h"*/

static int IntegrandCuba(const int *ndim, const double xx[],
                      const int *ncomp, double ff[],void* userdata, unsigned int *points,int *core)
//integrand_t IntegrandCuba
{
  //printf("Core %d, seeded %d\n",cuba_thread_number,*points);
// 
runExpr((double*)xx,g_fscan,userdata,ff,*points,*core);

return 0;
}/*IntegrandCuba*/

#define EPSREL 1e-5
#define EPSABS 1e-12
#define VERBOSE 0
#define LAST 4
#define MINEVAL 0
#define MAXEVAL 50000

#define NSTART 1000
#define NINCREASE 500

#define NNEW 1000
#define FLATNESS 25.

#define KEY1 0
#define KEY2 0
#define KEY3 1
#define MAXPASS 5
#define BORDER 0.000
#define MAXCHISQ 10.
#define MINDEVIATION .25


//#define NBATCH 1000
#define GRIDNO 0

#define NGIVEN 0

#define KEY 0

static int key=KEY;
static int key1=KEY1;
static int key2=KEY2;
static int key3=KEY3;

static FLOAT epsrel=EPSREL;
static FLOAT epsabs=EPSABS;
static long long int mineval=MINEVAL;
static long long int maxeval=MAXEVAL;
static long long int nstart=NSTART;
static long long int nincrease=NINCREASE;
static int nnew=NNEW;
static FLOAT flatness=FLATNESS; 
static int maxpass=MAXPASS;
static FLOAT border=BORDER;
static FLOAT maxchisq=MAXCHISQ;
static FLOAT mindeviation=MINDEVIATION;

static int seed = 0;
static int rng = 0;

/*
static int ngiven=NGIVEN;
*/
static paramsArrayStruct_t vegasCubaParameters[]={
   {"epsrel",FMT_E,&epsrel},
   {"epsabs",FMT_E,&epsabs},
   {"mineval",FMT_I,&mineval},
   {"maxeval",FMT_I,&maxeval},
   {"nstart",FMT_I,&nstart},
   {"nincrease",FMT_I,&nincrease},
   {"seed",FMT_I,&seed},
   {"rng",FMT_I,&rng},
   {NULL,NULL,NULL}
};



#define BatchNumber ((GPUBatch*GPUCores) + (CPUBatch*CPUCores))

static int vegasCuba(result_t *result,void* userdata)
{
  long long int  neval;
  int fail;
  double integral[2], error[2], prob[2];
 
  llVegas(integral_dimension, NDIM, (integrand_t)IntegrandCuba, userdata, BatchNumber, 
    epsrel, epsabs, 
    VERBOSE  + (8*rng), //flags instead of VERBOSE 
    seed, //seed
    mineval, maxeval,
    nstart, nincrease,
    BatchNumber, //nbatch
    GRIDNO , //gridno
    NULL, // statefile
    &CubaSpin,
    &neval, &fail, integral, error, prob);
  //printf("%d,%d\n",fail,neval);
      
    result->s1=integral[0];
    result->s2=error[0];
    result->s3=integral[1];
    result->s4=error[1];    
     
    return (fail>0);
}
/*vegasCuba*/


static paramsArrayStruct_t suaveCubaParameters[]={
   {"epsrel",FMT_E,&epsrel},
   {"epsabs",FMT_E,&epsabs},
   {"mineval",FMT_I,&mineval},
   {"maxeval",FMT_I,&maxeval},
   {"nnew",FMT_I,&nnew},
   {"flatness",FMT_F,&flatness},
      {"seed",FMT_I,&seed},
   {"rng",FMT_I,&rng},
   {NULL,NULL,NULL}
};

static int suaveCuba(result_t *result,void* userdata) {
int  long long neval;
int nregions, fail;
  double integral[2], error[2], prob[2];
  int dim=integral_dimension;
  if (dim==1) dim++;
  llSuave(dim,NDIM, (integrand_t)IntegrandCuba, userdata, BatchNumber,
    epsrel, epsabs, (VERBOSE | LAST )+ (8*rng), seed, mineval, maxeval,
    nnew, flatness, "",&CubaSpin,
    &nregions, &neval, &fail, integral, error, prob);
  result->s1=integral[0];
  result->s2=error[0];
  result->s3=integral[1];
  result->s4=error[1];
  return (fail>0);
}

static paramsArrayStruct_t divonneCubaParameters[]={
   {"epsrel",FMT_E,&epsrel},
   {"epsabs",FMT_E,&epsabs},
   {"mineval",FMT_I,&mineval},
   {"maxeval",FMT_I,&maxeval},
   {"key1",FMT_I,&key1},
   {"key2",FMT_I,&key2},
   {"key3",FMT_I,&key3},
   {"maxpass",FMT_I,&maxpass},
   {"border",FMT_F,&border},
   {"maxchisq",FMT_F,&maxchisq},
   {"mindeviation",FMT_F,&mindeviation},
      {"seed",FMT_I,&seed},
   {"rng",FMT_I,&rng},
/*   {"ngiven",FMT_I,&ngiven},*/
   {NULL,NULL,NULL}
};


static int divonneCuba(result_t *result,void* userdata)
{
int  long long neval;
int nregions, fail;
  double integral[2], error[2], prob[2];
  int dim=integral_dimension;
  if (dim==1) dim++;
  llDivonne(dim,NDIM, (integrand_t)IntegrandCuba, userdata, BatchNumber, 
   epsrel, epsabs, VERBOSE + (8*rng), seed, mineval, maxeval,
    key1, key2, key3, maxpass, border, maxchisq, mindeviation,
    NGIVEN, dim, NULL, 0, NULL, "",&CubaSpin,
    &nregions, &neval, &fail, integral, error, prob);
  result->s1=integral[0];
  result->s2=error[0];
  result->s3=integral[1];
  result->s4=error[1];
  return (fail>0);
}

static paramsArrayStruct_t cuhreCubaParameters[]={
   {"epsrel",FMT_E,&epsrel},
   {"epsabs",FMT_E,&epsabs},
   {"mineval",FMT_I,&mineval},
   {"maxeval",FMT_I,&maxeval},
   {"key",FMT_I,&key},
   {NULL,NULL,NULL}
};


static int cuhreCuba(result_t *result,void* userdata)
{
int  long long neval;
int nregions, fail;
  double integral[2], error[2], prob[2];
  int dim=integral_dimension;
  if (dim==1) dim++;
  llCuhre(dim, NDIM, (integrand_t)IntegrandCuba, userdata, BatchNumber, 
    epsrel, epsabs, (VERBOSE | LAST ) + (8*rng), mineval, maxeval,
    key, "",&CubaSpin,
    &nregions, &neval, &fail, integral, error, prob);
    result->s1=integral[0];
    result->s2=error[0];
    result->s3=integral[1];
    result->s4=error[1];
    //printf("%d\n",fail);
    return (fail>0);
}




/*********** :CUBA ***************************/

int setpoints(int i1,int i2,int i11,int i22)
{
return 0;
}


/*Returns 0 on success:*/
int setPar(int nIntegrator, char *name, char *val)
{
   paramsArrayStruct_t *itr;

   for(itr=integratorParams[nIntegrator];itr->name!=NULL;itr++)
      if(strcmp(itr->name,name)==0){
         if(sscanf(val,itr->fmt,itr->addr)!=1)
            return 2;
         return 0;
      }
   return 1;
}/*setPar*/

/*If the output of getAllPars is >= STR_WIDTH it breaks the line:*/
//no!!!
#define STR_WIDTH 50

/*Att! Very dangerous! No overfolow checkup!*/
int getAllPars(int nIntegrator, char *result)
{
   paramsArrayStruct_t *itr;
   char *str=result;
  // char *lastStop=result;
   int wasComma=0;
   //*str++=' ';*str++=' ';*str++=' ';
   *str++='{';
   for(itr=integratorParams[nIntegrator];itr->name!=NULL;itr++){
      sprintf(str,"{\"%s\",\"",itr->name);
      while((*str)!='\0')str++;
      if(strcmp(FMT_I,itr->fmt)==0){
         if(sprintf(str,itr->fmt,*((int*)itr->addr))<=0)
            return -2;
      }
      else if(strcmp(FMT_F,itr->fmt)==0){
         if(sprintf(str,itr->fmt,*((FLOAT*)itr->addr))<=0)
            return -2;
      }
      else if(strcmp(FMT_E,itr->fmt)==0){
         if(sprintf(str,itr->fmt,*((FLOAT*)itr->addr))<=0)
            return -2;
      }
      else /*Not implemented format*/
         return -3;

      while((*str)!='\0')str++;

      *str++='"';
      *str++='}';
      *str++=',';wasComma=1;
/*
      if(str-lastStop >= STR_WIDTH){
        *str++='\n';*str++=' ';*str++=' ';*str++=' ';
        lastStop=str;
      }
      */
   }/*for(itr=integratorParams[nIntegrator];itr->name!=NULL;itr++)*/
   if(wasComma)
      while(*str != ',')str--;
   *str++='}';*str='\0';
   return 0;
}/*getAllPars*/

FLOAT one_point[40]={0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5};

static int justEvaluate(result_t *result,void* userdata) {

FLOAT res[8];
//int CubaBatchOld = CubaBatch;
//CubaBatch = 4;

runExpr((FLOAT*)one_point,g_fscan,userdata,res,4,0);
result->s1=res[0];
result->s2=0;
result->s3=res[1];
result->s4=0;

//CubaBatch = CubaBatchOld;

return 1;
};

static paramsArrayStruct_t justEvaluateParameters[]={
  {"x1",FMT_E,one_point+0},
  {"x2",FMT_E,one_point+1},
  {"x3",FMT_E,one_point+2},
  {"x4",FMT_E,one_point+3},
  {"x5",FMT_E,one_point+4},
  {"x6",FMT_E,one_point+5},
  {"x7",FMT_E,one_point+6},
  {"x8",FMT_E,one_point+7},
  {"x9",FMT_E,one_point+8},
  {"x10",FMT_E,one_point+9},
  {NULL,NULL,NULL}  
};



int initIntegrators(void)
{
   if(g_topIntegrator>0)
      return 0;
#if 0
   if(registerIntegrator(&vegasF,"vegasf",vegasFParameters))
      return -1;
#endif
   if(registerIntegrator(&vegasCuba,"vegasCuba",vegasCubaParameters))
      return -1;
   if(registerIntegrator(&suaveCuba,"suaveCuba",suaveCubaParameters))
      return -1;
   if(registerIntegrator(&divonneCuba,"divonneCuba",divonneCubaParameters))
      return -1;
   if(registerIntegrator(&cuhreCuba,"cuhreCuba",cuhreCubaParameters))
      return -1;
   if(registerIntegrator(&justEvaluate,"justEvaluate",justEvaluateParameters))
      return -1;
   return 0;
}/*initIntegrators*/
