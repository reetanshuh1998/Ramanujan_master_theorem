SECTOR25_CPP = \
	src/sector_25.cpp \
	src/sector_25_n3.cpp \
	src/sector_25_n2.cpp \
	src/sector_25_n1.cpp \
	src/sector_25_0.cpp \
	src/contour_deformation_sector_25_n3.cpp \
	src/contour_deformation_sector_25_n2.cpp \
	src/contour_deformation_sector_25_n1.cpp \
	src/contour_deformation_sector_25_0.cpp \
	src/optimize_deformation_parameters_sector_25_n3.cpp \
	src/optimize_deformation_parameters_sector_25_n2.cpp \
	src/optimize_deformation_parameters_sector_25_n1.cpp \
	src/optimize_deformation_parameters_sector_25_0.cpp
SECTOR25_DISTSRC = \
	distsrc/sector_25_n3.cpp \
	distsrc/sector_25_n2.cpp \
	distsrc/sector_25_n1.cpp \
	distsrc/sector_25_0.cpp \
	distsrc/sector_25_n3.cu \
	distsrc/sector_25_n2.cu \
	distsrc/sector_25_n1.cu \
	distsrc/sector_25_0.cu
SECTOR25_MMA = \
	mma/sector_25_n3.m \
	mma/sector_25_n2.m \
	mma/sector_25_n1.m \
	mma/sector_25_0.m
SECTOR_CPP += $(SECTOR25_CPP)
SECTOR_MMA += $(SECTOR25_MMA)

$(SECTOR25_DISTSRC) $(SECTOR25_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR25_CPP)) : codegen/sector25.done ;
$(SECTOR25_MMA) : codegen/sector25.mma.done ;
