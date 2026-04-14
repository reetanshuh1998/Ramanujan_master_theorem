SECTOR36_CPP = \
	src/sector_36.cpp \
	src/sector_36_n1.cpp \
	src/sector_36_0.cpp \
	src/contour_deformation_sector_36_n1.cpp \
	src/contour_deformation_sector_36_0.cpp \
	src/optimize_deformation_parameters_sector_36_n1.cpp \
	src/optimize_deformation_parameters_sector_36_0.cpp
SECTOR36_DISTSRC = \
	distsrc/sector_36_n1.cpp \
	distsrc/sector_36_0.cpp \
	distsrc/sector_36_n1.cu \
	distsrc/sector_36_0.cu
SECTOR36_MMA = \
	mma/sector_36_n1.m \
	mma/sector_36_0.m
SECTOR_CPP += $(SECTOR36_CPP)
SECTOR_MMA += $(SECTOR36_MMA)

$(SECTOR36_DISTSRC) $(SECTOR36_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR36_CPP)) : codegen/sector36.done ;
$(SECTOR36_MMA) : codegen/sector36.mma.done ;
