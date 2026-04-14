include ../paths.inc
include ../libs.inc
include ../sources/obj.inc

PRECISION = 64

vpath %.c ../sources
vpath %.h ../sources
vpath %.cu ../sources


CIntegrateMPG : $(OBJ) kernel.o
	if [ -f ${CUDALIBDIR:-L%=%}/libcudart_static.a ]; then $(CC) $(OBJ) kernel.o ${LFLAGS} ${CUDALIBDIR} ${MPFRLIBDIR} ${CUBALIBDIR} ${LIBSSTART} -lmpfr -lgmp -lcuba -lcudart_static ${LIBSEND} -ldl -o $@; else $(CC) $(OBJ) kernel.o ${LFLAGS} ${CUDALIBDIR} ${MPFRLIBDIR} ${CUBALIBDIR} ${LIBSSTART} -lmpfr -lgmp -lcuba ${LIBSEND} -lcudart -lcuda -ldl -o $@; fi; 

.c.o:
	$(CC) $(CFLAGS) -DGPU=TRUE -DPRECISION=$(PRECISION) ${CUDAINCLUDEDIR} ${MPFRINCLUDEDIR} ${CUBAINCLUDEDIR} -c $<

kernel.o: kernel.cu
	$(CUDABINDIR)$(NVCC) --include-path ${MPFRINCLUDEDIR:-I%=%} -Xptxas -v -lineinfo -arch=sm_20 -DGPU=TRUE $< -c -o $@

dep: depend

depend:
	cd ../sources && makedepend -w20 -Y -s '\# ******** DEPENDENCIES: *********' -f ../mpfr/Makefile $(OBJ:.o=.c)
# ******** DEPENDENCIES: *********

kernel.o: comdef.h
collectstr.o: collectstr.h
collectstr.o: comdef.h
scanner.o: scanner.h
scanner.o: comdef.h
scanner.o: triesi.h
scanner.o: collectstr.h
scanner.o: hash.h
scanner.o: tries.h
scanner.o: constants.h
scanner.o: queue.h
runline.o: scanner.h
runline.o: comdef.h
runline.o: triesi.h
runline.o: collectstr.h
runline.o: hash.h
runline.o: runline.h
hash.o: comdef.h
hash.o: scanner.h
hash.o: triesi.h
hash.o: collectstr.h
hash.o: hash.h
integrators.o: integrators.h
integrators.o: scanner.h
integrators.o: comdef.h
integrators.o: triesi.h
integrators.o: collectstr.h
integrators.o: hash.h
integrators.o: runline.h
CIntegrate.o: scanner.h
CIntegrate.o: comdef.h
CIntegrate.o: triesi.h
CIntegrate.o: collectstr.h
CIntegrate.o: hash.h
CIntegrate.o: runline.h
CIntegrate.o: integrators.h
CIntegrate.o: kernel.h
scanner.o: kernel.h
runline.o: kernel.h