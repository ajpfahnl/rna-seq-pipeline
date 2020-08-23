An example directory tree of `rna-seq`:

```
rna-seq
├── 03_demultiplexed
│   ├── TV_1_pool_24_RNA_0685
│   │   ├── 10_S10_R1_001.fastq.gz
│   │   ├── 11_S11_R1_001.fastq.gz
│   │   ├── 12_S12_R1_001.fastq.gz
│   │   ├── 13_S1_R1_001.fastq.gz
│   │   ├── 14_S2_R1_001.fastq.gz
│   │   ├── 15_S3_R1_001.fastq.gz
│   │   ├── 16_S4_R1_001.fastq.gz
│   │   ├── 17_S5_R1_001.fastq.gz
│   │   ├── 18_S6_R1_001.fastq.gz
│   │   ├── 19_S7_R1_001.fastq.gz
│   │   ├── 1_S1_R1_001.fastq.gz
│   │   ├── 20_S8_R1_001.fastq.gz
│   │   ├── 21_S9_R1_001.fastq.gz
│   │   ├── 22_S10_R1_001.fastq.gz
│   │   ├── 23_S11_R1_001.fastq.gz
│   │   ├── 24_S12_R1_001.fastq.gz
│   │   ├── 2_S2_R1_001.fastq.gz
│   │   ├── 3_S3_R1_001.fastq.gz
│   │   ├── 4_S4_R1_001.fastq.gz
│   │   ├── 5_S5_R1_001.fastq.gz
│   │   ├── 6_S6_R1_001.fastq.gz
│   │   ├── 7_S7_R1_001.fastq.gz
│   │   ├── 8_S8_R1_001.fastq.gz
│   │   └── 9_S9_R1_001.fastq.gz
│   └── TV_1_pool_24_RNA_0685_FA256
│       ├── 10_S10_R1_001.fastq.gz
│       ├── 11_S11_R1_001.fastq.gz
│       ├── 12_S12_R1_001.fastq.gz
│       ├── 13_S1_R1_001.fastq.gz
│       ├── 14_S2_R1_001.fastq.gz
│       ├── 15_S3_R1_001.fastq.gz
│       ├── 16_S4_R1_001.fastq.gz
│       ├── 17_S5_R1_001.fastq.gz
│       ├── 18_S6_R1_001.fastq.gz
│       ├── 19_S7_R1_001.fastq.gz
│       ├── 1_S1_R1_001.fastq.gz
│       ├── 20_S8_R1_001.fastq.gz
│       ├── 21_S9_R1_001.fastq.gz
│       ├── 22_S10_R1_001.fastq.gz
│       ├── 23_S11_R1_001.fastq.gz
│       ├── 24_S12_R1_001.fastq.gz
│       ├── 2_S2_R1_001.fastq.gz
│       ├── 3_S3_R1_001.fastq.gz
│       ├── 4_S4_R1_001.fastq.gz
│       ├── 5_S5_R1_001.fastq.gz
│       ├── 6_S6_R1_001.fastq.gz
│       ├── 7_S7_R1_001.fastq.gz
│       ├── 8_S8_R1_001.fastq.gz
│       └── 9_S9_R1_001.fastq.gz
├── 04_trim
│   ├── TV_1_pool_24_RNA_0685
│   │   ├── trim_10_S10_R1_001.fastq.gz
│   │   ├── trim_11_S11_R1_001.fastq.gz
│   │   ├── trim_12_S12_R1_001.fastq.gz
│   │   ├── trim_13_S1_R1_001.fastq.gz
│   │   ├── trim_14_S2_R1_001.fastq.gz
│   │   ├── trim_15_S3_R1_001.fastq.gz
│   │   ├── trim_16_S4_R1_001.fastq.gz
│   │   ├── trim_17_S5_R1_001.fastq.gz
│   │   ├── trim_18_S6_R1_001.fastq.gz
│   │   ├── trim_19_S7_R1_001.fastq.gz
│   │   ├── trim_1_S1_R1_001.fastq.gz
│   │   ├── trim_20_S8_R1_001.fastq.gz
│   │   ├── trim_21_S9_R1_001.fastq.gz
│   │   ├── trim_22_S10_R1_001.fastq.gz
│   │   ├── trim_23_S11_R1_001.fastq.gz
│   │   ├── trim_24_S12_R1_001.fastq.gz
│   │   ├── trim_2_S2_R1_001.fastq.gz
│   │   ├── trim_3_S3_R1_001.fastq.gz
│   │   ├── trim_4_S4_R1_001.fastq.gz
│   │   └── trim_5_S5_R1_001.fastq.gz
│   └── TV_1_pool_24_RNA_0685_FA256
│       ├── trim_10_S10_R1_001.fastq.gz
│       ├── trim_11_S11_R1_001.fastq.gz
│       ├── trim_12_S12_R1_001.fastq.gz
│       ├── trim_13_S1_R1_001.fastq.gz
│       ├── trim_14_S2_R1_001.fastq.gz
│       ├── trim_15_S3_R1_001.fastq.gz
│       ├── trim_16_S4_R1_001.fastq.gz
│       ├── trim_17_S5_R1_001.fastq.gz
│       ├── trim_18_S6_R1_001.fastq.gz
│       ├── trim_19_S7_R1_001.fastq.gz
│       ├── trim_1_S1_R1_001.fastq.gz
│       ├── trim_20_S8_R1_001.fastq.gz
│       ├── trim_21_S9_R1_001.fastq.gz
│       ├── trim_22_S10_R1_001.fastq.gz
│       ├── trim_23_S11_R1_001.fastq.gz
│       ├── trim_24_S12_R1_001.fastq.gz
│       ├── trim_2_S2_R1_001.fastq.gz
│       ├── trim_3_S3_R1_001.fastq.gz
│       ├── trim_4_S4_R1_001.fastq.gz
│       └── trim_5_S5_R1_001.fastq.gz
├── 05_hisat2_map
│   ├── TV_1_pool_24_RNA_0685
│   │   ├── trim_10_S10_R1_001.sam
│   │   ├── trim_11_S11_R1_001.sam
│   │   ├── trim_12_S12_R1_001.sam
│   │   ├── trim_13_S1_R1_001.sam
│   │   ├── trim_14_S2_R1_001.sam
│   │   ├── trim_15_S3_R1_001.sam
│   │   ├── trim_16_S4_R1_001.sam
│   │   ├── trim_17_S5_R1_001.sam
│   │   ├── trim_18_S6_R1_001.sam
│   │   ├── trim_19_S7_R1_001.sam
│   │   ├── trim_1_S1_R1_001.sam
│   │   ├── trim_20_S8_R1_001.sam
│   │   ├── trim_21_S9_R1_001.sam
│   │   ├── trim_22_S10_R1_001.sam
│   │   ├── trim_23_S11_R1_001.sam
│   │   ├── trim_24_S12_R1_001.sam
│   │   ├── trim_2_S2_R1_001.sam
│   │   ├── trim_3_S3_R1_001.sam
│   │   ├── trim_4_S4_R1_001.sam
│   │   └── trim_5_S5_R1_001.sam
│   └── TV_1_pool_24_RNA_0685_FA256
│       ├── trim_10_S10_R1_001.sam
│       ├── trim_11_S11_R1_001.sam
│       ├── trim_12_S12_R1_001.sam
│       ├── trim_13_S1_R1_001.sam
│       ├── trim_14_S2_R1_001.sam
│       ├── trim_15_S3_R1_001.sam
│       ├── trim_16_S4_R1_001.sam
│       ├── trim_17_S5_R1_001.sam
│       ├── trim_18_S6_R1_001.sam
│       ├── trim_19_S7_R1_001.sam
│       ├── trim_1_S1_R1_001.sam
│       ├── trim_20_S8_R1_001.sam
│       ├── trim_21_S9_R1_001.sam
│       ├── trim_22_S10_R1_001.sam
│       ├── trim_23_S11_R1_001.sam
│       ├── trim_24_S12_R1_001.sam
│       ├── trim_2_S2_R1_001.sam
│       ├── trim_3_S3_R1_001.sam
│       ├── trim_4_S4_R1_001.sam
│       └── trim_5_S5_R1_001.sam
├── 06_merge_sam
│   ├── logs
│   │   ├── trim_10_S10_R1_001.log
│   │   ├── trim_11_S11_R1_001.log
│   │   ├── trim_12_S12_R1_001.log
│   │   ├── trim_13_S1_R1_001.log
│   │   ├── trim_14_S2_R1_001.log
│   │   ├── trim_15_S3_R1_001.log
│   │   ├── trim_16_S4_R1_001.log
│   │   ├── trim_17_S5_R1_001.log
│   │   ├── trim_18_S6_R1_001.log
│   │   ├── trim_19_S7_R1_001.log
│   │   ├── trim_1_S1_R1_001.log
│   │   ├── trim_20_S8_R1_001.log
│   │   ├── trim_21_S9_R1_001.log
│   │   ├── trim_22_S10_R1_001.log
│   │   ├── trim_23_S11_R1_001.log
│   │   ├── trim_24_S12_R1_001.log
│   │   ├── trim_2_S2_R1_001.log
│   │   ├── trim_3_S3_R1_001.log
│   │   ├── trim_4_S4_R1_001.log
│   │   └── trim_5_S5_R1_001.log
│   └── merge_0685
│       ├── trim_10_S10_R1_001_merged.sam
│       ├── trim_11_S11_R1_001_merged.sam
│       ├── trim_12_S12_R1_001_merged.sam
│       ├── trim_13_S1_R1_001_merged.sam
│       ├── trim_14_S2_R1_001_merged.sam
│       ├── trim_15_S3_R1_001_merged.sam
│       ├── trim_16_S4_R1_001_merged.sam
│       ├── trim_17_S5_R1_001_merged.sam
│       ├── trim_18_S6_R1_001_merged.sam
│       ├── trim_19_S7_R1_001_merged.sam
│       ├── trim_1_S1_R1_001_merged.sam
│       ├── trim_20_S8_R1_001_merged.sam
│       ├── trim_21_S9_R1_001_merged.sam
│       ├── trim_22_S10_R1_001_merged.sam
│       ├── trim_23_S11_R1_001_merged.sam
│       ├── trim_24_S12_R1_001_merged.sam
│       ├── trim_2_S2_R1_001_merged.sam
│       ├── trim_3_S3_R1_001_merged.sam
│       ├── trim_4_S4_R1_001_merged.sam
│       └── trim_5_S5_R1_001_merged.sam
├── 07_counts
│   └── counts_0685
│       ├── trim_10_S10_R1_001_merged.count
│       ├── trim_11_S11_R1_001_merged.count
│       ├── trim_12_S12_R1_001_merged.count
│       ├── trim_13_S1_R1_001_merged.count
│       ├── trim_14_S2_R1_001_merged.count
│       ├── trim_15_S3_R1_001_merged.count
│       ├── trim_16_S4_R1_001_merged.count
│       ├── trim_17_S5_R1_001_merged.count
│       ├── trim_18_S6_R1_001_merged.count
│       ├── trim_19_S7_R1_001_merged.count
│       ├── trim_1_S1_R1_001_merged.count
│       ├── trim_20_S8_R1_001_merged.count
│       ├── trim_21_S9_R1_001_merged.count
│       ├── trim_22_S10_R1_001_merged.count
│       ├── trim_23_S11_R1_001_merged.count
│       ├── trim_24_S12_R1_001_merged.count
│       ├── trim_2_S2_R1_001_merged.count
│       ├── trim_3_S3_R1_001_merged.count
│       ├── trim_4_S4_R1_001_merged.count
│       └── trim_5_S5_R1_001_merged.count
├── FastQC_reports
│   ├── trim_10_S10_R1_001_fastqc.html
│   └── trim_10_S10_R1_001_fastqc.zip
├── GENAN
│   └── gencode.vM25.annotation.gff3
├── GENCODE
│   ├── GRCm38.1.ht2
│   ├── GRCm38.2.ht2
│   ├── GRCm38.3.ht2
│   ├── GRCm38.4.ht2
│   ├── GRCm38.5.ht2
│   ├── GRCm38.6.ht2
│   ├── GRCm38.7.ht2
│   ├── GRCm38.8.ht2
│   └── GRCm38.p6.genome.fa
└── scripts
    ├── 01_demultiplex.sh
    ├── 02_trim.sh
    ├── 03_index_build.sh
    ├── 04_hisat2_map.sh
    ├── 05_merge_sam.sh
    ├── 06_count.sh
    ├── commands
    └── logs
        ├── count.e4166709
        ├── count.o4166709
        ├── index_build.e4153456
        ├── index_build.o4153456
        ├── map_0685.e4156974
        ├── map_0685_FA256.e4156975
        ├── merge.o4161352
        ├── trim_0685_FA256.o4156902
        └── trim_0685.o4156900

19 directories, 216 files
```
