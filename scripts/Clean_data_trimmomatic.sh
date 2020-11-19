#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

# Define a directory where the clean data will be stored after trimmomatic has operated
mkdir -p trimmed_data
cd sra_data

# Create a list with all the SRR files (they all end with .gz as they are zipped)
SRR=$(ls *.gz)

# Scan this list with a "for" loop and use the trimmomatic tool on the raw data
for srr in $SRR
do
echo $srr
java -jar /softwares/Trimmomatic-0.39/trimmomatic-0.39.jar SE /home/rstudio/data/mydatalocal/data/sra_data/$srr /home/rstudio/data/mydatalocal/data/trimmed_data/$srr ILLUMINACLIP:/softwares/Trimmomatic-0.39/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 
done

