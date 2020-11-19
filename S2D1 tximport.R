library("tximport")
setwd (ifb/data/mydatalocal/data)
dir <- "/ifb/data/mydatalocal/data/alignment/quant_results"

files=list.files(dir)
cells <- gsub(".fastq.gz","",files)
files1=paste0(dir,"/",files,"/","quant.sf")
names(files1)=cells

library(biomaRt)

ensembl <- useEnsembl(biomart = "genes", dataset = "mmusculus_gene_ensembl")
attributeNames <- c('ensembl_transcript_id','external_gene_name')
annot <- getBM(attributes=attributeNames, 
               mart = ensembl)
names(annot) <- c("txname","geneid")

txi <- tximport(files1,type="salmon",tx2gene=annot,ignoreTxVersion=T)


txi1 <- tximport(files1[1:500],type="salmon",tx2gene=annot,ignoreTxVersion=T)

txi2 <- tximport(files1[501:1000],type="salmon",tx2gene=annot,ignoreTxVersion=T)
txi3 <- tximport(files1[1001:1500],type="salmon",tx2gene=annot,ignoreTxVersion=T)
txi4 <- tximport(files1[1501:2000],type="salmon",tx2gene=annot,ignoreTxVersion=T)
txi5 <- tximport(files1[2001:2553],type="salmon",tx2gene=annot,ignoreTxVersion=T)

txi <- txi1
txi$"abundance" <- cbind(txi1$"abundance",txi2$"abundance",txi3$"abundance",txi4$"abundance",txi5$"abundance")
txi$"counts" <- cbind(txi1$"counts",txi2$"counts",txi3$"counts",txi4$"counts",txi5$"counts")
txi$"length" <- cbind(txi1$"length",txi2$"length",txi3$"length",txi4$"length",txi5$"length")
txi$"countsFromAbundance" <- cbind(txi1$"countsFromAbundance",txi2$"countsFromAbundance",txi3$"countsFromAbundance",txi4$"countsFromAbundance",txi5$"countsFromAbundance")

saveRDS(txi, "txi.rds")
