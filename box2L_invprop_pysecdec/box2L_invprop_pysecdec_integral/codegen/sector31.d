SECTOR31_CPP = \
	src/sector_31.cpp \
	src/sector_31_n4.cpp \
	src/sector_31_n3.cpp \
	src/sector_31_n2.cpp \
	src/sector_31_n1.cpp \
	src/sector_31_0.cpp \
	src/contour_deformation_sector_31_n4.cpp \
	src/contour_deformation_sector_31_n3.cpp \
	src/contour_deformation_sector_31_n2.cpp \
	src/contour_deformation_sector_31_n1.cpp \
	src/contour_deformation_sector_31_0.cpp \
	src/optimize_deformation_parameters_sector_31_n4.cpp \
	src/optimize_deformation_parameters_sector_31_n3.cpp \
	src/optimize_deformation_parameters_sector_31_n2.cpp \
	src/optimize_deformation_parameters_sector_31_n1.cpp \
	src/optimize_deformation_parameters_sector_31_0.cpp
SECTOR31_DISTSRC = \
	distsrc/sector_31_n4.cpp \
	distsrc/sector_31_n3.cpp \
	distsrc/sector_31_n2.cpp \
	distsrc/sector_31_n1.cpp \
	distsrc/sector_31_0.cpp \
	distsrc/sector_31_n4.cu \
	distsrc/sector_31_n3.cu \
	distsrc/sector_31_n2.cu \
	distsrc/sector_31_n1.cu \
	distsrc/sector_31_0.cu
SECTOR31_MMA = \
	mma/sector_31_n4.m \
	mma/sector_31_n3.m \
	mma/sector_31_n2.m \
	mma/sector_31_n1.m \
	mma/sector_31_0.m
SECTOR_CPP += $(SECTOR31_CPP)
SECTOR_MMA += $(SECTOR31_MMA)

$(SECTOR31_DISTSRC) $(SECTOR31_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR31_CPP)) : codegen/sector31.done ;
$(SECTOR31_MMA) : codegen/sector31.mma.done ;
