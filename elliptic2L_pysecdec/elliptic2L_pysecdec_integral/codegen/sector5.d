SECTOR5_CPP = \
	src/sector_5.cpp \
	src/sector_5_0.cpp \
	src/contour_deformation_sector_5_0.cpp \
	src/optimize_deformation_parameters_sector_5_0.cpp
SECTOR5_DISTSRC = \
	distsrc/sector_5_0.cpp \
	distsrc/sector_5_0.cu
SECTOR5_MMA = \
	mma/sector_5_0.m
SECTOR_CPP += $(SECTOR5_CPP)
SECTOR_MMA += $(SECTOR5_MMA)

$(SECTOR5_DISTSRC) $(SECTOR5_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR5_CPP)) : codegen/sector5.done ;
$(SECTOR5_MMA) : codegen/sector5.mma.done ;
