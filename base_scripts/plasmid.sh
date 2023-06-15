
#!/usr/bin/bash

# Environment: mob_suite_env
# tools: mob_suite, chebbaca, pandas <=1.0.5

# Input files
input_dir="/home/srotich/CPO_Analysis/test/illumina/results/assembly"
output_dir="/home/srotich/CPO_Analysis/test/illumina/results/plasmids"
mkdir -p $output_dir


# Run the mob_suite to check on plasmids
mob_recon --infile $input_dir/*.fasta --outdir plasmid

## chewbbaca
chewBBACA.py CreateSchema -i $input_dir -o $chew

chewBBACA.py AlleleCall -i $input_dir -g $chew/schema_seed/ -o $chew

chewBBACA.py ExtractCgMLST -i $chew/*results_*/results_alleles.tsv -o $chew
