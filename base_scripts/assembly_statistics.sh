#!/usr/bin/bash

# Environment to activate ==cpo_assembly_statistics
	# tools used = Quast

# Path to input and ouput directories
assembly="/home/srotich/CPO_Analysis/test/illumina/results/assembly"
Assembly_statistics="/home/srotich/CPO_Analysis/test/illumina/results/Assembly_statistics"
mkdir -p $Assembly_statistics

#Run Quast analysis
for file in $assembly/*.fasta
do
	quast.py $file -o $Assembly_statistics
done
