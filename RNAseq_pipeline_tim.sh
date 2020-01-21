### RNA-seq Pipeline for Tarling-Vallim Lab ###
### author: Timothy Yu ###
### STILL A WORK IN PROGRESS ###

#1. Demultiplex files: Multiple samples are pooled together during the sequencing run in the same lane, but given unique barcodes. 
# the demultiplex process divides the raw reads into separate samples for analysis.

# got raw sequencing files (4 different lanes)

[timyu98@login2 timyu98]$ curl https://bitbucket.org/gallaher/htseqtools/get/master.zip -o htSeqTools.zip

#  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                 Dload  Upload   Total   Spent    Left  Speed
#100 22489    0 22489    0     0  19733      0 --:--:--  0:00:01 --:--:-- 42592

[timyu98@login2 timyu98]$ unzip htSeqTools.zip

#Archive:  htSeqTools.zip
#b0188e959c38c06253418f0e2c1861e47037ee8e
#   creating: gallaher-htseqtools-b0188e959c38/
#  inflating: gallaher-htseqtools-b0188e959c38/README.txt  
#   creating: gallaher-htseqtools-b0188e959c38/bin/
#  inflating: gallaher-htseqtools-b0188e959c38/bin/demultiplexer  
#  inflating: gallaher-htseqtools-b0188e959c38/bin/downloader  
#  inflating: gallaher-htseqtools-b0188e959c38/bin/qseq2fastq  
#  inflating: gallaher-htseqtools-b0188e959c38/gpl-3.0.txt  

[timyu98@login2 timyu98]$ mv gallaher* htSeqTools/
[timyu98@login2 timyu98]$ nano demultiplex_3.sh
[timyu98@login4 timyu98]$ chmod 777 demultiplex_3.sh 
[timyu98@login4 timyu98]$ rm htSeqTools.zip

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

qsub demultiplex_3.sh

# 2. Trim sequences, this is necessary because we need to trim adaptor sequences that were added on for sequencing after
# isolating RNA. We then remove any low quality bases based on a Q value (Q value, which is defined as the negative log of 
# the probability the base was called incorrectly). the Q value tends to decrease (quality gets worse) towards the 3’ end of 
# the read. These lower quality regions can negatively impact downstream analyses such as mapping, mutation calling, etc.


# Go into 03_demultiplexed and create trim00s.sh, trim10s.sh, trim20s.sh in each lane's demultiplexed folder.
# run command qsub -cwd -V -N L3_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh

alias python=python3
module load python/3.7.0

# trim00s.sh code
# ------------------------------------------------------
#!/bin/bash
#runs cutadapt to trim 10 As and 10 Ts with options -m 15 -q 30
#on files 01-09

for i in {1..9}
do
fastq="Index0${i}.for.fq"
trimmedFastq="Index0${i}_trimmed.for.fq"
/u/home/t/timyu98/.local/bin/cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG -a "A{10}" -a "T{10}" -m 15 -q 30 -o ../../L3_trimmed-fq/$trimmedFastq $fas$
done


# need to do 10s and 20s for Lane 3, and everything for all the other lanes
qsub -cwd -V -N L3_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh


[timyu98@login2 SxaQSEQsYB051L3]$ qsub -cwd -V -N L3_trim10s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim10s.sh
Your job 4313523 ("L3_trim10s") has been submitted
[timyu98@login2 SxaQSEQsYB051L3]$ qsub -cwd -V -N L3_trim20s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim20s.sh
Your job 4313526 ("L3_trim20s") has been submitted

[timyu98@login2 SxaQSEQsYB051L4]$ qsub -cwd -V -N L4_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh
Your job 4313548 ("L4_trim00s") has been submitted
[timyu98@login2 SxaQSEQsYB051L4]$ qsub -cwd -V -N L4_trim10s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim10s.sh
Your job 4313551 ("L4_trim10s") has been submitted
[timyu98@login2 SxaQSEQsYB051L4]$ qsub -cwd -V -N L4_trim20s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim20s.sh
Your job 4313552 ("L4_trim20s") has been submitted

[timyu98@login2 SxaQSEQsYB051L5]$ qsub -cwd -V -N L5_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh
Your job 4313562 ("L5_trim00s") has been submitted
[timyu98@login2 SxaQSEQsYB051L5]$ qsub -cwd -V -N L5_trim10s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim10s.sh
Your job 4313563 ("L5_trim10s") has been submitted
[timyu98@login2 SxaQSEQsYB051L5]$ qsub -cwd -V -N L5_trim20s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim20s.sh
Your job 4313565 ("L5_trim20s") has been submitted

[timyu98@login2 SxaQSEQsYB051L6]$ qsub -cwd -V -N L6_trim00s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim00s.sh
Your job 4313570 ("L6_trim00s") has been submitted
[timyu98@login2 SxaQSEQsYB051L6]$ qsub -cwd -V -N L6_trim10s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim10s.sh
Your job 4313571 ("L6_trim10s") has been submitted
[timyu98@login2 SxaQSEQsYB051L6]$ qsub -cwd -V -N L6_trim20s -l h_data=4G,h_rt=8:00:00 -pe shared 4 trim20s.sh
Your job 4313574 ("L6_trim20s") has been submitted


# 3. QC: looks for repetitive sequences, if it's there, then it's not right. (error keeps sequencing the same fragment over 
# and over again. get rid of it from whole pool of sequences)
# maybe when trimming didn't trim enough and kept a little of the adaptor sequences, can check if something matches an
# illumina adaptor. looks for overrepresentation of certain base pairs at a particular position along fragment, should have
# around equally divided.


[hylin@n2180 ~]$ cd $SCRATCH
[hylin@n2180 hylin]$ mkdir FastQC_reports
#installing fastqc on home node
[hylin@n4034 ~]$ wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.7.zip
[hylin@n4034 ~]$ unzip fastqc_v0.11.7.zip
[hylin@n4034 FastQC]$ chmod 755 fastqc

[timyu98@login2 timyu98]$ ~/FastQC/fastqc --outdir=FastQC_reports ./L3_trimmed-fq/Index12_trimmed.for.fq
Started analysis of Index12_trimmed.for.fq
Approx 5% complete for Index12_trimmed.for.fq
Approx 10% complete for Index12_trimmed.for.fq
Approx 15% complete for Index12_trimmed.for.fq
Approx 20% complete for Index12_trimmed.for.fq
Approx 25% complete for Index12_trimmed.for.fq
Approx 30% complete for Index12_trimmed.for.fq
Approx 35% complete for Index12_trimmed.for.fq
Approx 40% complete for Index12_trimmed.for.fq
Approx 45% complete for Index12_trimmed.for.fq
Approx 50% complete for Index12_trimmed.for.fq
Approx 55% complete for Index12_trimmed.for.fq
Approx 60% complete for Index12_trimmed.for.fq
Approx 65% complete for Index12_trimmed.for.fq
Approx 70% complete for Index12_trimmed.for.fq
Approx 75% complete for Index12_trimmed.for.fq
Approx 80% complete for Index12_trimmed.for.fq
Approx 85% complete for Index12_trimmed.for.fq
Approx 90% complete for Index12_trimmed.for.fq
Approx 95% complete for Index12_trimmed.for.fq
Analysis complete for Index12_trimmed.for.fq
[timyu98@login2 timyu98]$ cd FastQC_reports/
[timyu98@login2 FastQC_reports]$ mv Index12_trimmed.for_fastqc.html SxaQSEQsYB051L3_Index12_trimmed.for_fastqc.html
[timyu98@login2 FastQC_reports]$ mv Index12_trimmed.for_fastqc.zip SxaQSEQsYB051L3_Index12_trimmed.for_fastqc.zip



# 4. Mapping: hisat2 maps sequencing data to the general human population and a single reference genome. This allows you 
# to infer what transcripts are being expressed. 

[timyu98@login4 timyu98]$ mkdir GENCODE
[timyu98@login4 timyu98]$ cd GENCODE/
[timyu98@login4 GENCODE]$ wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grcm38.tar.gz
[timyu98@login4 GENCODE]$ tar xvf grcm38.tar.gz
[timyu98@login4 grcm38]$ module load hisat2 # REALLY IMPORTANT!
[timyu98@login4 grcm38]$ cd ../../
[timyu98@login4 timyu98]$ cd scripts
[timyu98@login4 scripts]$ nano hisat2_map.sh

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

[timyu98@login4 scripts]$ qsub -V -N hisat2L3 -l h_data=4G,h_rt=8:00:00 -pe shared 8 -v path='/u/flashscratch/t/timyu98/L3_trimmed-fq/' hisat2_map.sh
Your job 141016 ("hisat2L3") has been submitted
[timyu98@login4 scripts]$ qsub -V -N hisat2L4 -l h_data=4G,h_rt=8:00:00 -pe shared 8 -v path='/u/flashscratch/t/timyu98/L4_trimmed-fq/' hisat2_map.sh
Your job 141017 ("hisat2L4") has been submitted
[timyu98@login4 scripts]$ qsub -V -N hisat2L5 -l h_data=4G,h_rt=8:00:00 -pe shared 8 -v path='/u/flashscratch/t/timyu98/L5_trimmed-fq/' hisat2_map.sh
Your job 141018 ("hisat2L5") has been submitted
[timyu98@login4 scripts]$ qsub -V -N hisat2L6 -l h_data=4G,h_rt=8:00:00 -pe shared 8 -v path='/u/flashscratch/t/timyu98/L6_trimmed-fq/' hisat2_map.sh
Your job 141019 ("hisat2L6") has been submitted

# For hisat2L3 stats
    11415182 (77.33%) aligned exactly 1 time
    2566598 (17.39%) aligned >1 times
94.72% overall alignment rate
16575216 reads; of these:
  16575216 (100.00%) were unpaired; of these:
    1015289 (6.13%) aligned 0 times
    12514965 (75.50%) aligned exactly 1 time
    3044962 (18.37%) aligned >1 times
93.87% overall alignment rate
15062115 reads; of these:
  15062115 (100.00%) were unpaired; of these:
    802107 (5.33%) aligned 0 times
    11573572 (76.84%) aligned exactly 1 time
    2686436 (17.84%) aligned >1 times
94.67% overall alignment rate
15028672 reads; of these:
  15028672 (100.00%) were unpaired; of these:
    1021254 (6.80%) aligned 0 times
    11262603 (74.94%) aligned exactly 1 time
    2744815 (18.26%) aligned >1 times
93.20% overall alignment rate
16900645 reads; of these:
  16900645 (100.00%) were unpaired; of these:
    1413849 (8.37%) aligned 0 times
    12398355 (73.36%) aligned exactly 1 time
    3088441 (18.27%) aligned >1 times
91.63% overall alignment rate
17312678 reads; of these:
  17312678 (100.00%) were unpaired; of these:
    1100901 (6.36%) aligned 0 times
    13070967 (75.50%) aligned exactly 1 time
    3140810 (18.14%) aligned >1 times
93.64% overall alignment rate
12407673 reads; of these:
  12407673 (100.00%) were unpaired; of these:
    757136 (6.10%) aligned 0 times
    9183312 (74.01%) aligned exactly 1 time
    2467225 (19.88%) aligned >1 times
93.90% overall alignment rate

# For hisat2L4 stats
    10927505 (76.85%) aligned exactly 1 time
    2501542 (17.59%) aligned >1 times
94.44% overall alignment rate
16138294 reads; of these:
  16138294 (100.00%) were unpaired; of these:
    1035040 (6.41%) aligned 0 times
    12098224 (74.97%) aligned exactly 1 time
    3005030 (18.62%) aligned >1 times
93.59% overall alignment rate
14595026 reads; of these:
  14595026 (100.00%) were unpaired; of these:
    816017 (5.59%) aligned 0 times
    11157025 (76.44%) aligned exactly 1 time
    2621984 (17.96%) aligned >1 times
94.41% overall alignment rate
14473884 reads; of these:
  14473884 (100.00%) were unpaired; of these:
    1021143 (7.06%) aligned 0 times
    10779599 (74.48%) aligned exactly 1 time
    2673142 (18.47%) aligned >1 times
92.94% overall alignment rate
16466163 reads; of these:
  16466163 (100.00%) were unpaired; of these:
    1419810 (8.62%) aligned 0 times
    12007941 (72.92%) aligned exactly 1 time
    3038412 (18.45%) aligned >1 times
91.38% overall alignment rate
16907511 reads; of these:
  16907511 (100.00%) were unpaired; of these:
    1119464 (6.62%) aligned 0 times
    12687645 (75.04%) aligned exactly 1 time
    3100402 (18.34%) aligned >1 times
93.38% overall alignment rate
12158348 reads; of these:
  12158348 (100.00%) were unpaired; of these:
    770765 (6.34%) aligned 0 times
    8944934 (73.57%) aligned exactly 1 time
    2442649 (20.09%) aligned >1 times
93.66% overall alignment rate

# for hisat2L5 stats 
    9844010 (71.65%) aligned exactly 1 time
    2625215 (19.11%) aligned >1 times
90.76% overall alignment rate
16804550 reads; of these:
  16804550 (100.00%) were unpaired; of these:
    1131447 (6.73%) aligned 0 times
    12588269 (74.91%) aligned exactly 1 time
    3084834 (18.36%) aligned >1 times
93.27% overall alignment rate
13576527 reads; of these:
  13576527 (100.00%) were unpaired; of these:
    669199 (4.93%) aligned 0 times
    10528733 (77.55%) aligned exactly 1 time
    2378595 (17.52%) aligned >1 times
95.07% overall alignment rate
14033311 reads; of these:
  14033311 (100.00%) were unpaired; of these:
    1107804 (7.89%) aligned 0 times
    10375632 (73.94%) aligned exactly 1 time
    2549875 (18.17%) aligned >1 times
92.11% overall alignment rate
14485825 reads; of these:
  14485825 (100.00%) were unpaired; of these:
    1075692 (7.43%) aligned 0 times
    10821652 (74.71%) aligned exactly 1 time
    2588481 (17.87%) aligned >1 times
92.57% overall alignment rate
15427311 reads; of these:
  15427311 (100.00%) were unpaired; of these:
    1800440 (11.67%) aligned 0 times
    10877240 (70.51%) aligned exactly 1 time
    2749631 (17.82%) aligned >1 times
88.33% overall alignment rate
12725003 reads; of these:
  12725003 (100.00%) were unpaired; of these:
    1696337 (13.33%) aligned 0 times
    8393922 (65.96%) aligned exactly 1 time
    2634744 (20.71%) aligned >1 times
86.67% overall alignment rate

# for hisat2L6 stats
    9997686 (71.19%) aligned exactly 1 time
    2714898 (19.33%) aligned >1 times
90.52% overall alignment rate
17028673 reads; of these:
  17028673 (100.00%) were unpaired; of these:
    1183265 (6.95%) aligned 0 times
    12692677 (74.54%) aligned exactly 1 time
    3152731 (18.51%) aligned >1 times
93.05% overall alignment rate
13867578 reads; of these:
  13867578 (100.00%) were unpaired; of these:
    709955 (5.12%) aligned 0 times
    10709442 (77.23%) aligned exactly 1 time
    2448181 (17.65%) aligned >1 times
94.88% overall alignment rate
14335323 reads; of these:
  14335323 (100.00%) were unpaired; of these:
    1160540 (8.10%) aligned 0 times
    10550374 (73.60%) aligned exactly 1 time
    2624409 (18.31%) aligned >1 times
91.90% overall alignment rate
14748882 reads; of these:
  14748882 (100.00%) were unpaired; of these:
    1122296 (7.61%) aligned 0 times
    10971390 (74.39%) aligned exactly 1 time
    2655196 (18.00%) aligned >1 times
92.39% overall alignment rate
15740093 reads; of these:
  15740093 (100.00%) were unpaired; of these:
    1872296 (11.90%) aligned 0 times
    11038432 (70.13%) aligned exactly 1 time
    2829365 (17.98%) aligned >1 times
88.10% overall alignment rate
13024972 reads; of these:
  13024972 (100.00%) were unpaired; of these:
    1761074 (13.52%) aligned 0 times
    8545506 (65.61%) aligned exactly 1 time
    2718392 (20.87%) aligned >1 times
86.48% overall alignment rate


# 5. Merging

[timyu98@login1 scripts]$ wget https://github.com/broadinstitute/picard/releases/download/2.18.15/picard.jar -O picard.jar
[timyu98@login1 scripts]$ nano mergeSam.sh

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

[timyu98@login1 scripts]$ qsub -V -N mergeSam_56 -l h_data=4G,h_rt=4:00:00 -pe shared 2 -v L1dir='L5_sam' -v L2dir='L6_sam' -v mergedir='SxaQSEQsYB051L5L6_merged' mergeSam.sh



# 6. Count features
[timyu98@login3 timyu98]$ cd GENCODE
[timyu98@login3 GENCODE]$ wget ftp://ftp.ensembl.org/pub/release-84/gtf/mus_musculus/Mus_musculus.GRCm38.84.gtf.gz
[timyu98@login3 GENCODE]$ gunzip Mus_musculus.GRCm38.84.gtf.gz



