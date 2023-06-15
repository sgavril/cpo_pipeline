#!/usr/bin/bash

# Environment to use: cpo_comparative_genomics
# tools to use:
   # bwa
   # samtools
   # freebayes

# Set up variables
reference="/home/srotich/CPO_Analysis/test/nanopore/results/assembly/assembly.fasta"
input_dir="/home/srotich/CPO_Analysis/test/illumina/results/adapter_removed"
output_dir="/home/srotich/CPO_Analysis/test/illumina/results/variant"
mkdir -p $output_dir

# Step 1: Align reads to the reference using BWA
bwa index "$reference"

# Loop through input files in the input directory
for reads1 in "$input_dir"/*_1.fastq.gz
do
    # Extract the sample name
    sample_name=$(basename "$reads1" _1.fastq.gz)
   
    # Set up the paths for the paired reads
    reads2="$input_dir/${sample_name}_2.fastq.gz";
    output="$output_dir/${sample_name}.vcf";
   
    # Align reads using BWA
    bwa mem -t 4 "$reference" "$reads1" "$reads2" | samtools view -Sb - > aligned_reads.bam;
   
    # Sort and index the aligned reads
    samtools sort -@ 4 -o aligned_reads_sorted.bam aligned_reads.bam;
    samtools index aligned_reads_sorted.bam;
   
    # Perform variant calling using FreeBayes
    freebayes -f "$reference" aligned_reads_sorted.bam > "$output"
done

