# TP NGS Single cell

The objective of the part of the TP NGS described in this document was to build an atlas of dental cell types in healthy mouse incisor based on single-cell mRNA sequencing data obtained with SmartSeq2. We will download these data and control their quality. Then we will align these cDNA sequences obtained with SmartSeq2 with a reference transcriptome of mus musculus cells to quantify the expression of genes in each single cell. Then we will ultimately build the atlas based on the transcription profiles of each cell through clustering analyses.

#Make a brief overview of the main scRNA-seq techniques, in particular Smart-seq2?

#Raw RNA-Seq data download 

First, access to the dataset which is publicly available on the GEO database using the accession code GSE146123. Select the samples of interest through these filters :
- Platform : smart_seq2
- Phenotype : healthy
- Organism : mus musculus
- source_name : incisor

Download the list of SRA identifiers (there is one for each single cell).

Download automatically the transcripts from the GEO database thanks to the list and transform them to fastq format with the fastq-dump tool.
First, we verify that the data are well extracted from the GO website and transformed on a few cells with this bash script:

``` 
#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

#Define a directory where the raw data will be stored
mkdir -p sra_data
cd sra_data

#Create an intermediate .txt file with the names of the first 10 cells
head -10 /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt > SRR_partial.txt

#Define SRR
SRR=`cat /home/rstudio/data/mydatalocal/data/SRR_partial.txt`

#Extract data from the GO website for the 10 cells chosen with Fastq-dump on SRR
for srr in $SRR
do
echo $srr
fastq-dump $srr --gzip
done

``` 

If it works well, procede and extract the transcripts from all the cells using the complete SRA list with this bash script.

``` 
#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

#Define a directory where the data will be stored
mkdir -p sra_data
cd sra_data

#Define SRR
SRR=`cat /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt`

#Extract data from the GO website
for srr in $SRR
do
echo $srr
fastq-dump $srr --gzip
done

``` 

# Raw RNASeq data quality control

Analyse data quality using fastqc.

``` 
#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

mkdir -p fastq_data

cd sra_data
SRR=$(ls /home/rstudio/data/mydatalocal/data/sra_data | head -10)

for srr in $SRR
do
fastqc $srr -o /home/rstudio/data/mydatalocal/data/fastq_data -t 4
done
``` 
Finally visualize the data with multiqc.

``` 
multiqc fastq_data
``` 

Clean the sequences with trimmomatic. You can use the tool fastq-dump (of SRA-toolkit) to download the data and transform it to fastq format automatically. 

Tip 1 : zipping the files may be useful.

Tip 2 : is our data single-end ? paired-end ? If you need trimmomatic, you can check its user manual.
M. musculus transcriptome download

Recover the M. musculus transcriptome from the ensembl database (we need the cDNA of all transcripts) https://www.ensembl.org/info/data/index.html
Transcript expression quantification

Key points :

    We will first use salmon since it is a fast tool adapted to SMART-Seq2 mapping.

    In the particular case of velocity : use STAR instead on the genome (much longer!)

Tip : separate indexing and mapping in different scripts


