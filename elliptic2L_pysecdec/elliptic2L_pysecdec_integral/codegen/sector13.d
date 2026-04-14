SECTOR13_CPP = \
	src/sector_13.cpp \
	src/sector_13_0.cpp \
	src/contour_deformation_sector_13_0.cpp \
	src/optimize_deformation_parameters_sector_13_0.cpp
SECTOR13_DISTSRC = \
	distsrc/sector_13_0.cpp \
	distsrc/sector_13_0.cu
SECTOR13_MMA = \
	mma/sector_13_0.m
SECTOR_CPP += $(SECTOR13_CPP)
SECTOR_MMA += $(SECTOR13_MMA)

$(SECTOR13_DISTSRC) $(SECTOR13_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR13_CPP)) : codegen/sector13.done ;
$(SECTOR13_MMA) : codegen/sector13.mma.done ;
