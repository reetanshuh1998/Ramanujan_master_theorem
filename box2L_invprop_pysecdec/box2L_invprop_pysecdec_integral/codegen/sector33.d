SECTOR33_CPP = \
	src/sector_33.cpp \
	src/sector_33_n3.cpp \
	src/sector_33_n2.cpp \
	src/sector_33_n1.cpp \
	src/sector_33_0.cpp \
	src/contour_deformation_sector_33_n3.cpp \
	src/contour_deformation_sector_33_n2.cpp \
	src/contour_deformation_sector_33_n1.cpp \
	src/contour_deformation_sector_33_0.cpp \
	src/optimize_deformation_parameters_sector_33_n3.cpp \
	src/optimize_deformation_parameters_sector_33_n2.cpp \
	src/optimize_deformation_parameters_sector_33_n1.cpp \
	src/optimize_deformation_parameters_sector_33_0.cpp
SECTOR33_DISTSRC = \
	distsrc/sector_33_n3.cpp \
	distsrc/sector_33_n2.cpp \
	distsrc/sector_33_n1.cpp \
	distsrc/sector_33_0.cpp \
	distsrc/sector_33_n3.cu \
	distsrc/sector_33_n2.cu \
	distsrc/sector_33_n1.cu \
	distsrc/sector_33_0.cu
SECTOR33_MMA = \
	mma/sector_33_n3.m \
	mma/sector_33_n2.m \
	mma/sector_33_n1.m \
	mma/sector_33_0.m
SECTOR_CPP += $(SECTOR33_CPP)
SECTOR_MMA += $(SECTOR33_MMA)

$(SECTOR33_DISTSRC) $(SECTOR33_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR33_CPP)) : codegen/sector33.done ;
$(SECTOR33_MMA) : codegen/sector33.mma.done ;
