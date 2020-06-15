#!/bin/bash
#$ -cwd
#$ -V
#$ -N index_build
#$ -l h_data=32G,h_rt=8:00:00,exclusive
#$ -M $USER
#$ -m bea

#gunzip ../GENCODE/GRCm38.p6.genome.fa.gz
hisat2-build ../GENCODE/GRCm38.p6.genome.fa -p 8 ../GENCODE/GRCm38