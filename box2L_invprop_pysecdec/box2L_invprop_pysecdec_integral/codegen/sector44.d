SECTOR44_CPP = \
	src/sector_44.cpp \
	src/sector_44_n2.cpp \
	src/sector_44_n1.cpp \
	src/sector_44_0.cpp \
	src/contour_deformation_sector_44_n2.cpp \
	src/contour_deformation_sector_44_n1.cpp \
	src/contour_deformation_sector_44_0.cpp \
	src/optimize_deformation_parameters_sector_44_n2.cpp \
	src/optimize_deformation_parameters_sector_44_n1.cpp \
	src/optimize_deformation_parameters_sector_44_0.cpp
SECTOR44_DISTSRC = \
	distsrc/sector_44_n2.cpp \
	distsrc/sector_44_n1.cpp \
	distsrc/sector_44_0.cpp \
	distsrc/sector_44_n2.cu \
	distsrc/sector_44_n1.cu \
	distsrc/sector_44_0.cu
SECTOR44_MMA = \
	mma/sector_44_n2.m \
	mma/sector_44_n1.m \
	mma/sector_44_0.m
SECTOR_CPP += $(SECTOR44_CPP)
SECTOR_MMA += $(SECTOR44_MMA)

$(SECTOR44_DISTSRC) $(SECTOR44_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR44_CPP)) : codegen/sector44.done ;
$(SECTOR44_MMA) : codegen/sector44.mma.done ;
