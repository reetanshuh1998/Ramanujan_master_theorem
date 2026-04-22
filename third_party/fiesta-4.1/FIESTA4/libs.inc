################################################################################
#                                                                              #
# Normally you do not have to edit this file.                                  #
# But if you have problems with linking FIESTA binaries then this is the place #
#                                                                              #
################################################################################

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
LFLAGS = 
LIBSSTART = 
LIBSEND = -lpthread -lstdc++ -lz -lm
else
LFLAGS = -march=native -Wl,-Bstatic
LIBSSTART = -Wl,-Bstatic
LIBSEND = -Wl,-Bdynamic -pthread -lstdc++ -lrt -lz -lm
endif

# if you have problems with linking, remove LFLAGS and LIBSSTART

# native uses ${LFLAGS} ${LIBSSTART} -lcuba ${LIBSEND}
# mpfr uses ${LFLAGS} -lmpfr -lgmp ${LIBSSTART} -lcuba ${LIBSEND}
# threads uses ${LFLAGS} ${LIBSSTART} -lkyotocabinet ${LIBSEND}
# mpi uses ${LIBSSTART} -lkyotocabinet ${LIBSEND} -WL,-Bdynamic -lc
# KLink uses ${LIBSSTART} -lkyotocabinet ${LIBSEND} -WL,-Bdynamic


################################################################################
# 
# in rare cases you might also need to edit CFLAGS

CFLAGS = -O3 -Wall -Wno-char-subscripts -Wno-misleading-indentation -Wno-format-overflow -fcommon

############# gcc related paths and settings ####################
CC=gcc
CCPLUS=g++
CCMPI=mpicxx
NVCC=nvcc
