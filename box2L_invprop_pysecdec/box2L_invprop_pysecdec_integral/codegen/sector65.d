SECTOR65_CPP = \
	src/sector_65.cpp \
	src/sector_65_n2.cpp \
	src/sector_65_n1.cpp \
	src/sector_65_0.cpp \
	src/contour_deformation_sector_65_n2.cpp \
	src/contour_deformation_sector_65_n1.cpp \
	src/contour_deformation_sector_65_0.cpp \
	src/optimize_deformation_parameters_sector_65_n2.cpp \
	src/optimize_deformation_parameters_sector_65_n1.cpp \
	src/optimize_deformation_parameters_sector_65_0.cpp
SECTOR65_DISTSRC = \
	distsrc/sector_65_n2.cpp \
	distsrc/sector_65_n1.cpp \
	distsrc/sector_65_0.cpp \
	distsrc/sector_65_n2.cu \
	distsrc/sector_65_n1.cu \
	distsrc/sector_65_0.cu
SECTOR65_MMA = \
	mma/sector_65_n2.m \
	mma/sector_65_n1.m \
	mma/sector_65_0.m
SECTOR_CPP += $(SECTOR65_CPP)
SECTOR_MMA += $(SECTOR65_MMA)

$(SECTOR65_DISTSRC) $(SECTOR65_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR65_CPP)) : codegen/sector65.done ;
$(SECTOR65_MMA) : codegen/sector65.mma.done ;
