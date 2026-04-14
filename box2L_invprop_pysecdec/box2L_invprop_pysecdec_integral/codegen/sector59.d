SECTOR59_CPP = \
	src/sector_59.cpp \
	src/sector_59_n1.cpp \
	src/sector_59_0.cpp \
	src/contour_deformation_sector_59_n1.cpp \
	src/contour_deformation_sector_59_0.cpp \
	src/optimize_deformation_parameters_sector_59_n1.cpp \
	src/optimize_deformation_parameters_sector_59_0.cpp
SECTOR59_DISTSRC = \
	distsrc/sector_59_n1.cpp \
	distsrc/sector_59_0.cpp \
	distsrc/sector_59_n1.cu \
	distsrc/sector_59_0.cu
SECTOR59_MMA = \
	mma/sector_59_n1.m \
	mma/sector_59_0.m
SECTOR_CPP += $(SECTOR59_CPP)
SECTOR_MMA += $(SECTOR59_MMA)

$(SECTOR59_DISTSRC) $(SECTOR59_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR59_CPP)) : codegen/sector59.done ;
$(SECTOR59_MMA) : codegen/sector59.mma.done ;
