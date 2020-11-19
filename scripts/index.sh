#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

# Download automatically the reference transcriptome of mus musculus from ensembl.org
wget ftp://ftp.ensembl.org/pub/release-101/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz 

# Rename it (optionnal)
mv Mus_musculus.GRCm38.cdna.all.fa.gz ref_transcriptome.fa.gz

# De-zip the reference transcriptome file so that salmon can read it (remove the .gz)
gunzip ref_transcriptome.fa.gz

# Create an index from this reference transcriptome
salmon index -t ref_transcriptome.fa -i transcripts_index -k 31

# Place this index in a new working directory dedicated to the quantification
mkdir -p alignment
mv transcripts_index alignment