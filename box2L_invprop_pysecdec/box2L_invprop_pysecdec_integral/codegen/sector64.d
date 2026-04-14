SECTOR64_CPP = \
	src/sector_64.cpp \
	src/sector_64_n2.cpp \
	src/sector_64_n1.cpp \
	src/sector_64_0.cpp \
	src/contour_deformation_sector_64_n2.cpp \
	src/contour_deformation_sector_64_n1.cpp \
	src/contour_deformation_sector_64_0.cpp \
	src/optimize_deformation_parameters_sector_64_n2.cpp \
	src/optimize_deformation_parameters_sector_64_n1.cpp \
	src/optimize_deformation_parameters_sector_64_0.cpp
SECTOR64_DISTSRC = \
	distsrc/sector_64_n2.cpp \
	distsrc/sector_64_n1.cpp \
	distsrc/sector_64_0.cpp \
	distsrc/sector_64_n2.cu \
	distsrc/sector_64_n1.cu \
	distsrc/sector_64_0.cu
SECTOR64_MMA = \
	mma/sector_64_n2.m \
	mma/sector_64_n1.m \
	mma/sector_64_0.m
SECTOR_CPP += $(SECTOR64_CPP)
SECTOR_MMA += $(SECTOR64_MMA)

$(SECTOR64_DISTSRC) $(SECTOR64_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR64_CPP)) : codegen/sector64.done ;
$(SECTOR64_MMA) : codegen/sector64.mma.done ;
