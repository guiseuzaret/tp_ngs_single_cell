#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

mkdir -p trimmed_data
cd sra_data

#Test sur quelques cellules
#SRR=$(ls *.gz | head -10)


#Test sur tout le jeu de données
SRR=$(ls *.gz)

for srr in $SRR
do
echo $srr
java -jar /softwares/Trimmomatic-0.39/trimmomatic-0.39.jar SE /home/rstudio/data/mydatalocal/data/sra_data/$srr /home/rstudio/data/mydatalocal/data/trimmed_data/$srr ILLUMINACLIP:/softwares/Trimmomatic-0.39/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 
done

