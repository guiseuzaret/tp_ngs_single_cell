# TP NGS Single cell

The objective of the part of the TP NGS described in this document was to build an atlas of dental cell types in healthy mouse incisor based on single-cell mRNA sequencing data obtained with SmartSeq2. We will download these data and control their quality. Then we will align these cDNA sequences obtained with SmartSeq2 with a reference transcriptome of mus musculus cells to quantify the expression of genes in each single cell. Then we will ultimately build the atlas based on the transcription profiles of each cell through clustering analyses.

#Make a brief overview of the main scRNA-seq techniques, in particular Smart-seq2? Is our data single-end ? Paired-end ? (And when in the protocol will it matter?)

#Raw RNA-Seq data download 

First, access to the dataset which is publicly available on the GEO database using the accession code GSE146123. Select the samples of interest through these filters :
- Platform : smart_seq2
- Phenotype : healthy
- Organism : mus musculus
- source_name : incisor

Download the list of SRA identifiers (there is one for each single cell).

Download automatically the transcripts from the GEO database thanks to the list and transform them to fastq format with the fastq-dump tool.
First, we verify that the data are well extracted from the GO website and transformed on a first 10 cells with the bash script "**Data_download_script_test.sh**" in this GitHub. 

You should see the data from each single cell being downloaded as a transformed .fastq.gz file in your target directory (here sra_data).
If it works well, proceed and extract the transcripts from all the cells using the complete SRA list with the bash script "**Data_download_script.sh**" in this GitHub as well.


# Raw RNASeq data quality control

When the transcriptomic data of the 2555 cells are downloaded and transformed in your target directory allright, analyse their quality using the fastqc tool. It will outline, for each cells, the content in adapters, the overrepresented sequence (and try to identify them) or the %GC content in the transcriptome. This is mainly to verify that the data are not contaminated or odd in any way before aligning them with a reference transcriptome.
Use the FastQC tool on a few cells of your data set. The script "**Fast_qc.sh**" in this GitHub do it on the first 10 cells. Then, the quality results for these 10 cells can be visualized altogether using the MultiQC tool, which is at the end of this same script.


# Cleaning of the raw sequences 

A last step before using our sequences for alignment is to clean them of adaptors, sequences that are too short and will therefore not be aligned, and overrepresented sequences. We do it with the "**Clean_data_trimmomatic.sh**" bash script in this GitHub which uses the Trimmomatic tool. Trimmomatic erase from the sequences what has been aforementioned (adaptors, overrespresented sequences..), "trimming" or "cleaning" the data.

Check the efficiency of cleaning by verifying that all the features that we wanted like overrepresented sequences have been reduced by trimmomatic. For this, use FastQC and MultiQC tools on the first 10 cells of the clean data generated by trimmomatic. It is done through the "**Fast_qc_clean_data.sh**" bash scripts in this GitHub.
We can now compare the MultiQC reports to see the effect of trimmomatic on our data.


# M. musculus transcriptome download

Recover the M. musculus transcriptome from the ensembl database (https://www.ensembl.org/info/data/index.html). On "FTP site" in "Complete datasets and databases", we chose the latest relase (101) and all cDNA transcripts of mus musculus obtained with Fasta (ftp://ftp.ensembl.org/pub/release-101/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz)

This M.musculus reference transcriptome is downloaded in our machine automatically with the function wget.
Salmon is a tool that we will use for to map and quantify the transcripts data from our incisor's single cells. This tool, which is well adapted for SmartSeq2 data, need and index to map the transcript. We use the aforementioned mus musculus reference transcriptome that we define as the index for Salmon in the "**index.sh**" bash script in this GitHub (after automatic download of the reference transcriptome).

# Transcript expression quantification
Using Salmon, we then quantify the occurence of each cDNA transcript (identified from M.musculus reference transcriptome) in our SmartSeq2 mouse incisor single-cell transcriptomic data. We used the quantification function provided by Salmon on our cleaned data (post-trimmomatic). This function requires the index that we already established from the reference transcriptome. See the bash script "**quantif.sh**" in this GitHub. Here, Salmon generates a file for each cell containing the transcript identity of each read and their occurence.


# Realization of the dental atlas
In this second part, we will use these incisor single-cell transcriptomic data to generate an atlas of the cell types in mouse incisor based on gene expression profiles. 
The method is also available in a Rmarkdown document that can be open with Rstudio in the "TP NGS single cell part 2.Rmd" file in this same GitHub.

We want to create an atlas of dental cells out of single cell transcriptomic data obtained on mouse incisor with Smart-Seq2.
To do so, we will use the SeuRat package to try to apprehend our dataset through clustering the cells and finding markers within these clusters. Ultimately, we will perform RNA velocity analysis to try to decipher if cells from a given cluster prefentially give cells from other clusters, i.e. try to establish directions of differentiation across dental cells.

# Importation of Salmon data
First, we import the files generated by Salmon that contain the transcriptomic data and summarize them into a matrix.

```{r tximport, eval=F, echo=T}
# Define the folder with all the files generated by Salmon as a directory
setwd ("/ifb/data/mydatalocal/data")
dir <- "/ifb/data/mydatalocal/data/alignment/quant_results"
# De-zip the files through creating a list with all them and using the function gsub to replace the ".fastq.gz" by a blank
files=list.files(dir)
cells <- gsub(".fastq.gz","",files)
# Finish their transformation into a format that can be read by SeuRat through concatenation with the suitable termination "quant.sf"
files1=paste0(dir,"/",files,"/","quant.sf")
names(files1)=cells
# Import the biomaRt tool
library(biomaRt)
# Create a function "annot" that use biomaRt to attribute the gene name for each transcript in every file (fetched from the Ensembl database)
ensembl <- useEnsembl(biomart = "genes", dataset = "mmusculus_gene_ensembl")
attributeNames <- c('ensembl_transcript_id','external_gene_name')
annot <- getBM(attributes=attributeNames, 
               mart = ensembl)
names(annot) <- c("txname","geneid")
# Import the tximport tool
library("tximport")
# Using tximport we generate the matrix containing all the transcripts with their gene names (associated thanks to the "annot" function) for each cell
# Due to the size of the files that can impede the import, we import them separetely and concatenate them afterwards
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
# At this stage we can save the matrix in a .rds file
saveRDS(txi, "txi.rds")
# One can then start the clustering using SeuRat from scratch by just re-opening this file as follows :
 txi=readRDS("txi.rds")
```

# SeuRat - Scaling, Normalization, Dimension Reduction, Clustering and Finding Markers

# Setting-up of the Seurat object
We need to import the SeuRat package into Rstudio to perfom reduction dimension, clustering, etc...

```{r Seurat, eval=F, echo=T}
# Import the SeuRat and dplyr tools
library(dplyr)
library(Seurat)
# Define a working directory
setwd("/ifb/data/mydatalocal/tp_ngs_single_cell")
# Change the matrix into a SeuRat object (which is a similar matrix but exploitable by SeuRat)
incisor <- CreateSeuratObject(counts = txi$counts, project = "incisor", min.cells = 3, min.features = 200)
```

# Cells' quality control prior to downstream analyses
Before trying to understand what the variance in our dataset corresponds to and try to identify clusters of cells with similar identity based on transcripts expression, we want to clear the dataset from cells with too few or too many reads or in which a high proportion of reads correspond to mtDNA. These cells would introduce bias in downstream analyses.

```{r Quality control, eval=F, echo=T}
# Visualize the distribution of the % of mtDNA genes across our dataset with a Violin Plot
incisor[["percent.mt"]] <- PercentageFeatureSet(incisor, pattern = "^mt-")
VlnPlot(incisor, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
# Another way of visualizing the quality of the dataset : a 2 dimension Scatter Plot
plot1 <- FeatureScatter(incisor, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(incisor, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
plot1 + plot2
```

![Cells quality control plot](https://github.com/guiseuzaret/tp_ngs_single_cell/blob/master/Before%20selection.png)

# Selection to eliminate the cells supposed of bad quality 

```{r Features filtering, eval=F, echo=T}
# Filter the cells : here we eliminate the cells that are below the 5% quantile for the quantity of different transcript expressed and the ones that have more than 15% of mtDNA transcripts. We also eliminate cells with an oddly high level of reads
quantile5_incisor <- quantile(incisor$nFeature_RNA, probs = c(0.05), na.rm = FALSE, names = TRUE, type = 7)
incisor <- subset(incisor, subset = nFeature_RNA > quantile5_incisor & percent.mt < 15 & nCount_RNA < 1000000)
# Visualize the effects of the filter on the dataset
VlnPlot(incisor, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
```
![Cells quality control plot](https://github.com/guiseuzaret/tp_ngs_single_cell/blob/master/After%20selection.png)

# Normalization
To have a relevant comparison of gene expression levels across cells, we normalize the count numbers using the LogNormalize method that normalize the expression of each transcript in each given cell by the total expression and multiplies it by the scale factor.

```{r Normalization, eval=F, echo=T}
incisor <- NormalizeData(incisor, normalization.method = "LogNormalize", scale.factor = 10000)
```

# Identification of highly variable genes
Then, we identify the genes for which the number of counts are the more variable across cells with the FindVariableFeatures function.
Here there are 28851 different genes so we stick with the 2885 most variable genes (90% quantile).

```{r Variant identification, eval=F, echo=T}
# Apply the selection method to detect differentially expressed genes
incisor <- FindVariableFeatures(incisor, selection.method = "vst", nfeatures = 2885)
VariableFeatures(incisor)
# Identify the 10 most highly variable genes
top10 <- head(VariableFeatures(incisor), 10)
top10
# Plot the variable features 
plot1 <- VariableFeaturePlot(incisor)
# Add labels for the 10 most highly variable genes defined earlier in the variable top10
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE, xnudge=0, ynudge=0)
plot1
plot2
```
![Cells quality control plot](https://github.com/guiseuzaret/tp_ngs_single_cell/blob/master/Most%20variable%20genes.png)
# Scaling the data
Prior to perform reduction dimension of our dataset, we need to scale the data. The ScaleData function basically shift the mean expression and variance across cells to 0 and 1, respectively. Its purpose is to avoid bias in downstream analyses due to genes that are have a very high number of counts whenever they are expressed by a cell.

```{r Data Scaling, eval=FALSE}
# Select all the genes' names 
all.genes <- rownames(incisor)
# Scale the data
incisor <- ScaleData(incisor, features = all.genes)
```

# Linear dimensional reduction through Principal Component Analysis (PCA)
We next perform PCA using the most variable genes.

```{r PCA, eval=F, echo=T}
# Perform PCA with selection of the most variable genes through the 'features' parameter
incisor <- RunPCA(incisor, features = VariableFeatures(object = incisor))
```

# Visualization of the results of PCA in many different ways

```{r PCA results, eval=F, echo=T}
# Shows the main differentially expressed genes that have been used to construct the dimensions, or Principal Components (PC)
print(incisor[["pca"]], dims = 1:5, nfeatures = 5)
# Plot all the genes that have been used to construct the dimensions (PC). Shows the number of dimension plots specified with the parameter "dims"
VizDimLoadings(incisor, dims = 1:2, reduction = "pca")
# Project all the cells on a 2 dimension graph with each axis being one of the two first PC that account for most of the variance in the dataset (PC_1 and 2)
DimPlot(incisor, reduction = "pca")
# Shows a heatmap of gene expression across the dataset for the genes with which the selected dimension have been constructed
DimHeatmap(incisor, dims = 1, cells = 2257, balanced = TRUE)
```

# Choose the dimensionality of the dataset
We want to ultimately reduce the dimensionality of our dataset to a representation in 2 dimension to better apprehend our dataset. 
We thus procede to a non-linear dimension reduction using the UMAP tool. It is less sensitive to extreme datapoints than PCA, that can be an issue for the representation of the dataset as we have few points (2553 cells) with a high number of dimensions. 
The aim is to have a global explanation of the maximum of variance in our dataset, we will stick with the dimensions obtained after the PCA that are the more explicative of the overall variance. This is a tricky part as we don't want to lose any significant biological information by removing some dimensions, but UMAP works better with less dimensions in input. To assess the importance of each PC, there are a few representative methods :

``` {r Dimensionality, eval=F, echo=T}
# Plot the p-values associated with each PC and compare them to a uniform distribution (dashed line). PCs for which the genes have very low p-values are more likely to be of significative importance
incisor <- JackStraw(incisor, num.replicate = 100)
incisor <- ScoreJackStraw(incisor, dims = 1:20)
JackStrawPlot(incisor, dims = 1:20)
# Plots all PCs with a ranking depending on the percentage of total variance that is explained by them. 
ElbowPlot(incisor)
```

# Non-linear dimensional reduction through UMAP
Here we decided to stick with 20 dimensions despite the high drop after 10 PCs on the Elbow Plot. The analysis done with only 10 PCs showed similar results.

```{r UMAP, eval=F, echo=T}
#Run the UMAP on the dataset
incisor <- RunUMAP(incisor, dims = 1:20)
#Visualize UMAP result in a 2 dimension graph
DimPlot(incisor, reduction = "umap")
```

# Clustering 
Based on how the cells have been separated in space by our subsequent dimensional reductions, we hope to find cluster of cells that are close to each other and could be the same cell type. We thereby want to establish the dental cell atlas based on these clusters that will represent supposedly all the cell types within mouse incisor.
The FindNeighbors technique is used. Based on the distance matrix, it constructs a graph of the closest neighbours then refine the weight of the border between two cells depending on their shared common identity with their common neighbours, locally. 
This data is used to generate clusters with the FindClusters tool.
``` {r Clustering, eval=F, echo=T}
# Apply the FindNeighbors technique and FindClusters 
incisor <- FindNeighbors(incisor, dims = 1:20)
incisor <- FindClusters(incisor, resolution = 0.5)
# Visualize the UMAP plot again with the clusters added, each in a different color
DimPlot(incisor, reduction = "umap")
```

# Finding clusters' biomarkers
To finish our atlas, we need to identify the cell types that clusters could correspond to. We seeked for the specific markers of each clusters. Based on online databases such as Blast to identify the function of those genes and which cell types normally express them, we tried to annote our clusters.

```{r Cluster biomarkers, eval=F, echo=T}
# FindMarkers give the most specific markers of the first cluster, i.e. the ones that have the highest expression in this cluster compared to all the others
cluster1.markers <- FindMarkers(incisor, ident.1 = 1, min.pct = 0.25)
# Shows the 5 first specific markers
head(cluster1.markers, n = 5)
# FindAllMarkers allow to do the same thing as FindMarkers but find the specific markers of every cluster simultaneously
incisor.markers <- FindAllMarkers(incisor, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
# Show the 5 first specific markers of each cluster in a table, with the associated p-value
incisor.markers %>% group_by(cluster) %>% top_n(n = 5, wt = avg_log2FC)
# Adding of the ROC test which gives the 'classification power' of each marker, a score between 0 and 1
cluster1.markers <- FindMarkers(incisor, ident.1 = 0, logfc.threshold = 0.25, test.use = "roc", only.pos = TRUE)
head(cluster1.markers, n = 5)
# Plot the expression levels in cells classified by clusters for a given marker
VlnPlot(incisor, features = c("Mrc1", "C1qb"))
VlnPlot(incisor, features = c("Mrc1", "C1qb"), slot = "counts", log = TRUE)
# Show the distribution of cells expressing a given marker on the UMAP
FeaturePlot(incisor, features = c("Smoc2", "C1qb","Tnc","Emcn","Car2","Sfrp2","Cd83","Epcam"))
FeaturePlot(incisor, features = c("S100a9","Cd209a","Ibsp","Scn7a","Rgs5","Krt17","Gm10801","Gm17660"))
# Generates a HeatMap of the expression of the 10 best markers of each cluster across all the dataset
top10 <- incisor.markers %>% group_by(cluster) %>% top_n(n = 10, wt = avg_log2FC)
DoHeatmap(incisor, features = top10$gene) + NoLegend()
# Same HeatMap with only the 2 best markers so that it's more readable
top2 <- incisor.markers %>% group_by(cluster) %>% top_n(n = 2, wt = avg_log2FC)
DoHeatmap(incisor, features = top2$gene) + NoLegend()
```
# RNA velocity
We then tried to establish if cells from a given cluster preferentially becomes cells from another cluster. This would suggest that these clusters are intermediate cell types along a differentiation pathway. This is done through RNA velocity. The presence of unspliced versus spliced transcripts for each gene is analyzed to decipher if the cell is increasing or decreasing the expression of this gene. This analysis done on thousands of transcripts allow to infer if a cell was currently acquiring a gene expression profile closer to another given cell in the dataset.
The whole process and the method are described further in this GitHub :
https://github.com/Lelmose/TP_NGS_2020_Single_Cell

    © 2021 GitHub, Inc.
    Terms
    Privacy
    Security
    Status
    Help

    Contact GitHub
    Pricing
    API
    Training
    Blog
    About







