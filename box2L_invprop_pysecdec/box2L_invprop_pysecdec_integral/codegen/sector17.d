SECTOR17_CPP = \
	src/sector_17.cpp \
	src/sector_17_n4.cpp \
	src/sector_17_n3.cpp \
	src/sector_17_n2.cpp \
	src/sector_17_n1.cpp \
	src/sector_17_0.cpp \
	src/contour_deformation_sector_17_n4.cpp \
	src/contour_deformation_sector_17_n3.cpp \
	src/contour_deformation_sector_17_n2.cpp \
	src/contour_deformation_sector_17_n1.cpp \
	src/contour_deformation_sector_17_0.cpp \
	src/optimize_deformation_parameters_sector_17_n4.cpp \
	src/optimize_deformation_parameters_sector_17_n3.cpp \
	src/optimize_deformation_parameters_sector_17_n2.cpp \
	src/optimize_deformation_parameters_sector_17_n1.cpp \
	src/optimize_deformation_parameters_sector_17_0.cpp
SECTOR17_DISTSRC = \
	distsrc/sector_17_n4.cpp \
	distsrc/sector_17_n3.cpp \
	distsrc/sector_17_n2.cpp \
	distsrc/sector_17_n1.cpp \
	distsrc/sector_17_0.cpp \
	distsrc/sector_17_n4.cu \
	distsrc/sector_17_n3.cu \
	distsrc/sector_17_n2.cu \
	distsrc/sector_17_n1.cu \
	distsrc/sector_17_0.cu
SECTOR17_MMA = \
	mma/sector_17_n4.m \
	mma/sector_17_n3.m \
	mma/sector_17_n2.m \
	mma/sector_17_n1.m \
	mma/sector_17_0.m
SECTOR_CPP += $(SECTOR17_CPP)
SECTOR_MMA += $(SECTOR17_MMA)

$(SECTOR17_DISTSRC) $(SECTOR17_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR17_CPP)) : codegen/sector17.done ;
$(SECTOR17_MMA) : codegen/sector17.mma.done ;
