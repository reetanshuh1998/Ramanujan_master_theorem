SECTOR21_CPP = \
	src/sector_21.cpp \
	src/sector_21_0.cpp \
	src/contour_deformation_sector_21_0.cpp \
	src/optimize_deformation_parameters_sector_21_0.cpp
SECTOR21_DISTSRC = \
	distsrc/sector_21_0.cpp \
	distsrc/sector_21_0.cu
SECTOR21_MMA = \
	mma/sector_21_0.m
SECTOR_CPP += $(SECTOR21_CPP)
SECTOR_MMA += $(SECTOR21_MMA)

$(SECTOR21_DISTSRC) $(SECTOR21_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR21_CPP)) : codegen/sector21.done ;
$(SECTOR21_MMA) : codegen/sector21.mma.done ;
