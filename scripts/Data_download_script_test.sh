#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

#define a directory where the data will be stored
mkdir -p sra_data
cd sra_data

#First Test to verify that the data are well extracted from the GO website

#Create an intermediate .txt file with the names of the first 10 cells
head -10 /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt > SRR_partial.txt

#Define SRR
SRR=`cat /home/rstudio/data/mydatalocal/data/SRR_partial.txt`

#Extract data from the GO website for the 10 cells chosen with Fastq-dump on SRR and print the name of the cell (SRR...) whose data are being downloaded
for srr in $SRR
do
echo $srr
fastq-dump $srr --gzip
done

