#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

mkdir -p sra_data
cd sra_data

#head -10 /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt > SRR_partial.txt
SRR=`cat /home/rstudio/data/mydatalocal/data/SRR_Acc_List.txt`

for srr in $SRR
do
echo $srr
fastq-dump $srr --gzip
done


