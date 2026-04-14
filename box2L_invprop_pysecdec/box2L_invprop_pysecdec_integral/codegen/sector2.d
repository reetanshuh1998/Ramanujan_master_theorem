SECTOR2_CPP = \
	src/sector_2.cpp \
	src/sector_2_n3.cpp \
	src/sector_2_n2.cpp \
	src/sector_2_n1.cpp \
	src/sector_2_0.cpp \
	src/contour_deformation_sector_2_n3.cpp \
	src/contour_deformation_sector_2_n2.cpp \
	src/contour_deformation_sector_2_n1.cpp \
	src/contour_deformation_sector_2_0.cpp \
	src/optimize_deformation_parameters_sector_2_n3.cpp \
	src/optimize_deformation_parameters_sector_2_n2.cpp \
	src/optimize_deformation_parameters_sector_2_n1.cpp \
	src/optimize_deformation_parameters_sector_2_0.cpp
SECTOR2_DISTSRC = \
	distsrc/sector_2_n3.cpp \
	distsrc/sector_2_n2.cpp \
	distsrc/sector_2_n1.cpp \
	distsrc/sector_2_0.cpp \
	distsrc/sector_2_n3.cu \
	distsrc/sector_2_n2.cu \
	distsrc/sector_2_n1.cu \
	distsrc/sector_2_0.cu
SECTOR2_MMA = \
	mma/sector_2_n3.m \
	mma/sector_2_n2.m \
	mma/sector_2_n1.m \
	mma/sector_2_0.m
SECTOR_CPP += $(SECTOR2_CPP)
SECTOR_MMA += $(SECTOR2_MMA)

$(SECTOR2_DISTSRC) $(SECTOR2_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR2_CPP)) : codegen/sector2.done ;
$(SECTOR2_MMA) : codegen/sector2.mma.done ;
