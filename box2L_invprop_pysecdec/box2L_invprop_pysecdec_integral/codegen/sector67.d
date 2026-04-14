SECTOR67_CPP = \
	src/sector_67.cpp \
	src/sector_67_n1.cpp \
	src/sector_67_0.cpp \
	src/contour_deformation_sector_67_n1.cpp \
	src/contour_deformation_sector_67_0.cpp \
	src/optimize_deformation_parameters_sector_67_n1.cpp \
	src/optimize_deformation_parameters_sector_67_0.cpp
SECTOR67_DISTSRC = \
	distsrc/sector_67_n1.cpp \
	distsrc/sector_67_0.cpp \
	distsrc/sector_67_n1.cu \
	distsrc/sector_67_0.cu
SECTOR67_MMA = \
	mma/sector_67_n1.m \
	mma/sector_67_0.m
SECTOR_CPP += $(SECTOR67_CPP)
SECTOR_MMA += $(SECTOR67_MMA)

$(SECTOR67_DISTSRC) $(SECTOR67_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR67_CPP)) : codegen/sector67.done ;
$(SECTOR67_MMA) : codegen/sector67.mma.done ;
