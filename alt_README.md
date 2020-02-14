# RNA-seq pipeline
__THIS USES A SLIGHTLY DIFFERENT WAY TO INDEX (LOOK UNDER THE MAPPING STEP)__

__MAKE SURE TO USE THE CORRECT ANNOTATED GENOME FILE FOR THE COUNTING STEP__

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
https://www.hoffman2.idre.ucla.edu/computing/running/#Build_a_UGE_command_file_for_your_job_and_use_UGE_commands_directly \
Another useful website: \
https://www.ccn.ucla.edu/wiki/index.php/Hoffman2

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
### Demultiplexing
Once `htSeqTools` has been installed, create a bash script to perform the demultiplexing using the following code. \
`$CRED_list` is a list of folders containing raw qseq files separated by spaces. The following script assumes `$CRED` folders are located in a folder `01_qseq`. Adjust `cd` commands as necessary. \
You may also need to adjust the output path in the `demultiplexer` or `qseq2fastq` Perl scripts that you installed from `htSeqTools`.
#### 01_demultiplex.sh
```
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
```
To run this script, use the following command:
```
qsub 01_demultiplex.sh
```
This will create a directory called `02_fastq` that contains all fastq files, and a directory called `03_demultiplexed` that contains all demultiplexed files for each lane.

Test data (options `-l h_data=16g,h_rt=48:00:00,highp -pe shared 2`):
 * User Time: 1:21:03:12
 * System Time: 00:28:25
 * Wallclock Time: 22:38:34
 * CPU: 1:21:31:37
 * Max vmem: 7.030G

## 2. Trimming
This is a necessary step because we need to trim adaptor sequences that were added on for sequencing after isolating RNA. We then remove any low quality bases based on a Q value (which is defined as the negative log of the probability the base was called incorrectly). The Q value tends to decrease (quality gets worse) towards the 3’ end of the read. These lower quality regions can negatively impact downstream analyses such as mapping, mutation calling, etc. We will do this using cutadapt.

### Installing cutadapt
```
module avail python
module load python/3.7.2
pip3 install --user --upgrade cutadapt
```
Make sure the `~/.local/bin` folder is added to `$PATH`.
### Trimming
Trim with the following script:
#### 02_trim.sh
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -N trim
#$ -l h_data=32G,h_rt=8:00:00,exclusive
#$ -M $USER
#$ -m bea

#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30

lanes="SxaQSEQsYB051L3 SxaQSEQsYB051L4"

trim () {
    local fastq=$1
    local lane=$2
    local num=$(echo ${fastq} | grep -o "[0-9][0-9]")
    local trimmedFastq="Index${num}_trimmed.for.fq"
    cutadapt \
	--quiet \
        -j 0 \
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
To run the trimming, run `qsub 02_trim.sh`.

Test data (options: `-l h_data=32G,h_rt=8:00:00,exclusive`):
 * User Time: 07:17:04
 * System Time: 00:43:39
 * Wallclock Time: 00:40:30
 * CPU: 08:00:44
 * Max vmem: 172.120G
 
## 3. Quality Control
The purpose of quality control is to look for repetitive sequences. If it's there, it could be due to an error where the machine keeps sequencing the same fragment over and over again. As such, we need to get rid of it from the whole pool of sequences. Another issue is that maybe when trimming we didn't trim enough and kept a little of the adaptor sequences. We can check if something matches an illumina adaptor here. Lastly, we look for overrepresentation of certain base pairs at a particular position along fragment, since they should be equally divided.

### Installing FastQC
```
mkdir FastQC_reports
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.7.zip
unzip fastqc_v0.11.7.zip
chmod 755 fastqc
```
### Running FastQC
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

### Obtaining Reference Genome and Creating an Index with hisat2
Before running, make sure you load the hisat2 module. Also add the following directory:
```
module load hisat2

mkdir GENCODE
cd GENCODE
```
Build the index with hisat2 using this script:
```
#!/bin/sh

#
# Downloads sequence for the GRCm38 release 99 version of M. Musculus (mouse) from
# Ensembl.
#
# By default, this script builds and index for just the base files,
# since alignments to those sequences are the most useful.  To change
# which categories are built by this script, edit the CHRS_TO_INDEX
# variable below.
#

ENSEMBL_RELEASE=99
ENSEMBL_GRCm38_BASE=ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/fasta/mus_musculus/dna

get() {
        file=$1
        if ! wget --version >/dev/null 2>/dev/null ; then
                if ! curl --version >/dev/null 2>/dev/null ; then
                        echo "Please install wget or curl somewhere in your PATH"
                        exit 1
                fi
                curl -o `basename $1` $1
                return $?
        else
                wget $1
                return $?
        fi
}

HISAT2_BUILD_EXE=./hisat2-build
if [ ! -x "$HISAT2_BUILD_EXE" ] ; then
        if ! which hisat2-build ; then
                echo "Could not find hisat2-build in current directory or in PATH"
                exit 1
        else
                HISAT2_BUILD_EXE=`which hisat2-build`
        fi
fi

rm -f genome.fa
F=Mus_musculus.GRCm38.dna.primary_assembly.fa
if [ ! -f $F ] ; then
        get ${ENSEMBL_GRCm38_BASE}/$F.gz || (echo "Error getting $F" && exit 1)
        gunzip $F.gz || (echo "Error unzipping $F" && exit 1)
        mv $F genome.fa
fi

CMD="${HISAT2_BUILD_EXE} genome.fa genome"
echo Running $CMD
if $CMD ; then
        echo "genome index built; you may remove fasta files"
else
        echo "Index building failed; see error message"
fi
```
You may want to create an interactive session (or put this in a script and execute with `qsub`) when executing the command above, so that the system doesn't kill the process:
```
qrsh -l h_rt=8:00:00,h_data=4G -pe shared 4
```

### Mapping
We create a script `04_hisat2_map.sh` that performs the mapping using a specified path. Adjust the `../../GENCODE/genome` path for option `-x` to the basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final `.1.ht2`, `.2.ht2`, etc.

#### 04_hisat2_map.sh
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=4G,h_rt=8:00:00
#$ -pe shared 8

# load hisat2 before running this script
# pass the basename of the directory containing
# fq files as an argument

lane=$1

dir_check () {
    if [ ! -d "../05_hisat2_map/" ]
    then
        mkdir ../05_hisat2_map/
    fi
    if [ ! -d "../05_hisat2_map/$lane" ]
    then
        mkdir ../05_hisat2_map/${lane}
    fi

dir_check
cd ../04_trim/$lane
for i in $( ls Index*.fq |  awk 'BEGIN{FS="_"}{print $1}' | uniq )
do
    fqFileName=${i}_trimmed.for.fq
    outFileName=../../05_hisat2_map/$lane/${i}.sam
    hisat2 \
	-q \
        -p 8 \
	-x ../../GENCODE/genome \
        -U $fqFileName \
        -S $outFileName
done
```
Now, run the script for each trimmed lane like the command below:
```
qsub -N map_L3 04_hisat2_map.sh SxaQSEQsYB051L3
```
Lastly, we can view the statistics of the alignment by checking the error output once the script has terminated.

## 5. Merging
If we have replicates, now is the time to merge the datasets together. For instance if lane 2 and lane 3 are replicates of one another, then we merge their mapped reads together. We do this using picard tools.

### Installing Picard Tools (For Latest Version)
#### Pre-Compiled
```
wget https://github.com/broadinstitute/picard/releases/download/2.18.15/picard.jar
wget https://github.com/broadinstitute/picard/releases/download/2.21.8/picard.jar
```
#### From Source
Installing from source (I install in my home directory):
```
git clone https://github.com/broadinstitute/picard.git
cd picard/
./gradlew shadowJar
```
If necessary, load the correct version of Java. For example, at least Java 1.8 is needed for picard 2.21.8:
```
module load java/1.8.0_111
```
Test picard with with an interactive shell (not enough memory for login node):
```
qrsh -l h_rt=8:00:00,h_data=4G -pe shared 4
java -jar ~/picard/build/libs/picard.jar -h
```
### Merging
Next, we create a bash script `05_merge_sam.sh` to merge the sam files output by the previous step using the following code. Make sure to create the required input and output directories using the `mkdir` command.
Note: We can also use the built-in version of picard tools with `module load picard_tools` and omit setting the `$PICARD` variable in the script
#### 05_merge_sam.sh
```
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
```
We can then merge lanes (e.g. L3 and L4) using the following command as an example:
```
qsub 05_merge_sam.sh SxaQSEQsYB051L3 SxaQSEQsYB051L4 L3_L4_merge
```
Test data (`-l h_data=4G,h_rt=4:00:00,exclusive -pe shared 4`):
 * User Time: 07:02:29
 * System Time: 00:33:08
 * Wallclock Time: 01:55:14
 * CPU: 07:35:38
 * Max vmem: 45.442G
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
#### 06_count.sh
```
#!/bin/bash
#$ -cwd
#$ -V
#$ -l h_data=4G,h_rt=7:00:00,exclusive
# -pe shared 4
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

cd ../

dir_check () {
    if [ ! -d "./07_counts/" ]
    then
        mkdir ./07_counts/
    fi
    if [ ! -d "./07_counts/$count_dir" ]
    then
        mkdir ./07_counts/${count_dir}
    fi
}
dir_check

for i in `ls ./06_merge_sam/${sam_dir}/*${3}?_*.sam |
    awk 'BEGIN{FS="/"}{print$4}' |
    awk 'BEGIN{FS="_"}{print$1}' |
    uniq`
do
    htseq-count \
        -f bam \
        -s reverse \
        ./06_merge_sam/${sam_dir}/${i}_merged.sam \
        ./GENAN/Mus_musculus.GRCm38.99.gtf > \
        ./07_counts/${count_dir}/${i}.count
done
```
Run like so:
`qsub -N count0x 06_count.sh L3_L4_merge L3_L4_counts 0`

The resulting count files can be transferred to the local computer for downstream analyses.
