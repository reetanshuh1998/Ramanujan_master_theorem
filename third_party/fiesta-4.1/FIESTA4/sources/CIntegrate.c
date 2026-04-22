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
The main file for the CIntegrate program.
The routine Integrate() adds the rest and invokes the
translator masterScan(), file "scanner.c".  After the incoming
expression is translated into the tetrad array the routine Integrate()
invokes the VEGAS routine for numberOfIterations1 repetitions with
numberOfCalls1 sampling points in order to ``warmup'' the
grid. Finally, the VEGAS routine is invoked by the Integrate() routine
for numberOfIterations2 repetitions with numberOfCalls2 sampling
points for the real integration. Parameters numberOfCalls1,
numberOfIterations1, numberOfCalls2 and numberOfIterations2 could be
changed by the function setpoints().

The integrand for the VEGAS routine, the function theIntegrand(),
invokes the interpreter runExpr(), see the file "runline.c".

*/

#include <sys/wait.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "scanner.h"
#include "runline.h"
#ifdef GPU
#include "kernel.h"
#endif
#include "comdef.h"
#include "integrators.h"

#define CUT_MULTIPLIER 10.0

#ifdef GPU
#include <cuda_runtime.h>
#endif


#ifdef FILE_TO_SAVE_INPUT
#include <sys/types.h>
#include <unistd.h>
#endif

#define SHMMAX_SYS_FILE "/proc/sys/kernel/shmmax"
unsigned long int SHMMAX;
#define MAX_BUFFERS 100
// normal buffer size is 35MB. We are not normally integrating something larger than that. so 100 buffers is a lot!
size_t* size_of_string_transfered;
int* number_of_buffers_used;


/*
#define DEBUG_CHECK_RETURNED 1
*/

#ifdef DEBUG_CHECK_RETURNED
#include <unistd.h>
void whaitForGDB(void){
   volatile int loopForever=1;
   while(loopForever)
      sleep(1);
}/*whaitForGDB*/
#endif

int g_default_precision=PRECISION;
int g_default_precisionChanged=0;
   int userdata[3];


FLOAT g_mpsmallX=MPSMALLX;
FLOAT g_mpthreshold=MPTHRESHOLD;
FLOAT g_mpmin=MPMIN;
int g_mpminChanged=0;
int g_mpPrecisionShift = MPPRECISIONSHIFT;

integrator_t g_integratorArray[MAX_INTEGRATOR];
char *g_integratorNamesArray[MAX_INTEGRATOR];

int g_currentIntegrator=0;
int g_topIntegrator=0;
int testF=0;
int debug=0;
int int_mode=0;

void* CubaSpin;  //for tracing the cuba cores

SC_INT cuda_sm = 2;
SC_INT memory_limit = 2147155968;

int GPUBatch = 0;
int CPUBatch = 0;
int CubaBatch = 0;
int TheSingleGPUNumber = 0;
int GPUMemoryPart = 1;

int RealGPUCores;

scan_t *g_fscan=NULL;

#ifdef STATISTICS_OUT
extern long int allT;
extern long int newT;
#endif

void getCurrentIntegratorParameters(void)
{
   /*Att! Very dangerous! No overfolow checkup!*/
   char res[2048];
    initIntegrators();
   /*
  if(g_currentIntegrator==0) {
      printf("{}\n");
      return;
  }*/
   
   if(getAllPars(g_currentIntegrator, res))
      printf("$Error : failed to get integrator params\n");
   else
      printf("%s\n",res);
}/*getCurrentIntegratorParameters*/

void setCurrentIntegratorParameter(char *name, char *value)
{
    initIntegrators();
   int ret=setPar(g_currentIntegrator,name,value);
   if(ret==0)
      printf("Ok\n");
   else
      printf("$Error : failed to set integrator params\n");
}/*setCurrentIntegratorParameter*/

void setIntegrator(char *name)
{
int i;
   /*If the integrator array is already initialized, the function does nothing:*/
   initIntegrators();/*fixme: check the returned code!*/
   for(i=0;i<g_topIntegrator;i++)
      if( strcmp(name,g_integratorNamesArray[i])==0 ){
         g_currentIntegrator=i;
         printf("Ok\n");
         return;
      }
   printf("$Error : failed to set integrator \n");
}/*setIntegrator*/

void PutErrorMessage(char* function,char* message) {
  printf("$Error - %s: %s",function,message);
}

int had_complex_error;

void setError() {
    //printf("%d\n",had_complex_error);
    had_complex_error=1;
    halt(-5,"Incorrect complex sign\n");
    //printf("Incorrect complex sign\n");
}


int setDefaultPrecision(int p)
{
   if (p==0){
      g_default_precision=PRECISION;
      g_default_precisionChanged=0;
      return 0;
   }
   if( p < PREC_MIN ){
      PutErrorMessage("SetMPPrecision","Too small number.\n");
      return 1;
   }
   if( p > PREC_MAX){
      PutErrorMessage("SetMPPrecision","Too large number.\n");
      return 1;
   }
   g_default_precision=p;
   g_default_precisionChanged=1;
   return 0;
}/*setDefaultPrecision*/

static multiLine_t ml;


int setMPSmallX(FLOAT ep)
{
   if(ep <=0.0){
      PutErrorMessage("SetSmallX","Ep <= 0!");
      return 1;
   }
   if( ep > 1.0)
      ep=1.0/ep;
   g_mpsmallX=ep;
   return 0;
}/*setMPSmallX*/

int setMPthreshold(FLOAT ep)
{
   if(ep <=0.0){
      PutErrorMessage("SetMPThreshold","Ep <= 0!");
      return 1;
   }
   if( ep > 1.0)
      ep=1.0/ep;
   g_mpthreshold=ep;
   return 0;
}/*setMPthreshold*/

int setMPmin(FLOAT ep)
{
   if(ep <= 0.0){
      g_mpmin=MPMIN;
      g_mpminChanged=0;
      return 0;
   }
   if( ep > 1.0)
      ep=1.0/ep;
   g_mpmin=ep;
   g_mpminChanged=1;
   return 0;
}/*setMPmin*/

int setMPPrecisionShift(int s)
{
   if( s > PREC_MAX){
      PutErrorMessage("SetMPPrecisionShift","Too large number.\n");
      return 1;
   }
   if( s <= 0){
      PutErrorMessage("SetMPPrecisionShift","Negative number.\n");
      return 1;
   }
   g_mpPrecisionShift=s;
   return 0;
}/*setMPPrecisionShift*/



int doAddString (char* s)
{
  if( ml.mline.buf == NULL){
     if(initMultiLine(&ml)){
        destroyMultiLine(&ml);
        return 1;
     }/*if(initMultiLine(&ml))*/
  }/*if( ml.mline.buf == NULL)*/
  if(addToMultiLine(&ml,s)){
     destroyMultiLine(&ml);
     return 1;
  }/*if(addToMultiLine(&ml,s))*/
  return 0;
}/*doAddString*/

struct shminfo_s {
  void *addr;
  int id;
};
typedef struct shminfo_s shminfo;
//shminfo buffer;    

#include <errno.h>

void shmalloc_(const int n, shminfo *base) {
  base->id = shmget(IPC_PRIVATE, n, IPC_CREAT | 0600);
  if (base->id == -1) {
      printf("shmget error %d\n",errno);
      if (errno==EINVAL) printf("EINVAL\n");
      if (errno==EEXIST) printf("EEXIST\n");
      if (errno==ENOSPC) printf("ENOSPC\n");
      if (errno==ENOENT) printf("ENOENT\n");
      if (errno==EACCES) printf("EACCES\n");
      if (errno==ENOMEM) printf("ENOMEM\n");
      assert (base->id != -1);
  }
  base->addr = shmat(base->id, NULL, 0);
  assert(base->addr != (void *)-1);
}

void shmfree_(shminfo *base) {
  shmdt(base->addr);
  shmctl(base->id, IPC_RMID, NULL);
}

int total_statistics[2];
float total_cuda_statistics[6];


#include <pthread.h>

pthread_mutex_t mutex;
pthread_mutexattr_t mutexAttr;


FLOAT** locations;
SC_INT min_op;
SC_INT locations_counter;


int CPUCores,GPUCores;

shminfo shared_mem; // for statistics and id passing





void* init_Cuda(int* param,int* a) {
   
      
  if (*a==32768) cuba_thread_number = 0;
  else if ((*a)>=0) cuba_thread_number=(*a)+1;   
  else cuba_thread_number= *a;  
   
   pthread_mutex_lock(&mutex);
   pthread_mutex_unlock(&mutex);
  
  if (GPUCores+CPUCores!=1) {  // no need to receive in case of 1 thread
  

  
   shminfo buffer;    
    
  //*size_of_string_transfered = strlen(s)+1;
  //*number_of_buffers_used = 0;
 
   char* s = malloc(*size_of_string_transfered);
   int current_buffer;
   for (current_buffer=0;current_buffer!=*number_of_buffers_used;++current_buffer) {   
      buffer.id=buffer_shared_id_address[current_buffer]; 
      
      if (buffer.id<=0) {
	fprintf(stderr, "incorrect buffer id in init_Cuda\n");
        exit(EXIT_FAILURE);
      }
	
      buffer.addr = shmat(buffer.id, NULL, 0);
   
      if (current_buffer+1==*number_of_buffers_used) 
	  strncpy(s+(current_buffer*SHMMAX),buffer.addr,(*size_of_string_transfered)-(current_buffer*SHMMAX));
      else
	  strncpy(s+(current_buffer*SHMMAX),buffer.addr,SHMMAX);
	
      if (shmdt(buffer.addr) == -1) {
        fprintf(stderr, "shmdt failed init_Cuda\n");
        exit(EXIT_FAILURE);
      }
   
   }   
      
  

  
   if(doAddString(s)){
      return NULL;
   }
   
   free(s);
    
   g_fscan=newScannerMultiStr(&ml);

   if(g_fscan==NULL){
      return NULL;
   }

   if(masterScan(g_fscan)){
      return NULL;
   }
   
} //(GPUCores+CPUCores!=1)
   


// fprintf(stderr,"Cuba number: %d\n",cuba_thread_number);
  
   

  
  

#ifdef GPU
    	
  if ((cuba_thread_number<0) || ((GPUCores==1) && (CPUCores==0) && (cuba_thread_number==0))) { 

    this_core_uses_gpu = 1;
    
    int used_core;
    if (cuba_thread_number==0) used_core=TheSingleGPUNumber%RealGPUCores; else used_core=(-cuba_thread_number-1)%RealGPUCores;
    
    if (cudaSetDevice(used_core)!=cudaSuccess) {
	printf("Could not set Cuda device (init_Cuda, %d, %d, %d)!\n",cuba_thread_number,RealGPUCores,used_core);
	return NULL;         
    }
    
    size_t Mfree,Mtotal;
    cudaMemGetInfo(&Mfree,&Mtotal);
   // fprintf(stderr,"Free on process %d: %zu/%zu\n",(int)getpid(),Mfree,Mtotal); 
    
    
    SAFE_CALL((cudaDeviceSetCacheConfig(cudaFuncCachePreferL1)));
    
    SAFE_CALL((cudaEventCreate(&cuda_start)));
    SAFE_CALL((cudaEventCreate(&cuda_stop)));    
    
    // allocating slots on GPU
    
    
   // cudaMemcpyToSymbol	("CubaBatchLocal",&CubaBatch,sizeof(int),0,cudaMemcpyHostToDevice);
//size_t 	count,
//size_t 	offset = 0,
//enum cudaMemcpyKind 	kind = cudaMemcpyHostToDevice	 
//)	
    
    //char *rto;
    char *rto=g_fscan->rtTriad.nativeOperations;
    rt_triadaddr_t *rta;
    //rt_triadaddr_t *rtaN;
    rt_gpu_triad *rtg=g_fscan->rtTriad.gpu_operands;
    char *rtoStop=g_fscan->rtTriad.nativeOperations+g_fscan->rtTriad.length;
    min_op=0;
    SC_INT max_op=0;
    // finding min and max op
    for(;rto<rtoStop;rto++,rtg++){
	//printf("First: %ld, second: %ld, result: %ld\n",rtg->firstOperandSlot,rtg->secondOperandSlot,rtg->resultSlot);
	if (rtg->firstOperandSlot<min_op) min_op = rtg->firstOperandSlot;
	if (rtg->secondOperandSlot<min_op) min_op = rtg->secondOperandSlot;
	if (rtg->resultSlot<min_op) min_op = rtg->resultSlot;
	if (rtg->firstOperandSlot>max_op) max_op = rtg->firstOperandSlot;
	if (rtg->secondOperandSlot>max_op) max_op = rtg->secondOperandSlot;
	if (rtg->resultSlot>max_op) max_op = rtg->resultSlot;
    }
    
    
    min_op = -(g_fscan->fNativeLine->fill+g_fscan->nx +g_fscan->nf+1);
    
    
    locations = (FLOAT**) malloc((-min_op+max_op+1)*sizeof(FLOAT*));  // temporary array. may be this is overuse of RAM, but it is fast
    if (locations==NULL) {
	halt(-10,"cuda_init: malloc fails");
    }
    
    
    SAFE_CALL((cudaMalloc( (void**)&g_fscan->nativeXGPU, g_fscan->nx * sizeof(FLOAT) * CubaBatch * COMPLEX_MULTIPLIER)));
    int i;
    for (i=-1;i>-g_fscan->nx;--i) {
      locations[i-min_op]=g_fscan->nativeXGPU+(CubaBatch*(-i) * COMPLEX_MULTIPLIER);
      //printf("x[%d]: %p\n",-i,locations[i-min_op]);
    }
    // filling locations of nativeXGPU
    
    
    
    FLOAT**first_operand_local=(FLOAT**) malloc(sizeof(FLOAT*)*g_fscan->rtTriad.length);
    FLOAT** second_operand_local=(FLOAT**) malloc(sizeof(FLOAT*)*g_fscan->rtTriad.length);
    SC_INT* second_operandI_local=(SC_INT*) malloc(sizeof(SC_INT)*g_fscan->rtTriad.length);
    FLOAT** result_local=(FLOAT**) malloc(sizeof(FLOAT*)*g_fscan->rtTriad.length);
    char* operation_local=(char*) malloc(sizeof(char)*g_fscan->rtTriad.length);
    
    int index;     
    int j;  
    
    //filling numbers for gpu
    
    
    for(j=0;j!=g_fscan->fNativeLine->fill;++j) {

	SAFE_CALL((cudaMalloc( (void**)&(locations[-j - (g_fscan->nx + g_fscan->nf+1) - min_op]), CubaBatch * sizeof(FLOAT)* COMPLEX_MULTIPLIER)));
	SAFE_CALL((cudaMemcpy(locations[-j - (g_fscan->nx + g_fscan->nf+1) - min_op],(FLOAT*)(g_fscan->fNativeLine->buf)+(CubaBatch*COMPLEX_MULTIPLIER*j),CubaBatch*sizeof(FLOAT)* COMPLEX_MULTIPLIER,cudaMemcpyHostToDevice)));
    }    
    
    //size_t total,freee;
   // cudaMemGetInfo(&freee,&total);
    //fprintf(stderr,"%zd,%zd\n",total,freee);	
   // size_t prev = freee;
    for(rto=g_fscan->rtTriad.nativeOperations,rtg=g_fscan->rtTriad.gpu_operands,rta=g_fscan->rtTriad.nativeOperands,index=0;rto<rtoStop;rto++,rtg++,rta++,index++){
	  locations[rtg->resultSlot-min_op] = NULL;
    }
    
    locations_counter=0;
   
    for(rto=g_fscan->rtTriad.nativeOperations,rtg=g_fscan->rtTriad.gpu_operands,rta=g_fscan->rtTriad.nativeOperands,index=0;rto<rtoStop;rto++,rtg++,rta++,index++){
        if (locations[rtg->resultSlot-min_op] == NULL) {
	  locations_counter++;
	  // size_t total,freee;
    //cudaMemGetInfo(&freee,&total);
    //fprintf(stderr,"%zd,%zd\n",total,freee);	
	//fprintf(stderr,"%ld,%zd |",locations_counter,freee);
	    SAFE_CALL((cudaMalloc( (void**)&rtg->result, CubaBatch * sizeof(FLOAT)* COMPLEX_MULTIPLIER )));
	    //fprintf(stderr,"%ld\n",rtg->resultSlot-min_op);
	    locations[rtg->resultSlot-min_op] = rtg->result;	    
	}  else {
	 rtg->result =  locations[rtg->resultSlot-min_op];	  
	}
	//  fprintf(stderr,"[%ld,%ld]\n",locations_counter-min_op-1,rtg->resultSlot-min_op);
	
	rtg->firstOperand = locations[rtg->firstOperandSlot-min_op];
	rtg->secondOperand = locations[rtg->secondOperandSlot-min_op];
	
	
	first_operand_local[index]=    rtg->firstOperand;
	second_operand_local[index]=   rtg->secondOperand;
	second_operandI_local[index]=   rta->aIPN.secondOperand;
	result_local[index]=           rtg->result;
	//if (*rto==ROP_IPOW_P) operation_local[index]=100+rta->aIPN.secondOperand; else
	operation_local[index]=*rto;
	// inverting order. x goes to... max_op+1
	//if (*rto==ROP_IPOW_P) printf("%ld\n",rta->aIPN.secondOperand);
	rtg->resultSlot = *rto;   //reusing for operation
	//     cudaMemGetInfo(&freee,&total);
  //  printf("!!!%zd,%zd, %zd,  %d\n",total,freee,freee-prev,index);
	//printf("First: %ld, second: %ld, result: %ld\n",rtg->firstOperandSlot-min_op,rtg->secondOperandSlot-min_op,rtg->resultSlot-min_op);
	//printf("First: %p, second: %p, result: %p\n",rtg->firstOperand,rtg->secondOperand,rtg->result);
 //   prev=freee;
    }
    // now all GPU memory pointers are correct.
   locations_counter=locations_counter;
  //  fprintf(stderr,"%ld, %ld\n",g_fscan->rtTriad.length,locations_counter);
    
    
   //  cudaMemGetInfo(&freee,&total);
    //printf("!!!%zd,%zd\n",total,freee);	
    
    
    SAFE_CALL((cudaMalloc( (void**)&first_operand_gpu, sizeof(FLOAT*)*g_fscan->rtTriad.length)));
    SAFE_CALL((cudaMemcpy(first_operand_gpu,first_operand_local,sizeof(FLOAT*)*g_fscan->rtTriad.length,cudaMemcpyHostToDevice)));
    
    SAFE_CALL((cudaMalloc( (void**)&second_operand_gpu, sizeof(FLOAT*)*g_fscan->rtTriad.length)));
    SAFE_CALL((cudaMemcpy(second_operand_gpu,second_operand_local,sizeof(FLOAT*)*g_fscan->rtTriad.length,cudaMemcpyHostToDevice)));
    
    SAFE_CALL((cudaMalloc( (void**)&second_operandI_gpu, sizeof(SC_INT)*g_fscan->rtTriad.length)));
    SAFE_CALL((cudaMemcpy(second_operandI_gpu,second_operandI_local,sizeof(SC_INT)*g_fscan->rtTriad.length,cudaMemcpyHostToDevice)));    
    
    SAFE_CALL((cudaMalloc( (void**)&result_gpu, sizeof(FLOAT*)*g_fscan->rtTriad.length)));
    SAFE_CALL((cudaMemcpy(result_gpu,result_local,sizeof(FLOAT*)*g_fscan->rtTriad.length,cudaMemcpyHostToDevice)));
    
    SAFE_CALL((cudaMalloc( (void**)&operation_gpu, sizeof(char)*g_fscan->rtTriad.length)));
    SAFE_CALL((cudaMemcpy(operation_gpu,operation_local,sizeof(char)*g_fscan->rtTriad.length,cudaMemcpyHostToDevice)));
    
   free(first_operand_local);
   free(second_operand_local);
   free(second_operandI_local);
   free(result_local);
   free(operation_local);
  } 
  else this_core_uses_gpu = 0; 

#endif    
    //printf("core %d uses %d\n",cuba_thread_number,this_core_uses_gpu);
    return NULL;
}

void* exit_Cuda(void* param) {
     //printf("Cuba number: %d, native: %d, MPFR: %d\n",cuba_thread_number,statistics[2*cuba_thread_number+0],statistics[2*cuba_thread_number+1]);     
#ifdef GPU
if (this_core_uses_gpu) {  // that is the main process that also works    
    
    int j;
    
    for(j=0;j!=locations_counter;++j){
	SAFE_CALL((cudaFree(locations[j-min_op])));	 
    }
    



    SAFE_CALL((cudaFree(g_fscan->nativeXGPU)));
    
    
    
    

    for(j=0;j!=g_fscan->fNativeLine->fill;++j) {
       if (locations[-j - (g_fscan->nx + g_fscan->nf+1) - min_op]!=NULL) {
	SAFE_CALL((cudaFree(locations[-j - (g_fscan->nx + g_fscan->nf+1) - min_op])));
	locations[-j - (g_fscan->nx + g_fscan->nf+1) - min_op]=NULL;
       }
    }
   
    free(locations);
    
    SAFE_CALL((cudaFree(first_operand_gpu)));
    SAFE_CALL((cudaFree(second_operand_gpu)));
    SAFE_CALL((cudaFree(second_operandI_gpu)));
    SAFE_CALL((cudaFree(result_gpu)));
    SAFE_CALL((cudaFree(operation_gpu)));
    
    

    
    SAFE_CALL((cudaEventDestroy(cuda_start)));
    SAFE_CALL((cudaEventDestroy(cuda_stop)));
    
        
 //   size_t total,freee;
  //  cudaMemGetInfo(&freee,&total);
  //  fprintf(stderr,"%zd,%zd\n",total,freee);	

}    
#endif    

    destroyScanner(g_fscan);    
    return NULL;
}


void init_cores() {
    GPUBatch=(CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm);
    if (GPUCores==0) GPUBatch=0;
    CPUBatch=128;
    if (CPUCores==0) CPUBatch=0;
    
    if (GPUBatch>CPUBatch) CubaBatch=GPUBatch; else CubaBatch = CPUBatch;

    
    //fprintf(stderr,"%d,%d,%d,%d,%d,%d\n",(int)getpid(),GPUCores,CPUCores,CPUBatch,CubaBatch,((GPUBatch*GPUCores) + (CPUBatch*CPUCores)));
   
    cubacores(CPUCores, CPUBatch);
    cubaaccel(GPUCores, GPUBatch);
    cubainit((void*) init_Cuda,&new_core_number);
    cubaexit((void*) exit_Cuda,&new_core_number);

    
    
    
    FILE *f = fopen(SHMMAX_SYS_FILE, "r");

    if (!f) {
        fprintf(stderr, "Failed to open file: `%s'\n", SHMMAX_SYS_FILE);
        assert(0);
    }

    if (fscanf(f, "%lu", &SHMMAX) != 1) {
        fprintf(stderr, "Failed to read shmmax from file: `%s'\n", SHMMAX_SYS_FILE);
        fclose(f);
        assert(0);
    }

    fclose(f);

    if (SHMMAX>pow(2,25)) SHMMAX = pow(2,25);

    //printf("shmmax: %u\n", SHMMAX);
    
    shmalloc_(sizeof(size_t)+(2*(GPUCores+CPUCores+1)+MAX_BUFFERS+1)*sizeof(int)+5*(GPUCores+CPUCores+1)*sizeof(float), &shared_mem);
    
    size_of_string_transfered = ((size_t*) shared_mem.addr);
      
    number_of_buffers_used=((int*) (size_of_string_transfered+1));
    
    buffer_shared_id_address=number_of_buffers_used+1;
    
    int i;
    for (i=0;i!=MAX_BUFFERS;++i) buffer_shared_id_address[i]=0;
    
    statistics = buffer_shared_id_address+MAX_BUFFERS;
    
    for (i=0;i!=(GPUCores+CPUCores+1);++i) {
	statistics[2*i+0]=0;  //native points
	statistics[2*i+1]=0; //mpfr points
    }    
    cuda_statistics = (float*)(statistics+(2*(GPUCores+CPUCores+1)));
    for (i=0;i!=(GPUCores+CPUCores+1);++i) {
      cuda_statistics[5*i+0]=0.;
      cuda_statistics[5*i+1]=0.;
      cuda_statistics[5*i+2]=0.;
      cuda_statistics[5*i+3]=0.;
      cuda_statistics[5*i+4]=0.;
    }
    
    total_statistics[0]=0;
    total_statistics[1]=0;
    total_cuda_statistics[0]=0.;
    total_cuda_statistics[1]=0.;
    total_cuda_statistics[2]=0.;
    total_cuda_statistics[3]=0.;
    total_cuda_statistics[4]=0.;
    total_cuda_statistics[5]=0.;
    
   userdata[0]=testF;  //passing whether is is a simple F test, not integration
   userdata[1]=debug;
   userdata[2]=int_mode;
   
   cubafork(&CubaSpin);
}    


void exit_cores() {
    cubawait(&CubaSpin);
    shmfree_(&shared_mem);
}

void restart_cores() {
    exit_cores();
    init_cores();
}
  
int integral_dimension;

void Integrate(char* s, int only_parse) { // true or false
     result_t results;

     GPUBatch=(CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm);
    if (GPUCores==0) GPUBatch=0;
    CPUBatch=128;
    if (CPUCores==0) CPUBatch=0;
    
    if (GPUBatch>CPUBatch) CubaBatch=GPUBatch; else CubaBatch = CPUBatch;
     
     initIntegrators();/*fixme: check the returned code!*/
    
   if ((only_parse) || (GPUCores+CPUCores==1)) {
       if(doAddString(s)){
	  return;
      }

      g_fscan=newScannerMultiStr(&ml);

      if(g_fscan==NULL){
	  return;
      }

      if(masterScan(g_fscan)){
	  return;
      }
      
      if (only_parse) {
	destroyScanner(g_fscan);
	printf("{0,0,0,0}\n");
	return;
      }
   }
   
   

  //printf("%ld,%ld\n",(long int) (strlen(s)+1),SHMMAX);
  
 
  
  shminfo buffer[MAX_BUFFERS];     
if (GPUCores+CPUCores!=1) {  // no need to pass for one thread
    pthread_mutex_lock(&mutex);
  // creating shared buffers
  

    
  *size_of_string_transfered = strlen(s)+1;
  *number_of_buffers_used = 0;
//  printf("!\n");
//  printf("%ld\n",SHMMAX);
  
  while (SHMMAX*(*number_of_buffers_used) < *size_of_string_transfered) {
    assert((*number_of_buffers_used)!=MAX_BUFFERS);
//    printf("%d\n",(int)(*size_of_string_transfered-SHMMAX*(*number_of_buffers_used)));
    
    if (SHMMAX*((*number_of_buffers_used)+1) < *size_of_string_transfered)
      buffer[*number_of_buffers_used].id = shmget(IPC_PRIVATE, SHMMAX, IPC_CREAT | 0600);  // new shared memory slot for the string buffer
    else
      buffer[*number_of_buffers_used].id = shmget(IPC_PRIVATE, *size_of_string_transfered-SHMMAX*(*number_of_buffers_used), IPC_CREAT | 0600);  
    
    if (buffer[*number_of_buffers_used].id==-1) {
	printf("shmget error %d\n",errno);
	if (errno==EINVAL) printf("EINVAL\n");
	if (errno==EEXIST) printf("EEXIST\n");
	if (errno==ENOSPC) printf("ENOSPC\n");
	if (errno==ENOENT) printf("ENOENT\n");
	if (errno==EACCES) printf("EACCES\n");
	if (errno==ENOMEM) printf("ENOMEM\n");
	if (errno==ENOSPC) printf("ENOSPC\n");      
    }
    assert(buffer[*number_of_buffers_used].id != -1);
    buffer_shared_id_address[*number_of_buffers_used] = buffer[*number_of_buffers_used].id; // writing the id into the preallocated shared memory
    buffer[*number_of_buffers_used].addr = shmat(buffer[*number_of_buffers_used].id, NULL, 0);
  
    assert(buffer[*number_of_buffers_used].addr != (void *)-1);
    
    if (SHMMAX*((*number_of_buffers_used)+1) < *size_of_string_transfered)
	strncpy(buffer[*number_of_buffers_used].addr,s+SHMMAX*(*number_of_buffers_used),SHMMAX);
    else
	strncpy(buffer[*number_of_buffers_used].addr,s+SHMMAX*(*number_of_buffers_used),*size_of_string_transfered-SHMMAX*(*number_of_buffers_used));
    
    (*number_of_buffers_used)++;
  }
    
  // creating shared buffers end
  
  
  pthread_mutex_unlock(&mutex);
  
} //if (GPUCores+CPUCores!=1)   
    
   struct timeval tv;   // see gettimeofday(2)
   gettimeofday(&tv, NULL); 
   double time_start = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
 
   integral_dimension = atoi(s);
   //fprintf(stderr,"%d\n",integral_dimension);
   {
   int i;
    for (i=0;i!=(GPUCores+CPUCores+1);++i) {
	statistics[2*i+0]=0;  //native points
	statistics[2*i+1]=0; //mpfr points
    }    
    cuda_statistics = (float*)(statistics+(2*(GPUCores+CPUCores+1)));
    for (i=0;i!=(GPUCores+CPUCores+1);++i) {
      cuda_statistics[5*i+0]=0.;
      cuda_statistics[5*i+1]=0.;
      cuda_statistics[5*i+2]=0.;
      cuda_statistics[5*i+3]=0.;
      cuda_statistics[5*i+4]=0.;
    }
   }
   
   //int success = 
   g_integratorArray[g_currentIntegrator](&results,userdata);  //main integration
   //if (!success) {results.s1=nan("");results.s2=nan("");results.s3=nan("");results.s4=nan("");}
   
   gettimeofday(&tv, NULL);
   double time_stop = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec; 
   
 
if (GPUCores+CPUCores!=1) {   
   //detaching from shared buffers
   //fprintf(stderr,"Detaching\n");
   while ((*number_of_buffers_used)>0) {
      (*number_of_buffers_used)--;
     
      if (shmdt(buffer[*number_of_buffers_used].addr) == -1) {
        fprintf(stderr, "shmdt failed Integrate %d %d \n", errno, EINVAL);
        exit(EXIT_FAILURE);
      }
     
      int er=shmctl(buffer[*number_of_buffers_used].id, IPC_RMID, NULL);
      if (er==-1) {
	printf("smctl error %d\n",errno); 
	assert(er!=-1);
      }
      
      
   }
   //detaching from shared buffers end
  
} //if (GPUCores+CPUCores!=1)  
  
#ifndef COMPLEX   
   printf("{%.15lf,%.15lf,%.15lf,%.15lf}\n",results.s1,results.s2,0.0,0.0);    
#else
   printf("{%.15lf,%.15lf,%.15lf,%.15lf}\n",results.s1,results.s2,results.s3,results.s4);   
#endif
    
    total_statistics[0]=0;
    total_statistics[1]=0;
    total_cuda_statistics[0]=0.;
    total_cuda_statistics[1]=0.;
    total_cuda_statistics[2]=0.;
    total_cuda_statistics[3]=0.;
  //  total_cuda_statistics[4]=0.;
    total_cuda_statistics[5]=0.;
   
    int i;
    for (i=0;i!=(GPUCores+CPUCores+1);++i) {
	total_statistics[0]+=statistics[2*i+0];  //native points
	total_statistics[1]+=statistics[2*i+1]; //mpfr points
	total_cuda_statistics[0]+=cuda_statistics[5*i+0];
	total_cuda_statistics[1]+=cuda_statistics[5*i+1];     
	total_cuda_statistics[2]+=cuda_statistics[5*i+2];
	total_cuda_statistics[3]+=cuda_statistics[5*i+3];
	total_cuda_statistics[5]+=cuda_statistics[5*i+4];  
    }
     total_cuda_statistics[4]+=(time_stop-time_start);



}/*Integrate*/



char* ugets(char* input_buffer,unsigned int *size, char separator)
{
    char* buffer;
    if (input_buffer==NULL) {
	buffer = (char*)malloc(*size);
    } else {
	buffer = input_buffer;
    }
 
    if(buffer != NULL) /* NULL if malloc() fails */
    {
        char ch = EOF;
        int pos = 0;
 
        /* Read input one character at a time, resizing the buffer as necessary */
        while((ch = getchar()) != EOF && ch != separator)
        {
            buffer[pos++] = ch;
            if(pos == *size) /* Next character to be inserted needs more memory */
            {
                *size = *size*2;
                buffer = (char*)realloc(buffer, *size);
		if (buffer==NULL) break;
            }
        }
        //if (separator=='|') buffer[pos-1]='\0';
        buffer[pos] = '\0'; /* Null-terminate the completed string */
    }
    return buffer;
}


/*
 * At start the number GPUCores is set to the real number of GPU cores
 * CPUCores is set to 1 if there are no GPU cores or 0 otherwise
 * GPUCores can be changed by the GPUCores setting
 * CPUCores can be changed by the CPUCores setting
 * If the total number of cores is 1, we use master
 * if it is GPU, te used core will be 0 by default, or any other if set with GPUForceCore
 * used_core
 * */


int main(int argc, char *argv[])
{
  
  //printf("%d\n",(int)(2048*(8. + 1)/12.));
  //return -1;
  if (argc>0) {
   if (!freopen(argv[1], "r", stdin)) {
     printf("Input file could not be opened");
     return 1;
   }
  }
  
    char* buffer=NULL;
    unsigned int size=10;

    pthread_mutexattr_setpshared(&mutexAttr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&mutex, &mutexAttr);
    

#ifdef GPU  
   shminfo shared_mem;    
   shmalloc_(3* sizeof(SC_INT), &shared_mem);
    
  
 
   SC_INT* device_count_shared=((SC_INT*) shared_mem.addr);
   SC_INT* device_memory_shared=((SC_INT*) shared_mem.addr)+1;
   SC_INT* sm_number_shared=((SC_INT*) shared_mem.addr)+2;
   GPUCores=-1;
  int process = fork();
  if (process==0) { // child
      int temp;
      cudaGetDeviceCount(&temp);
      *device_count_shared=temp;
      struct cudaDeviceProp devProp;
      cudaGetDeviceProperties ( &devProp, 0);
      *device_memory_shared = devProp.totalGlobalMem;
      *sm_number_shared=devProp.multiProcessorCount;  
      size_t Mfree,Mtotal;
      cudaMemGetInfo(&Mfree,&Mtotal);
      *device_memory_shared = Mfree;
      //fprintf(stderr,"%zu,%zu,%zu\n",Mfree,Mtotal,memory_limit);
      return 0;
  } else {
      int status;
      waitpid(process,&status,0);     
      GPUCores = *device_count_shared;
      //if ((GPUCores <=0) || (process%2==1)) {
      if ((GPUCores <=0) || (GPUCores >= 32000)) { // error codes
	fprintf(stderr,"No Cuda enabled devices (main) !\n");
	 printf("Error!\n");
	return 1;
	//GPUCores = 0;
	//RealGPUCores =0;
      } else {	
	 cuda_sm = *sm_number_shared;
	 memory_limit = *device_memory_shared;
	 //fprintf(stderr,"%zu\n",memory_limit);
	 
	 
	 RealGPUCores = GPUCores;
      }
  }

  shmfree_(&shared_mem);
#else  
  GPUCores = 0;
#endif
  
  
  
  if (GPUCores>0) CPUCores=0; else CPUCores=1;
  
  
  
  init_cores();   // rerun it upon reading core settings!

  
  while (1) {
	fflush(stdout);
	buffer=ugets(buffer,&size,'\n');
	//printf("%s\n",buffer);
	if (buffer==NULL) {
	    printf("Buffer allocation error for size %d\n",size);
	    return 1;
	}
	if ((!strcmp(buffer,"exit")) || (!strcmp(buffer,"Exit")) || (!strcmp(buffer,"quit")) || (!strcmp(buffer,"Quit"))) {
	    break;
	} else if ((buffer[0]=='/') && (buffer[1]=='/')) {
	  //buffer=ugets(buffer,&size,'\n');
	  continue;	  
	} else if ((!strcmp(buffer,"ClearStatistics"))) {
	  total_statistics[0]=0;
	  total_statistics[1]=0;
	  total_cuda_statistics[0]=0.;
	  total_cuda_statistics[1]=0.;
	  total_cuda_statistics[2]=0.;
	  total_cuda_statistics[3]=0.;
	  total_cuda_statistics[4]=0.;
	  total_cuda_statistics[5]=0.;
	} else if ((!strcmp(buffer,"Statistics"))) {
	  printf("Native points: %d, MPFR points: %d",total_statistics[0],total_statistics[1]);
#ifdef GPU
	  printf(", cuda copy time: %f, cuda total time: %f",total_cuda_statistics[0],total_cuda_statistics[1]);
#else
	  printf(", runlineNative time, %f",total_cuda_statistics[3]);
#endif
	  printf(", MPFR time: %f",total_cuda_statistics[5]);
	  
	  printf(", runexpr time: %f",total_cuda_statistics[2]);
	  
	  printf(", call time: %f",total_cuda_statistics[4]);
	  printf("\n");
	  fflush(stdout);
	} else if (!strcmp(buffer,"Integrate")) {
	    buffer=ugets(buffer,&size,'|');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    Integrate(buffer,0);
	    getchar();//final \n
	} else if (!strcmp(buffer,"Parse")) {
	    buffer=ugets(buffer,&size,'|');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    Integrate(buffer,1);
	    getchar();//final \n
	} else if (!strcmp(buffer,"GPUCores")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    if (!sscanf(buffer,"%d",&GPUCores)) {
	       printf("Wrong input for GPUCores\n");
	       return 1;
	    }  
	    restart_cores();
	    printf("Ok\n");
	}  else if (!strcmp(buffer,"CPUCores")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    if (!sscanf(buffer,"%d",&CPUCores)) {
	       printf("Wrong input for CPUCores\n");
	       return 1;
	    }  
	    restart_cores();
	    printf("Ok\n");
	}  else if (!strcmp(buffer,"GPUForceCore")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    if (!sscanf(buffer,"%d",&TheSingleGPUNumber)) {
	       printf("Wrong input for GPUForceCore\n");
	       return 1;
	    }  
	    restart_cores();
	    printf("Ok\n");	    
	} else if (!strcmp(buffer,"GPUMemoryPart")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    if (!sscanf(buffer,"%d",&GPUMemoryPart)) {
	       printf("Wrong input for GPUMemoryPart\n");
	       return 1;
	    }  
	    restart_cores();
	    printf("Ok\n");	    
	}
	
	/*else if (!strcmp(buffer,"CubaBatch")) {
	  if (!scanf("%d",&CubaBatch)) {
	     printf("Wrong input for CubaBatch\n");
	     CubaBatch = 96;
	     return 1;
	     if ((CubaBatch<=0) || (CubaBatch%4 !=0)) {
		printf("Improper CubaBatch value\n");
		CubaBatch = 96;
		return 1;	     
	     }
	  }
	  restart_cores();
	  printf("Ok\n");
	} */else if (!strcmp(buffer,"SetMath")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    if (math_binary!=NULL) free(math_binary);
	    if (strlen(buffer)==0) {
		math_binary=NULL;
	    } else {
		math_binary=(char *) malloc(strlen(buffer));
		strcpy(math_binary,buffer);
	    }	
	    restart_cores();
	    printf("Ok\n");
	} else if (!strcmp(buffer,"SetIntegrator")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    setIntegrator(buffer);	    
	} else if (!strcmp(buffer,"SetCurrentIntegratorParameter")) {
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    char res[200];
	    strncpy(res,buffer,200);
	    buffer=ugets(buffer,&size,'\n');
	    if (buffer==NULL) {
		printf("Buffer allocation error for size %d\n",size);
		return 1;
	    }
	    setCurrentIntegratorParameter(res,buffer);	    
	} else if (!strcmp(buffer,"GetCurrentIntegratorParameters")) {
	    getCurrentIntegratorParameters();	    
	} else if (!strcmp(buffer,"SetMPPrecision")) {
	  int n;
	  if (!scanf("%d",&n)) {
	     printf("Wrong input for SetMPPrecision\n");
	     return 1;
	  }
	  if (!setDefaultPrecision(n)) {
	      restart_cores();
	    printf("Ok\n");
	  }
	} else if (!strcmp(buffer,"SetMPPrecisionShift")) {
	  int n;
	  if (!scanf("%d",&n)) {
	     printf("Wrong input for SetMPPrecisionShift\n");
	     return 1;
	  }
	  if (!setMPPrecisionShift(n)) {
	      restart_cores();
	    printf("Ok\n");
	  }
	} else if (!strcmp(buffer,"SetSmallX")) {
	  float n;
	  if (!scanf("%f",&n)) {
	     printf("Wrong input for SetSmallX\n");
	     return 1;
	  }
	  //printf("Ok?\n");
	  if (!setMPSmallX(n)) {
	     restart_cores();
	    printf("Ok\n");
	     fflush(stdout);
	  }
	} else if (!strcmp(buffer,"SetMPThreshold")) {
	  float n;
	  if (!scanf("%f",&n)) {
	     printf("Wrong input for SetMPThreshold\n");
	     return 1;
	  }
	  //printf("Ok?\n");
	  if (!setMPthreshold(n)) {
	     restart_cores();
	    printf("Ok\n");
	     fflush(stdout);
	  }
	} else if (!strcmp(buffer,"SetMPMin")) {
	  float n;
	  if (!scanf("%f",&n)) {
	     restart_cores();
	    printf("Wrong input for SetMPMin\n");
	     return 1;
	  }
	  //printf("Ok?\n");
	  if (!setMPmin(n)) {
	    restart_cores();
	     printf("Ok\n");
	     fflush(stdout);
	  }
	}else if ((!strcmp(buffer,"help")) || (!strcmp(buffer,"Help")) || (!strcmp(buffer,"?"))) {
	  printf("Possible commands: Quit, Integrate, Parse, SetMath, SetSmallX, SetMPPrecision, SetMPPrecisionShift, SetMPThreshold, SetMPMin, SetIntegrator, GetCurrentIntegratorParameters, GetCurrentIntegratorParameter, TestF, CPUCores, GPUCores, Debug, MPFR, Native, Mixed, Statistics, GPUData, GPUForceCore, GPUMemoryPart, ClearStatistics\n");
	  fflush(stdout);	  
	}else if (!strcmp(buffer,"TestF")) {
	  testF=1;
	  restart_cores();
	    printf("OK\n");
	  fflush(stdout);	  
	}else if (!strcmp(buffer,"Debug")) {
	  debug=1;
	  restart_cores();
	    printf("OK\n");
	  fflush(stdout);	  
	}else if (!strcmp(buffer,"MPFR")) {
	  int_mode=1;
	  restart_cores();
	    printf("OK\n");
	  fflush(stdout);	  
	} else if (!strcmp(buffer,"Native")) {
	  int_mode=2;
	  restart_cores();
	    printf("OK\n");
	  fflush(stdout);	  
	} else if (!strcmp(buffer,"Mixed")) {
	  int_mode=0;
	  restart_cores();
	    printf("OK\n");
	  fflush(stdout);	  
	} else if (!strcmp(buffer,"GPUData")) {
#ifdef GPU	  
	int deviceCount = -1;
        cudaGetDeviceCount( &deviceCount );
#ifdef __cplusplus
	cudaDeviceProp devProp;
#else 
	struct cudaDeviceProp devProp;
#endif	
	fprintf(stderr,"Found %d devices\n", deviceCount);
	//выводим параметры каждого устройства
	int device;
	for (device = 0; device < deviceCount; device++)
	{
        //получение параметров устройств
        cudaGetDeviceProperties ( &devProp, device);
        fprintf(stderr,"Device number %d\n", device);
        fprintf(stderr,"Compute compatibility : %d.%d\n", devProp.major, devProp.minor);
        fprintf(stderr,"Device name : %s\n", devProp.name);
        fprintf(stderr,"Global memory size : %zu\n", devProp.totalGlobalMem);
        fprintf(stderr,"Memory bus width : %d\n", devProp.memoryBusWidth);
        fprintf(stderr,"Memory clock rate : %d\n", devProp.memoryClockRate);
        fprintf(stderr,"Number of multiprocessors : %d\n", devProp.multiProcessorCount);
	fprintf(stderr,"Maximal number of threeds per multiprocessor : %d\n", devProp.maxThreadsPerMultiProcessor);
        fprintf(stderr,"Clock rate of CUDA cores : %d\n", devProp.clockRate);
        fprintf(stderr,"L2 cache size : %d\n", devProp.l2CacheSize);
        fprintf(stderr,"Shared memory per block : %zu\n", devProp.sharedMemPerBlock);
        fprintf(stderr,"Registers per block : %d\n", devProp.regsPerBlock);
        fprintf(stderr,"Warp size : %d\n", devProp.warpSize);
        fprintf(stderr,"Maximal number of threads per block : %d\n", devProp.maxThreadsPerBlock);
        fprintf(stderr,"Constant memory size: %zu\n", devProp.totalConstMem);
        fprintf(stderr,"Texture alignment : %zu\n", devProp.textureAlignment);
        fprintf(stderr,"Device overlap possibility : %d\n", devProp.deviceOverlap);
        fprintf(stderr,"Memory mapping possibility : %d\n", devProp.canMapHostMemory);
        fprintf(stderr,"Unified addressing possibility : %d\n", devProp.unifiedAddressing);
        fprintf(stderr,"Maximal thread dimension : %d %d %d\n", devProp.maxThreadsDim[0], devProp.maxThreadsDim[1], devProp.maxThreadsDim[2]);
        fprintf(stderr,"Maximal grid dimension : %d %d %d\n", devProp.maxGridSize[0],devProp.maxGridSize[1], devProp.maxGridSize[2]);
        fprintf(stderr,"Concurent kernels possibility : %d\n", devProp.concurrentKernels);
        fprintf(stderr,"PCI bus ID : %d\n", devProp.pciBusID);
        fprintf(stderr,"PCI device ID : %d\n", devProp.pciDeviceID);
	}
#endif 
	  printf("OK\n");
	  fflush(stdout);	  
	}
	else if (strcmp(buffer,"")) {
	    printf("$Error - Undefined command: %s\n",buffer);
	}
    }
  //  printf("Statistics: %d\n",statistics[0]);

    exit_cores(); 
  
    return 0;
}/*main*/
