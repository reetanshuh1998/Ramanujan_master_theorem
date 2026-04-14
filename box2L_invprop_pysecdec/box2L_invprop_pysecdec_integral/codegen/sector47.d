SECTOR47_CPP = \
	src/sector_47.cpp \
	src/sector_47_n3.cpp \
	src/sector_47_n2.cpp \
	src/sector_47_n1.cpp \
	src/sector_47_0.cpp \
	src/contour_deformation_sector_47_n3.cpp \
	src/contour_deformation_sector_47_n2.cpp \
	src/contour_deformation_sector_47_n1.cpp \
	src/contour_deformation_sector_47_0.cpp \
	src/optimize_deformation_parameters_sector_47_n3.cpp \
	src/optimize_deformation_parameters_sector_47_n2.cpp \
	src/optimize_deformation_parameters_sector_47_n1.cpp \
	src/optimize_deformation_parameters_sector_47_0.cpp
SECTOR47_DISTSRC = \
	distsrc/sector_47_n3.cpp \
	distsrc/sector_47_n2.cpp \
	distsrc/sector_47_n1.cpp \
	distsrc/sector_47_0.cpp \
	distsrc/sector_47_n3.cu \
	distsrc/sector_47_n2.cu \
	distsrc/sector_47_n1.cu \
	distsrc/sector_47_0.cu
SECTOR47_MMA = \
	mma/sector_47_n3.m \
	mma/sector_47_n2.m \
	mma/sector_47_n1.m \
	mma/sector_47_0.m
SECTOR_CPP += $(SECTOR47_CPP)
SECTOR_MMA += $(SECTOR47_MMA)

$(SECTOR47_DISTSRC) $(SECTOR47_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR47_CPP)) : codegen/sector47.done ;
$(SECTOR47_MMA) : codegen/sector47.mma.done ;
