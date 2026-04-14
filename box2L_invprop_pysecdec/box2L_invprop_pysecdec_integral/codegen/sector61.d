SECTOR61_CPP = \
	src/sector_61.cpp \
	src/sector_61_n2.cpp \
	src/sector_61_n1.cpp \
	src/sector_61_0.cpp \
	src/contour_deformation_sector_61_n2.cpp \
	src/contour_deformation_sector_61_n1.cpp \
	src/contour_deformation_sector_61_0.cpp \
	src/optimize_deformation_parameters_sector_61_n2.cpp \
	src/optimize_deformation_parameters_sector_61_n1.cpp \
	src/optimize_deformation_parameters_sector_61_0.cpp
SECTOR61_DISTSRC = \
	distsrc/sector_61_n2.cpp \
	distsrc/sector_61_n1.cpp \
	distsrc/sector_61_0.cpp \
	distsrc/sector_61_n2.cu \
	distsrc/sector_61_n1.cu \
	distsrc/sector_61_0.cu
SECTOR61_MMA = \
	mma/sector_61_n2.m \
	mma/sector_61_n1.m \
	mma/sector_61_0.m
SECTOR_CPP += $(SECTOR61_CPP)
SECTOR_MMA += $(SECTOR61_MMA)

$(SECTOR61_DISTSRC) $(SECTOR61_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR61_CPP)) : codegen/sector61.done ;
$(SECTOR61_MMA) : codegen/sector61.mma.done ;
