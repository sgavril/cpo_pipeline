#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//params.input_dir = "/home/sgav/silas_cpo/illumina_seq/"
params.raw = "/home/sgav/silas_cpo/illumina_seq/*_{1,2}.fastq.gz"
params.output_dir = "/home/sgav/silas_cpo/nf_out/"
params.kraken2_db = "/home/srotich/CPO_Analysis/minikraken2_db/minikraken2_v2_8GB_201904_UPDATE"
params.adapter_removed = "/home/sgav/silas_cpo/nf_out/adapter_removed"


reads_ch = Channel.fromFilePairs(params.raw, checkIfExists: true )

process QC1 {
    publishDir "${params.output_dir}", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("fastqc_out")

    script:
    """
    mkdir fastqc_out
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    fastqc -t 10 -o fastqc_out ${reads[0]} ${reads[1]}
    multiqc -f fastqc_out -o fastqc_out
    """
}

process FASTP {
    publishDir "${params.adapter_removed}", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("fastp_out")

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    fastp --in1 ${reads[0]} --in2 ${reads[1]} --out1 ${sample_id}_1.fastq.gz --out2 ${sample_id}_2.fastq.gz
    """
}

workflow {
    fastqc1_out = QC1(reads_ch)
    fastp_out = FASTP(reads_ch)
    //fastqc1_out.qc1.view()
    //fastp_out = Fastp(fastqc1_out.qc1.join(fastq_ch2))
    //fastqc2_out = FastQC2(fastp_out.fastp_out)
    //multiqc_out = MultiQC(fastqc2_out.qc2.collect())
    //kraken_out = Kraken2(fastp_out.fastp_out)
    //Krona(kraken_out.kraken_out)
}