SECTOR48_CPP = \
	src/sector_48.cpp \
	src/sector_48_n3.cpp \
	src/sector_48_n2.cpp \
	src/sector_48_n1.cpp \
	src/sector_48_0.cpp \
	src/contour_deformation_sector_48_n3.cpp \
	src/contour_deformation_sector_48_n2.cpp \
	src/contour_deformation_sector_48_n1.cpp \
	src/contour_deformation_sector_48_0.cpp \
	src/optimize_deformation_parameters_sector_48_n3.cpp \
	src/optimize_deformation_parameters_sector_48_n2.cpp \
	src/optimize_deformation_parameters_sector_48_n1.cpp \
	src/optimize_deformation_parameters_sector_48_0.cpp
SECTOR48_DISTSRC = \
	distsrc/sector_48_n3.cpp \
	distsrc/sector_48_n2.cpp \
	distsrc/sector_48_n1.cpp \
	distsrc/sector_48_0.cpp \
	distsrc/sector_48_n3.cu \
	distsrc/sector_48_n2.cu \
	distsrc/sector_48_n1.cu \
	distsrc/sector_48_0.cu
SECTOR48_MMA = \
	mma/sector_48_n3.m \
	mma/sector_48_n2.m \
	mma/sector_48_n1.m \
	mma/sector_48_0.m
SECTOR_CPP += $(SECTOR48_CPP)
SECTOR_MMA += $(SECTOR48_MMA)

$(SECTOR48_DISTSRC) $(SECTOR48_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR48_CPP)) : codegen/sector48.done ;
$(SECTOR48_MMA) : codegen/sector48.mma.done ;
