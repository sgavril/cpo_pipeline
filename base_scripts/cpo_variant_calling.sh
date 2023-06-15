#!/usr/bin/bash

# Fail on error
set -e

# Environment to use: cpo_comparative_genomics
# Tools to use: bwa, samtools, freebayes

# Set up variables
reference="/home/srotich/CPO_Analysis/test/nanopore/results/assembly/assembly.fasta"
input_dir="/home/srotich/CPO_Analysis/test/illumina/results/adapter_removed"
output_dir="/home/srotich/CPO_Analysis/test/illumina/results/variant"
threads=4
mkdir -p $output_dir

# Step 1: Align reads to the reference using BWA
bwa index "$reference"

# Create an empty array to store output BAM files
bam_files=()

# Loop through input files in the input directory
for reads1 in "$input_dir"/*_1.fastq.gz
do
    # Extract the sample name
    sample_name=$(basename "$reads1" _1.fastq.gz)

    # Set up the paths for the paired reads
    reads2="$input_dir/${sample_name}_2.fastq.gz";

    # Align reads using BWA
    aligned_bam="$output_dir/aligned_reads_${sample_name}.bam"
    bwa mem -t $threads "$reference" "$reads1" "$reads2" | samtools view -Sb - > "$aligned_bam"

    # Add BAM file to array
    bam_files+=("$aligned_bam")
done

# Concatenate all BAM files
concatenated_bam="$output_dir/concatenated.bam"
samtools cat -o "$concatenated_bam" "${bam_files[@]}"

# Sort and index the concatenated BAM file
sorted_bam="$output_dir/sorted_concatenated.bam"
samtools sort -@ $threads -o "$sorted_bam" "$concatenated_bam"
samtools index "$sorted_bam"

# Perform variant calling using FreeBayes
output="$output_dir/final_output.vcf";
freebayes -f "$reference" "$sorted_bam" > "$output"

# filter indels using bcftools
output_filt="${output_dir}/final_output_filt.vcf"
# ode for filtering
bcftools view -v indels "${output}" > "${output_filt}"
