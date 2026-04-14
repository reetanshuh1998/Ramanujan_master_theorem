SECTOR27_CPP = \
	src/sector_27.cpp \
	src/sector_27_n2.cpp \
	src/sector_27_n1.cpp \
	src/sector_27_0.cpp \
	src/contour_deformation_sector_27_n2.cpp \
	src/contour_deformation_sector_27_n1.cpp \
	src/contour_deformation_sector_27_0.cpp \
	src/optimize_deformation_parameters_sector_27_n2.cpp \
	src/optimize_deformation_parameters_sector_27_n1.cpp \
	src/optimize_deformation_parameters_sector_27_0.cpp
SECTOR27_DISTSRC = \
	distsrc/sector_27_n2.cpp \
	distsrc/sector_27_n1.cpp \
	distsrc/sector_27_0.cpp \
	distsrc/sector_27_n2.cu \
	distsrc/sector_27_n1.cu \
	distsrc/sector_27_0.cu
SECTOR27_MMA = \
	mma/sector_27_n2.m \
	mma/sector_27_n1.m \
	mma/sector_27_0.m
SECTOR_CPP += $(SECTOR27_CPP)
SECTOR_MMA += $(SECTOR27_MMA)

$(SECTOR27_DISTSRC) $(SECTOR27_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR27_CPP)) : codegen/sector27.done ;
$(SECTOR27_MMA) : codegen/sector27.mma.done ;
