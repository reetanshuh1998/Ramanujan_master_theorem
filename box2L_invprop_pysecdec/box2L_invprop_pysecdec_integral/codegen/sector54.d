SECTOR54_CPP = \
	src/sector_54.cpp \
	src/sector_54_n3.cpp \
	src/sector_54_n2.cpp \
	src/sector_54_n1.cpp \
	src/sector_54_0.cpp \
	src/contour_deformation_sector_54_n3.cpp \
	src/contour_deformation_sector_54_n2.cpp \
	src/contour_deformation_sector_54_n1.cpp \
	src/contour_deformation_sector_54_0.cpp \
	src/optimize_deformation_parameters_sector_54_n3.cpp \
	src/optimize_deformation_parameters_sector_54_n2.cpp \
	src/optimize_deformation_parameters_sector_54_n1.cpp \
	src/optimize_deformation_parameters_sector_54_0.cpp
SECTOR54_DISTSRC = \
	distsrc/sector_54_n3.cpp \
	distsrc/sector_54_n2.cpp \
	distsrc/sector_54_n1.cpp \
	distsrc/sector_54_0.cpp \
	distsrc/sector_54_n3.cu \
	distsrc/sector_54_n2.cu \
	distsrc/sector_54_n1.cu \
	distsrc/sector_54_0.cu
SECTOR54_MMA = \
	mma/sector_54_n3.m \
	mma/sector_54_n2.m \
	mma/sector_54_n1.m \
	mma/sector_54_0.m
SECTOR_CPP += $(SECTOR54_CPP)
SECTOR_MMA += $(SECTOR54_MMA)

$(SECTOR54_DISTSRC) $(SECTOR54_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR54_CPP)) : codegen/sector54.done ;
$(SECTOR54_MMA) : codegen/sector54.mma.done ;
