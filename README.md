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
Once htSeqTools has been installed, create a bash script to perform the demultiplexing using the following code. Here, I created a script named demultiplex_L3.sh to demultiplex lane 3. CRED refers to the name of the folder containing the raw qseq files. Note that the cd commands may need to be modified accordingly depending on the hierarchy of your files in order to access the correct directory!
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
To run this script, use the following command:
```
qsub demultiplex_L3.sh
```

