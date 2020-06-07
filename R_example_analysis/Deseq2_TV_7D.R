library(DESeq2)

dir = getwd()
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

row_names <- rownames(res7D)

# rename rownames
i = 1
no_name = 0
for (name in row_names) {
  name <- sub("^([^.]*).*", "\\1", name)
  j = match(name, name_map$Gene_stable_ID)
  if (!is.na(j))
    row_names[i] <- name_map$Gene_name[j]
  else {
    no_name = no_name + 1
    print(name)
  }
  i = i + 1
}

no_name

rownames(res7D) <- row_names

summary(res7D, 0.05)

sum(res7D$padj < 0.05, na.rm=TRUE)



### Enhanced Volcano Plot
# Documentation here: https://www.bioconductor.org/packages/release/bioc/vignettes/EnhancedVolcano/inst/doc/EnhancedVolcano.html

library(EnhancedVolcano)

#pcut_exp = 5
#fcut = 1.8

pcut_exp = 6
fcut = 0.9
# Defaults: FCcutoff = 2; pCutoff = 10e-6
#evolcano_1
#default
EnhancedVolcano(res7D,
                lab = rownames(res7D),
                title = 'Cre7D v Control',
                x = 'log2FoldChange',
                y = 'pvalue',
                ylim = c(0, 100),
                xlim = c(-6, 6))

EnhancedVolcano(res7D,
                lab = rownames(res7D),
                title = 'Cre7D v Control',
                x = 'log2FoldChange',
                y = 'pvalue',
                pCutoff = 10*10**(-pcut_exp),
                FCcutoff = fcut,
                ylim = c(0, 250),
                xlim = c(-8, 10)
                )


res7D

write.csv(res7D, "res7D_all.csv")
sum(res7D$padj < 0.05, na.rm=TRUE)
