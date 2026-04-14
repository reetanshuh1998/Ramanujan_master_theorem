SECTOR69_CPP = \
	src/sector_69.cpp \
	src/sector_69_n2.cpp \
	src/sector_69_n1.cpp \
	src/sector_69_0.cpp \
	src/contour_deformation_sector_69_n2.cpp \
	src/contour_deformation_sector_69_n1.cpp \
	src/contour_deformation_sector_69_0.cpp \
	src/optimize_deformation_parameters_sector_69_n2.cpp \
	src/optimize_deformation_parameters_sector_69_n1.cpp \
	src/optimize_deformation_parameters_sector_69_0.cpp
SECTOR69_DISTSRC = \
	distsrc/sector_69_n2.cpp \
	distsrc/sector_69_n1.cpp \
	distsrc/sector_69_0.cpp \
	distsrc/sector_69_n2.cu \
	distsrc/sector_69_n1.cu \
	distsrc/sector_69_0.cu
SECTOR69_MMA = \
	mma/sector_69_n2.m \
	mma/sector_69_n1.m \
	mma/sector_69_0.m
SECTOR_CPP += $(SECTOR69_CPP)
SECTOR_MMA += $(SECTOR69_MMA)

$(SECTOR69_DISTSRC) $(SECTOR69_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR69_CPP)) : codegen/sector69.done ;
$(SECTOR69_MMA) : codegen/sector69.mma.done ;
