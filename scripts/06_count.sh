#!/bin/bash
#$ -cwd
#$ -N count
#$ -V
#$ -j y
#$ -o logs/$JOB_NAME.$JOB_ID.log
#$ -l h_data=6G,h_rt=3:30:00
#$ -pe shared 8
#$ -M $USER
#$ -m bea

# load python before running this script
# arg 1: basename of directory with sam files
#        located in the 06_merge_sam directory
#        or 05_hisat2_map directory (no merge)
# arg 2: basename of directory with counts
#        located in the 07_counts directory (either
#        already created or will be created by
#        this script)

cd ../

sam_dir=$1
count_dir=$2

merge_dir="06_merge_sam"
no_merge_dir="05_hisat2_map"

out_dir="07_counts"


set_src_dir () {
    if [ ! -d "./${merge_dir}/${sam_dir}" ]
    then
	source_dir=${no_merge_dir}
    else
	source_dir=${merge_dir}
    fi
}

count () {
    local file_base=$(echo $1 | grep -o "^[^.]*")
    echo $file_base
    htseq-count \
        -f sam \
        -s reverse \
        ./${source_dir}/${sam_dir}/${file_base}.sam \
        ./GENAN/gencode.vM25.annotation.gff3 > \
        ./${out_dir}/${count_dir}/${file_base}.count
}

set_src_dir
mkdir -p ./${out_dir}/${count_dir}

N=8

for file in `ls ./${source_dir}/${sam_dir}`
do
    ((i=i%N)); ((i++==0)) && wait
    count "$file" &
done
wait
