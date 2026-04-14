SECTOR43_CPP = \
	src/sector_43.cpp \
	src/sector_43_n2.cpp \
	src/sector_43_n1.cpp \
	src/sector_43_0.cpp \
	src/contour_deformation_sector_43_n2.cpp \
	src/contour_deformation_sector_43_n1.cpp \
	src/contour_deformation_sector_43_0.cpp \
	src/optimize_deformation_parameters_sector_43_n2.cpp \
	src/optimize_deformation_parameters_sector_43_n1.cpp \
	src/optimize_deformation_parameters_sector_43_0.cpp
SECTOR43_DISTSRC = \
	distsrc/sector_43_n2.cpp \
	distsrc/sector_43_n1.cpp \
	distsrc/sector_43_0.cpp \
	distsrc/sector_43_n2.cu \
	distsrc/sector_43_n1.cu \
	distsrc/sector_43_0.cu
SECTOR43_MMA = \
	mma/sector_43_n2.m \
	mma/sector_43_n1.m \
	mma/sector_43_0.m
SECTOR_CPP += $(SECTOR43_CPP)
SECTOR_MMA += $(SECTOR43_MMA)

$(SECTOR43_DISTSRC) $(SECTOR43_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR43_CPP)) : codegen/sector43.done ;
$(SECTOR43_MMA) : codegen/sector43.mma.done ;
