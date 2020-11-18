#! /bin/bash

data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

cd alignment
mkdir quant_results
cd quant_results

SRR=$(ls /home/rstudio/data/mydatalocal/data/trimmed_data)
transcriptome_index="/home/rstudio/data/mydatalocal/data/alignment/transcripts_index"

for srr in $SRR
do
echo $srr
salmon quant -i $transcriptome_index -l SR -r /home/rstudio/data/mydatalocal/data/trimmed_data/$srr --validateMappings -o $srr --gcBias
done