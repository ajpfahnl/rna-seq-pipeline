#!/bin/bash
#$ -cwd
#$ -N demultiplex
#$ -V
#$ -l h_data=16g,h_rt=48:00:00,highp
#$ -pe shared 2
#$ -M $USER
#$ -m bea 

CRED_list='SxaQSEQsYB051L3 SxaQSEQsYB051L4'
demultiplex () {
    local CRED=$1
    cd ../01_qseq/$CRED
    pwd
    local LANE=$(echo $CRED | sed -E 's/SxaQSEQs.{5}L(.):.{12}/lane_\1/')
    qseq2fastq
    cd ../../02_fastq/$LANE/
    demultiplexer
}
for CRED in $CRED_list; do demultiplex "$CRED" & done
wait
echo "Done demultiplexing"