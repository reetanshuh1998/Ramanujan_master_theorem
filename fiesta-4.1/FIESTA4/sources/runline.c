/*
    Copyright (C) Alexander Smirnov and Mikhail Tentyukov. 
    This file is part of the program CIntegrate.
    The program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    The program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/
/*
In this file one can find an interpretor of the array of quadruples
("rt_triad_t", for historical reasons). The array is built by the
function buildRtTriad from the file scanner.c.

The interface function runExpr() makes some initializations and
invokes the interpreter runline().
*/

#include "scanner.h"
#include "runline.h"

#include <sys/time.h>
#include <errno.h>
#include <string.h>
#include <math.h>

/*#define DEBUG 1*/
#define DEBUG_PREC 1
//#define CUBA_MINIMIM_THREAD_NUMBER 9


static INTERNAL_FLOAT *l_one;



#ifndef COMPLEX

#ifdef DEBUG_PREC
#define CHC1(a) \
   if(mpfr_get_prec(a)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(a),g_default_precision);

#define CHC2(a,b) \
   if(mpfr_get_prec(a)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(a),g_default_precision);\
   if(mpfr_get_prec(b)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(b),g_default_precision);

#define CHC3(a,b,c) \
   if(mpfr_get_prec(a)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(a),g_default_precision);\
   if(mpfr_get_prec(b)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(b),g_default_precision);\
   if(mpfr_get_prec(c)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec(c),g_default_precision);
#else
#define CHC1(a)
#define CHC2(a,b)
#define CHC3(a,b,c) 
#endif

#define RE(a) (a)
#define IM(a) (0)
#define INIT_RE(a,b) {CHC1(a) mpfr_set((a),(b),GMP_RNDN); }
#define CPY(a,b)  { CHC2(a,b) mpfr_set((a),(b),GMP_RNDN); }
#define LOG(a,b) { CHC1(a) if (mpfr_cmp_d((b),1.0E-100) <=0)\
                      mpfr_set_d((a),-230.258509299405,GMP_RNDN);\
                   else mpfr_log((a),(b),GMP_RNDN); }
#define NEG(a,b) { CHC2(a,b) mpfr_neg((a),(b),GMP_RNDN);}
#define INV(a,b) { CHC2(a,b) mpfr_div((a),*l_one,(b),GMP_RNDN);}
#define POW(a,b,c) {CHC3(a,b,c) mpfr_pow((a),(b),(c),GMP_RNDN);}
#define IPOW(a,b,c) {CHC2(a,b) mpfr_pow_si((a),(b),(c),GMP_RNDN);}
#define MUL(a,b,c) { CHC3(a,b,c) mpfr_mul((a),(b),(c),GMP_RNDN);}
#define POW3(a,b) { CHC1(a) mpfr_pow_ui((a),(b),3,GMP_RNDN);}
#define POW4(r,b) { CHC1(r) mpfr_pow_ui((r),(b),4,GMP_RNDN);}
#define POW5(r,b) { CHC1(r) mpfr_pow_ui((r),(b),5,GMP_RNDN);}
#define POW6(r,b) { CHC1(r) mpfr_pow_ui((r),(b),6,GMP_RNDN);}
#define MINUS(a,b,c) { CHC3(a,b,c) mpfr_sub((a),(b),(c),GMP_RNDN);}
#define DIV(a,b,c) { CHC3(a,b,c) mpfr_div((a),(b),(c),GMP_RNDN);}
#define PLUS(a,b,c) { CHC3(a,b,c) mpfr_add((a),(b),(c),GMP_RNDN);}


#else


#ifdef DEBUG_PREC
#define CHC1(a) \
   if(mpfr_get_prec((a).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((a).re),g_default_precision);

#define CHC2(a,b) \
   if(mpfr_get_prec((a).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((a).re),g_default_precision);\
   if(mpfr_get_prec((b).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((b).re),g_default_precision);

#define CHC3(a,b,c) \
   if(mpfr_get_prec((a).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((a).re),g_default_precision);\
   if(mpfr_get_prec((b).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((b).re),g_default_precision);\
   if(mpfr_get_prec((c).re)<g_default_precision)fprintf(stderr,"%ld<%d\n",\
   mpfr_get_prec((c).re),g_default_precision);
#else
#define CHC1(a)
#define CHC2(a,b)
#define CHC3(a,b,c) 
#endif


#define RE(a) (a).re
#define IM(a) (a).im
#define INIT_RE(a,b) {CHC1(a) mpfr_set((a).re,(b),GMP_RNDN); mpfr_set_d((a).im,0.0,GMP_RNDN);}
#define CPY(a,b)  { CHC2(a,b) mpfr_set((a).re,(b).re,GMP_RNDN); mpfr_set((a).im,(b).im,GMP_RNDN);}
#define LOG(a,b) {if ((mpfr_cmp_d((b).re,1.0E-100) <=0) && (mpfr_cmp_d((b).re,0.0) >=0) && (mpfr_cmp_d((b).im,0.0) ==0)) {mpfr_set_d((a).re,-230.258509299405,GMP_RNDN); mpfr_set_d((a).im,0.0,GMP_RNDN);} \
	else if ((mpfr_cmp_d((b).re,0.0) >=0) && (mpfr_cmp_d((b).im,0.0) ==0)) {mpfr_log((a).re,(b).re,GMP_RNDN); mpfr_set_d((a).im,0.0,GMP_RNDN);} \
	else if ((mpfr_cmp_d((b).re,0.0) <0) && (mpfr_cmp_d((b).im,0.0) ==0)) {mpfr_t temp1; mpfr_init(temp1); mpfr_neg(temp1,(b).re,GMP_RNDN); mpfr_log((a).re,temp1,GMP_RNDN); mpfr_set_d((a).im,-M_PI,GMP_RNDN); mpfr_clear(temp1);} \
	else if ((mpfr_cmpabs((b).re,(b).im) <=0) && (mpfr_cmp_d((b).im,0.0) >0)) {mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
	      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
	      mpfr_log(temp1,denom,GMP_RNDN); mpfr_set_d(temp2,2.0,GMP_RNDN); mpfr_div((a).re,temp1,temp2,GMP_RNDN); \
	      mpfr_div(temp1,(b).re,(b).im,GMP_RNDN);  mpfr_atan(temp2,temp1,GMP_RNDN); mpfr_set_d(temp1,M_PI/2,GMP_RNDN); mpfr_sub((a).im,temp1,temp2,GMP_RNDN);\
	      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} \
	else if ((mpfr_cmpabs((b).re,(b).im) <=0) && (mpfr_cmp_d((b).im,0.0) <0)) {mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
	      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
	      mpfr_log(temp1,denom,GMP_RNDN); mpfr_set_d(temp2,2.0,GMP_RNDN); mpfr_div((a).re,temp1,temp2,GMP_RNDN); \
	      mpfr_div(temp1,(b).re,(b).im,GMP_RNDN);  mpfr_atan(temp2,temp1,GMP_RNDN); mpfr_set_d(temp1,-M_PI/2,GMP_RNDN); mpfr_sub((a).im,temp1,temp2,GMP_RNDN);\
	      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} \
	else if (mpfr_cmp_d((b).re,0.0) > 0) {mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
	      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
	      mpfr_log(temp1,denom,GMP_RNDN); mpfr_set_d(temp2,2.0,GMP_RNDN); mpfr_div((a).re,temp1,temp2,GMP_RNDN); \
	      mpfr_div(temp1,(b).im,(b).re,GMP_RNDN);  mpfr_atan((a).im,temp1,GMP_RNDN); \
	      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} \
	else if (mpfr_cmp_d((b).im,0.0) > 0) {mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
	      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
	      mpfr_log(temp1,denom,GMP_RNDN); mpfr_set_d(temp2,2.0,GMP_RNDN); mpfr_div((a).re,temp1,temp2,GMP_RNDN); \
	      mpfr_div(temp1,(b).im,(b).re,GMP_RNDN);  mpfr_atan(temp2,temp1,GMP_RNDN); mpfr_set_d(temp1,M_PI,GMP_RNDN); mpfr_add((a).im,temp2,temp1,GMP_RNDN);\
	      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} \
	else {mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
	      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
	      mpfr_log(temp1,denom,GMP_RNDN); mpfr_set_d(temp2,2.0,GMP_RNDN); mpfr_div((a).re,temp1,temp2,GMP_RNDN); \
	      mpfr_div(temp1,(b).im,(b).re,GMP_RNDN);  mpfr_atan(temp2,temp1,GMP_RNDN); mpfr_set_d(temp1,M_PI,GMP_RNDN); mpfr_sub((a).im,temp2,temp1,GMP_RNDN);\
	      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} \
  }
#define NEG(a,b) { CHC2(a,b) mpfr_neg((a).re,(b).re,GMP_RNDN);mpfr_neg((a).im,(b).im,GMP_RNDN);}
#define INV(a,b) { CHC2(a,b) mpfr_t temp1,temp2,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); \
      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
      mpfr_div((a).re, (b).re, denom, GMP_RNDN); mpfr_neg(temp1, (b).im, GMP_RNDN); mpfr_div((a).im, temp1, denom, GMP_RNDN); \
      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(denom);} 
#define POW(a,b,c) {printf("Complex power not supported!!!"); halt(-25,"Complex power");}  
#define POW2(a,b) { CHC2(a,b) \
      mpfr_t temp1,temp2; mpfr_init(temp1); mpfr_init(temp2); \
      mpfr_mul(temp1,(b).re,(b).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(b).im,GMP_RNDN); mpfr_sub((a).re,temp1,temp2,GMP_RNDN); \
      mpfr_mul(temp1,(b).re,(b).im,GMP_RNDN); mpfr_add((a).im,temp1,temp1,GMP_RNDN); \
      mpfr_clear(temp1); mpfr_clear(temp2);} 
#define IPOW(a,b,c) {CHC2(a,b) \
      DINTERNAL_FLOAT u; mpfr_init(u.re); mpfr_init(u.im); \
      DINTERNAL_FLOAT v; mpfr_init(v.re); mpfr_init(v.im); \
      DINTERNAL_FLOAT z; mpfr_init(z.re); mpfr_init(z.im); \
      int y = c; \
      if (y==2) POW2(u,b) else { \
	  if ( ( y & 1 ) != 0 ) CPY(u,b)  \
	   else { \
	      FLOAT cc=1.0L;\
	      mpfr_t temp;\
	      mpfr_init(temp);		\
	      float2IFloat(&temp,&cc);\
	      INIT_RE(u,temp);\
	      mpfr_clear(temp);\
	  }\
	  CPY(z,b);\
	  y >>= 1;\
	  while ( y ) {\
	    POW2(v,z);\
	    CPY(z,v);\
	    if ( ( y & 1 ) != 0 ) {MUL(v,u,z);CPY(u,v);}\
	    y >>= 1;\
	  }\
      }\
      CPY(a,u);\
      mpfr_clear(u.re); mpfr_clear(u.im); \
      mpfr_clear(v.re); mpfr_clear(v.im); \
      mpfr_clear(z.re); mpfr_clear(z.im); \
      }	  
#define MUL(a,b,c) { CHC3(a,b,c) \
      mpfr_t temp1,temp2; mpfr_init(temp1); mpfr_init(temp2); \
      mpfr_mul(temp1,(b).re,(c).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(c).im,GMP_RNDN); mpfr_sub((a).re,temp1,temp2,GMP_RNDN); \
      mpfr_mul(temp1,(b).re,(c).im,GMP_RNDN); mpfr_mul(temp2,(b).im,(c).re,GMP_RNDN); mpfr_add((a).im,temp1,temp2,GMP_RNDN); \
      mpfr_clear(temp1); mpfr_clear(temp2);} 
#define POW3(a,b) { CHC1(a) DINTERNAL_FLOAT temp; mpfr_init(temp.re); mpfr_init(temp.im); \
      MUL(temp,b,b); MUL(a,temp,b); mpfr_clear(temp.re); mpfr_clear(temp.im);}
#define POW4(a,b) { CHC1(a) DINTERNAL_FLOAT temp; mpfr_init(temp.re); mpfr_init(temp.im); \
      MUL(temp,b,b); MUL(a,temp,temp); mpfr_clear(temp.re); mpfr_clear(temp.im);}
#define POW5(a,b) { CHC1(a) DINTERNAL_FLOAT temp; mpfr_init(temp.re); mpfr_init(temp.im); \
      MUL(a,b,b); MUL(temp,a,a); MUL(a,temp,b); mpfr_clear(temp.re); mpfr_clear(temp.im);}      
#define POW6(a,b) { CHC1(a) DINTERNAL_FLOAT temp; mpfr_init(temp.re); mpfr_init(temp.im); \
      MUL(a,b,b); MUL(temp,a,b); MUL(a,temp,temp); mpfr_clear(temp.re); mpfr_clear(temp.im);}  
#define MINUS(a,b,c) { CHC3(a,b,c) mpfr_sub((a).re,(b).re,(c).re,GMP_RNDN);mpfr_sub((a).im,(b).im,(c).im,GMP_RNDN);}
#define DIV(a,b,c) { CHC3(a,b,c) \
      mpfr_t temp1,temp2,temp3,denom; mpfr_init(temp1); mpfr_init(temp2); mpfr_init(denom); mpfr_init(temp3);\
      mpfr_mul(temp1,(c).re,(c).re,GMP_RNDN); mpfr_mul(temp2,(c).im,(c).im,GMP_RNDN); mpfr_add(denom,temp1,temp2,GMP_RNDN); \
      mpfr_mul(temp1,(b).re,(c).re,GMP_RNDN); mpfr_mul(temp2,(b).im,(c).im,GMP_RNDN); mpfr_add(temp3,temp1,temp2,GMP_RNDN); mpfr_div((a).re,temp3,denom,GMP_RNDN);\
      mpfr_mul(temp1,(b).re,(c).im,GMP_RNDN); mpfr_mul(temp2,(b).im,(c).re,GMP_RNDN); mpfr_sub(temp3,temp2,temp1,GMP_RNDN); mpfr_div((a).im,temp3,denom,GMP_RNDN);\
      mpfr_clear(temp1); mpfr_clear(temp2); mpfr_clear(temp3); mpfr_clear(denom);} 
#define PLUS(a,b,c) { CHC3(a,b,c) mpfr_add((a).re,(b).re,(c).re,GMP_RNDN);mpfr_add((a).im,(b).im,(c).im,GMP_RNDN);}





#endif


static RL_INLINE FLOAT IFloat2Float(INTERNAL_FLOAT *f)
{
/*@@@*/ /*mpfr_fprintf(stderr,"%RE\n",*f);*/
return mpfr_get_d(*f,GMP_RNDN);
}/*IFloat2Float*/



/*Parametr NINTERNAL_FLOAT a is just auxiliary variable, for non-native
  arithmetic it is used for the final result:*/
void runline(rt_triad_t *rt,NINTERNAL_FLOAT *a)
{
char *rto=rt->operations;
char *rtoStop=rt->operations+rt->length;
rt_triadaddr_t *rta=rt->operands;

   for(;rto<rtoStop;rto++,rta++){
      switch(*rto){
         case ROP_CPY_F :
               CPY(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_LOG_F:
            LOG(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_NEG_F :
            NEG(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_INV_F :
            INV(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_POW_F :
            POW(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.secondOperand));
            break;
         case ROP_IPOW_F :
            IPOW(rta->aIF.result,*(rta->aIF.firstOperand),rta->aIF.secondOperand);
            break;
         case ROP_IPOW2_F :
            MUL(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.firstOperand));
            break;
         case ROP_IPOW3_F:
            POW3(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_IPOW4_F:
            POW4(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_IPOW5_F:
            POW5(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_IPOW6_F:
           POW6(rta->aF.result,*(rta->aF.firstOperand));
            break;
         case ROP_MINUS_F :
            MINUS(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.secondOperand));
            break;
         case ROP_DIV_F :
            DIV(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.secondOperand));
            break;
         case ROP_PLUS_F :
            PLUS(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.secondOperand));
            break;
         case ROP_MUL_F :
            MUL(rta->aF.result,*(rta->aF.firstOperand),*(rta->aF.secondOperand));
            break;
        /*:MUL*/
      }/*switch(*rto)*/
   }/*for(;rto<rtoStop;rto++,rta++)*/

  
   
   rta--;
   rto--;

     if (*rto == ROP_IPOW_F) 
	CPY(*a,(rta->aIF.result))
     else
	CPY(*a,(rta->aF.result));
   return;
   
   /*An error!*/
   halt (-10, "Runline error %d\n",*rto);
//   *a=0.0;
   return;
}/*runline*/



#define BUNCHSTART for (run=0;run!=local_bunch;run+=4) {
#define BUNCHEND }




//#include <immintrin.h>

// it happens only for native within mixed
void runlineNative(rt_triad_t *rt,FLOAT *res,int llocal_bunch)
{
int local_bunch = llocal_bunch;
if ((local_bunch%4)!=0) local_bunch+=(4-(local_bunch%4));

char *rto=rt->nativeOperations;   // another branch of operations for native
char *rtoStop=rt->nativeOperations+rt->length;
rt_triadaddr_t *rta=rt->nativeOperands;


int run;
int j;
  struct timeval tv;   // see gettimeofday(2)
  gettimeofday(&tv, NULL);
  double time_start = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  

  for(;rto<rtoStop;rto++,rta++){
      switch(*rto){
	case ROP_CPY_P: BUNCHSTART 
#ifdef VEXT
	   {NP_CPY(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),run/4,CubaBatch/4);}	    
#else
	   {NP_CPY(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);}
	   {NP_CPY(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_CPY(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_CPY(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
#endif	   
	   BUNCHEND break;
	 case ROP_LOG_P: BUNCHSTART 
	   {NP_LOG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);}
	   {NP_LOG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_LOG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_LOG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 	   
	   BUNCHEND break;
	 case ROP_NEG_P: BUNCHSTART 
#ifdef VEXT
	   {NP_NEG(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),run/4,CubaBatch/4);}	    
#else
	   {NP_NEG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);} 
	   {NP_NEG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);}
	   {NP_NEG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);}
	   {NP_NEG(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);}
#endif	   
	   BUNCHEND break;
	 case ROP_INV_P: BUNCHSTART 
	   {NP_INV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);} 
	   {NP_INV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_INV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_INV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
	   BUNCHEND break;	 
	 case ROP_IPOW2_P: BUNCHSTART 
//#ifdef VEXT
//	   {NP_POW2(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),run/4,CubaBatch/4);}	    
//#else	   
	   {NP_POW2(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);} 
	   {NP_POW2(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_POW2(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_POW2(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
//#endif	   
	   BUNCHEND break;
	 case ROP_IPOW3_P: BUNCHSTART 
//#ifdef VEXT
//	   {NP_POW3(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),run/4,CubaBatch/4);}	    
//#else	   
	   {NP_POW3(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);}
	   {NP_POW3(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_POW3(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_POW3(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
//#endif	   
	   BUNCHEND break;
	 case ROP_IPOW4_P: BUNCHSTART 
	   {NP_POW4(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);} 
	   {NP_POW4(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_POW4(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_POW4(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
	   BUNCHEND break;
	 case ROP_IPOW5_P: BUNCHSTART 
	   {NP_POW5(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);} 
	   {NP_POW5(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_POW5(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_POW5(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
	   BUNCHEND break;
	 case ROP_IPOW6_P: BUNCHSTART 
	   {NP_POW6(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+0,CubaBatch);}
	   {NP_POW6(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+1,CubaBatch);} 
	   {NP_POW6(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+2,CubaBatch);} 
	   {NP_POW6(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),run+3,CubaBatch);} 
	   BUNCHEND break;	 
	 case ROP_IPOW_P: BUNCHSTART 
	   {NP_IPOW(((FLOAT*)rta->aIPN.result),((FLOAT*)rta->aIPN.firstOperand),rta->aIPN.secondOperand,run+0,CubaBatch);}
	   {NP_IPOW(((FLOAT*)rta->aIPN.result),((FLOAT*)rta->aIPN.firstOperand),rta->aIPN.secondOperand,run+1,CubaBatch);} 
	   {NP_IPOW(((FLOAT*)rta->aIPN.result),((FLOAT*)rta->aIPN.firstOperand),rta->aIPN.secondOperand,run+2,CubaBatch);} 
	   {NP_IPOW(((FLOAT*)rta->aIPN.result),((FLOAT*)rta->aIPN.firstOperand),rta->aIPN.secondOperand,run+3,CubaBatch);} 	   
	   BUNCHEND break;
	 case ROP_PLUS_P: BUNCHSTART 
#ifdef VEXT	   	    
	   {NP_PLUS(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),((VVFLOAT*)rta->aPN.secondOperand),run/4,CubaBatch/4);}	    
#else	   
	   {NP_PLUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+0,CubaBatch);}
	   {NP_PLUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+1,CubaBatch);} 
	   {NP_PLUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+2,CubaBatch);} 
	   {NP_PLUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+3,CubaBatch);} 	   
#endif	   
	   BUNCHEND break;	   
	 case ROP_MUL_P: BUNCHSTART 
#ifdef VEXT
/*
	   VFLOAT p11 =  _mm256_mul_pd(rta->aPN.firstOperand[(run)/4], rta->aPN.secondOperand[(run)/4]);
	   VFLOAT p12 =  _mm256_mul_pd(rta->aPN.firstOperand[(run)/4], rta->aPN.secondOperand[(run+CubaBatch)/4]);
	   VFLOAT p21 =  _mm256_mul_pd(rta->aPN.firstOperand[(run+CubaBatch)/4], rta->aPN.secondOperand[(run)/4]);
	   VFLOAT p22 =  _mm256_mul_pd(rta->aPN.firstOperand[(run+CubaBatch)/4], rta->aPN.secondOperand[(run+CubaBatch)/4]);
	   rta->aPN.result[(run)/4]=_mm256_sub_pd(p11,p22);
	   rta->aPN.result[(run+CubaBatch)/4]=_mm256_add_pd(p12,p21);
*/	   

	   {NP_MUL(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),((VVFLOAT*)rta->aPN.secondOperand),run/4,CubaBatch/4);}	    
#else	 
	   {NP_MUL(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+0,CubaBatch);}
	   {NP_MUL(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+1,CubaBatch);} 
	   {NP_MUL(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+2,CubaBatch);} 
	   {NP_MUL(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+3,CubaBatch);} 
#endif	   
	   BUNCHEND break;
	   
	 case ROP_DIV_P: BUNCHSTART 
	   {NP_DIV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+0,CubaBatch);} 
	   {NP_DIV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+1,CubaBatch);} 
	   {NP_DIV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+2,CubaBatch);} 
	   {NP_DIV(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+3,CubaBatch);} 
	   BUNCHEND break;
	 case ROP_MINUS_P: BUNCHSTART 
#ifdef VEXT	   
	   {NP_MINUS(((VVFLOAT*)rta->aPN.result),((VVFLOAT*)rta->aPN.firstOperand),((VVFLOAT*)rta->aPN.secondOperand),run/4,CubaBatch/4);}	    
#else
	   {NP_MINUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+0,CubaBatch);} 
	   {NP_MINUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+1,CubaBatch);}
	   {NP_MINUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+2,CubaBatch);}
	   {NP_MINUS(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+3,CubaBatch);}
#endif	
	    BUNCHEND break;	   
	 case ROP_POW_P: BUNCHSTART 
	   {NP_POW(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+0,CubaBatch);} 
	   {NP_POW(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+1,CubaBatch);} 
	   {NP_POW(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+2,CubaBatch);} 
	   {NP_POW(((FLOAT*)rta->aPN.result),((FLOAT*)rta->aPN.firstOperand),((FLOAT*)rta->aPN.secondOperand),run+3,CubaBatch);} 
	   BUNCHEND break;	
      }/*switch(*rto)*/
  }/*for(;rto<rtoStop;rto++,rta++)*/

   rta--;
   rto--;
   

    for (j=0;j!=local_bunch;++j) {
	if (*rto==ROP_IPOW_P) {	
	  (res)[j]=((FLOAT*)rta->aIPN.result)[j];
#ifdef COMPLEX	 
	  (res)[j+CubaBatch]=((FLOAT*)rta->aIPN.result)[j+CubaBatch];
#endif	  	  
	} else {
	  (res)[j]=((FLOAT*)rta->aPN.result)[j];
#ifdef COMPLEX	 
	  (res)[j+CubaBatch]=((FLOAT*)rta->aPN.result)[j+CubaBatch];
#endif	  
	}
   }


     
  gettimeofday(&tv, NULL);
  double time_stop = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  
  cuda_statistics[5*(cuba_thread_number+GPUCores) + 3]+=(time_stop-time_start);
  
   return;
  
   /*An error!*/
   halt (-10, "Runline error %d\n",*rto);
//   N_INIT_RE(*res,0.0);
   return;
}/*runlineNative*/

//FLOAT l_prod;   

static RL_INLINE int isArithmeticNative(FLOAT *x,scan_t *theScan,FLOAT* l_prod)
{
int i;
   *l_prod=1.0;
   if(theScan->maxX[0]>0){
      for(i=1;i<theScan->nx; i++){
         if(theScan->maxX[i]>0) *l_prod*=ipow(x[i],theScan->maxX[i]);
      }
      if(*l_prod>=g_mpthreshold)
         return 1;
     return 0;
   }/*if(theScan->maxX[0]>0)*/
   return 1;
}/*isArithmeticNative*/

static RL_INLINE void createTruncatedX(scan_t *theScan,FLOAT* l_prod)
{
FLOAT mpsmallX=g_mpsmallX/10.0l,ep=ABS_MONOM_MIN/10.0l;
int i,n=0;

if (*l_prod < ABS_MONOM_MIN) {

   if(mpsmallX < ABS_MONOM_MIN)
      mpsmallX = ABS_MONOM_MIN;

   for (i=1;i<theScan->nx;i++)
      if(theScan->x_local[i]<mpsmallX) {
         theScan->x_local2[i]=(mpsmallX-theScan->x_local[i])/2.0;
      } else {
         theScan->x_local2[i]=0.0l;
      }

   do{
      n++;
      *l_prod=1.0;
      for(i=1;i<theScan->nx; i++)
         (*l_prod)*=ipow(theScan->x_local[i]+theScan->x_local2[i],theScan->maxX[i]);
      if((*l_prod) < ABS_MONOM_MIN) {
         for(i=1;i<theScan->nx; i++)
            theScan->x_local2[i]*=1.5l;
      } else {
         for(i=1;i<theScan->nx; i++)
            theScan->x_local2[i]*=0.5l;
      }
      if((n>=128)&& ((*l_prod)>=ABS_MONOM_MIN))
         break;
      if(n==256)
         break;
   }while( ((*l_prod)<ABS_MONOM_MIN)||((*l_prod)-ABS_MONOM_MIN > ep) );

} else 
for(i=1;i<theScan->nx; i++) {   // no need to truncate, 0 shift
     theScan->x_local2[i]=0;  
}

   
   for(i=1;i<theScan->nx; i++) {
     theScan->x_local2[i]+=theScan->x_local[i];  //now initial data added
   }

 //  *l_prod=prod;
}/*createTruncatedX*/

static RL_INLINE void resetConstants(scan_t *theScan)
{
   int i,j;
   for(j=i=0; i <theScan->fNativeLine->fill; i++){
      char *str=(char*) (theScan->newConstantsPool.pool + theScan->constStrings->buf[i]);
      char *pos=str;
	while ((*pos!='/') && (*pos!='\0') && (pos-str<10)) ++pos;
	if (*pos=='/') {
		++pos;
		mpfr_t nom,denom;
		mpfr_init(nom);
		mpfr_init(denom);
		mpfr_set_str(nom,str,10,GMP_RNDN);
		mpfr_set_str(denom,pos,10,GMP_RNDN);			
#ifndef COMPLEX		
		mpfr_div(theScan->fline->buf[j++],nom,denom,GMP_RNDN);
#else
		mpfr_div(theScan->fline->buf[j].re,nom,denom,GMP_RNDN);
		mpfr_set_d(theScan->fline->buf[j++].im,0.0,GMP_RNDN); 
		// only real fractions
		j++;
#endif
	} else  {	  
#ifndef COMPLEX		  
      mpfr_set_str(theScan->fline->buf[j++],str,10,GMP_RNDN);
#else
      if ((str[0]=='I') && (str[1]=='\0')) {  // it's I!!
	    mpfr_set_d(theScan->fline->buf[j].re,0.0,GMP_RNDN);   
	    mpfr_set_d(theScan->fline->buf[j].im,1.0,GMP_RNDN);   	    
      } else {
	    mpfr_set_str(theScan->fline->buf[j].re,str,10,GMP_RNDN);
	    mpfr_set_d(theScan->fline->buf[j].im,0.0,GMP_RNDN);   
      }
      j++;

#endif
      }
      if(theScan->constStrings->buf[i+1] == -1){
         /*Store also */
         /*fline->buf[1] is 1, fline->buf[fline->fill-1] is 'val', we
           store 1/val into fline->buf[fline->fill]:*/
#ifndef COMPLEX
         mpfr_div(theScan->fline->buf[j],
               theScan->fline->buf[1],
               theScan->fline->buf[j-1],GMP_RNDN);
#else	 
	 mpfr_div(theScan->fline->buf[j].re,
               theScan->fline->buf[1].re,
               theScan->fline->buf[j-1].re,GMP_RNDN);
	 mpfr_set_d(theScan->fline->buf[j].im,0.0,GMP_RNDN);
	 // ONLY REAL CONSTANTS
#endif
         j++;
         i++;/*Skip next "-1" in theScan->constStrings*/
      }/*if(theScan->constStrings->buf[i+1] == -1)*/
   }/*for(i=0; i <theScan->fNativeline->fill; i++)*/
}/*resetConstants*/

static RL_INLINE int resetPrecision(scan_t *theScan)
{
int i;
   mpfr_set_default_prec(g_default_precision);
   for(i=theScan->allMPvariables->fill-1; i>=0; i--)
      mpfr_prec_round( *((mpfr_t *)(theScan->allMPvariables->buf[i])),g_default_precision,GMP_RNDN);
   resetConstants(theScan);
   return 0;
}/*resetPrecision*/

static RL_INLINE int intlog2(FLOAT x){return ceil(log(x)*1.44269504088896l);}

void setError();




void runSingeMPFRExpr(scan_t *theScan,void * userdata,FLOAT *res,FLOAT* l_prod) {
  
  struct timeval tv;   // see gettimeofday(2)
  gettimeofday(&tv, NULL);
  double time_start = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  


  int i;

    
      static int l_default_precision_mem=0;
  	 
      createTruncatedX(theScan,l_prod);   // sets theScan ->x_local2
	 
      if(*l_prod>=g_mpmin){
         if(l_default_precision_mem){
            /*Restore the default precision*/
            g_default_precision=l_default_precision_mem;
            l_default_precision_mem=0;
            resetPrecision(theScan);
         }
      }/*if(l_prod>=g_mpmin)*/
      else
      {
         int newPrec=-intlog2(*l_prod)+g_mpPrecisionShift;
         if(l_default_precision_mem){
            if(g_default_precision<newPrec){
               g_default_precision=newPrec;
               resetPrecision(theScan);
            }
         }/*if(l_default_precision_mem)*/
         else{
            l_default_precision_mem=g_default_precision;
            g_default_precision=newPrec;
            resetPrecision(theScan);
         }/*if(l_default_precision_mem)...else*/
      }/*if(l_prod>=g_mpmin)...else*/

      for(i=1;i<theScan->nx;i++) {
		mpfr_t temp;
		mpfr_init(temp);		
		float2IFloat(&temp,theScan->x_local2+i);  //uses theScan->x_local2
		INIT_RE(*(theScan->x+i),temp);
		mpfr_clear(temp);
	}
      

  
    NINTERNAL_FLOAT a;
    initIFvar(&a);
    l_one=&RE(*(theScan->fline->buf+1));
    runline(&theScan->rtTriad,&a);
    res[0]=IFloat2Float(&RE(a));
#ifdef COMPLEX
    res[1]=IFloat2Float(&IM(a));
#endif	 	
    clearIFvar(&a);
    
  gettimeofday(&tv, NULL);
  double time_stop = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  
  cuda_statistics[5*(cuba_thread_number+GPUCores) + 4]+=(time_stop-time_start);
}


void runExpr(FLOAT *x,scan_t *theScan,void * userdata,FLOAT *res,unsigned int num_total, int core) {
  x--;
  int i,j;
  //int num_total=0;
  FLOAT l_prod;
  struct timeval tv;   // see gettimeofday(2)
  gettimeofday(&tv, NULL);
  double time_start = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  
  int num_native = 0;  // the number of native points in this bunch
  for (j=0;j!=num_total;++j) {
     // if (x[1 + (j * (theScan->nx - 1))]<0) {break;}
      int current_native = 0; //whether the current x from the batch is native
      if (((int*)userdata)[2]==2) current_native=1; //always native
      if (((int*)userdata)[2]<=1) { // mixed or MPFR	
	for(i=1;i<theScan->nx; i++) {
	  theScan->x_local[i] = x[i + (j * (theScan->nx - 1))];  // fill array for one set of x	
	}
	int return_from_isArithmeticNative = isArithmeticNative(theScan->x_local,theScan,&l_prod);  // we check whether this point is native and calculate l_prod
	if (((int*)userdata)[2]==0) current_native = return_from_isArithmeticNative; //mixed
      }

      if (current_native) {
	 for(i=1;i<theScan->nx; i++) {//printf("(%f)",x[i + (j * (theScan->nx - 1))]);
	   ((FLOAT*)theScan->nativeXsplit)[(i * CubaBatch * COMPLEX_MULTIPLIER) + num_native] = x[i + (j * (theScan->nx - 1))];
#ifdef COMPLEX
	   ((FLOAT*)theScan->nativeXsplit)[(i * CubaBatch * COMPLEX_MULTIPLIER) + CubaBatch + num_native] = 0.;
#endif	   	   
	 }
	 theScan->answer_position[num_native] = j;
	 num_native++;
      } else {
	 runSingeMPFRExpr(theScan,userdata,res + (COMPLEX_MULTIPLIER*j),&l_prod); 
      }
 //     num_total++;
  }
  
 // printf("Native: %d\n",num_native);
  
  statistics[2*(cuba_thread_number+GPUCores) + 0]+=num_native;
  statistics[2*(cuba_thread_number+GPUCores) + 1]+=(num_total-num_native);
#ifndef GPU
  int this_core_uses_gpu=0;
  this_core_uses_gpu=this_core_uses_gpu;
#endif
  
  
  //fprintf(stderr,"core: %d, internal core %u, native: %d(%d), MPFR: %d(%d), uses %d\n",cuba_thread_number,core,statistics[2*(cuba_thread_number+GPUCores)+0],num_native,statistics[2*(cuba_thread_number+GPUCores)+1],(num_total-num_native),this_core_uses_gpu);
  
  //
#ifdef GPU
   if (this_core_uses_gpu) {  
      gettimeofday(&tv, NULL);
      double time_start2 = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
 
   //if (core<=device_count) {
     MEASURE_GPU_TIME((SAFE_CALL((cudaMemcpy(theScan->nativeXGPU, theScan->nativeXsplit, theScan->nx * CubaBatch * sizeof(FLOAT) * COMPLEX_MULTIPLIER, cudaMemcpyHostToDevice)))),0);
     // filling nativeX on GPU. to replace CubaBatch with local_bunch one needs a cycle.
     runlineNativeGPU(num_native,theScan->rtTriad.length);
     MEASURE_GPU_TIME((SAFE_CALL((cudaMemcpy(theScan->answer, theScan->rtTriad.gpu_operands[theScan->rtTriad.length-1].result, CubaBatch * sizeof(FLOAT) * COMPLEX_MULTIPLIER, cudaMemcpyDeviceToHost)))),0);
     cudaDeviceSynchronize();
     
     gettimeofday(&tv, NULL);
     double time_stop2 = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  
     cuda_statistics[5*(cuba_thread_number+GPUCores) + 1]+=(time_stop2-time_start2);
     
  } else {
#endif
    runlineNative(&theScan->rtTriad,theScan->answer,num_native); 
#ifdef GPU
  }  
#endif    
    
           
#ifndef COMPLEX
  for (j=0;j!=num_native;++j) res[(theScan->answer_position[j])+0]=theScan->answer[j];
#else
  for (j=0;j!=num_native;++j) res[(2*theScan->answer_position[j])+0]=((FLOAT*)theScan->answer)[j];
  for (j=0;j!=num_native;++j) res[(2*theScan->answer_position[j])+1]=((FLOAT*)theScan->answer)[j+CubaBatch];     
#endif	 

  
   if (((int*)userdata)[1]) { //debug
	for (j=0;j!=num_total;++j) {
	  printf("core %d, point: {",cuba_thread_number);
	  for(i=1;i<=((theScan->nx -1)); i++) {printf("%f, ",x[i+(j*(theScan->nx-1))]);}
	  printf("} ");
	  printf("result: ");
#ifndef COMPLEX
	  printf("{%.15lf}",res[j]);            
#else
	  printf("{%.15lf,%.15lf}",res[2*j+0],res[2*j+1]);            
#endif
	  printf("\n");
	}
   }
  
#ifdef COMPLEX
   if (((int*)userdata)[0]) { //testF
      for (j=0;j!=num_total;++j) {
	if (res[(2*j)+1]>0) {
	  printf("{");
	  for(i=1;i<theScan->nx; i++) {printf("%f, ",x[i + (j * (theScan->nx - 1))]);}
	  printf("} result: ");
	  printf("{%.15lf,%.15lf}\n",res[(2*j)+0],res[(2*j)+1]);    
	  setError();
	}
      }
   }
#endif	   
  gettimeofday(&tv, NULL);
  double time_stop = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
  
  cuda_statistics[5*(cuba_thread_number+GPUCores) + 2]+=(time_stop-time_start);
}



/*
 * 
 * 
процес такой с константами (типа G)

tAndSConst (строка,значение)
cheсkTrie строка ищется в списке строк. Если нашли, вернули ее номер.
иначе вычисляем
в MIXED кладем в Nativeline (addNativeFloat)  (ЗДЕСЬ I ПО-ДРУГОМУ)
и кладем val в список констант pushConst: в theScan->newConstantsPool, theScan->constStrings
в NATIVE нас не волнует
затем кидаем номер в список строк - по строке теперь находится номер в Nativeline

а потом диада метится как константная

позже (после парса, конец masterScan)
для всех Nativeline добывается значение из theScan->newConstantsPool
и пихается в addInternalFloatStr (ВОТ ЗДЕСЬ НАДО ОБРАБОТАТЬ I)

обращать его мы не будем, -1 в эти буфера не пихаем

все бы хорошо, но в runLine есть функция resetConstants, которая что-то с этими константами делает

она бежит по всем из NativeLine, опять добывает строку
если находит в ней дробь, то вычисляет с нужной точностью,
иначе же создает mpfr по строке (ВОТ ЗДЕСЬ НАДО ОПЯТЬ ОБРАБОТАТЬ I)

потом обращается, если нужно (мы этого для I делать не будем)

*/
