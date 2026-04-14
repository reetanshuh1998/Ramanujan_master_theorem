SECTOR21_CPP = \
	src/sector_21.cpp \
	src/sector_21_n4.cpp \
	src/sector_21_n3.cpp \
	src/sector_21_n2.cpp \
	src/sector_21_n1.cpp \
	src/sector_21_0.cpp \
	src/contour_deformation_sector_21_n4.cpp \
	src/contour_deformation_sector_21_n3.cpp \
	src/contour_deformation_sector_21_n2.cpp \
	src/contour_deformation_sector_21_n1.cpp \
	src/contour_deformation_sector_21_0.cpp \
	src/optimize_deformation_parameters_sector_21_n4.cpp \
	src/optimize_deformation_parameters_sector_21_n3.cpp \
	src/optimize_deformation_parameters_sector_21_n2.cpp \
	src/optimize_deformation_parameters_sector_21_n1.cpp \
	src/optimize_deformation_parameters_sector_21_0.cpp
SECTOR21_DISTSRC = \
	distsrc/sector_21_n4.cpp \
	distsrc/sector_21_n3.cpp \
	distsrc/sector_21_n2.cpp \
	distsrc/sector_21_n1.cpp \
	distsrc/sector_21_0.cpp \
	distsrc/sector_21_n4.cu \
	distsrc/sector_21_n3.cu \
	distsrc/sector_21_n2.cu \
	distsrc/sector_21_n1.cu \
	distsrc/sector_21_0.cu
SECTOR21_MMA = \
	mma/sector_21_n4.m \
	mma/sector_21_n3.m \
	mma/sector_21_n2.m \
	mma/sector_21_n1.m \
	mma/sector_21_0.m
SECTOR_CPP += $(SECTOR21_CPP)
SECTOR_MMA += $(SECTOR21_MMA)

$(SECTOR21_DISTSRC) $(SECTOR21_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR21_CPP)) : codegen/sector21.done ;
$(SECTOR21_MMA) : codegen/sector21.mma.done ;
