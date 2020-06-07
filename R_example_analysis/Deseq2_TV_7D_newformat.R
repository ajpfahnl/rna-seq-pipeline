library(DESeq2)
#library(tidyr)
#library(ggplot2)

#library(tidyverse)
# dplyr
# ggplot2
# directories for files of concern
dir = "/Users/ajpfahnl/Google Drive (ajpfahnl@g.ucla.edu)/__RESEARCH_Vallim/Cre/"
htseq_dir = paste(dir,"TV_counts/", sep = "")
phen_table_file = paste(dir,"ETV093_samplecodes.csv", sep = "")
name_map_file = paste(dir,"mart_export_99.txt", sep = "")

# read in condition table
phen_table = read.csv(phen_table_file, header = T, stringsAsFactors = FALSE)
head(phen_table)

# read in name mapping
name_map = read.table(name_map_file, header = T, stringsAsFactors = FALSE)

# filter 7D files
phen_filtered <- phen_table[phen_table$Time == "7D",]$File_name
files_7D <- paste("trim_", sub("^([^.]*).*","\\1", phen_filtered), ".count", sep = "")
files_7D
sampleFiles <- files_7D

sampleCondition <- phen_table[phen_table$Time == "7D",]$Treatment
sampleCondition

# DESeq2 import using DESeqDataSetFromHTSeqCount()
sampleTable <- data.frame(sampleName = sampleFiles,
                          fileName = sampleFiles,
                          condition = sampleCondition)

ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,
                                       directory = htseq_dir,
                                       design= ~ condition)
ddsHTSeq

# Pre-filtering
keep <- rowSums(counts(ddsHTSeq)) >= 10
dds <- ddsHTSeq[keep,]
dds

# Relevel
dds$condition <- relevel(dds$condition, ref = "Control")


# Differential expression analysis
dds <- DESeq(dds)
res7D <- results(dds, contrast=c("condition","Cre","Control"))
res7D

#################                ################# 
################# NEW FORMATTING ################# 
#################                ################# 
# NOTE: this assumes that you already have a results table from 
#       the DESeq analysis

library("biomaRt")
library(readxl)
library(tidyverse)

### ### ### ### 
### SETUP
### ### ### ### 

setwd("~/Google Drive (ajpfahnl@g.ucla.edu)/__RESEARCH_Vallim/Cre")
# load excel file
AEGDEA = read_excel("All_Expressed_Genes_DifferentialExpression_AntimiRs.xlsx", sheet = 1, skip =1)

# extract ensembl ids from the DESeq results table
ensembl_ids = rownames(res7D)

### ### ### ### ### ### ### ### ### ### ### 
### CREATE TABLE WITH GENE NAME CONVERSIONS
### ### ### ### ### ### ### ### ### ### ### 
listEnsembl()
mouse_ensembl <- useEnsembl(biomart = "ensembl", dataset = "mmusculus_gene_ensembl", mirror = "uswest")


#mouse_ensembl = useMart("ensembl",dataset="mmusculus_gene_ensembl")

# optional info about mart objects
mouse_filt = listFilters(mouse_ensembl) # what filters
mouse_attri = listAttributes(mouse_ensembl) # what attributes

# extract data from biomart (adjust attributes and filters as necessary)
# e.g. my ensembl ids that I input have version ids so the filter I use is 
#      ensembl_gene_id_version
gene_ids = getBM(attributes = c("ensembl_gene_id_version", "ensembl_gene_id", "entrezgene_id", "uniprot_gn_id", "uniprot_gn_symbol"),
                 filters    = c("ensembl_gene_id_version"),
                 values     = ensembl_ids,
                 mart       = mouse_ensembl)
gene_ids = tbl_df(gene_ids)
head(gene_ids)
### ### ### ### ### ### ### ### ### ### 
### ENSEMBL GENES WITH SECRETION TAG
### ### ### ### ### ### ### ### ### ### 

# extract uniprot genes from the EXCEL file with 
# with their secretion tags
secrete = data.frame("Uniprot" = AEGDEA$Uniprot,
                     "Secreted"  = AEGDEA$Secreted)

secrete = subset(secrete, !is.na(Secreted), select = c(Uniprot, Secreted))
secrete = tbl_df(secrete) # convert to tbl class
#write.csv(secrete, "uniprot_secrete.csv")

# add ensembl name column
secrete = mutate(secrete, Ensembl = NA)

for (i in 1:nrow(secrete)) {
  uniprot = secrete$Uniprot[i]
  ensembl = filter(gene_ids, uniprot_gn_id == uniprot)$ensembl_gene_id
  if (!identical(ensembl, character(0))) {
    secrete$Ensembl[i] = ensembl
  }
}

# extract the genes that were expressed and create a .csv file
secrete_filt <- filter(secrete, 
                       !is.na(secrete$Ensembl))

#write.csv(secrete_filt, "secrete7D.csv")

# Ensembl genes in results that are secreted
res_secreted = data.frame(Ensembl_ids = ensembl_ids,
                          Uniprot_gn_id = NA,
                          Secreted = NA)
res_secreted = tbl_df(res_secreted)

for (i in 1:nrow(res_secreted)) {
  # my ensembl genes have version numbers
  # so the sub command gets rid of those
  # should still work with normal ensembl
  # gene names
  gene_exp = sub("^([^.]*).*","\\1", res_secreted$Ensembl_ids[i])
  secrete_filt_row = filter(secrete_filt, Ensembl == gene_exp)
  secreted = secrete_filt_row$Ensembl
  a_uniprot = secrete_filt_row$Uniprot
  if (!identical(secreted, character(0))) {
    res_secreted$Secreted[i] = 'Y'
    res_secreted$Uniprot_gn_id[i] = toString(a_uniprot)
  }
  else {
    res_secreted$Secreted[i] = ''
    res_secreted$Uniprot_gn_id[i] = ''
  }
  
}

# count secreted genes
sum(res_secreted$Secreted == 'Y', na.rm=TRUE)

write.csv(res_secreted, "res_secrete7D.csv")
