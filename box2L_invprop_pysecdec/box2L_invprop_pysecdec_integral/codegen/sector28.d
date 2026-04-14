SECTOR28_CPP = \
	src/sector_28.cpp \
	src/sector_28_n3.cpp \
	src/sector_28_n2.cpp \
	src/sector_28_n1.cpp \
	src/sector_28_0.cpp \
	src/contour_deformation_sector_28_n3.cpp \
	src/contour_deformation_sector_28_n2.cpp \
	src/contour_deformation_sector_28_n1.cpp \
	src/contour_deformation_sector_28_0.cpp \
	src/optimize_deformation_parameters_sector_28_n3.cpp \
	src/optimize_deformation_parameters_sector_28_n2.cpp \
	src/optimize_deformation_parameters_sector_28_n1.cpp \
	src/optimize_deformation_parameters_sector_28_0.cpp
SECTOR28_DISTSRC = \
	distsrc/sector_28_n3.cpp \
	distsrc/sector_28_n2.cpp \
	distsrc/sector_28_n1.cpp \
	distsrc/sector_28_0.cpp \
	distsrc/sector_28_n3.cu \
	distsrc/sector_28_n2.cu \
	distsrc/sector_28_n1.cu \
	distsrc/sector_28_0.cu
SECTOR28_MMA = \
	mma/sector_28_n3.m \
	mma/sector_28_n2.m \
	mma/sector_28_n1.m \
	mma/sector_28_0.m
SECTOR_CPP += $(SECTOR28_CPP)
SECTOR_MMA += $(SECTOR28_MMA)

$(SECTOR28_DISTSRC) $(SECTOR28_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR28_CPP)) : codegen/sector28.done ;
$(SECTOR28_MMA) : codegen/sector28.mma.done ;
