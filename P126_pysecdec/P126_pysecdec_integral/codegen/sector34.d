SECTOR34_CPP = \
	src/sector_34.cpp \
	src/sector_34_n1.cpp \
	src/sector_34_0.cpp \
	src/contour_deformation_sector_34_n1.cpp \
	src/contour_deformation_sector_34_0.cpp \
	src/optimize_deformation_parameters_sector_34_n1.cpp \
	src/optimize_deformation_parameters_sector_34_0.cpp
SECTOR34_DISTSRC = \
	distsrc/sector_34_n1.cpp \
	distsrc/sector_34_0.cpp \
	distsrc/sector_34_n1.cu \
	distsrc/sector_34_0.cu
SECTOR34_MMA = \
	mma/sector_34_n1.m \
	mma/sector_34_0.m
SECTOR_CPP += $(SECTOR34_CPP)
SECTOR_MMA += $(SECTOR34_MMA)

$(SECTOR34_DISTSRC) $(SECTOR34_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR34_CPP)) : codegen/sector34.done ;
$(SECTOR34_MMA) : codegen/sector34.mma.done ;
