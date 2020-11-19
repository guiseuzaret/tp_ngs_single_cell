#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

#define a directory where the data will be stored
mkdir -p sra_data
cd sra_data

#define SRR
SRR=`cat /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt`

#Extract data from the GO website with FastQ-dump on SRR and print the name of the cell (SRR...) whose data are being downloaded
for srr in $SRR
do
echo $srr
fastq-dump $srr --gzip
done


