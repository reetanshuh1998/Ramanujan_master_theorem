SECTOR37_CPP = \
	src/sector_37.cpp \
	src/sector_37_n2.cpp \
	src/sector_37_n1.cpp \
	src/sector_37_0.cpp \
	src/contour_deformation_sector_37_n2.cpp \
	src/contour_deformation_sector_37_n1.cpp \
	src/contour_deformation_sector_37_0.cpp \
	src/optimize_deformation_parameters_sector_37_n2.cpp \
	src/optimize_deformation_parameters_sector_37_n1.cpp \
	src/optimize_deformation_parameters_sector_37_0.cpp
SECTOR37_DISTSRC = \
	distsrc/sector_37_n2.cpp \
	distsrc/sector_37_n1.cpp \
	distsrc/sector_37_0.cpp \
	distsrc/sector_37_n2.cu \
	distsrc/sector_37_n1.cu \
	distsrc/sector_37_0.cu
SECTOR37_MMA = \
	mma/sector_37_n2.m \
	mma/sector_37_n1.m \
	mma/sector_37_0.m
SECTOR_CPP += $(SECTOR37_CPP)
SECTOR_MMA += $(SECTOR37_MMA)

$(SECTOR37_DISTSRC) $(SECTOR37_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR37_CPP)) : codegen/sector37.done ;
$(SECTOR37_MMA) : codegen/sector37.mma.done ;
