UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
MATHEXE=/Applications/Mathematica.app/Contents/MacOS/MathKernel
else
# MATHEXE=math
MATHEXE=/usr/local/bin/MathKernel
endif



SHELL=/bin/bash
VERSION := $(shell echo -e $$ VersionNumber | tr -d " " | $(MATHEXE) -noprompt | tr -d ".\"\n" )
MBASE := $(shell echo -e $$ InstallationDirectory | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n")
SYSID :=  $(shell echo -e $$ SystemID | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n" )
MLINKDIR = ${MBASE}/SystemFiles/Links/MathLink/DeveloperKit
ifeq ($(SYSID), Linux)
	BIT := 32
endif
ifeq ($(SYSID), Linux-x86-64) 
	BIT := 64
endif

ifeq ($(shell echo "$(VERSION)>=10" | bc), 1)
EXTRALIBS= -luuid -ldl
MLIBVERSION=4
else
MLIBVERSION=3
endif


CADDSDIR = ${MLINKDIR}/${SYSID}/CompilerAdditions
MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
MPREP = ${CADDSDIR}/mprep

ifeq ($(UNAME_S),Darwin)
LIBS=-L${CADDSDIR} -lkyotocabinet -lMLi${MLIBVERSION} -lstdc++ -framework Foundation -lz -lm -mmacosx-version-min=10.5
else
LIBS=${MLIB} ${EXTRALIBS} -Wl,-Bstatic -lkyotocabinet -Wl,-Bdynamic -pthread -lstdc++ -lrt -lz -lm
endif


OBJ = KLink.o MathSide.o

CC=gcc

KLink: $(OBJ)
	$(CC) $(OBJ) -L../usr/lib/ -L../usr/lib64/ ${LIBS} -o $@

.c.o:
	$(CC) -c -I${CADDSDIR} -I../usr/include/ -O2 -c $<

MathSide.c : MathSide.tm
	${MPREP} -o MathSide.c MathSide.tm

clean:
	rm -f KLink.o MathSide.c MathSide.o

	
dep: depend

depend:
	makedepend -w20 -Y -s '\# ******** DEPENDENCIES: *********' -f Makefile MathSide.tm MathSide.c KLink.c


# ******** DEPENDENCIES: *********
