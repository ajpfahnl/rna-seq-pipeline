#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=6G,h_rt=7:00:00
#$ -pe shared 4
#$ -M $USER
#$ -m bea

# load python before running this script
# arg 1: basename of directory with sam files
#        located in the 06_merge_sam directory
# arg 2: basename of directory with counts
#        located in the 07_counts directory (either
#        already created or will be created by
#        this script)
# arg 3: 1, 2, 3 ... etc of the first digit of
#        the sam files (e.g. if $3 is 2, only
#        Index20.sam, Index21.sam, ... , Index29.sam
#        will be counted
sam_dir=$1
count_dir=$2

merge_dir="06_merge_sam"
no_merge_dir="05_hisat2_map"

out_dir="07_counts"

cd ../

set_src_dir () {
    if [ ! -d "./${merge_dir}/${sam_dir}" ]
    then
	source_dir=${no_merge_dir}
    else
	source_dir=${merge_dir}
    fi
}


dir_check () {
    if [ ! -d "./${out_dir}/" ]
    then
        mkdir ./${out_dir}/
    fi
    if [ ! -d "./${out_dir}/${count_dir}" ]
    then
        mkdir ./${out_dir}/${count_dir}
    fi
}

count () {
    local file_base=$(echo $1 | grep -o "^[^.]*")
    echo $file_base
    htseq-count \
        -f sam \
        -s reverse \
        ./${source_dir}/${sam_dir}/${file_base}.sam \
        ./GENAN/gencode.vM21.annotation.gff3 > \
        ./${out_dir}/${count_dir}/${file_base}.count
}

set_src_dir
dir_check

N=4

for file in `ls ./${source_dir}/${sam_dir}`
do
    ((i=i%N)); ((i++==0)) && wait
    count "$file" &
done
wait