SECTOR51_CPP = \
	src/sector_51.cpp \
	src/sector_51_n3.cpp \
	src/sector_51_n2.cpp \
	src/sector_51_n1.cpp \
	src/sector_51_0.cpp \
	src/contour_deformation_sector_51_n3.cpp \
	src/contour_deformation_sector_51_n2.cpp \
	src/contour_deformation_sector_51_n1.cpp \
	src/contour_deformation_sector_51_0.cpp \
	src/optimize_deformation_parameters_sector_51_n3.cpp \
	src/optimize_deformation_parameters_sector_51_n2.cpp \
	src/optimize_deformation_parameters_sector_51_n1.cpp \
	src/optimize_deformation_parameters_sector_51_0.cpp
SECTOR51_DISTSRC = \
	distsrc/sector_51_n3.cpp \
	distsrc/sector_51_n2.cpp \
	distsrc/sector_51_n1.cpp \
	distsrc/sector_51_0.cpp \
	distsrc/sector_51_n3.cu \
	distsrc/sector_51_n2.cu \
	distsrc/sector_51_n1.cu \
	distsrc/sector_51_0.cu
SECTOR51_MMA = \
	mma/sector_51_n3.m \
	mma/sector_51_n2.m \
	mma/sector_51_n1.m \
	mma/sector_51_0.m
SECTOR_CPP += $(SECTOR51_CPP)
SECTOR_MMA += $(SECTOR51_MMA)

$(SECTOR51_DISTSRC) $(SECTOR51_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR51_CPP)) : codegen/sector51.done ;
$(SECTOR51_MMA) : codegen/sector51.mma.done ;
