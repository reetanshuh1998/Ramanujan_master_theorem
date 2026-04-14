SECTOR38_CPP = \
	src/sector_38.cpp \
	src/sector_38_n3.cpp \
	src/sector_38_n2.cpp \
	src/sector_38_n1.cpp \
	src/sector_38_0.cpp \
	src/contour_deformation_sector_38_n3.cpp \
	src/contour_deformation_sector_38_n2.cpp \
	src/contour_deformation_sector_38_n1.cpp \
	src/contour_deformation_sector_38_0.cpp \
	src/optimize_deformation_parameters_sector_38_n3.cpp \
	src/optimize_deformation_parameters_sector_38_n2.cpp \
	src/optimize_deformation_parameters_sector_38_n1.cpp \
	src/optimize_deformation_parameters_sector_38_0.cpp
SECTOR38_DISTSRC = \
	distsrc/sector_38_n3.cpp \
	distsrc/sector_38_n2.cpp \
	distsrc/sector_38_n1.cpp \
	distsrc/sector_38_0.cpp \
	distsrc/sector_38_n3.cu \
	distsrc/sector_38_n2.cu \
	distsrc/sector_38_n1.cu \
	distsrc/sector_38_0.cu
SECTOR38_MMA = \
	mma/sector_38_n3.m \
	mma/sector_38_n2.m \
	mma/sector_38_n1.m \
	mma/sector_38_0.m
SECTOR_CPP += $(SECTOR38_CPP)
SECTOR_MMA += $(SECTOR38_MMA)

$(SECTOR38_DISTSRC) $(SECTOR38_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR38_CPP)) : codegen/sector38.done ;
$(SECTOR38_MMA) : codegen/sector38.mma.done ;
