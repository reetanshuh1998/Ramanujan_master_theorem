SECTOR50_CPP = \
	src/sector_50.cpp \
	src/sector_50_n3.cpp \
	src/sector_50_n2.cpp \
	src/sector_50_n1.cpp \
	src/sector_50_0.cpp \
	src/contour_deformation_sector_50_n3.cpp \
	src/contour_deformation_sector_50_n2.cpp \
	src/contour_deformation_sector_50_n1.cpp \
	src/contour_deformation_sector_50_0.cpp \
	src/optimize_deformation_parameters_sector_50_n3.cpp \
	src/optimize_deformation_parameters_sector_50_n2.cpp \
	src/optimize_deformation_parameters_sector_50_n1.cpp \
	src/optimize_deformation_parameters_sector_50_0.cpp
SECTOR50_DISTSRC = \
	distsrc/sector_50_n3.cpp \
	distsrc/sector_50_n2.cpp \
	distsrc/sector_50_n1.cpp \
	distsrc/sector_50_0.cpp \
	distsrc/sector_50_n3.cu \
	distsrc/sector_50_n2.cu \
	distsrc/sector_50_n1.cu \
	distsrc/sector_50_0.cu
SECTOR50_MMA = \
	mma/sector_50_n3.m \
	mma/sector_50_n2.m \
	mma/sector_50_n1.m \
	mma/sector_50_0.m
SECTOR_CPP += $(SECTOR50_CPP)
SECTOR_MMA += $(SECTOR50_MMA)

$(SECTOR50_DISTSRC) $(SECTOR50_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR50_CPP)) : codegen/sector50.done ;
$(SECTOR50_MMA) : codegen/sector50.mma.done ;
