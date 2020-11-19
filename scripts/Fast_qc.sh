#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

# Define a directory where the data will be stored
mkdir -p fastq_data

# Create a list containing the .fast.gz files of the first 10 cells stored in sra_data
SRR=$(ls /home/rstudio/data/mydatalocal/data/sra_data | head -10)

# Use a "for" loop to scan this list and analyse each file, generating a fastqc.html and fastqc.zip files that can be consulted to check the quality
for srr in $SRR
do
fastqc $srr -o /home/rstudio/data/mydatalocal/data/fastq_data -t 4
done

# The Multiqc command will use the files for the first 10 cells that we just stored in the new directory fastq_data to generate a report (.html) that summarize the quality of the data
multiqc fastq_data