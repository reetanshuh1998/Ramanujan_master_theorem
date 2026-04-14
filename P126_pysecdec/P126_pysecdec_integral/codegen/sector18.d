SECTOR18_CPP = \
	src/sector_18.cpp \
	src/sector_18_n1.cpp \
	src/sector_18_0.cpp \
	src/contour_deformation_sector_18_n1.cpp \
	src/contour_deformation_sector_18_0.cpp \
	src/optimize_deformation_parameters_sector_18_n1.cpp \
	src/optimize_deformation_parameters_sector_18_0.cpp
SECTOR18_DISTSRC = \
	distsrc/sector_18_n1.cpp \
	distsrc/sector_18_0.cpp \
	distsrc/sector_18_n1.cu \
	distsrc/sector_18_0.cu
SECTOR18_MMA = \
	mma/sector_18_n1.m \
	mma/sector_18_0.m
SECTOR_CPP += $(SECTOR18_CPP)
SECTOR_MMA += $(SECTOR18_MMA)

$(SECTOR18_DISTSRC) $(SECTOR18_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR18_CPP)) : codegen/sector18.done ;
$(SECTOR18_MMA) : codegen/sector18.mma.done ;
