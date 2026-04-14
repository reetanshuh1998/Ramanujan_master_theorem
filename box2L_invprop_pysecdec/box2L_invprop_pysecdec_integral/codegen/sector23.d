SECTOR23_CPP = \
	src/sector_23.cpp \
	src/sector_23_n4.cpp \
	src/sector_23_n3.cpp \
	src/sector_23_n2.cpp \
	src/sector_23_n1.cpp \
	src/sector_23_0.cpp \
	src/contour_deformation_sector_23_n4.cpp \
	src/contour_deformation_sector_23_n3.cpp \
	src/contour_deformation_sector_23_n2.cpp \
	src/contour_deformation_sector_23_n1.cpp \
	src/contour_deformation_sector_23_0.cpp \
	src/optimize_deformation_parameters_sector_23_n4.cpp \
	src/optimize_deformation_parameters_sector_23_n3.cpp \
	src/optimize_deformation_parameters_sector_23_n2.cpp \
	src/optimize_deformation_parameters_sector_23_n1.cpp \
	src/optimize_deformation_parameters_sector_23_0.cpp
SECTOR23_DISTSRC = \
	distsrc/sector_23_n4.cpp \
	distsrc/sector_23_n3.cpp \
	distsrc/sector_23_n2.cpp \
	distsrc/sector_23_n1.cpp \
	distsrc/sector_23_0.cpp \
	distsrc/sector_23_n4.cu \
	distsrc/sector_23_n3.cu \
	distsrc/sector_23_n2.cu \
	distsrc/sector_23_n1.cu \
	distsrc/sector_23_0.cu
SECTOR23_MMA = \
	mma/sector_23_n4.m \
	mma/sector_23_n3.m \
	mma/sector_23_n2.m \
	mma/sector_23_n1.m \
	mma/sector_23_0.m
SECTOR_CPP += $(SECTOR23_CPP)
SECTOR_MMA += $(SECTOR23_MMA)

$(SECTOR23_DISTSRC) $(SECTOR23_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR23_CPP)) : codegen/sector23.done ;
$(SECTOR23_MMA) : codegen/sector23.mma.done ;
