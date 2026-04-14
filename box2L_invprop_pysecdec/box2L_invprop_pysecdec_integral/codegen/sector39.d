SECTOR39_CPP = \
	src/sector_39.cpp \
	src/sector_39_n4.cpp \
	src/sector_39_n3.cpp \
	src/sector_39_n2.cpp \
	src/sector_39_n1.cpp \
	src/sector_39_0.cpp \
	src/contour_deformation_sector_39_n4.cpp \
	src/contour_deformation_sector_39_n3.cpp \
	src/contour_deformation_sector_39_n2.cpp \
	src/contour_deformation_sector_39_n1.cpp \
	src/contour_deformation_sector_39_0.cpp \
	src/optimize_deformation_parameters_sector_39_n4.cpp \
	src/optimize_deformation_parameters_sector_39_n3.cpp \
	src/optimize_deformation_parameters_sector_39_n2.cpp \
	src/optimize_deformation_parameters_sector_39_n1.cpp \
	src/optimize_deformation_parameters_sector_39_0.cpp
SECTOR39_DISTSRC = \
	distsrc/sector_39_n4.cpp \
	distsrc/sector_39_n3.cpp \
	distsrc/sector_39_n2.cpp \
	distsrc/sector_39_n1.cpp \
	distsrc/sector_39_0.cpp \
	distsrc/sector_39_n4.cu \
	distsrc/sector_39_n3.cu \
	distsrc/sector_39_n2.cu \
	distsrc/sector_39_n1.cu \
	distsrc/sector_39_0.cu
SECTOR39_MMA = \
	mma/sector_39_n4.m \
	mma/sector_39_n3.m \
	mma/sector_39_n2.m \
	mma/sector_39_n1.m \
	mma/sector_39_0.m
SECTOR_CPP += $(SECTOR39_CPP)
SECTOR_MMA += $(SECTOR39_MMA)

$(SECTOR39_DISTSRC) $(SECTOR39_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR39_CPP)) : codegen/sector39.done ;
$(SECTOR39_MMA) : codegen/sector39.mma.done ;
