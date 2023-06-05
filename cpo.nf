#!/usr/bin/env nextflow

params.input_dir = "/home/srotich/CPO_Analysis/test/nanopore"
params.output_dir = "/home/srotich/CPO_Analysis/test/nanopore/results"

Channel
    .fromPath("${params.input_dir}/*.fastq")
    .set { fastq_ch }

process fastQC {
    publishDir "${params.output_dir}/fastqc_output", mode:'copy'

    input:
        file(fastq) from fastq_ch

    output:
        file("*") into fastqc_files

    container 'docker://staphb/fastqc:latest'

    script:
    """
        fastqc -o . $fastq
    """
}