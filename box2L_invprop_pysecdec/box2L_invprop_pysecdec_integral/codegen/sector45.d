SECTOR45_CPP = \
	src/sector_45.cpp \
	src/sector_45_n3.cpp \
	src/sector_45_n2.cpp \
	src/sector_45_n1.cpp \
	src/sector_45_0.cpp \
	src/contour_deformation_sector_45_n3.cpp \
	src/contour_deformation_sector_45_n2.cpp \
	src/contour_deformation_sector_45_n1.cpp \
	src/contour_deformation_sector_45_0.cpp \
	src/optimize_deformation_parameters_sector_45_n3.cpp \
	src/optimize_deformation_parameters_sector_45_n2.cpp \
	src/optimize_deformation_parameters_sector_45_n1.cpp \
	src/optimize_deformation_parameters_sector_45_0.cpp
SECTOR45_DISTSRC = \
	distsrc/sector_45_n3.cpp \
	distsrc/sector_45_n2.cpp \
	distsrc/sector_45_n1.cpp \
	distsrc/sector_45_0.cpp \
	distsrc/sector_45_n3.cu \
	distsrc/sector_45_n2.cu \
	distsrc/sector_45_n1.cu \
	distsrc/sector_45_0.cu
SECTOR45_MMA = \
	mma/sector_45_n3.m \
	mma/sector_45_n2.m \
	mma/sector_45_n1.m \
	mma/sector_45_0.m
SECTOR_CPP += $(SECTOR45_CPP)
SECTOR_MMA += $(SECTOR45_MMA)

$(SECTOR45_DISTSRC) $(SECTOR45_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR45_CPP)) : codegen/sector45.done ;
$(SECTOR45_MMA) : codegen/sector45.mma.done ;
