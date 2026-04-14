SECTOR1_CPP = \
	src/sector_1.cpp \
	src/sector_1_n4.cpp \
	src/sector_1_n3.cpp \
	src/sector_1_n2.cpp \
	src/sector_1_n1.cpp \
	src/sector_1_0.cpp \
	src/contour_deformation_sector_1_n4.cpp \
	src/contour_deformation_sector_1_n3.cpp \
	src/contour_deformation_sector_1_n2.cpp \
	src/contour_deformation_sector_1_n1.cpp \
	src/contour_deformation_sector_1_0.cpp \
	src/optimize_deformation_parameters_sector_1_n4.cpp \
	src/optimize_deformation_parameters_sector_1_n3.cpp \
	src/optimize_deformation_parameters_sector_1_n2.cpp \
	src/optimize_deformation_parameters_sector_1_n1.cpp \
	src/optimize_deformation_parameters_sector_1_0.cpp
SECTOR1_DISTSRC = \
	distsrc/sector_1_n4.cpp \
	distsrc/sector_1_n3.cpp \
	distsrc/sector_1_n2.cpp \
	distsrc/sector_1_n1.cpp \
	distsrc/sector_1_0.cpp \
	distsrc/sector_1_n4.cu \
	distsrc/sector_1_n3.cu \
	distsrc/sector_1_n2.cu \
	distsrc/sector_1_n1.cu \
	distsrc/sector_1_0.cu
SECTOR1_MMA = \
	mma/sector_1_n4.m \
	mma/sector_1_n3.m \
	mma/sector_1_n2.m \
	mma/sector_1_n1.m \
	mma/sector_1_0.m
SECTOR_CPP += $(SECTOR1_CPP)
SECTOR_MMA += $(SECTOR1_MMA)

$(SECTOR1_DISTSRC) $(SECTOR1_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR1_CPP)) : codegen/sector1.done ;
$(SECTOR1_MMA) : codegen/sector1.mma.done ;
