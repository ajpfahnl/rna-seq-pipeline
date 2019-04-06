# RNA-seq pipeline

This is a custom RNA-seq pipeline that I have been using to convert raw Illumina RNA-seq datasets to lists of genes
in the Tarling-Vallim lab.

## Getting Started

To execute this pipeline, you will need an account on the Hoffman server. I do everything in my scratch folder.

### Prerequisites

You will need the following installed before you begin your analyses.

## 1. Demultiplexing

Multiple samples are pooled together during the sequencing run in the same lane, but given unique barcodes. Demultiplexing divides the raw reads into separate samples for analysis. We will do this using htSeqTools.

### Installing Sean Gallaher htSeqTools
```
curl https://bitbucket.org/gallaher/htseqtools/get/master.zip -o htSeqTools.zip
unzip htSeqTools.zip
mv gallaher* htSeqTools/
rm htSeqTools.zip
```
Once htSeqTools has been installed, create a bash script to perform the demultiplexing using the following code.
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=8g,h_rt=48:00:00,highp

CRED='SxaQSEQsYB051L3'
cd ../$CRED/$CRED
pwd
LANE=$(echo $CRED | sed -E 's/SxaQSEQs.{5}L(.):.{12}/lane_\1/')
qseq2fastq
cd ../../02_fastq/$LANE/
demultiplexer
```



