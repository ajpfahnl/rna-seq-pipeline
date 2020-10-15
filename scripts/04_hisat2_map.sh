#!/bin/bash
#$ -cwd
#$ -V
#$ -j y
#$ -o logs/$JOB_NAME.$JOB_ID.log
#$ -l h_data=5G,h_rt=4:00:00
#$ -pe shared 4
#$ -M $USER
#$ -m bea

# load hisat2 before running this script
# pass the base name of the directory containing 
# fq files as an argument

lane=$1

sourcedir="05_hisat2_map"
outdir="04_trim"

mkdir -p ../${sourcedir}/${lane}

cd ../$outdir/$lane

for i in *
do
    fqFileName=$i
    fqNoExt=$(echo $i | grep -o "^[^.]*")
    outFileName=../../05_hisat2_map/$lane/${fqNoExt}.sam
    hisat2 \
		-q \
		-p 4 \
		-x ../../GENCODE/GRCm38 \
		-U $fqFileName \
		-S $outFileName
done
