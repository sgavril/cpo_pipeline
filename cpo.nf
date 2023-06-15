#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input_dir = "/home/sgav/silas_cpo/illumina_seq/"
params.output_dir = "/home/sgav/silas_cpo/nf_out/"
params.kraken2_db = "/home/srotich/CPO_Analysis/minikraken2_db/minikraken2_v2_8GB_201904_UPDATE"


shell:
"""
mkdir -p ${params.output_dir}
"""

fastq_ch1 = Channel.fromPath("${params.input_dir}/*_1.fastq.gz").map { file -> tuple(file.baseName.replaceAll(/_1$/, ''), file) }
fastq_ch2 = Channel.fromPath("${params.input_dir}/*_2.fastq.gz").map { file -> tuple(file.baseName.replaceAll(/_2$/, ''), file) }

fastq_pairs_ch = fastq_ch1.join(fastq_ch2)

process FastQC1 {
    input:
    tuple val(sample), path(r1)

    output:
    tuple val("${reads}_1.fastq"), file("${reads}_1.fastq.gz"), file("${reads}_1_fastqc.html"), file("${reads}_1_fastqc.zip") into fastqc1_out

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    fastqc $r1
    """
}

process Fastp {
    input:
    tuple val(sample), path(r1), path(r2)

    output:
    tuple val(sample), path("${sample}_fastp_1.fastq.gz"), path("${sample}_fastp_2.fastq.gz"), path("${sample}_fastp_report.html"), path("${sample}_fastp_report.json"), emit: fastp_out

    script:
    """
    echo "Running fastp on files: $r1 and $r2"
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    fastp -i $r1 -I $r2 -o ${sample}_fastp_1.fastq.gz -O ${sample}_fastp_2.fastq.gz -h ${sample}_fastp_report.html -j ${sample}_fastp_report.json
    """
}

process FastQC2 {
    input:
    tuple val(sample), path(fastp_r1), path(fastp_r2), path(fastp_html), path(fastp_json)

    output:
    tuple val(sample), path("*.html"), path("*.zip"), emit: qc2

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    fastqc $fastp_r1 $fastp_r2
    """
}

process MultiQC {
    input:
    path qc_files

    output:
    path("*"), emit: multiqc_out

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    multiqc .
    """
}

process Kraken2 {
    input:
    tuple val(sample), path(fastp_r1), path(fastp_r2)

    output:
    path("*.report"), emit: kraken_out

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    kraken2 --db ${params.kraken2_db} --paired $fastp_r1 $fastp_r2 --report ${sample}.report
    """
}

process Krona {
    input:
    path reports

    output:
    path("*.html"), emit: krona_out

    script:
    """
    source activate /home/srotich/miniconda3/envs/cpo_preprocess
    ktImportTaxonomy -q 1 -t 2 -o krona_output.html $reports
    """
}

workflow {
    fastqc1_out = FastQC1(fastq_ch1)
    fastqc1_out.qc1.view()
    fastp_out = Fastp(fastqc1_out.qc1.join(fastq_ch2))
    fastqc2_out = FastQC2(fastp_out.fastp_out)
    multiqc_out = MultiQC(fastqc2_out.qc2.collect())
    kraken_out = Kraken2(fastp_out.fastp_out)
    Krona(kraken_out.kraken_out)
}