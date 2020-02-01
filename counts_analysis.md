# Analyzing the counts data from the RNA-seq pipeline
## Intro
We will use the DESeq2 package for R in RStudio. Documentation is here (htseq-count input section):
http://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#htseq-count-input

Sample RNA-seq workflow in R:
http://master.bioconductor.org/packages/release/workflows/html/rnaseqGene.html
http://master.bioconductor.org/packages/release/workflows/vignettes/rnaseqGene/inst/doc/rnaseqGene.html

## Installation of Packages
Install `DESeq2` with this command in the console:
```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("DESeq2")
```
Install `apeglm` which provides approximate posterior estimation for GLM coefficients. 
```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("apeglm")
```
## R script
```
library(DESeq2)

# directories for files of concern
dir = "/Users/ajpfahnl/Google Drive (ajpfahnl@g.ucla.edu)/__RESEARCH_Vallim/"
htseq_dir = paste(dir,"L3L4_counts/", sep = "")
phen_table_file = paste(dir,"rnaseq_mapping_list.txt", sep = "")

# read in phenotype table
phen_table = read.table(phen_table_file, header = TRUE)

# DESeq2 import using DESeqDataSetFromHTSeqCount()
sampleFiles = list.files(htseq_dir)
sampleCondition <- sub(".*(treated).*","\\1", phen_table[1:24,1])
sampleCondition <- sub(".*(control).*","\\1", sampleCondition)
print(sampleCondition)
sampleTable <- data.frame(sampleName = sampleFiles,
                          fileName = sampleFiles,
                          condition = sampleCondition)

ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,
                                       directory = directory,
                                       design= ~ condition)
ddsHTSeq

# Pre-filtering
keep <- rowSums(counts(ddsHTSeq)) >= 10
dds <- ddsHTSeq[keep,]

# Relevel
dds$condition <- relevel(dds$condition, ref = "control")

# Differential expression analysis
dds <- DESeq(dds)
res <- results(dds)
res

res <- results(dds, contrast=c("condition","treated","control"))

# Log fold change shrinkage for visualization and ranking

#resultsNames(dds)
#resLFC <- lfcShrink(dds, coef="condition_treated_vs_control", type="apeglm")
#resLFC

# Plotting

plotMA(res, ylim=c(-1,1))
plotMA(resLFC, ylim=c(-2,2))
plotCounts(dds, gene=which.max(res$padj), intgroup="condition")
```
