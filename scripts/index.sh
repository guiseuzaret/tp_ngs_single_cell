#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data


wget ftp://ftp.ensembl.org/pub/release-101/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz 

mv Mus_musculus.GRCm38.cdna.all.fa.gz ref_transcriptome.fa.gz

gunzip ref_transcriptome.fa.gz

salmon index -t ref_transcriptome.fa -i transcripts_index -k 31

mkdir -p alignment

mv transcripts_index alignment