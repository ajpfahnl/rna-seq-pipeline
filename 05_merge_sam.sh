#!/bin/bash
#$ -cwd
#$ -V
#$ -N merge
#$ -l h_data=4G,h_rt=4:00:00,exclusive
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

dir_check () {
    if [ ! -d "./06_merge_sam/" ]
    then
        mkdir ./06_merge_sam/
    fi
    if [ ! -d "./06_merge_sam/$merge_dir" ]
    then
        mkdir ./06_merge_sam/${merge_dir}
    fi
    if [ ! -d "./06_merge_sam/logs" ]
    then
	mkdir ./06_merge_sam/logs
    fi
}

merge () {
    local i=$1
    touch $logs_dir/$i.log
    java -jar $PICARD MergeSamFiles \
        I=${lane1_map}/$i.sam \
        I=${lane2_map}/$i.sam \
        O=06_merge_sam/${merge_dir}/${i}_merged.sam \
	> $logs_dir/$i.log \
	2>&1
}

dir_check

# number of processors
N=4

for sam in `find ./${lane1_map}/Index*.sam |
          awk 'BEGIN{FS="/"}{print $4}' |
          awk 'BEGIN{FS="."}{print $1}' |
          uniq`
do
    ((i=i%N)); ((i++==0)) && wait
    merge "$sam" &
done
wait