SECTOR9_CPP = \
	src/sector_9.cpp \
	src/sector_9_0.cpp \
	src/contour_deformation_sector_9_0.cpp \
	src/optimize_deformation_parameters_sector_9_0.cpp
SECTOR9_DISTSRC = \
	distsrc/sector_9_0.cpp \
	distsrc/sector_9_0.cu
SECTOR9_MMA = \
	mma/sector_9_0.m
SECTOR_CPP += $(SECTOR9_CPP)
SECTOR_MMA += $(SECTOR9_MMA)

$(SECTOR9_DISTSRC) $(SECTOR9_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR9_CPP)) : codegen/sector9.done ;
$(SECTOR9_MMA) : codegen/sector9.mma.done ;
