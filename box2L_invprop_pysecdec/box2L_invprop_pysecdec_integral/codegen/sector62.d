SECTOR62_CPP = \
	src/sector_62.cpp \
	src/sector_62_n2.cpp \
	src/sector_62_n1.cpp \
	src/sector_62_0.cpp \
	src/contour_deformation_sector_62_n2.cpp \
	src/contour_deformation_sector_62_n1.cpp \
	src/contour_deformation_sector_62_0.cpp \
	src/optimize_deformation_parameters_sector_62_n2.cpp \
	src/optimize_deformation_parameters_sector_62_n1.cpp \
	src/optimize_deformation_parameters_sector_62_0.cpp
SECTOR62_DISTSRC = \
	distsrc/sector_62_n2.cpp \
	distsrc/sector_62_n1.cpp \
	distsrc/sector_62_0.cpp \
	distsrc/sector_62_n2.cu \
	distsrc/sector_62_n1.cu \
	distsrc/sector_62_0.cu
SECTOR62_MMA = \
	mma/sector_62_n2.m \
	mma/sector_62_n1.m \
	mma/sector_62_0.m
SECTOR_CPP += $(SECTOR62_CPP)
SECTOR_MMA += $(SECTOR62_MMA)

$(SECTOR62_DISTSRC) $(SECTOR62_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR62_CPP)) : codegen/sector62.done ;
$(SECTOR62_MMA) : codegen/sector62.mma.done ;
