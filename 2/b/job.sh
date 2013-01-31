#!/bin/bash

#$ -V
#$ -cwd
#$ -q gpu
#$ -pe 1way 12
#$ -N prob
#$ -o output_prob
#$ -e error_prob
#$ -M duke.lnmiit@gmail.com
#$ -m be
#$ -l h_rt=01:00:00

module load cuda
set -x
for n in 16 32 1024 2048 4096 8192 16384 32768 65536 131072 262144  
do
./prob < rand-$n-in.txt > OUTPUT/out_diag_parallel_$n
done
