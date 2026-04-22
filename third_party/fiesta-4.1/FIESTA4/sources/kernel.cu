#include "kernel.h"

#define IF_VALID_THREAD int tid = blockIdx.x * blockDim.x + threadIdx.x; if (tid<N) 



#ifndef COMPLEX

#define NP_PLUS_NEW(are,aim,bre,bim,cre,cim) are=bre+cre
#define NP_MUL_NEW(are,aim,bre,bim,cre,cim) are=bre*cre
#define NP_MINUS_NEW(are,aim,bre,bim,cre,cim) are=bre-cre
#define NP_DIV_NEW(are,aim,bre,bim,cre,cim) are=bre/cre
#define NP_IPOW_NEW(are,aim,bre,bim,deg) {FLOAT x=bre;FLOAT z;\
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
are=u;}
#define NP_POW2_NEW(are,aim,bre,bim) (are) = (bre)*(bre)
#define NP_POW3_NEW(are,aim,bre,bim) (are) = (bre)*(bre)*(bre)
#define NP_POW4_NEW(are,aim,bre,bim) {FLOAT temp; (temp)=(bre)*(bre);(are)=(temp)*(temp);}
#define NP_POW5_NEW(are,aim,bre,bim) {FLOAT temp; (temp)=(bre)*(bre);(are)=(temp)*(temp)*(bre);}
#define NP_POW6_NEW(are,aim,bre,bim) {FLOAT temp; (temp)=(bre)*(bre);(are)=(temp)*(temp)*(temp);}
#define NP_CPY_NEW(are,aim,bre,bim) (are) = (bre)
#define NP_NEG_NEW(are,aim,bre,bim) (are) = -(bre)
#define NP_INV_NEW(are,aim,bre,bim) (are) = 1.0 / (bre)
#define NP_LOG_NEW(are,aim,bre,bim) if((bre) <= 1.0E-100 ) (are) = -230.258509299405; else (are) = log(bre);          
#define NP_POW_NEW(are,aim,bre,bim,cre,cim) (are) = pow((bre),(cre))

#else

#define NP_PLUS_NEW(are,aim,bre,bim,cre,cim) are=bre+cre;aim=bim+cim;
#define NP_MINUS_NEW(are,aim,bre,bim,cre,cim) are=bre-cre;aim=bim-cim;
#define NP_MUL_NEW(are,aim,bre,bim,cre,cim) are=(bre*cre)-(bim*cim);aim=(bim*cre)+(bre*cim);
#define NP_DIV_NEW(are,aim,bre,bim,cre,cim) FLOAT denom = (cre*cre)+(cim*cim); are=((bre*cre)+(bim*cim))/denom;aim=((bim*cre)-(bre*cim))/denom;

#define NP_IPOW_NEW(are,aim,bre,bim,deg) int y=deg;; ;FLOAT temp;\
   if (y == 2) {are=(bre*bre)-(bim*bim);aim=2*(bre*bim);}\
   else {\
     if ( ( y & 1 ) != 0 ) {are=bre;aim=bim;} else {are=1.0L;aim=0.0L;}\
     y >>= 1;\
     while ( y ){\
       temp = bre*bre-bim*bim; bim = 2*bre*bim; bre = temp;\
       if ( ( y & 1 ) != 0 ) {temp = are*bre - aim*bim; aim = are*bim+aim*bre; are = temp;}\
       y >>= 1;\
     }\
   }\


#define NP_POW2_NEW(are,aim,bre,bim) are=(bre*bre)-(bim*bim);aim=2*(bim*bre);
#define NP_POW3_NEW(are,aim,bre,bim) are = bre * bre * bre - 3 * bre * bim * bim; aim = 3 * bim * bre * bre - bim * bim * bim;
#define NP_POW4_NEW(are,aim,bre,bim) {FLOAT tre=(bre*bre)-(bim*bim);FLOAT tim=2*(bim*bre); \
                                  are=(tre*tre)-(tim*tim);aim=2*(tre*tim);}
#define NP_POW5_NEW(are,aim,bre,bim) {NP_IPOW_NEW(are,aim,bre,bim,5)}

#define NP_POW6_NEW(are,aim,bre,bim) {FLOAT tre=(bre*bre)-(bim*bim);FLOAT tim=2*(bim*bre); \
                                  are=(tre*tre*tre)-(3*tre*tim*tim);aim=(3*tre*tre*tim)-(tim*tim*tim);}
#define NP_CPY_NEW(are,aim,bre,bim) (are) = (bre);(aim) = (bim)
#define NP_NEG_NEW(are,aim,bre,bim) (are) = -(bre);(aim) = -(bim)
#define NP_INV_NEW(are,aim,bre,bim) {FLOAT denom = bre * bre + bim * bim;  are = bre / denom; aim = - bim / denom;} 

#define NP_LOG_NEW(are,aim,bre,bim) ;;if((bre <= 1.0E-100) && (bre>=0) && (bim==0.0)) {are = -230.258509299405; aim = 0;} \
    else if ((bim==0.0) && (bre>0)) {are = log(bre); aim=0;} \
    else if ((bim==0.0) && (bre<0)) {are = log(-bre); aim=- M_PI;} \
    else if ((bim>0) && (bre <= bim) && (bre >= - bim)) {FLOAT denom = bre * bre + bim * bim; are = log(denom)/2; aim = M_PI/2 - atan(bre / bim);} \
    else if ((bim<0) && (bre <= - bim) && (bre >= bim)) {FLOAT denom = bre * bre + bim * bim; are = log(denom)/2; aim = - M_PI/2 - atan(bre / bim);} \
    else if (bre>0) {FLOAT denom = bre * bre + bim * bim; are = log(denom)/2; aim = atan(bim / bre);} \
    else if (bim>0) {FLOAT denom = bre * bre + bim * bim; are = log(denom)/2; aim = atan(bim / bre) + M_PI;} \
    else {FLOAT denom = bre * bre + bim * bim; are = log(denom)/2; aim = atan(bim / bre) - M_PI;}


#ifndef GPU
#define NP_POW_NEW(are,aim,bre,bim,cre,cim) {  printf("Complex power not supported!!!"); halt(-25,"Complex power");}
#else
#define NP_POW_NEW(are,aim,bre,bim,cre,cim) {are=1/(1-1.);}
#endif



#endif




__global__ void 
//__launch_bounds__( CUDA_BLOCK_SIZE, CUDA_MIN_BLOCKS)
EVALUATION_KERNEL(SC_INT length, int N, int CubaBatchLocal,FLOAT** first_operand_gpu_internal, FLOAT** second_operand_gpu_internal, SC_INT* second_operandI_gpu_internal,FLOAT** result_gpu_internal, char* operation_gpu_internal) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x; 
  FLOAT* ind_first;
  FLOAT* ind_second;
  FLOAT* ind_result;
  
  
FLOAT are,bre,cre;  

  
#ifndef COMPLEX
#define SET_OPERAND1 {bre=ind_first[tid];}
#define SET_OPERAND2 {cre=ind_second[tid];}
#else
FLOAT aim,bim,cim;  
#define SET_OPERAND1 {bre=ind_first[tid];bim=ind_first[tid+CubaBatchLocal];}
#define SET_OPERAND2 {cre=ind_second[tid];cim=ind_second[tid+CubaBatchLocal];}
#endif
  
  
  if (tid<N) {
      int i;
//#pragma unroll 2
      for(i=0;i!=length;++i) {
	      char op = operation_gpu_internal[i];	    
	      ind_first = first_operand_gpu_internal[i];	    
	      ind_result = result_gpu_internal[i];	      	  
	      SET_OPERAND1
	      
	      switch (op) {
		
		  case ROP_PLUS_P: {ind_second = second_operand_gpu_internal[i];SET_OPERAND2 NP_PLUS_NEW(are,aim,bre,bim,cre,cim); break;}
		  case ROP_MUL_P: {ind_second = second_operand_gpu_internal[i];SET_OPERAND2 NP_MUL_NEW(are,aim,bre,bim,cre,cim); break;}
		  case ROP_MINUS_P: {ind_second = second_operand_gpu_internal[i];SET_OPERAND2 NP_MINUS_NEW(are,aim,bre,bim,cre,cim); break;}
		  case ROP_DIV_P: {ind_second = second_operand_gpu_internal[i];SET_OPERAND2 NP_DIV_NEW(are,aim,bre,bim,cre,cim); break;}
		  case ROP_POW_P: {ind_second = second_operand_gpu_internal[i];SET_OPERAND2 NP_POW_NEW(are,aim,bre,bim,cre,cim); break;}
		  case ROP_IPOW2_P: {NP_POW2_NEW(are,aim,bre,bim); break;}
		  case ROP_IPOW3_P: {NP_POW3_NEW(are,aim,bre,bim); break;}
		  case ROP_IPOW4_P: {NP_POW4_NEW(are,aim,bre,bim); break;}
		  case ROP_IPOW5_P: {NP_POW5_NEW(are,aim,bre,bim); break;}
		  case ROP_IPOW6_P: {NP_POW6_NEW(are,aim,bre,bim); break;}
		  case ROP_IPOW_P: {NP_IPOW_NEW(are,aim,bre,bim,second_operandI_gpu_internal[i]); break;}
		  case ROP_CPY_P:  {NP_CPY_NEW(are,aim,bre,bim); break;}
		  case ROP_NEG_P:  {NP_NEG_NEW(are,aim,bre,bim); break;}
		  case ROP_INV_P:  {NP_INV_NEW(are,aim,bre,bim); break;}
		  case ROP_LOG_P:  {NP_LOG_NEW(are,aim,bre,bim); break;}
		   //default: case ROP_IPOW_P: {NP_IPOW(ind_result,ind_first,((int)op)-100,tid,CubaBatchLocal); break;}
	      }     
	      ind_result[tid]=are;
#ifdef COMPLEX
	      ind_result[tid+CubaBatchLocal]=aim;
#endif	     
   }//for
  }//if tid <N
}//kernel


void runlineNativeGPU(int local_bunch,SC_INT length) {
      SAFE_KERNEL_CALL(( EVALUATION_KERNEL<<<dim3((local_bunch-1)/CUDA_BLOCK_SIZE+1),dim3(CUDA_BLOCK_SIZE)>>>(length,local_bunch,CubaBatch,first_operand_gpu,second_operand_gpu,second_operandI_gpu,result_gpu,operation_gpu)));
      return;
}

