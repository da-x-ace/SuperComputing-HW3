############################################
## This file contains information about   ##
## each file in this folder.              ##
############################################

1) serial.cpp
	This file is the serial implementation of the problem

2) prob.cu
	This file is the parallel implementation of the problem

3) job.sh
	This file will run the job for executable "prob"

4) Makefile
	This file will compile the prob.cu to "prob" executable.


In this, we need to pass "k" as argv[1], and it will randomly
allocate that much elements. It will print the array if N = 2^{k} <= 256.
