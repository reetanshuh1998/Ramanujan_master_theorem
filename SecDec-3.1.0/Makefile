run:
	./install/install

.PHONY: check clean cleanall
check:
	./check/check 2

clean:
	rm -rf check/checks/*/{temp,backup}*

cleanall: clean
	rm -f src/sobol/sobol.hh.gch
	rm -f src/sobol/sobol.o
	# to do, cquad, cuba
