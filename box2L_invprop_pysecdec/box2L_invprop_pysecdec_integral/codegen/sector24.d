SECTOR24_CPP = \
	src/sector_24.cpp \
	src/sector_24_n2.cpp \
	src/sector_24_n1.cpp \
	src/sector_24_0.cpp \
	src/contour_deformation_sector_24_n2.cpp \
	src/contour_deformation_sector_24_n1.cpp \
	src/contour_deformation_sector_24_0.cpp \
	src/optimize_deformation_parameters_sector_24_n2.cpp \
	src/optimize_deformation_parameters_sector_24_n1.cpp \
	src/optimize_deformation_parameters_sector_24_0.cpp
SECTOR24_DISTSRC = \
	distsrc/sector_24_n2.cpp \
	distsrc/sector_24_n1.cpp \
	distsrc/sector_24_0.cpp \
	distsrc/sector_24_n2.cu \
	distsrc/sector_24_n1.cu \
	distsrc/sector_24_0.cu
SECTOR24_MMA = \
	mma/sector_24_n2.m \
	mma/sector_24_n1.m \
	mma/sector_24_0.m
SECTOR_CPP += $(SECTOR24_CPP)
SECTOR_MMA += $(SECTOR24_MMA)

$(SECTOR24_DISTSRC) $(SECTOR24_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR24_CPP)) : codegen/sector24.done ;
$(SECTOR24_MMA) : codegen/sector24.mma.done ;
