SECTOR32_CPP = \
	src/sector_32.cpp \
	src/sector_32_n1.cpp \
	src/sector_32_0.cpp \
	src/contour_deformation_sector_32_n1.cpp \
	src/contour_deformation_sector_32_0.cpp \
	src/optimize_deformation_parameters_sector_32_n1.cpp \
	src/optimize_deformation_parameters_sector_32_0.cpp
SECTOR32_DISTSRC = \
	distsrc/sector_32_n1.cpp \
	distsrc/sector_32_0.cpp \
	distsrc/sector_32_n1.cu \
	distsrc/sector_32_0.cu
SECTOR32_MMA = \
	mma/sector_32_n1.m \
	mma/sector_32_0.m
SECTOR_CPP += $(SECTOR32_CPP)
SECTOR_MMA += $(SECTOR32_MMA)

$(SECTOR32_DISTSRC) $(SECTOR32_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR32_CPP)) : codegen/sector32.done ;
$(SECTOR32_MMA) : codegen/sector32.mma.done ;
