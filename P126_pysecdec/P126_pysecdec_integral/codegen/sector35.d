SECTOR35_CPP = \
	src/sector_35.cpp \
	src/sector_35_n1.cpp \
	src/sector_35_0.cpp \
	src/contour_deformation_sector_35_n1.cpp \
	src/contour_deformation_sector_35_0.cpp \
	src/optimize_deformation_parameters_sector_35_n1.cpp \
	src/optimize_deformation_parameters_sector_35_0.cpp
SECTOR35_DISTSRC = \
	distsrc/sector_35_n1.cpp \
	distsrc/sector_35_0.cpp \
	distsrc/sector_35_n1.cu \
	distsrc/sector_35_0.cu
SECTOR35_MMA = \
	mma/sector_35_n1.m \
	mma/sector_35_0.m
SECTOR_CPP += $(SECTOR35_CPP)
SECTOR_MMA += $(SECTOR35_MMA)

$(SECTOR35_DISTSRC) $(SECTOR35_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR35_CPP)) : codegen/sector35.done ;
$(SECTOR35_MMA) : codegen/sector35.mma.done ;
