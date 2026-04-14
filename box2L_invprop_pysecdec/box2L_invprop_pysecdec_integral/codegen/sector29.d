SECTOR29_CPP = \
	src/sector_29.cpp \
	src/sector_29_n3.cpp \
	src/sector_29_n2.cpp \
	src/sector_29_n1.cpp \
	src/sector_29_0.cpp \
	src/contour_deformation_sector_29_n3.cpp \
	src/contour_deformation_sector_29_n2.cpp \
	src/contour_deformation_sector_29_n1.cpp \
	src/contour_deformation_sector_29_0.cpp \
	src/optimize_deformation_parameters_sector_29_n3.cpp \
	src/optimize_deformation_parameters_sector_29_n2.cpp \
	src/optimize_deformation_parameters_sector_29_n1.cpp \
	src/optimize_deformation_parameters_sector_29_0.cpp
SECTOR29_DISTSRC = \
	distsrc/sector_29_n3.cpp \
	distsrc/sector_29_n2.cpp \
	distsrc/sector_29_n1.cpp \
	distsrc/sector_29_0.cpp \
	distsrc/sector_29_n3.cu \
	distsrc/sector_29_n2.cu \
	distsrc/sector_29_n1.cu \
	distsrc/sector_29_0.cu
SECTOR29_MMA = \
	mma/sector_29_n3.m \
	mma/sector_29_n2.m \
	mma/sector_29_n1.m \
	mma/sector_29_0.m
SECTOR_CPP += $(SECTOR29_CPP)
SECTOR_MMA += $(SECTOR29_MMA)

$(SECTOR29_DISTSRC) $(SECTOR29_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR29_CPP)) : codegen/sector29.done ;
$(SECTOR29_MMA) : codegen/sector29.mma.done ;
