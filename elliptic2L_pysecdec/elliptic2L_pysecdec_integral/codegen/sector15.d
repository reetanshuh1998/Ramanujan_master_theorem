SECTOR15_CPP = \
	src/sector_15.cpp \
	src/sector_15_0.cpp \
	src/contour_deformation_sector_15_0.cpp \
	src/optimize_deformation_parameters_sector_15_0.cpp
SECTOR15_DISTSRC = \
	distsrc/sector_15_0.cpp \
	distsrc/sector_15_0.cu
SECTOR15_MMA = \
	mma/sector_15_0.m
SECTOR_CPP += $(SECTOR15_CPP)
SECTOR_MMA += $(SECTOR15_MMA)

$(SECTOR15_DISTSRC) $(SECTOR15_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR15_CPP)) : codegen/sector15.done ;
$(SECTOR15_MMA) : codegen/sector15.mma.done ;
