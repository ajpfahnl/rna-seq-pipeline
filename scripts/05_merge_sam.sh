#!/bin/bash
#$ -cwd
#$ -V
#$ -N merge
#$ -l h_data=4G,h_rt=4:00:00
#$ -pe shared 4
#$ -M $USER
#$ -m bea

# arg 1: basename of lane 1 to merge in 05_hisat2_map
# arg 2: basename of lane 2 to merge in 05_hisat2_map
# arg 3: merged directory name (will be created in
#        06_merge_sam)

PICARD=~/picard/build/libs/picard.jar

cd ../

lane1_map=05_hisat2_map/$1
lane2_map=05_hisat2_map/$2
merge_dir=$3
logs_dir=./06_merge_sam/logs

merge () {
    local i=$1
	local i_strip=$(echo $1 | grep -o "^[^.]*")
    touch $logs_dir/$i_strip.log
    java -jar $PICARD MergeSamFiles \
        I=${lane1_map}/$i \
        I=${lane2_map}/$i \
        O=06_merge_sam/${merge_dir}/${i_strip}_merged.sam \
	> $logs_dir/$i_strip.log \
	2>&1
}

mkdir -p ./06_merge_sam/$merge_dir
mkdir -p ./06_merge_sam/logs

# number of processors
N=4

for sam in ./$lane1_map/* ; do
    ((i=i%N)); ((i++==0)) && wait 
	sam=$(basename $sam)
	echo $sam
	merge $sam &
done
wait
