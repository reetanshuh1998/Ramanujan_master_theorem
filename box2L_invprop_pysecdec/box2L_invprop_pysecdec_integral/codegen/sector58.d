SECTOR58_CPP = \
	src/sector_58.cpp \
	src/sector_58_n1.cpp \
	src/sector_58_0.cpp \
	src/contour_deformation_sector_58_n1.cpp \
	src/contour_deformation_sector_58_0.cpp \
	src/optimize_deformation_parameters_sector_58_n1.cpp \
	src/optimize_deformation_parameters_sector_58_0.cpp
SECTOR58_DISTSRC = \
	distsrc/sector_58_n1.cpp \
	distsrc/sector_58_0.cpp \
	distsrc/sector_58_n1.cu \
	distsrc/sector_58_0.cu
SECTOR58_MMA = \
	mma/sector_58_n1.m \
	mma/sector_58_0.m
SECTOR_CPP += $(SECTOR58_CPP)
SECTOR_MMA += $(SECTOR58_MMA)

$(SECTOR58_DISTSRC) $(SECTOR58_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR58_CPP)) : codegen/sector58.done ;
$(SECTOR58_MMA) : codegen/sector58.mma.done ;
