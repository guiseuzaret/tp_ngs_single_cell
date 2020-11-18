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


multiqc fastq_data