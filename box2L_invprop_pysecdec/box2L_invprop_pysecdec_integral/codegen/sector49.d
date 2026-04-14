SECTOR49_CPP = \
	src/sector_49.cpp \
	src/sector_49_n3.cpp \
	src/sector_49_n2.cpp \
	src/sector_49_n1.cpp \
	src/sector_49_0.cpp \
	src/contour_deformation_sector_49_n3.cpp \
	src/contour_deformation_sector_49_n2.cpp \
	src/contour_deformation_sector_49_n1.cpp \
	src/contour_deformation_sector_49_0.cpp \
	src/optimize_deformation_parameters_sector_49_n3.cpp \
	src/optimize_deformation_parameters_sector_49_n2.cpp \
	src/optimize_deformation_parameters_sector_49_n1.cpp \
	src/optimize_deformation_parameters_sector_49_0.cpp
SECTOR49_DISTSRC = \
	distsrc/sector_49_n3.cpp \
	distsrc/sector_49_n2.cpp \
	distsrc/sector_49_n1.cpp \
	distsrc/sector_49_0.cpp \
	distsrc/sector_49_n3.cu \
	distsrc/sector_49_n2.cu \
	distsrc/sector_49_n1.cu \
	distsrc/sector_49_0.cu
SECTOR49_MMA = \
	mma/sector_49_n3.m \
	mma/sector_49_n2.m \
	mma/sector_49_n1.m \
	mma/sector_49_0.m
SECTOR_CPP += $(SECTOR49_CPP)
SECTOR_MMA += $(SECTOR49_MMA)

$(SECTOR49_DISTSRC) $(SECTOR49_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR49_CPP)) : codegen/sector49.done ;
$(SECTOR49_MMA) : codegen/sector49.mma.done ;
