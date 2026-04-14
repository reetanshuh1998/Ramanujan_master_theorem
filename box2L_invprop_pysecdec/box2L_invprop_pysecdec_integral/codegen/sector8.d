SECTOR8_CPP = \
	src/sector_8.cpp \
	src/sector_8_n3.cpp \
	src/sector_8_n2.cpp \
	src/sector_8_n1.cpp \
	src/sector_8_0.cpp \
	src/contour_deformation_sector_8_n3.cpp \
	src/contour_deformation_sector_8_n2.cpp \
	src/contour_deformation_sector_8_n1.cpp \
	src/contour_deformation_sector_8_0.cpp \
	src/optimize_deformation_parameters_sector_8_n3.cpp \
	src/optimize_deformation_parameters_sector_8_n2.cpp \
	src/optimize_deformation_parameters_sector_8_n1.cpp \
	src/optimize_deformation_parameters_sector_8_0.cpp
SECTOR8_DISTSRC = \
	distsrc/sector_8_n3.cpp \
	distsrc/sector_8_n2.cpp \
	distsrc/sector_8_n1.cpp \
	distsrc/sector_8_0.cpp \
	distsrc/sector_8_n3.cu \
	distsrc/sector_8_n2.cu \
	distsrc/sector_8_n1.cu \
	distsrc/sector_8_0.cu
SECTOR8_MMA = \
	mma/sector_8_n3.m \
	mma/sector_8_n2.m \
	mma/sector_8_n1.m \
	mma/sector_8_0.m
SECTOR_CPP += $(SECTOR8_CPP)
SECTOR_MMA += $(SECTOR8_MMA)

$(SECTOR8_DISTSRC) $(SECTOR8_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR8_CPP)) : codegen/sector8.done ;
$(SECTOR8_MMA) : codegen/sector8.mma.done ;
