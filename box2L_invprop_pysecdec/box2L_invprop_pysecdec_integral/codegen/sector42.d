SECTOR42_CPP = \
	src/sector_42.cpp \
	src/sector_42_n2.cpp \
	src/sector_42_n1.cpp \
	src/sector_42_0.cpp \
	src/contour_deformation_sector_42_n2.cpp \
	src/contour_deformation_sector_42_n1.cpp \
	src/contour_deformation_sector_42_0.cpp \
	src/optimize_deformation_parameters_sector_42_n2.cpp \
	src/optimize_deformation_parameters_sector_42_n1.cpp \
	src/optimize_deformation_parameters_sector_42_0.cpp
SECTOR42_DISTSRC = \
	distsrc/sector_42_n2.cpp \
	distsrc/sector_42_n1.cpp \
	distsrc/sector_42_0.cpp \
	distsrc/sector_42_n2.cu \
	distsrc/sector_42_n1.cu \
	distsrc/sector_42_0.cu
SECTOR42_MMA = \
	mma/sector_42_n2.m \
	mma/sector_42_n1.m \
	mma/sector_42_0.m
SECTOR_CPP += $(SECTOR42_CPP)
SECTOR_MMA += $(SECTOR42_MMA)

$(SECTOR42_DISTSRC) $(SECTOR42_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR42_CPP)) : codegen/sector42.done ;
$(SECTOR42_MMA) : codegen/sector42.mma.done ;
