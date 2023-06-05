#!/usr/bin/env nextflow

params.input_dir = "/home/sgav/silas_cpo/nanopore"
params.output_dir = "/home/sgav/silas_cpo/nanopore/results"

process fastQC {
    publishDir "${params.output_dir}/fastqc_output", mode:'copy'

    input:
        file(fastq) from fastqc_ch

    output:
        file("*") into fastqc_files

    container 'docker://staphb/fastqc:latest'

    script:
    """
    fastqc -o . ${fastq}
    """
}

workflow {
    fastqc_ch = Channel.fromPath("${params.input_dir}/*.fastq")
    fastQC(fastqc_ch)
}
