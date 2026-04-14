SECTOR46_CPP = \
	src/sector_46.cpp \
	src/sector_46_n3.cpp \
	src/sector_46_n2.cpp \
	src/sector_46_n1.cpp \
	src/sector_46_0.cpp \
	src/contour_deformation_sector_46_n3.cpp \
	src/contour_deformation_sector_46_n2.cpp \
	src/contour_deformation_sector_46_n1.cpp \
	src/contour_deformation_sector_46_0.cpp \
	src/optimize_deformation_parameters_sector_46_n3.cpp \
	src/optimize_deformation_parameters_sector_46_n2.cpp \
	src/optimize_deformation_parameters_sector_46_n1.cpp \
	src/optimize_deformation_parameters_sector_46_0.cpp
SECTOR46_DISTSRC = \
	distsrc/sector_46_n3.cpp \
	distsrc/sector_46_n2.cpp \
	distsrc/sector_46_n1.cpp \
	distsrc/sector_46_0.cpp \
	distsrc/sector_46_n3.cu \
	distsrc/sector_46_n2.cu \
	distsrc/sector_46_n1.cu \
	distsrc/sector_46_0.cu
SECTOR46_MMA = \
	mma/sector_46_n3.m \
	mma/sector_46_n2.m \
	mma/sector_46_n1.m \
	mma/sector_46_0.m
SECTOR_CPP += $(SECTOR46_CPP)
SECTOR_MMA += $(SECTOR46_MMA)

$(SECTOR46_DISTSRC) $(SECTOR46_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR46_CPP)) : codegen/sector46.done ;
$(SECTOR46_MMA) : codegen/sector46.mma.done ;
