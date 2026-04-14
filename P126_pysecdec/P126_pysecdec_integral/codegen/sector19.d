SECTOR19_CPP = \
	src/sector_19.cpp \
	src/sector_19_0.cpp \
	src/contour_deformation_sector_19_0.cpp \
	src/optimize_deformation_parameters_sector_19_0.cpp
SECTOR19_DISTSRC = \
	distsrc/sector_19_0.cpp \
	distsrc/sector_19_0.cu
SECTOR19_MMA = \
	mma/sector_19_0.m
SECTOR_CPP += $(SECTOR19_CPP)
SECTOR_MMA += $(SECTOR19_MMA)

$(SECTOR19_DISTSRC) $(SECTOR19_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR19_CPP)) : codegen/sector19.done ;
$(SECTOR19_MMA) : codegen/sector19.mma.done ;
