include ../paths.inc
include ../libs.inc
include ../sourcesPool/obj.inc

vpath %.c ../sourcesPool
vpath %.h ../sourcesPool

CIntegratePool : $(OBJ)
	$(CCPLUS) ${LFLAGS} $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -o $@

.c.o:
	$(CCPLUS) $(CFLAGS) ${KYOTOINCLUDEDIR} -DTHREADSMODE=1 -c $<

dep: depend

depend:
	cd ../sourcesPool && makedepend -w20 -Y -s '\# ******** DEPENDENCIES: *********' -f ../threads/Makefile $(OBJ:.o=.c)

# ******** DEPENDENCIES: *********

CIntegratePool.o: CIntegratePoolCommon.h
CIntegratePoolCommon.o: CIntegratePoolCommon.h
