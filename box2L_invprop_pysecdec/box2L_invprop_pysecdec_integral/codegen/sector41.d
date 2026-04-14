SECTOR41_CPP = \
	src/sector_41.cpp \
	src/sector_41_n2.cpp \
	src/sector_41_n1.cpp \
	src/sector_41_0.cpp \
	src/contour_deformation_sector_41_n2.cpp \
	src/contour_deformation_sector_41_n1.cpp \
	src/contour_deformation_sector_41_0.cpp \
	src/optimize_deformation_parameters_sector_41_n2.cpp \
	src/optimize_deformation_parameters_sector_41_n1.cpp \
	src/optimize_deformation_parameters_sector_41_0.cpp
SECTOR41_DISTSRC = \
	distsrc/sector_41_n2.cpp \
	distsrc/sector_41_n1.cpp \
	distsrc/sector_41_0.cpp \
	distsrc/sector_41_n2.cu \
	distsrc/sector_41_n1.cu \
	distsrc/sector_41_0.cu
SECTOR41_MMA = \
	mma/sector_41_n2.m \
	mma/sector_41_n1.m \
	mma/sector_41_0.m
SECTOR_CPP += $(SECTOR41_CPP)
SECTOR_MMA += $(SECTOR41_MMA)

$(SECTOR41_DISTSRC) $(SECTOR41_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR41_CPP)) : codegen/sector41.done ;
$(SECTOR41_MMA) : codegen/sector41.mma.done ;
