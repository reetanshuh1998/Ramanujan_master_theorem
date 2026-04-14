SECTOR40_CPP = \
	src/sector_40.cpp \
	src/sector_40_n4.cpp \
	src/sector_40_n3.cpp \
	src/sector_40_n2.cpp \
	src/sector_40_n1.cpp \
	src/sector_40_0.cpp \
	src/contour_deformation_sector_40_n4.cpp \
	src/contour_deformation_sector_40_n3.cpp \
	src/contour_deformation_sector_40_n2.cpp \
	src/contour_deformation_sector_40_n1.cpp \
	src/contour_deformation_sector_40_0.cpp \
	src/optimize_deformation_parameters_sector_40_n4.cpp \
	src/optimize_deformation_parameters_sector_40_n3.cpp \
	src/optimize_deformation_parameters_sector_40_n2.cpp \
	src/optimize_deformation_parameters_sector_40_n1.cpp \
	src/optimize_deformation_parameters_sector_40_0.cpp
SECTOR40_DISTSRC = \
	distsrc/sector_40_n4.cpp \
	distsrc/sector_40_n3.cpp \
	distsrc/sector_40_n2.cpp \
	distsrc/sector_40_n1.cpp \
	distsrc/sector_40_0.cpp \
	distsrc/sector_40_n4.cu \
	distsrc/sector_40_n3.cu \
	distsrc/sector_40_n2.cu \
	distsrc/sector_40_n1.cu \
	distsrc/sector_40_0.cu
SECTOR40_MMA = \
	mma/sector_40_n4.m \
	mma/sector_40_n3.m \
	mma/sector_40_n2.m \
	mma/sector_40_n1.m \
	mma/sector_40_0.m
SECTOR_CPP += $(SECTOR40_CPP)
SECTOR_MMA += $(SECTOR40_MMA)

$(SECTOR40_DISTSRC) $(SECTOR40_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR40_CPP)) : codegen/sector40.done ;
$(SECTOR40_MMA) : codegen/sector40.mma.done ;
