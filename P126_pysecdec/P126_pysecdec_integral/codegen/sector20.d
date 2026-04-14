SECTOR20_CPP = \
	src/sector_20.cpp \
	src/sector_20_0.cpp \
	src/contour_deformation_sector_20_0.cpp \
	src/optimize_deformation_parameters_sector_20_0.cpp
SECTOR20_DISTSRC = \
	distsrc/sector_20_0.cpp \
	distsrc/sector_20_0.cu
SECTOR20_MMA = \
	mma/sector_20_0.m
SECTOR_CPP += $(SECTOR20_CPP)
SECTOR_MMA += $(SECTOR20_MMA)

$(SECTOR20_DISTSRC) $(SECTOR20_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR20_CPP)) : codegen/sector20.done ;
$(SECTOR20_MMA) : codegen/sector20.mma.done ;
