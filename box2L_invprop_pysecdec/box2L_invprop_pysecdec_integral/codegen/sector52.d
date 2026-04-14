SECTOR52_CPP = \
	src/sector_52.cpp \
	src/sector_52_n2.cpp \
	src/sector_52_n1.cpp \
	src/sector_52_0.cpp \
	src/contour_deformation_sector_52_n2.cpp \
	src/contour_deformation_sector_52_n1.cpp \
	src/contour_deformation_sector_52_0.cpp \
	src/optimize_deformation_parameters_sector_52_n2.cpp \
	src/optimize_deformation_parameters_sector_52_n1.cpp \
	src/optimize_deformation_parameters_sector_52_0.cpp
SECTOR52_DISTSRC = \
	distsrc/sector_52_n2.cpp \
	distsrc/sector_52_n1.cpp \
	distsrc/sector_52_0.cpp \
	distsrc/sector_52_n2.cu \
	distsrc/sector_52_n1.cu \
	distsrc/sector_52_0.cu
SECTOR52_MMA = \
	mma/sector_52_n2.m \
	mma/sector_52_n1.m \
	mma/sector_52_0.m
SECTOR_CPP += $(SECTOR52_CPP)
SECTOR_MMA += $(SECTOR52_MMA)

$(SECTOR52_DISTSRC) $(SECTOR52_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR52_CPP)) : codegen/sector52.done ;
$(SECTOR52_MMA) : codegen/sector52.mma.done ;
