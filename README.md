# RNA-seq pipeline

This is a custom RNA-seq pipeline that I have been using to convert raw Illumina RNA-seq datasets to lists of genes
in the Tarling-Vallim lab.

## Getting Started

To execute this pipeline, you will need an account on the Hoffman2 server. I do everything in a folder `rna-seq` in my `$SCRATCH` folder.

Create a folder `scripts` within `rna-seq` where we store all our scripts.

For more information on submitting batch jobs to Univa Grid Engine, look under section 4 of this pdf: http://www.univa.com/resources/files/univa_user_guide_univa__grid_engine_854.pdf \
Section 4.2.2: Example 2: An Advanced Batch Job is particularly helpful.

The IDRE Hoffman2 webpage on commonly-used UGE commands is here: \
https://www.hoffman2.idre.ucla.edu/computing/sge/#qsub \
Also look here: \
https://www.hoffman2.idre.ucla.edu/computing/running/#Build_a_UGE_command_file_for_your_job_and_use_UGE_commands_directly


## 1. Demultiplexing

Multiple samples are pooled together during the sequencing run in the same lane, but given unique barcodes. Demultiplexing divides the raw reads into separate samples for analysis. We will do this using `htSeqTools`.

### Installing Sean Gallaher htSeqTools
```
curl https://bitbucket.org/gallaher/htseqtools/get/master.zip -o htSeqTools.zip
unzip htSeqTools.zip
mv gallaher* htSeqTools/
rm htSeqTools.zip
```
Make sure to add to your `$PATH` variable by adding the following lines to `~/.bash_profile`:
```
PATH="$PATH:<directory with htSeqTools>/htSeqTools/bin"
PATH="$PATH:~/.local/bin"
```
The `~/.local/bin` folder is important for `cutadapt` used later.

Once `htSeqTools` has been installed, create a bash script to perform the demultiplexing using the following code. \
`$CRED_list` is a list of folders containing raw qseq files separated by spaces. The following script assumes `$CRED` folders are located in a folder `01_qseq`. Adjust `cd` commands as necessary. \
You may also need to adjust the output path in the `demultiplexer` or `qseq2fastq` Perl scripts that you installed from `htSeqTools`.
#### demultiplex.sh
```
#!/bin/bash
#$ -cwd
#$ -N demultiplex
#$ -V
#$ -l h_data=16g,h_rt=8:00:00
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
```
To run this script, use the following command:
```
qsub demultiplex.sh
```
This will create a directory called `02_fastq` that contains all fastq files, and a directory called `03_demultiplexed` that contains all demultiplexed files for each lane.

## 2. Trimming
This is a necessary step because we need to trim adaptor sequences that were added on for sequencing after isolating RNA. We then remove any low quality bases based on a Q value (which is defined as the negative log of the probability the base was called incorrectly). The Q value tends to decrease (quality gets worse) towards the 3’ end of the read. These lower quality regions can negatively impact downstream analyses such as mapping, mutation calling, etc. We will do this using cutadapt.

### Installing cutadapt
```
module avail python
module load python/3.7.2
pip3 install --user --upgrade cutadapt
```
Make sure the `~/.local/bin` folder is added to `$PATH`.

We create 3 scripts in each lane's demultiplexed folder called trim00s.sh, trim10s.sh, trim20s.sh to parallelize the trimming.
#### 02_trim.sh
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -N L3_trim00s
#$ -l h_data=32G,h_rt=8:00:00,exclusive
# -pe shared 4
#$ -M $USER
#$ -m bea

#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30

lanes="SxaQSEQsYB051L3 SxaQSEQsYB051L4"

trim () {
    local fastq=$1
    local lane=$2
    local num=$(echo ${fastq} | grep -o "[0-9][0-9]")
    echo $num
    local trimmedFastq="Index${num}_trimmed.for.fq"
    cutadapt \
	--quiet
        -j 0
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
    local files=$(find . | grep -o "Index[0-9][0-9].for.fq")
    # trim each file in parallel
    for file in $files; do trim "$file" "$lane" & done
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
```
Before you run the trimming, make sure that Python 3.7 is launched. Sometimes, Terminal can get pretty annoying about this and so an easy way to ensure this is to use the following two line command.
```
alias python=python3
module load python/3.7.0
```
To run the trimming, run `qsub` followed by the script name for each script.

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
To copy the resulting html files to the Desktop, use the following command on your local machine (MacOS).
```
$ cd ~/Desktop
$ scp <username>@Hoffman2.idre.ucla.edu:<scratch dir>/rna-seq/FastQC_reports/L3_Index12_trimmed.for_fastqc.html ./
```
## 4. Mapping
We perform mapping using hisat2. hisat2 maps sequencing data to a single reference genome. This will allow us to infer what transcripts are being expressed. The first step is to download a reference genome.

### Obtaining Reference Genome and Installing hisat2
```
mkdir GENCODE
cd GENCODE
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M21/GRCm38.p6.genome.fa.gz
gunzip GRCm38.p6.genome.fa.gz
```
Before running, make sure you load the hisat2 module:
```
module load hisat2
```
Build the index with the following command:
```
hisat2-build GRCm38.p6.genome.fa GRCm38
```
We create a script `hisat2_map.sh` that performs the mapping using a specified path. Adjust the `$SCRATCH/GENCODE/GRCm38` path for option `-x` to the basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final `.1.ht2`, `.2.ht2`, etc.
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=4G,h_rt=8:00:00
#$ -pe shared 8

#load hisat2 before running this script
#pass the directory containing fq files as an argument

cd $1 #path argument
for i in $( ls Index*.fq |  awk 'BEGIN{FS="_"}{print $1}' | uniq )
do
    fqFileName=${i}_trimmed.for.fq
    outFileName=${i}.sam
    hisat2 \
    	-q \
	-p 8 \
	-x $SCRATCH/GENCODE/GRCm38 \
        -U $fqFileName \
        -S $outFileName
done
```
Now, run the script with for each trimmed lane with the command below.
```
qsub -N hisat2<lane> hisat2_map.sh $SCRATCH/rna-seq/<trimmed lane directory>
```
I also ran commands to move the `.sam` files into their own directories. e.g.:
```
mkdir L4_sam
mv L4_trimmed-fq/*.sam L4_sam/
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
Next, we create a bash script `merge_sam.sh` to merge the sam files output by the previous step using the following code. Make sure to create the required input and output directories using the `mkdir` command.
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -N mergeSam_34
#$ -l h_data=8G,h_rt=8:00:00
#$ -pe shared 2
#$ -v L1dir='L3_sam'
#$ -v L2dir='L4_sam'
#$ -v mergedir='L3L4_merged'

# load picard_tools before running this script
# use L1dir='PATHtoL1' L2dir='PATHtoL2'
# mergedir='PATHtoDestination' to indicate
# paths for directories to L1, L2, and merged
# sam destination
cd $SCRATCH/rna-seq/${L1dir}
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
qsub merge_sam.sh
```
## 6. Counting
We've finally made it to the last step! Here, we'll generate counts for each of the genes that we mapped our reads too. The final product will be a list of genes and their counts. We will do this using htseq-count.
### Download this (note: outdated)
Create a directory to store the downloaded gene annotations. This file is outdated. If you want to use it, you must make sure to download the proper key for this file when you do downstream analyses.
```
mkdir GENAN
cd GENAN
wget ftp://ftp.ensembl.org/pub/release-84/gtf/mus_musculus/Mus_musculus.GRCm38.84.gtf.gz
gunzip Mus_musculus.GRCm38.84.gtf.gz
```
### Updated link
`ftp://ftp.ensembl.org/pub/release-99/gtf/mus_musculus/Mus_musculus.GRCm38.99.gtf.gz`

### Installing htseq-count
#### Old Steps
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
#### New Steps
```
git clone https://github.com/simon-anders/htseq
cd htseq
module load python/2.7
python setup.py build install --user
```
### Counting
Create a directory with `mkdir L3L4_counts`. \
Similar to trimming, we split the counting into three sets to parallelize it. As such, we have:
#### count0.sh
```
#!/bin/bash
#$ -V
#$ -l h_data=4G,h_rt=7:00:00
#$ -pe shared 8
indir='L3L4_merged'
outdir='L3L4_counts'

#load python before running this script

cd $SCRATCH/rna-seq/
for i in `ls ./${indir}/*0?_*.sam |
    awk 'BEGIN{FS="/"}{print$3}' |
    awk 'BEGIN{FS="_"}{print$1}' |
    uniq`
do
    htseq-count \
        -f bam \
        -s reverse \
        ./${indir}/${i}_merged.sam \
        $SCRATCH/rna-seq/GENAN/Mus_musculus.GRCm38.99.gtf > \
        ./${outdir}/${i}.count
done
```
#### count1.sh
```
#!/bin/bash
#$ -V
#$ -l h_data=4G,h_rt=7:00:00
#$ -pe shared 8
indir='L3L4_merged'
outdir='L3L4_counts'

#load python before running this script

cd $SCRATCH/rna-seq/
for i in `ls ./${indir}/*1?_*.sam |
    awk 'BEGIN{FS="/"}{print$3}' |
    awk 'BEGIN{FS="_"}{print$1}' |
    uniq`
do
    htseq-count \
        -f bam \
        -s reverse \
        ./${indir}/${i}_merged.sam \
        $SCRATCH/rna-seq/GENAN/Mus_musculus.GRCm38.99.gtf > \
        ./${outdir}/${i}.count
done
```
#### count2.sh
```
#!/bin/bash
#$ -V
#$ -l h_data=4G,h_rt=7:00:00
#$ -pe shared 8
indir='L3L4_merged'
outdir='L3L4_counts'

#load python before running this script

cd $SCRATCH/rna-seq/
for i in `ls ./${indir}/*2?_*.sam |
    awk 'BEGIN{FS="/"}{print$3}' |
    awk 'BEGIN{FS="_"}{print$1}' |
    uniq`
do
    htseq-count \
        -f bam \
        -s reverse \
        ./${indir}/${i}_merged.sam \
        $SCRATCH/rna-seq/GENAN/Mus_musculus.GRCm38.99.gtf > \
        ./${outdir}/${i}.count
done
```
Finally, run each script with `qsub` followed by the script name.

The resulting count files can be transferred to the local computer for downstream analyses.
