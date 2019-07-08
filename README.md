# RNA-seq pipeline

This is a custom RNA-seq pipeline that I have been using to convert raw Illumina RNA-seq datasets to lists of genes
in the Tarling-Vallim lab.

## Getting Started

To execute this pipeline, you will need an account on the Hoffman server. I do everything in my scratch folder.

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
To copy the resulting html files to the Desktop, use the following command.
```
tims-mbp:Desktop timyu$ scp timyu98@Hoffman2.idre.ucla.edu:/u/flashscratch/t/timyu98/FastQC_reports/L3_Index12_trimmed.for_fastqc.html ./
```
## 4. Mapping
We perform mapping using hisat2. hisat2 maps sequencing data to a single reference genome. This will allow us to infer what transcripts are being expressed. The first step is to download a reference genome.

### Obtaining Reference Genome and Installing hisat2
```
mkdir GENCODE
cd GENCODE
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grcm38.tar.gz
tar xvf grcm38.tar.gz
```
The above is an outdated version. The current updated version is:
```
mkdir GENCODE
cd GENCODE
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M21/GRCm38.p6.genome.fa.gz
```


Before running, make sure you load the hisat2 module.
```
module load hisat2
```
We create a script hisat2_map.sh that performs the mapping using a specified path.
```
#!/bin/bash
#load hisat2 before running this script
#use path='PATH' to directory containing fq files

cd ${path}
for i in ` ls Index*.fq |  awk 'BEGIN{FS="_"}{print $1}' | uniq`
do
fqFileName=${i}_trimmed.for.fq
outFileName=${i}.sam
hisat2 -q -p 8 -x /u/flashscratch/t/timyu98/GENCODE/grcm38/genome -U $fqFileName -S $outFileName
done
```
To run, use the following command. You will need to do this for each lane's trimmed folder.
```
qsub -V -N hisat2L3 -l h_data=4G,h_rt=8:00:00 -pe shared 8 -v path='/u/flashscratch/t/timyu98/L3_trimmed-fq/' hisat2_map.sh
```
Lastly, we can view the statistics of the alignment by checking the error output once the script has terminated.

## 5. Merging
If we have replicates, now is the time to merge the datasets together. For instance if lane 2 and lane 3 are replicates of one another, then we merge their mapped reads together. We do this using picard tools.

### Installing picard tools
```
wget https://github.com/broadinstitute/picard/releases/download/2.18.15/picard.jar -O picard.jar
```
Before merging, we load picard tools using the following command:
```
module load picard_tools
```
Next, we create a bash script mergeSam.sh to merge the sam files output by the previous step using the following code.
```
#!/bin/bash
#load picard_tools before running this script
#use L1dir='PATHtoL1' L2dir='PATHtoL2' mergedir='PATHtoDestination' to indicate paths for directories to L1, L2, and merged sam destination
cd $SCRATCH/${L1dir}
for i in `ls Index*.sam |  awk 'BEGIN{FS="."}{print $1}' | uniq`
do
java -jar $PICARD MergeSamFiles \
I=$i.sam \
I=../${L2dir}/$i.sam \
O=../${mergedir}/${i}_merged.sam
done
```
We can then merge lanes 2 and 3 using the following command:
```
qsub -V -N mergeSam_23 -l h_data=8G,h_rt=8:00:00 -pe shared 2 -v L1dir='L2_sam' -v L2dir='L3_sam' -v mergedir='L2L3_merged' mergeSam.sh
```
## 6. Counting
We've finally made it to the last step! Here, we'll generate counts for each of the genes that we mapped our reads too. The final product will be a list of genes and their counts. We will do this using htseq-count.
### Download this (note: outdated)
Create a directory to store the downloaded gene annotations. This file is outdated. If you want to use it, you must make sure to download the proper key for this file when you do downstream analyses.
```
cd GENCODE
wget ftp://ftp.ensembl.org/pub/release-84/gtf/mus_musculus/Mus_musculus.GRCm38.84.gtf.gz
gunzip Mus_musculus.GRCm38.84.gtf.gz
```
### Installing htseq-count
```
wget https://github.com/simon-anders/htseq/archive/release_0.11.0.tar.gz
tar -zxvf release_0.11.0.tar.gz
cd htseq-release_0.11.0/
python setup.py install --user
chmod +x scripts/htseq-count
```
If you're having any trouble downloading/using htseq-count, make sure that your Python version is set to Python 2.6.6. You can do this easily with the following two-liner.
```
alias python=python2
module load python/2.7
```
Similar to trimming, we split the counting into three sets to parallelize it. As such, we have:
count0.sh
```
#!/bin/bash
#load python before running this script
cd $SCRATCH
for i in `ls ./${indir}/*0?_*.sam | awk 'BEGIN{FS="/"}{print$3}' | awk 'BEGIN{FS="_"}{print$1}' | uniq`
do
htseq-count -f bam -s reverse ./${indir}/${i}_merged.sam /u/scratch/t/timyu98/GENCODE/Mus_musculus.GRCm38.84.gtf > ./${outdir}/${i}.count
done
```
count1.sh
```
#!/bin/bash
#load python before running this script
cd $SCRATCH
for i in `ls ./${indir}/*1?_*.sam | awk 'BEGIN{FS="/"}{print$3}' | awk 'BEGIN{FS="_"}{print$1}' | uniq`
do
htseq-count -f bam -s reverse ./${indir}/${i}_merged.sam /u/scratch/t/timyu98/GENCODE/Mus_musculus.GRCm38.84.gtf > ./${outdir}/${i}.count
done
```
count2.sh
```
#!/bin/bash
#load python before running this script
cd $SCRATCH
for i in `ls ./${indir}/*2?_*.sam | awk 'BEGIN{FS="/"}{print$3}' | awk 'BEGIN{FS="_"}{print$1}' | uniq`
do
htseq-count -f bam -s reverse ./${indir}/${i}_merged.sam /u/scratch/t/timyu98/GENCODE/Mus_musculus.GRCm38.84.gtf > ./${outdir}/${i}.count
done
```
Finally, to run each of these scripts. Use the following command format:
```
qsub -V -l h_data=4G,h_rt=7:00:00 -pe shared 8 -v indir='L2L3_merged' -v outdir='L2L3_counts' count0.sh
```
The resulting count files can be transferred to the local computer for downstream analyses.
