SECTOR26_CPP = \
	src/sector_26.cpp \
	src/sector_26_n2.cpp \
	src/sector_26_n1.cpp \
	src/sector_26_0.cpp \
	src/contour_deformation_sector_26_n2.cpp \
	src/contour_deformation_sector_26_n1.cpp \
	src/contour_deformation_sector_26_0.cpp \
	src/optimize_deformation_parameters_sector_26_n2.cpp \
	src/optimize_deformation_parameters_sector_26_n1.cpp \
	src/optimize_deformation_parameters_sector_26_0.cpp
SECTOR26_DISTSRC = \
	distsrc/sector_26_n2.cpp \
	distsrc/sector_26_n1.cpp \
	distsrc/sector_26_0.cpp \
	distsrc/sector_26_n2.cu \
	distsrc/sector_26_n1.cu \
	distsrc/sector_26_0.cu
SECTOR26_MMA = \
	mma/sector_26_n2.m \
	mma/sector_26_n1.m \
	mma/sector_26_0.m
SECTOR_CPP += $(SECTOR26_CPP)
SECTOR_MMA += $(SECTOR26_MMA)

$(SECTOR26_DISTSRC) $(SECTOR26_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR26_CPP)) : codegen/sector26.done ;
$(SECTOR26_MMA) : codegen/sector26.mma.done ;
