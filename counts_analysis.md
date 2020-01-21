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
Install `tximportData` with this command in the console:
```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("tximportData")
```

## Notes
Will probably use `read.table` function
