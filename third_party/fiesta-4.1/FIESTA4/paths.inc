############# CUBA related paths and settings begin: ####################
#Set this two varables to full paths to "cuba.h" and to the CUBA library
#file. If you have CUBA installed in your system, leave this variables empty:
CUBAINCLUDEDIR = -I../usr/include/
CUBALIBDIR = -L../usr/lib/ -L../usr/lib64/
############# CUBA related paths and settings end. ####################

############# Kyotocabinet related paths and settings begin: ####################
#Set this two varables to full paths to "kclangc.h" and to the KyotoCabinet library
#file. If you have Kyotocabinet installed in your system, leave this variables empty:
KYOTOINCLUDEDIR = -I../usr/include/
KYOTOLIBDIR =  -L../usr/lib/ -L../usr/lib64/
############# Kyotocabinet related paths and settings end. ####################

############# MPFR related paths and settings begin: ####################
#Set this two varables to full paths to "cuba.h" and to the mpfr library
#file. If you have mpfr installed in your system, leave this variables empty:
# The following path is the default Mac OS X installation folder with finc
# It won't hurt anyway
# MPFRINCLUDEDIR = -I/sw/include
# MPFRLIBDIR = -L/sw/lib
MPFRINCLUDEDIR =
MPFRLIBDIR =
# ATTENTION! Here we assume that the GMP library is installed on the system.
# If you have non-standard GMP installation, add the paths to gmp as well here
############# MPFR related paths and settings end. ####################

############# CUDA related paths and settings begin: ####################
#Set this three varables to full paths to "cuda_runtime.h", to the CUDA library
#file and to nvcc. If you have CUDA installed in your system, leave this variables empty:
# CUDAINCLUDEDIR = -I/usr/local/cuda/include
# CUDALIBDIR     = -L/usr/local/cuda/lib64
# CUDABINDIR     = /usr/local/cuda/bin/
CUDAINCLUDEDIR =
CUDALIBDIR =
CUDABINDIR =
############# CUDA related paths and settings end. ####################
