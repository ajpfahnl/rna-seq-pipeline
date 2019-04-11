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
This will create a directory called 02_fastq that contains all fastq files, and a directory called 03_demultiplexed that contains all demultiplexed files for each lane.

## 2. Trimming
This is a necessary step because we need to trim adaptor sequences that were added on for sequencing after isolating RNA. We then remove any low quality bases based on a Q value (which is defined as the negative log of the probability the base was called incorrectly). The Q value tends to decrease (quality gets worse) towards the 3’ end of the read. These lower quality regions can negatively impact downstream analyses such as mapping, mutation calling, etc. We will do this using cutadapt.

### Installing cutadapt
```
module avail python
module load python/3.7.2
pip3 install --user --upgrade cutadapt
```
We create 3 scripts in each lane's demultiplexed folder called trim00s.sh, trim10s.sh, trim20s.sh to parallelize the trimming.
#### trim00s.sh
```
#!/bin/bash
#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30
#on files 01-09

for i in {1..9}
do
fastq="Index0${i}.for.fq"
trimmedFastq="Index0${i}_trimmed.for.fq"
/u/home/t/timyu98/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG -a "A{10}" -a "T{10}" -m 15 -q 30 -o ../../L3_trimmed-fq/$trimmedFastq $fastq
done
```
#### trim10s.sh
```
#!/bin/bash
#runs cutadapt with options -m 15 -q 30
#on files 10-19, skipping 17

for i in {0..6} {8..9}
do
fastq="Index1${i}.for.fq"
trimmedFastq="Index1${i}_trimmed.for.fq"
/u/home/t/timyu98/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG -a "A{10}" -a "T{10}" -m 15 -q 30 -o ../../L3_trimmed-fq/$trimmedFastq $fastq
done
```
#### trim20s.sh
```
#!/bin/bash
#runs cutadapt with options -m 15 -q 30
#on files 20-23, 25, 27

for i in 0 1 2 3 5 7
do
fastq="Index2${i}.for.fq"
trimmedFastq="Index2${i}_trimmed.for.fq"
/u/home/t/timyu98/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG -a "A{10}" -a "T{10}" -m 15 -q 30 -o ../../L3_trimmed-fq/$trimmedFastq $fastq
done
```
Before you run the trimming, make sure that Python 3.7 is launched. Sometimes, Terminal can get pretty annoying about this and so an easy way to ensure this is to use the following two line command.
```
alias python=python3
module load python/3.7.0
```
To run the trimming, use the following command for each of the 3 scripts in every demultiplexed lane folder.
```
qsub -cwd -V -N L3_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh
```
## 3. Quality Control
The purpose of quality control is to look for repetitive sequences. If it's there, it could be due to an error where the machine keeps sequencing the same fragment over and over again. As such, we need to get rid of it from the whole pool of sequences. Another issue is that maybe when trimming we didn't trim enough and kept a little of the adaptor sequences. We can check if something matches an illumina adaptor here. Lastly, we look for overrepresentation of certain base pairs at a particular position along fragment, since they should be equally divided.

### Installing FastQC
```
mkdir FastQC_reports
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.7.zip
unzip fastqc_v0.11.7.zip
chmod 755 fastqc
```
Run this following command on a random index sample from each of the trimmed directories.
```
 ~/FastQC/fastqc --outdir=FastQC_reports ./L3_trimmed-fq/Index12_trimmed.for.fq
```
## 4. Mapping
We perform mapping using HISAT2.
