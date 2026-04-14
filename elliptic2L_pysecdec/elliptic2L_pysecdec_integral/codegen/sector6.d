SECTOR6_CPP = \
	src/sector_6.cpp \
	src/sector_6_0.cpp \
	src/contour_deformation_sector_6_0.cpp \
	src/optimize_deformation_parameters_sector_6_0.cpp
SECTOR6_DISTSRC = \
	distsrc/sector_6_0.cpp \
	distsrc/sector_6_0.cu
SECTOR6_MMA = \
	mma/sector_6_0.m
SECTOR_CPP += $(SECTOR6_CPP)
SECTOR_MMA += $(SECTOR6_MMA)

$(SECTOR6_DISTSRC) $(SECTOR6_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR6_CPP)) : codegen/sector6.done ;
$(SECTOR6_MMA) : codegen/sector6.mma.done ;
