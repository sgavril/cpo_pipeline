#!/usr/bin/bash

######## Tools needed:
# Fastqc
# multiqc
# ddbuk
# chopper
# Path to minikraken2 database

# Activate pre-process conda environment
#conda activate cpo_preprocess

# Set up the input and ouput directories
input_dir="/home/srotich/CPO_Analysis/test/illumina"
output_dir="/home/srotich/CPO_Analysis/test/illumina/results"

# create output_dir
mkdir -p $output_dir

## STEP 1: FastQC and MultiQC

# set up QC output directories
fastqc_output="${output_dir}/fastqc_output"
multiqc_output="${output_dir}/multiqc_output"

# make these directories
mkdir -p $fastqc_output
mkdir -p $multiqc_output

# Run the fastqc
for file in $input_dir/*.fastq*
do
	fastqc -o $fastqc_output $file
done

# Run the multiqc
multiqc -o $multiqc_output $fastqc_output

## STEP 2: Adapter Removal using fastp

# set up directory for adapter removal
adapter_removed="${output_dir}/adapter_removed"
# create the directory
mkdir -p $adapter_removed

# Remove adapters
# loop through input files
for file in $input_dir/*_1.fastq.gz
do
	# Extract sample name from the file name
	sample=$(basename $file _1.fastq.gz)
	# define input file paths
	r1_file=$input_dir/${sample}_1.fastq.gz
	r2_file=$input_dir/${sample}_2.fastq.gz
	
	# Define output file paths
	out_file1=$adapter_removed/${sample}_fastp_1.fastq.gz
	out_file2=$adapter_removed/${sample}_fastp_2.fastq.gz
	out_html=$adapter_removed/${sample}_fastp_report.html
	out_json=$adapter_removed/${sample}_fastp_report.json
	
	# Run fastp
	fastp -i $r1_file -I $r2_file -o $out_file1 -O $out_file2 -h $out_html -j $out_json
done

## STEP 3: Second  QC check

# Set up second QC check output directories

fastqc_check2="${output_dir}/fastqc_check2"
multiqc_check2="${output_dir}/multiqc_check2"

# create second QC check output directories
mkdir -p $fastqc_check2
mkdir -p $multiqc_check2

# Run FastQC
for file in $adapter_removed/*.fastq*
do
	fastqc $file -o $fastqc_check2
done

# Run multiqc
multiqc $fastqc_check2 -o $multiqc_check2

## STEP 5: Taxa classification using Kraken2

# set up the directory
classified_dir="${output_dir}/adapter_removed"
# create the directory
mkdir -p $classified_dir

# path to minikraken2 database
kraken2_db="/home/srotich/CPO_Analysis/minikraken2_db/minikraken2_v2_8GB_201904_UPDATE"

# Run the taxa classification
for file in $adapter_removed/*.fastq*
do
	kraken2 --db "${kraken2_db}" --threads 4 -o "${classified_dir}/$(basename "$file")" --report "${classified_dir}/$(basename "$file").report" $file
	#kraken2-inspect-report $classifified_dir/*.report > $classifified_dir/*.txt
done
# rename kraken2_output files to .txt
#mv /home/srotich/CPO_Analysis/test/nanopore/results/classified_dir/*.report /home/srotich/CPO_Analysis/test/nanopore/results/classified_dir/*.txt

######### visualize kraken2 reports using krona

# set directory for krona reports
krona_reports="${output_dir}/krona_reports"
mkdir -p $krona_reports

# Run krona
ktImportTaxonomy -q 1 -t -2 -o $krona_reports/krona_output.html $classified_dir/*.report

