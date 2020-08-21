# RNA-seq pipeline

This is a custom RNA-seq pipeline that I have been using to convert raw Illumina RNA-seq datasets to lists of genes
in the Tarling-Vallim lab.

## Getting Started

To execute this pipeline, you will need an account on the Hoffman2 server. I do everything in a folder `$SCRATCH/rna-seq`.

Create a folder `rna-seq/scripts` where we store all our scripts.

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
Before you run the trimming, make sure that Python 3.7 is launched. An easy way to ensure this is to run the following commands:
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
Use a program such as `scp` to copy to your local machine.
## 4. Mapping
We perform mapping using hisat2. hisat2 maps sequencing data to a single reference genome. This will allow us to infer what transcripts are being expressed. The first step is to download a reference genome.

### Obtaining Reference Genome and Gene Annotations

1. Create a directory `rna-seq/GENCODE` and download the mouse genome. 
2. Create a directory `rna-seq/GENAN` and download the associated gene annotations from the same website. This will be used later in the counting step.
#### From `ftp.ebi.ac.uk` (we will use this in the next steps)
Mouse genome:
```
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M21/GRCm38.p6.genome.fa.gz
gunzip GRCm38.p6.genome.fa.gz
```
Mouse genome annotations:
```
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M21/gencode.vM21.annotation.gff3.gz
gunzip gencode.vM21.annotation.gff3.gz
```
#### From `ftp.ensembl.org`
Mouse genome:
```
wget ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
gunzip Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
```
Mouse genome annotations:
```
wget ftp://ftp.ensembl.org/pub/release-99/gtf/mus_musculus/Mus_musculus.GRCm38.99.gtf.gz
gunzip Mus_musculus.GRCm38.99.gtf.gz
```

### Building an Index with hisat2
Before running, make sure you load the hisat2 module:
```
module load hisat2
```
To build from source for HISAT2 2.2.1, in your home directory `~`:
```
module purge
module load gcc/7.2.0
wget https://cloud.biohpc.swmed.edu/index.php/s/fE9QCsX3NH4QwBi/download
unzip download
rm download
make
export PATH=~/hisat2-2.2.1:$PATH
```
Sometimes hisat2 can't find the libraries or programs it needs to run. Try the following:
```
module purge
module load python/3.7.2
module load gcc/7.2.0
```
#### 03_index_build.sh 
The script builds the index with the following command (`-p` option for more cores):
```
hisat2-build GRCm38.p6.genome.fa -p 4 GRCm38
```
Test data (options: `-l h_rt=1:00:00,h_data=4G -pe shared 4`):
 * User Time        = 01:27:28
 * System Time      = 00:01:28
 * Wallclock Time   = 00:26:07
 * CPU              = 01:28:57
 * Max vmem         = 5.881G
 
### Mapping
We create a script `04_hisat2_map.sh` that performs the mapping using a specified path. Adjust the `../../GENCODE/GRCm38` path for option `-x` to the basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final `.1.ht2`, `.2.ht2`, etc.

#### 04_hisat2_map.sh
Now, run the script with for each trimmed lane like the command below:
```
qsub -N map_L3 04_hisat2_map.sh SxaQSEQsYB051L3
```
Lastly, we can view the statistics of the alignment by checking the error output once the script has terminated.

## 5. Merging
If we have replicates, now is the time to merge the datasets together. For instance if lane 2 and lane 3 are replicates of one another, then we merge their mapped reads together. We do this using picard tools.

### Installing Picard Tools (For Latest Version)
#### Pre-Compiled
```
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
Next, we merge the sam files output from the previous step. Make sure to create the required input and output directories using the `mkdir` command.
Note: We can also use the built-in version of picard tools with `module load picard_tools` and omit setting the `$PICARD` variable in the script
#### 05_merge_sam.sh
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
### Download Gene Annotations (if not done so already from the mapping step)
Follow the steps in _Obtaining Reference Genome and Gene Annotations_ under _4. Mapping_.

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
Make sure you have loaded Python 2.7: `module load python/2.7`.
#### 06_count.sh
Run like so:
`qsub -N count0x 06_count.sh L3_L4_merge L3_L4_counts 0`

The resulting count files can be transferred to the local computer for downstream analyses.
