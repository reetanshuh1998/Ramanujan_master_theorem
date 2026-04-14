SECTOR68_CPP = \
	src/sector_68.cpp \
	src/sector_68_n2.cpp \
	src/sector_68_n1.cpp \
	src/sector_68_0.cpp \
	src/contour_deformation_sector_68_n2.cpp \
	src/contour_deformation_sector_68_n1.cpp \
	src/contour_deformation_sector_68_0.cpp \
	src/optimize_deformation_parameters_sector_68_n2.cpp \
	src/optimize_deformation_parameters_sector_68_n1.cpp \
	src/optimize_deformation_parameters_sector_68_0.cpp
SECTOR68_DISTSRC = \
	distsrc/sector_68_n2.cpp \
	distsrc/sector_68_n1.cpp \
	distsrc/sector_68_0.cpp \
	distsrc/sector_68_n2.cu \
	distsrc/sector_68_n1.cu \
	distsrc/sector_68_0.cu
SECTOR68_MMA = \
	mma/sector_68_n2.m \
	mma/sector_68_n1.m \
	mma/sector_68_0.m
SECTOR_CPP += $(SECTOR68_CPP)
SECTOR_MMA += $(SECTOR68_MMA)

$(SECTOR68_DISTSRC) $(SECTOR68_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR68_CPP)) : codegen/sector68.done ;
$(SECTOR68_MMA) : codegen/sector68.mma.done ;
