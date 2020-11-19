#! /bin/bash

# Define a working directory
data="/home/rstudio/data/mydatalocal/data"
mkdir -p $data
cd $data

# Define a directory where the results of quantification will be stored
cd alignment
mkdir quant_results
cd quant_results

# Create a list containing all the single cells' transcriptomic cleaned data stored in trimmed_data
SRR=$(ls /home/rstudio/data/mydatalocal/data/trimmed_data)

# Define transcriptome_index as the localization in the arborescence where index can be found to be aligned with the data
transcriptome_index="/home/rstudio/data/mydatalocal/data/alignment/transcripts_index"

# Use a "for" loop to scan this list and align each file with the reference transcriptome, generating a fastq.gz result file for each single cell
for srr in $SRR
do
echo $srr
salmon quant -i $transcriptome_index -l SR -r /home/rstudio/data/mydatalocal/data/trimmed_data/$srr --validateMappings -o $srr --gcBias
done
