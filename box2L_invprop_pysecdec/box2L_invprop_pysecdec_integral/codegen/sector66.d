SECTOR66_CPP = \
	src/sector_66.cpp \
	src/sector_66_n2.cpp \
	src/sector_66_n1.cpp \
	src/sector_66_0.cpp \
	src/contour_deformation_sector_66_n2.cpp \
	src/contour_deformation_sector_66_n1.cpp \
	src/contour_deformation_sector_66_0.cpp \
	src/optimize_deformation_parameters_sector_66_n2.cpp \
	src/optimize_deformation_parameters_sector_66_n1.cpp \
	src/optimize_deformation_parameters_sector_66_0.cpp
SECTOR66_DISTSRC = \
	distsrc/sector_66_n2.cpp \
	distsrc/sector_66_n1.cpp \
	distsrc/sector_66_0.cpp \
	distsrc/sector_66_n2.cu \
	distsrc/sector_66_n1.cu \
	distsrc/sector_66_0.cu
SECTOR66_MMA = \
	mma/sector_66_n2.m \
	mma/sector_66_n1.m \
	mma/sector_66_0.m
SECTOR_CPP += $(SECTOR66_CPP)
SECTOR_MMA += $(SECTOR66_MMA)

$(SECTOR66_DISTSRC) $(SECTOR66_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR66_CPP)) : codegen/sector66.done ;
$(SECTOR66_MMA) : codegen/sector66.mma.done ;
