SECTOR60_CPP = \
	src/sector_60.cpp \
	src/sector_60_n2.cpp \
	src/sector_60_n1.cpp \
	src/sector_60_0.cpp \
	src/contour_deformation_sector_60_n2.cpp \
	src/contour_deformation_sector_60_n1.cpp \
	src/contour_deformation_sector_60_0.cpp \
	src/optimize_deformation_parameters_sector_60_n2.cpp \
	src/optimize_deformation_parameters_sector_60_n1.cpp \
	src/optimize_deformation_parameters_sector_60_0.cpp
SECTOR60_DISTSRC = \
	distsrc/sector_60_n2.cpp \
	distsrc/sector_60_n1.cpp \
	distsrc/sector_60_0.cpp \
	distsrc/sector_60_n2.cu \
	distsrc/sector_60_n1.cu \
	distsrc/sector_60_0.cu
SECTOR60_MMA = \
	mma/sector_60_n2.m \
	mma/sector_60_n1.m \
	mma/sector_60_0.m
SECTOR_CPP += $(SECTOR60_CPP)
SECTOR_MMA += $(SECTOR60_MMA)

$(SECTOR60_DISTSRC) $(SECTOR60_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR60_CPP)) : codegen/sector60.done ;
$(SECTOR60_MMA) : codegen/sector60.mma.done ;
