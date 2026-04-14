SECTOR10_CPP = \
	src/sector_10.cpp \
	src/sector_10_0.cpp \
	src/contour_deformation_sector_10_0.cpp \
	src/optimize_deformation_parameters_sector_10_0.cpp
SECTOR10_DISTSRC = \
	distsrc/sector_10_0.cpp \
	distsrc/sector_10_0.cu
SECTOR10_MMA = \
	mma/sector_10_0.m
SECTOR_CPP += $(SECTOR10_CPP)
SECTOR_MMA += $(SECTOR10_MMA)

$(SECTOR10_DISTSRC) $(SECTOR10_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR10_CPP)) : codegen/sector10.done ;
$(SECTOR10_MMA) : codegen/sector10.mma.done ;
