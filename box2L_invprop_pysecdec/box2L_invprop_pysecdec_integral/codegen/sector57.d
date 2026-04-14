SECTOR57_CPP = \
	src/sector_57.cpp \
	src/sector_57_n1.cpp \
	src/sector_57_0.cpp \
	src/contour_deformation_sector_57_n1.cpp \
	src/contour_deformation_sector_57_0.cpp \
	src/optimize_deformation_parameters_sector_57_n1.cpp \
	src/optimize_deformation_parameters_sector_57_0.cpp
SECTOR57_DISTSRC = \
	distsrc/sector_57_n1.cpp \
	distsrc/sector_57_0.cpp \
	distsrc/sector_57_n1.cu \
	distsrc/sector_57_0.cu
SECTOR57_MMA = \
	mma/sector_57_n1.m \
	mma/sector_57_0.m
SECTOR_CPP += $(SECTOR57_CPP)
SECTOR_MMA += $(SECTOR57_MMA)

$(SECTOR57_DISTSRC) $(SECTOR57_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR57_CPP)) : codegen/sector57.done ;
$(SECTOR57_MMA) : codegen/sector57.mma.done ;
