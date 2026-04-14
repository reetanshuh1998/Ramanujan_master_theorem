################################################################################
#                                                                              #
# Normally you do not have to edit this file.                                  #
# But if you have problems with linking FIESTA binaries then this is the place #
#                                                                              #
################################################################################

LFLAGS = -static -static-libgcc
LIBSSTART = -Wl,-Bstatic 
LIBSEND = -pthread -lstdc++ -lrt -lz -lm

# native uses ${LFLAGS} ${LIBSSTART} -lcuba ${LIBSEND}
# mpfr uses ${LFLAGS} -lmpfr -lgmp ${LIBSSTART} -lcuba ${LIBSEND}
# threads uses ${LFLAGS} ${LIBSSTART} -lkyotocabinet ${LIBSEND}
# mpi uses ${LIBSSTART} -lkyotocabinet ${LIBSEND} -WL,-Bdynamic -lc
# KLink uses ${LIBSSTART} -lkyotocabinet ${LIBSEND} -WL,-Bdynamic

# mpi and KLink can't be compiled statically

################################################################################
# 
# in rare cases you might also need to edit CFLAGS

CFLAGS = -O3 -Werror -Wall -Wno-char-subscripts

############# gcc related paths and settings ####################
CC=gcc
CCPLUS=g++
CCMPI=mpic++
NVCC=nvcc