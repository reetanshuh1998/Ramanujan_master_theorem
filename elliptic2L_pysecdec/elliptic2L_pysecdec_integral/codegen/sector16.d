SECTOR16_CPP = \
	src/sector_16.cpp \
	src/sector_16_0.cpp \
	src/contour_deformation_sector_16_0.cpp \
	src/optimize_deformation_parameters_sector_16_0.cpp
SECTOR16_DISTSRC = \
	distsrc/sector_16_0.cpp \
	distsrc/sector_16_0.cu
SECTOR16_MMA = \
	mma/sector_16_0.m
SECTOR_CPP += $(SECTOR16_CPP)
SECTOR_MMA += $(SECTOR16_MMA)

$(SECTOR16_DISTSRC) $(SECTOR16_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR16_CPP)) : codegen/sector16.done ;
$(SECTOR16_MMA) : codegen/sector16.mma.done ;
