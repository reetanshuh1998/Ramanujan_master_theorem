#ifndef KERNEL_H
#define KERNEL_H 1

#include "comdef.h"



//actual runtime
FLOAT** first_operand_gpu;
FLOAT** second_operand_gpu;
FLOAT** result_gpu;
SC_INT* second_operandI_gpu;
char* operation_gpu;
// in complex mode they are stored im after the banch of x

int this_core_uses_gpu;







#define SAFE_CALL( CallInstruction ) { \
    cudaError_t cuerr = CallInstruction; \
    if(cuerr != cudaSuccess) { \
         printf("CUDA error: %s at call \"" #CallInstruction "\"\n", cudaGetErrorString(cuerr)); \
         exit(0); \
    } \
}


#define SAFE_KERNEL_CALL( KernelCallInstruction ){ \
    cudaError_t cuerr;\
    cuerr = cudaDeviceSynchronize(); \
    if(cuerr != cudaSuccess) { \
        printf("CUDA error in kernel execution: %s at kernel \"" #KernelCallInstruction "\"\n", cudaGetErrorString(cuerr)); \
        exit(0); \
    } \
    KernelCallInstruction; \
    cuerr = cudaGetLastError(); \
    if(cuerr != cudaSuccess) { \
        printf("CUDA error in kernel launch: %s at kernel \"" #KernelCallInstruction "\"\n", cudaGetErrorString(cuerr)); \
        exit(0); \
    } \
    cuerr = cudaDeviceSynchronize(); \
    if(cuerr != cudaSuccess) { \
        printf("CUDA error in kernel execution: %s at kernel \"" #KernelCallInstruction "\"\n", cudaGetErrorString(cuerr)); \
        exit(0); \
    } \
}

#ifdef GPU    


#define MEASURE_GPU_TIME(Function,number) {\
	  cudaEventRecord(cuda_start,0); \
	  Function; \
	  cudaEventRecord(cuda_stop,0); \
	  cudaEventSynchronize(cuda_stop);\
	  float temp;\
	  cudaEventElapsedTime(&temp,cuda_start,cuda_stop);\
	  cuda_statistics[5*(cuba_thread_number + GPUCores) + number]+=(temp/1000);}


/*
#define MEASURE_GPU_TIME(Function,number) {\
	  struct timeval tv;\
	  gettimeofday(&tv, NULL);\
	  double time_start = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec;\
	  Function;\
	  gettimeofday(&tv, NULL);\
	  double time_stop = (double) tv.tv_sec + (double) 1e-6 * tv.tv_usec;\
	  cuda_statistics[5*cuba_thread_number + number]+=(time_stop-time_start);}	  
*/
	  
//#define MEASURE_GPU_TIME(Function,number) {Function;}	  

#endif    


#ifdef __cplusplus
extern "C" {
#endif

void runlineNativeGPU(int local_bunch,SC_INT length);




#ifdef __cplusplus
}
#endif




#endif