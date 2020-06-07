#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=32G,h_rt=8:00:00
#$ -pe shared 2
#$ -M $USER
#$ -m bea

# load hisat2 before running this script
# pass the base name of the directory containing 
# fq files as an argument

lane=$1


sourcedir="05_hisat2_map"
outdir="04_trim"
dir_check () {
    if [ ! -d "../${sourcedir}/" ]
    then
        mkdir ../${sourcedir}/
    fi
    if [ ! -d "../${sourcedir}/$lane" ]
    then
        mkdir ../${sourcedir}/${lane}
    fi
}

dir_check
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