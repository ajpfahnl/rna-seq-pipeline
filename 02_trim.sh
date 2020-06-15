#!/bin/bash
#$ -cwd
#$ -V
#$ -N trim
#$ -l h_data=32G,h_rt=2:00:00,exclusive
# -l h_data=8G,h_rt=2:00:00
# -pe shared 8
#$ -M $USER
#$ -m bea

#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30

lanes="TV_2083_ZFP36_Cre_2D_7D"

trim () {
    local fastq=$1
    local lane=$2
    local trimmedFastq="trim_${fastq}"
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
}

lane_trim () {
    local lane=$1
    cd ../03_demultiplexed/$lane
    # trim each file in parallel
    for file in *; do trim "$file" "$lane" & done
    wait
}

dir_check () {
    local lane=$1
    if [ ! -d "../04_trim/" ]
    then
	mkdir ../04_trim
    fi
    if [ ! -d "../04_trim/$lane" ]
    then
	mkdir ../04_trim/${lane}
    fi
}

# check and create necessary directories
for lane in $lanes; do dir_check "$lane"; done
# trim each lane in parallel
for lane in $lanes; do lane_trim "$lane" & done
wait
echo "Finished trimming"