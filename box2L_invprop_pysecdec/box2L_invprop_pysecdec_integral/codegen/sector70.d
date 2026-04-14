SECTOR70_CPP = \
	src/sector_70.cpp \
	src/sector_70_n2.cpp \
	src/sector_70_n1.cpp \
	src/sector_70_0.cpp \
	src/contour_deformation_sector_70_n2.cpp \
	src/contour_deformation_sector_70_n1.cpp \
	src/contour_deformation_sector_70_0.cpp \
	src/optimize_deformation_parameters_sector_70_n2.cpp \
	src/optimize_deformation_parameters_sector_70_n1.cpp \
	src/optimize_deformation_parameters_sector_70_0.cpp
SECTOR70_DISTSRC = \
	distsrc/sector_70_n2.cpp \
	distsrc/sector_70_n1.cpp \
	distsrc/sector_70_0.cpp \
	distsrc/sector_70_n2.cu \
	distsrc/sector_70_n1.cu \
	distsrc/sector_70_0.cu
SECTOR70_MMA = \
	mma/sector_70_n2.m \
	mma/sector_70_n1.m \
	mma/sector_70_0.m
SECTOR_CPP += $(SECTOR70_CPP)
SECTOR_MMA += $(SECTOR70_MMA)

$(SECTOR70_DISTSRC) $(SECTOR70_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR70_CPP)) : codegen/sector70.done ;
$(SECTOR70_MMA) : codegen/sector70.mma.done ;
