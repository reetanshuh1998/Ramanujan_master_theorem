SECTOR53_CPP = \
	src/sector_53.cpp \
	src/sector_53_n3.cpp \
	src/sector_53_n2.cpp \
	src/sector_53_n1.cpp \
	src/sector_53_0.cpp \
	src/contour_deformation_sector_53_n3.cpp \
	src/contour_deformation_sector_53_n2.cpp \
	src/contour_deformation_sector_53_n1.cpp \
	src/contour_deformation_sector_53_0.cpp \
	src/optimize_deformation_parameters_sector_53_n3.cpp \
	src/optimize_deformation_parameters_sector_53_n2.cpp \
	src/optimize_deformation_parameters_sector_53_n1.cpp \
	src/optimize_deformation_parameters_sector_53_0.cpp
SECTOR53_DISTSRC = \
	distsrc/sector_53_n3.cpp \
	distsrc/sector_53_n2.cpp \
	distsrc/sector_53_n1.cpp \
	distsrc/sector_53_0.cpp \
	distsrc/sector_53_n3.cu \
	distsrc/sector_53_n2.cu \
	distsrc/sector_53_n1.cu \
	distsrc/sector_53_0.cu
SECTOR53_MMA = \
	mma/sector_53_n3.m \
	mma/sector_53_n2.m \
	mma/sector_53_n1.m \
	mma/sector_53_0.m
SECTOR_CPP += $(SECTOR53_CPP)
SECTOR_MMA += $(SECTOR53_MMA)

$(SECTOR53_DISTSRC) $(SECTOR53_CPP) $(patsubst %.cpp,%.hpp,$(SECTOR53_CPP)) : codegen/sector53.done ;
$(SECTOR53_MMA) : codegen/sector53.mma.done ;
