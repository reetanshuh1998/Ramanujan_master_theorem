SECTOR56_CPP = \
	src/sector_56.cpp \
	src/sector_56_n1.cpp \
	src/sector_56_0.cpp \
	src/contour_deformation_sector_56_n1.cpp \
	src/contour_deformation_sector_56_0.cpp \
	src/optimize_deformation_parameters_sector_56_n1.cpp \
	src/optimize_deformation_parameters_sector_56_0.cpp
SECTOR56_DISTSRC = \
	distsrc/sector_56_n1.cpp \
	distsrc/sector_56_0.cpp \
	distsrc/sector_56_n1.cu \
	distsrc/sector_56_0.cu
SECTOR56_MMA = \
	mma/sector_56_n1.m \
	mma/sector_56_0.m
SECTOR_CPP += $(SECTOR56_CPP)
SECTOR_MMA += $(SECTOR56_MMA)

$(SECTOR56_DISTSRC) $(SECTOR56_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR56_CPP)) : codegen/sector56.done ;
$(SECTOR56_MMA) : codegen/sector56.mma.done ;
