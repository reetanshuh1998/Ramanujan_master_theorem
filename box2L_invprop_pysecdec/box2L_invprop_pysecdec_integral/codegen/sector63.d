SECTOR63_CPP = \
	src/sector_63.cpp \
	src/sector_63_n2.cpp \
	src/sector_63_n1.cpp \
	src/sector_63_0.cpp \
	src/contour_deformation_sector_63_n2.cpp \
	src/contour_deformation_sector_63_n1.cpp \
	src/contour_deformation_sector_63_0.cpp \
	src/optimize_deformation_parameters_sector_63_n2.cpp \
	src/optimize_deformation_parameters_sector_63_n1.cpp \
	src/optimize_deformation_parameters_sector_63_0.cpp
SECTOR63_DISTSRC = \
	distsrc/sector_63_n2.cpp \
	distsrc/sector_63_n1.cpp \
	distsrc/sector_63_0.cpp \
	distsrc/sector_63_n2.cu \
	distsrc/sector_63_n1.cu \
	distsrc/sector_63_0.cu
SECTOR63_MMA = \
	mma/sector_63_n2.m \
	mma/sector_63_n1.m \
	mma/sector_63_0.m
SECTOR_CPP += $(SECTOR63_CPP)
SECTOR_MMA += $(SECTOR63_MMA)

$(SECTOR63_DISTSRC) $(SECTOR63_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR63_CPP)) : codegen/sector63.done ;
$(SECTOR63_MMA) : codegen/sector63.mma.done ;
