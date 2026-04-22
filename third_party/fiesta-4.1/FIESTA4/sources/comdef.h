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

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif



#ifndef COMDEF_H
#define COMDEF_H

#include <sys/shm.h>
#include <assert.h>
#include <stdio.h>

#define COM_INLINE inline

#define  NO_FILES 1

#ifdef GPU
#include <cuda_runtime.h>
#endif

#define WITH_OPTIMIZATION 1

/*#define COM_INT int*/
#define COM_INT long int

#ifdef COMPLEX
#define COMPLEX_MULTIPLIER 2
#else
#define COMPLEX_MULTIPLIER 1
#endif

/*IEEE FP type, used for input-output:*/
#define FLOAT double

#define CUDA_BLOCK_SIZE (128)
#define CUDA_BLOCKS_PER_SM (8)

//#define CUDA_MIN_BLOCKS (8)
//#define CubaBatchLocal (2*CUDA_BLOCK_SIZE*CUDA_MIN_BLOCKS)

//#define VEXT 1

#define VFLOAT __attribute__ ((vector_size (32))) FLOAT
#define VVFLOAT __attribute__ ((vector_size (32))) FLOAT

//#define VFLOAT __attribute__ ((aligned (32))) FLOAT
//#define VFLOAT FLOAT
//#define VFLOAT __attribute__ ((vector_size (32))) FLOAT



/*Could'n handle smaller values!*/
#define ABS_MONOM_MIN 1.0E-308

/*Initial precision for internal FP, in bits:*/
#ifndef PRECISION
#define PRECISION 64
#endif 


#include <mpfr.h>


#define INTERNAL_FLOAT mpfr_t


#ifndef COMPLEX
#define NINTERNAL_FLOAT INTERNAL_FLOAT
#else
struct DINTERNAL_FLOAT_s {INTERNAL_FLOAT re;INTERNAL_FLOAT im;};
typedef struct DINTERNAL_FLOAT_s DINTERNAL_FLOAT;
#define NINTERNAL_FLOAT DINTERNAL_FLOAT
#endif

int new_core_number;  // should be here as a reference but should not be used



extern int g_default_precision;
extern int g_default_precisionChanged;



#define MEMORY_LIMIT (1.5)

#define MPSMALLX 0.001
extern FLOAT g_mpsmallX;
#define MPTHRESHOLD 1E-9
extern FLOAT g_mpthreshold;
#define MPMIN 1E-48
extern FLOAT g_mpmin;
extern int g_mpminChanged;
#define MPPRECISIONSHIFT 38
extern int g_mpPrecisionShift;

extern char* math_binary;


extern int CubaBatch, GPUBatch, CPUBatch;
extern int CubaBatchRequested;
extern int GPUMemoryPart; // how to split memory among nodes

extern void* CubaSpin;



/* 
Run-time operations.  The result may be stored directly in a triad,
or in some extrnal array.
*/

#define ROP_CPY_P 2
#define ROP_CPY_F 4
#define ROP_LOG_P 5
#define ROP_LOG_F 6
#define ROP_NEG_P 7
#define ROP_NEG_F 8
#define ROP_INV_P 9
#define ROP_INV_F 10
#define ROP_POW_P 11
#define ROP_POW_F 12
#define ROP_IPOW_P 13
#define ROP_IPOW_F 14
#define ROP_IPOW2_P 15
#define ROP_IPOW2_F 16
#define ROP_IPOW3_P 17
#define ROP_IPOW3_F 18
#define ROP_IPOW4_P 19
#define ROP_IPOW4_F 20
#define ROP_IPOW5_P 21
#define ROP_IPOW5_F 22
#define ROP_IPOW6_P 23
#define ROP_IPOW6_F 24
#define ROP_MINUS_P 25
#define ROP_MINUS_F 26
#define ROP_DIV_P 27
#define ROP_DIV_F 28
#define ROP_PLUS_P 29
#define ROP_PLUS_F 30
#define ROP_MUL_P 31
#define ROP_MUL_F 32

#ifdef COM_INT
#define SC_INT COM_INT
#else
#define SC_INT int
#endif

extern SC_INT deviceCount; // obtained an init_cuba
extern SC_INT cuda_sm;
extern SC_INT memory_limit;

//#define OPDEBUG 1




#ifndef COMPLEX

#define NP_PLUS(a,b,c,shift,sim) a[shift]=b[shift]+c[shift]
#define NP_MUL(a,b,c,shift,sim) a[shift]=b[shift]*c[shift]
#define NP_MINUS(a,b,c,shift,sim) a[shift]=b[shift]-c[shift]
#define NP_DIV(a,b,c,shift,sim) a[shift]=b[shift]/c[shift]
#define NP_IPOW(a,b,deg,shift,sim) {FLOAT x=b[shift];FLOAT z;\
   int y = deg;\
   FLOAT u;\
   if ( y == 2 ) u = x*x;\
   else {\
      if ( ( y & 1 ) != 0 ) u = x;\
      else u = 1.0L;\
      z = x;\
      y >>= 1;\
      while ( y ) {\
         z = z*z;\
         if ( ( y & 1 ) != 0 ) u *= z;\
         y >>= 1;\
      }\
   }\
a[shift]=u;}

#define NP_IPOW_GPU(a,b,deg,shift,sim) {FLOAT x=b[shift];FLOAT z;\
   int y = deg;\
   FLOAT u;\
   if ( y == 2 ) u = x*x;\
   else {\
      if ( ( y & 1 ) != 0 ) u = x;\
      else u = 1.0L;\
      z = x;\
      y >>= 1;\
      while ( y ) {\
         z = z*z;\
         if ( ( y & 1 ) != 0 ) u *= z;\
         y >>= 1;\
      }\
   }\
a[shift]=u;}

#define NP_POW2(a,b,shift,sim) (a[shift]) = (b[shift])*(b[shift])
#define NP_POW3(a,b,shift,sim) (a[shift]) = (b[shift])*(b[shift])*(b[shift])
#define NP_POW4(a,b,shift,sim) {FLOAT temp; (temp)=(b[shift])*(b[shift]);(a[shift])=(temp)*(temp);}
#define NP_POW5(a,b,shift,sim) {FLOAT temp; (temp)=(b[shift])*(b[shift]);(a[shift])=(temp)*(temp)*(b[shift]);}
#define NP_POW6(a,b,shift,sim) {FLOAT temp; (temp)=(b[shift])*(b[shift]);(a[shift])=(temp)*(temp)*(temp);}
#define NP_CPY(a,b,shift,sim) (a[shift]) = (b[shift])
#define NP_NEG(a,b,shift,sim) (a[shift]) = -(b[shift])
#define NP_INV(a,b,shift,sim) (a[shift]) = 1.0 / (b[shift])
#define NP_LOG(a,b,shift,sim) if((b[shift]) <= 1.0E-100 ) (a[shift]) = -230.258509299405; else (a[shift]) = log(b[shift]);          
#ifndef GPU
#define NP_POW(a,b,c,shift,sim) (a[shift]) = pow((b[shift]),(c[shift]))
#else
#define NP_POW(a,b,c,shift,sim) {a[shift]=1/(1-1.);}
#endif

#else

#define NP_PLUS(a,b,c,shift,sim) a[shift]=b[shift]+c[shift];a[shift+sim]=b[shift+sim]+c[shift+sim];
#define NP_MINUS(a,b,c,shift,sim) a[shift]=b[shift]-c[shift];a[shift+sim]=b[shift+sim]-c[shift+sim];
#define NP_MUL(a,b,c,shift,sim) a[shift]=(b[shift]*c[shift])-(b[shift+sim]*c[shift+sim]);a[shift+sim]=(b[shift+sim]*c[shift])+(b[shift]*c[shift+sim]);
#define NP_DIV(a,b,c,shift,sim) FLOAT temp = (c[shift]*c[shift])+(c[shift+sim]*c[shift+sim]); a[shift]=((b[shift]*c[shift])+(b[shift+sim]*c[shift+sim]))/temp;a[shift+sim]=((b[shift+sim]*c[shift])-(b[shift]*c[shift+sim]))/temp;

#define NP_IPOW(a,b,deg,shift,sim) int y=deg;FLOAT bre=b[shift]; FLOAT bim=b[shift+sim];FLOAT temp;\
   if (y == 2) {a[shift]=(bre*bre)-(bim*bim);a[shift+sim]=2*(bre*bim);}\
   else {\
     FLOAT are,aim;\
     if ( ( y & 1 ) != 0 ) {are=bre;aim=bim;} else {are=1.0L;aim=0.0L;}\
     y >>= 1;\
     while ( y ){\
       temp = bre*bre-bim*bim; bim = 2*bre*bim; bre = temp;\
       if ( ( y & 1 ) != 0 ) {temp = are*bre - aim*bim; aim = are*bim+aim*bre; are = temp;}\
       y >>= 1;\
     }\
     a[shift]=are;a[shift+sim]=aim;\
   }\
  
#define NP_POW2(a,b,shift,sim) a[shift]=(b[shift]*b[shift])-(b[shift+sim]*b[shift+sim]);a[shift+sim]=2*(b[shift+sim]*b[shift]);
#define NP_POW3(a,b,shift,sim) a[shift] = b[shift] * b[shift] * b[shift] - 3 * b[shift] * b[shift+sim] * b[shift+sim]; a[shift+sim] = 3 * b[shift+sim] * b[shift] * b[shift] - b[shift+sim] * b[shift+sim] * b[shift+sim];
#define NP_POW4(a,b,shift,sim) {FLOAT tre=(b[shift]*b[shift])-(b[shift+sim]*b[shift+sim]);FLOAT tim=2*(b[shift+sim]*b[shift]); \
                                  a[shift]=(tre*tre)-(tim*tim);a[shift+sim]=2*(tre*tim);}
#define NP_POW5(a,b,shift,sim) {NP_IPOW(a,b,5,shift,sim)}

#define NP_POW6(a,b,shift,sim) {FLOAT tre=(b[shift]*b[shift])-(b[shift+sim]*b[shift+sim]);FLOAT tim=2*(b[shift+sim]*b[shift]); \
                                  a[shift]=(tre*tre*tre)-(3*tre*tim*tim);a[shift+sim]=(3*tre*tre*tim)-(tim*tim*tim);}
#define NP_CPY(a,b,shift,sim) (a[shift]) = (b[shift]);(a[shift+sim]) = (b[shift+sim])
#define NP_NEG(a,b,shift,sim) (a[shift]) = -(b[shift]);(a[shift+sim]) = -(b[shift+sim])
#define NP_INV(a,b,shift,sim) {FLOAT temp = b[shift] * b[shift] + b[shift+sim] * b[shift+sim];  a[shift] = b[shift] / temp; a[shift+sim] = - b[shift+sim] / temp;} 

#define NP_LOG(a,b,shift,sim) FLOAT bre=b[shift];FLOAT bim=b[shift+sim];if((bre <= 1.0E-100) && (bre>=0) && (bim==0.0)) {a[shift] = -230.258509299405; a[shift+sim] = 0;} \
    else if ((bim==0.0) && (bre>0)) {a[shift] = log(bre); a[shift+sim]=0;} \
    else if ((bim==0.0) && (bre<0)) {a[shift] = log(-bre); a[shift+sim]=- M_PI;} \
    else if ((bim>0) && (bre <= bim) && (bre >= - bim)) {FLOAT temp = bre * bre + bim * bim; a[shift] = log(temp)/2; a[shift+sim] = M_PI/2 - atan(bre / bim);} \
    else if ((bim<0) && (bre <= - bim) && (bre >= bim)) {FLOAT temp = bre * bre + bim * bim; a[shift] = log(temp)/2; a[shift+sim] = - M_PI/2 - atan(bre / bim);} \
    else if (bre>0) {FLOAT temp = bre * bre + bim * bim; a[shift] = log(temp)/2; a[shift+sim] = atan(bim / bre);} \
    else if (bim>0) {FLOAT temp = bre * bre + bim * bim; a[shift] = log(temp)/2; a[shift+sim] = atan(bim / bre) + M_PI;} \
    else {FLOAT temp = bre * bre + bim * bim; a[shift] = log(temp)/2; a[shift+sim] = atan(bim / bre) - M_PI;}


#ifndef GPU
#define NP_POW(a,b,c,shift,sim) {  printf("Complex power not supported!!!"); halt(-25,"Complex power");}
#else
#define NP_POW(a,b,c,shift,sim) {a[shift]=1/(1-1.);}
#endif



#endif



void halt(int retval,char *fmt, ...);






int* statistics;
int* buffer_shared_id_address;
int cuba_thread_number;
extern int GPUCores,CPUCores;
float* cuda_statistics;
extern int integral_dimension;


#ifdef GPU
cudaEvent_t cuda_start,cuda_stop;

typedef struct GPU_triad_struct {
   FLOAT *result;
   FLOAT *firstOperand;
   FLOAT *secondOperand;
   SC_INT firstOperandSlot;
   SC_INT secondOperandSlot;
   SC_INT resultSlot;
}rt_gpu_triad;


#endif


#define MALLOC(addr,size) if(posix_memalign((void**)&(addr),32,size)) halt(-26,"Bad aligned alloc");



#endif



