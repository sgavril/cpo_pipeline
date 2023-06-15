#!/usr/bin/bash

# Ativate Genome Assembly
#conda activate cpo_assembly


### STEP 6: Run unicycler

# Set input and output directories for assembly
input_dir="/home/srotich/CPO_Analysis/test/illumina/results/adapter_removed"
assembly="/home/srotich/CPO_Analysis/test/illumina/results/assembly"
mkdir -p $assembly

# Run  genome assembly
for file in $input_dir/*_1.fastq.gz
do
	# Extract sample name from the file name
        sample=$(basename $file _1.fastq.gz)
        
	# define input file paths
        r1_file=$input_dir/${sample}_1.fastq.gz
        r2_file=$input_dir/${sample}_2.fastq.gz
	
	# Run unicycler
	unicycler -1 $r1_file -2 $r2_file -o $assembly
done


