include ../paths.inc
include ../libs.inc
include ../sourcesPool/obj.inc

vpath %.c ../sourcesPool
vpath %.h ../sourcesPool

CIntegratePoolMPI : $(OBJ)
	$(CCMPI) $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -Wl,-Bdynamic -lc -o $@

.c.o:
	$(CCMPI) $(CFLAGS) -Wno-non-virtual-dtor ${KYOTOINCLUDEDIR} -DMPIMODE -DTHREADSMODE=0 -c $<

dep: depend

depend:
	cd ../sourcesPool && makedepend -w20 -Y -s '\# ******** DEPENDENCIES: *********' -f ../mpi/Makefile $(OBJ:.o=.c)

# ******** DEPENDENCIES: *********

CIntegratePool.o: CIntegratePoolCommon.h
CIntegratePoolCommon.o: CIntegratePoolCommon.h
