# README #

FIESTA stands for Feynman Integral Evaluation by a Sector decomposiTion Approach.

### Articles ###

* [FIESTA1](http://arxiv.org/abs/0807.4129) (basic version)
* [FIESTA2](http://arxiv.org/abs/0912.0158) (mpfr)
* [FIESTA3](http://arxiv.org/abs/1312.3186) (physical regions, databases, mpi)
* [FIESTA4](http://arxiv.org/abs/1511.03614) (vectorization, gpu)

Papers about FIESTA1-4 were published in Computer Physics Communications. 

**
IMPORTANT NOTICE: ALL VERSIONS 2.7-4.0 HAVE AN ERROR THAT CAN PRODUCE TO WRONG RESULTS! YOU SHOULD EITHER
**

* switch to 4.1
* set SmallX = 0.001 in Mathematica
* use -SmallX 0.001 when directly using CIntegratePool (old databases can be used)

### Installation ###

Either download a binary package, or

* git clone https://bitbucket.org/feynmanIntegrals/fiesta.git
* cd fiesta/FIESTA4
* make dep (if you do not have kyotocabinet and cuba installed)
* make

Those who had a clone before the url change should run

* git remote set-url origin git@bitbucket.org:feynmanIntegrals/fiesta.git

### Usage ###

* make test (just to get sure that the binaries work)
* Follow the instuctions in the articles
* There are some examples in the examples folder

### Versions ###

Static versions 4.0 and 4.1 build on Ubuntu 14.10 64bit can be found on the Download page.

Version 4 comes with speed improvements, bug fixes and the possibility to use GPUs.