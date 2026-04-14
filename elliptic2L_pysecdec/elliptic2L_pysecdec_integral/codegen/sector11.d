SECTOR11_CPP = \
	src/sector_11.cpp \
	src/sector_11_0.cpp \
	src/contour_deformation_sector_11_0.cpp \
	src/optimize_deformation_parameters_sector_11_0.cpp
SECTOR11_DISTSRC = \
	distsrc/sector_11_0.cpp \
	distsrc/sector_11_0.cu
SECTOR11_MMA = \
	mma/sector_11_0.m
SECTOR_CPP += $(SECTOR11_CPP)
SECTOR_MMA += $(SECTOR11_MMA)

$(SECTOR11_DISTSRC) $(SECTOR11_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR11_CPP)) : codegen/sector11.done ;
$(SECTOR11_MMA) : codegen/sector11.mma.done ;
