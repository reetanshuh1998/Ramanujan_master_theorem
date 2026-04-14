SECTOR30_CPP = \
	src/sector_30.cpp \
	src/sector_30_n2.cpp \
	src/sector_30_n1.cpp \
	src/sector_30_0.cpp \
	src/contour_deformation_sector_30_n2.cpp \
	src/contour_deformation_sector_30_n1.cpp \
	src/contour_deformation_sector_30_0.cpp \
	src/optimize_deformation_parameters_sector_30_n2.cpp \
	src/optimize_deformation_parameters_sector_30_n1.cpp \
	src/optimize_deformation_parameters_sector_30_0.cpp
SECTOR30_DISTSRC = \
	distsrc/sector_30_n2.cpp \
	distsrc/sector_30_n1.cpp \
	distsrc/sector_30_0.cpp \
	distsrc/sector_30_n2.cu \
	distsrc/sector_30_n1.cu \
	distsrc/sector_30_0.cu
SECTOR30_MMA = \
	mma/sector_30_n2.m \
	mma/sector_30_n1.m \
	mma/sector_30_0.m
SECTOR_CPP += $(SECTOR30_CPP)
SECTOR_MMA += $(SECTOR30_MMA)

$(SECTOR30_DISTSRC) $(SECTOR30_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR30_CPP)) : codegen/sector30.done ;
$(SECTOR30_MMA) : codegen/sector30.mma.done ;
