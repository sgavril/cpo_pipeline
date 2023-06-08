#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info "Input directory: ${params.input_dir}"
log.info "Output directory: ${params.output_dir}"
log.info "MultiQC directory: ${params.multiqc_dir}"

shell:
"""
mkdir -p ${params.output_dir}
mkdir -p ${params.multiqc_dir}
"""

fastq_ch = Channel.fromPath("${params.input_dir}/*.fastq")

process Fastp {
    beforeScript 'source activate /home/srotich/miniconda3/envs/cpo_preprocess'

    input:
    path fastq

    output:
    tuple val(fastq.baseName), path("${fastq.baseName}_fastp.fastq"), path("${fastq.baseName}_fastp.html"), emit: fastp

    script:
    """
    fastp -i $fastq -o ${fastq.baseName}_fastp.fastq -h ${fastq.baseName}_fastp.html --detect_adapter_for_pe --thread 4
    """
}

process FastQC {
    beforeScript 'source activate /home/srotich/miniconda3/envs/cpo_preprocess'

    input:
    tuple val(base), path(fastp_fastq), path(fastp_html)

    output:
    path("*.html"), emit: report
    path("*.zip"), emit: data

    script:
    """
    fastqc $fastp_fastq -o .
    """
}

workflow {
    fastp_out = Fastp(fastq_ch)
    FastQC(fastp_out)
}
