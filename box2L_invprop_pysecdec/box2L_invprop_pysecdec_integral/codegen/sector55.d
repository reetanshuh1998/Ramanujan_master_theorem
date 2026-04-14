SECTOR55_CPP = \
	src/sector_55.cpp \
	src/sector_55_n3.cpp \
	src/sector_55_n2.cpp \
	src/sector_55_n1.cpp \
	src/sector_55_0.cpp \
	src/contour_deformation_sector_55_n3.cpp \
	src/contour_deformation_sector_55_n2.cpp \
	src/contour_deformation_sector_55_n1.cpp \
	src/contour_deformation_sector_55_0.cpp \
	src/optimize_deformation_parameters_sector_55_n3.cpp \
	src/optimize_deformation_parameters_sector_55_n2.cpp \
	src/optimize_deformation_parameters_sector_55_n1.cpp \
	src/optimize_deformation_parameters_sector_55_0.cpp
SECTOR55_DISTSRC = \
	distsrc/sector_55_n3.cpp \
	distsrc/sector_55_n2.cpp \
	distsrc/sector_55_n1.cpp \
	distsrc/sector_55_0.cpp \
	distsrc/sector_55_n3.cu \
	distsrc/sector_55_n2.cu \
	distsrc/sector_55_n1.cu \
	distsrc/sector_55_0.cu
SECTOR55_MMA = \
	mma/sector_55_n3.m \
	mma/sector_55_n2.m \
	mma/sector_55_n1.m \
	mma/sector_55_0.m
SECTOR_CPP += $(SECTOR55_CPP)
SECTOR_MMA += $(SECTOR55_MMA)

$(SECTOR55_DISTSRC) $(SECTOR55_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR55_CPP)) : codegen/sector55.done ;
$(SECTOR55_MMA) : codegen/sector55.mma.done ;
