include ../paths.inc
include ../libs.inc

OBJ = OutputIntegrand.o

OutputIntegrand : $(OBJ)
	$(CCPLUS) $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -lc -o $@

.c.o:
	$(CCPLUS) $(CFLAGS) -Wno-non-virtual-dtor ${KYOTOINCLUDEDIR} -c $<

OutputIntegrand.o : OutputIntegrand.c