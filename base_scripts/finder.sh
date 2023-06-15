#!/usr/bin/bash
# tools used: 
	#AMRFinderPlus
# conda environment to use: Genome_annotation_and_amr_prediction

# Set paths to directories
input="/home/srotich/CPO_Analysis/test/illumina/results/assembly"
outputFile="/home/srotich/CPO_Analysis/test/illumina/amr_prediction/finder.txt"

# Create the output file  for the AMR finder
if [ ! -f $outputFile ]; then 
	touch $outputFile
fi

# Run AMRfinderPlus
amrfinder -n $input/*.fasta -o $outputFile
