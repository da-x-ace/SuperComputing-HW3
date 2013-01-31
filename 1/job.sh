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
for n in  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 
do

./prob $n > OUTPUT_SERIAL/parallel_$n

done
