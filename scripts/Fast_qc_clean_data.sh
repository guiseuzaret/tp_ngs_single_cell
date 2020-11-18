#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

mkdir -p fastq_data_clean

cd trimmed_data
SRR=$(ls /home/rstudio/data/mydatalocal/data/trimmed_data | head -10)

for srr in $SRR
do
fastqc $srr -o /home/rstudio/data/mydatalocal/data/fastq_data_clean -t 4
done


multiqc fastq_data_clean