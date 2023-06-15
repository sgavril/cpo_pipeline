#!/usr/bin/bash

# conda enviroment used
# Genome_annotation_and_amr_prediction

# Path to bakta database
amr_database="/home/srotich/CPO_Analysis/test/Bakta/db"

# path to assembly fasta file
input="/home/srotich/CPO_Analysis/test/illumina/results/assembly"

#make anotation directory
amr="/home/srotich/CPO_Analysis/test/nanopore/illumina/amr_prediction"
#mkdir -p $amr

## Run annotation using bakta
bakta --db $amr_database $input/*.fasta -o $amr
