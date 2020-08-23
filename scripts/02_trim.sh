#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=8G,h_rt=2:00:00
#$ -pe shared 4
#$ -M $USER
#$ -m bea

#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30

lane=$1

# number of cores
N=4

# -- rna-seq-pipeline
#     |-- demuxdir
#     |-- trimdir

demuxdir=03_demultiplexed
trimdir=04_trim

trim () {
	local fastq=$1
    local lane=$2
    local trimmedFastq="trim_${fastq}"
    echo "Creating trimmed file: $trimmedFastq"
	cutadapt \
		--quiet \
		-j 0 \
        -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG \
        -a "A{10}" \
        -a "T{10}" \
        -m 15 \
        -q 30 \
        -o ../../04_trim/$lane/$trimmedFastq \
	$fastq
	echo "Finished creating: $trimmedFastq"
}

lane_trim () {
    local lane=$1
    # trim each file in parallel
    for file in *; do 
		((i=i%N)); ((i++==0)) && wait
		trim "$file" "$lane" & 
	done
}

dir_check () {
    local lane=$1
    if [ ! -d "../$trimdir" ]
    then
	mkdir ../$trimdir
    fi
    if [ ! -d "../$trimdir/$lane" ]
    then
	mkdir ../$trimdir/$lane
    fi
}

# check and create necessary directories
dir_check $lane
# trim lane
cd ../$demuxdir/$lane
lane_trim $lane

echo "Finished trimming"
