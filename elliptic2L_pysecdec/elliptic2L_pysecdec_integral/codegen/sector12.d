SECTOR12_CPP = \
	src/sector_12.cpp \
	src/sector_12_0.cpp \
	src/contour_deformation_sector_12_0.cpp \
	src/optimize_deformation_parameters_sector_12_0.cpp
SECTOR12_DISTSRC = \
	distsrc/sector_12_0.cpp \
	distsrc/sector_12_0.cu
SECTOR12_MMA = \
	mma/sector_12_0.m
SECTOR_CPP += $(SECTOR12_CPP)
SECTOR_MMA += $(SECTOR12_MMA)

$(SECTOR12_DISTSRC) $(SECTOR12_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR12_CPP)) : codegen/sector12.done ;
$(SECTOR12_MMA) : codegen/sector12.mma.done ;
