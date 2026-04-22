.PHONY: clean cleanall integrators

integrators:
	rm -f install.log;
	if [ -d ${PWD}/Cuba-4.1 ]; then echo "Compiling Cuba"; ( cd Cuba-4.1 && ./configure && make lib ) >> install.log 2>&1; fi;
	if [ -d ${PWD}/cquad ]; then echo "Compiling Quadpack"; ( cd cquad && ./configure -prefix=${PWD}/cquad --libdir=${PWD}/cquad/lib && make && make install ) >> install.log 2>&1; fi; 
	if [ -d "sobol" ]; then echo "Compiling Sobol random sampler"; ( cd sobol && gcc -O -c sobol.cc ) >> install.log 2>&1 || echo "Could not compile Sobol random sampler"; fi;

clean:
	rm -rf *.o
	rm -rf *.exe

cleanall: clean
	rm -rf *.cc
