#!/bin/bash
#$ -cwd
#$ -V
#$ -j y
#$ -o logs/$JOB_NAME.$JOB_ID.log
#$ -N index_build
#$ -l h_rt=1:00:00,h_data=4G -pe shared 4
#$ -M $USER
#$ -m bea

# gunzip GENCODE/GRCm38.p6.genome.fa.gz
hisat2-build ../GENCODE/GRCm38.p6.genome.fa -p 4 ../GENCODE/GRCm38
