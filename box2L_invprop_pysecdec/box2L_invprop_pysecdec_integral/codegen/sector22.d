SECTOR22_CPP = \
	src/sector_22.cpp \
	src/sector_22_n4.cpp \
	src/sector_22_n3.cpp \
	src/sector_22_n2.cpp \
	src/sector_22_n1.cpp \
	src/sector_22_0.cpp \
	src/contour_deformation_sector_22_n4.cpp \
	src/contour_deformation_sector_22_n3.cpp \
	src/contour_deformation_sector_22_n2.cpp \
	src/contour_deformation_sector_22_n1.cpp \
	src/contour_deformation_sector_22_0.cpp \
	src/optimize_deformation_parameters_sector_22_n4.cpp \
	src/optimize_deformation_parameters_sector_22_n3.cpp \
	src/optimize_deformation_parameters_sector_22_n2.cpp \
	src/optimize_deformation_parameters_sector_22_n1.cpp \
	src/optimize_deformation_parameters_sector_22_0.cpp
SECTOR22_DISTSRC = \
	distsrc/sector_22_n4.cpp \
	distsrc/sector_22_n3.cpp \
	distsrc/sector_22_n2.cpp \
	distsrc/sector_22_n1.cpp \
	distsrc/sector_22_0.cpp \
	distsrc/sector_22_n4.cu \
	distsrc/sector_22_n3.cu \
	distsrc/sector_22_n2.cu \
	distsrc/sector_22_n1.cu \
	distsrc/sector_22_0.cu
SECTOR22_MMA = \
	mma/sector_22_n4.m \
	mma/sector_22_n3.m \
	mma/sector_22_n2.m \
	mma/sector_22_n1.m \
	mma/sector_22_0.m
SECTOR_CPP += $(SECTOR22_CPP)
SECTOR_MMA += $(SECTOR22_MMA)

$(SECTOR22_DISTSRC) $(SECTOR22_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR22_CPP)) : codegen/sector22.done ;
$(SECTOR22_MMA) : codegen/sector22.mma.done ;
