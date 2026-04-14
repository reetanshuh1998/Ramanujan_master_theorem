SECTOR14_CPP = \
	src/sector_14.cpp \
	src/sector_14_0.cpp \
	src/contour_deformation_sector_14_0.cpp \
	src/optimize_deformation_parameters_sector_14_0.cpp
SECTOR14_DISTSRC = \
	distsrc/sector_14_0.cpp \
	distsrc/sector_14_0.cu
SECTOR14_MMA = \
	mma/sector_14_0.m
SECTOR_CPP += $(SECTOR14_CPP)
SECTOR_MMA += $(SECTOR14_MMA)

$(SECTOR14_DISTSRC) $(SECTOR14_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR14_CPP)) : codegen/sector14.done ;
$(SECTOR14_MMA) : codegen/sector14.mma.done ;
