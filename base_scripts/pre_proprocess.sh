#/usr/bin/bash

# navigate to the directory containing the FastQ files

cd /home/srotich/CPO_Analysis/test/nanopore

#run multiQC on all the fastq files
multiqc *.fastq.gz -o /home/srotich/CPO_Analysis/test/report
