# cpo_pipeline
Nextflow implementation of CPO pipeline. Currently runs with conda. To run, use
```
nextflow run cpo.nf
```


### Set up
Installing nextflow:
```
wget -qO- https://get.nextflow.io | bash
chmod +x netflow
mv nextflow miniconda3/bin
```

### Notes on mobsuite and chewbacca
- mobsuite conflicts with current `CPO_comparativegenomics` env, so create a new one with the appropriate version of pandas: 
`mamba create -n mob_suite_env -c bioconda -c conda-forge mobsuite "pandas<=1.0.5" chewbbaca` 
- The conda environments were giving me problems, I just used `pip`:
```
pip install mob_suite chewBBACA
```
- run mobsuite using `mob_recon --infile assembly.fasta --outdir mobsuite_output`
- Run a typical chewBBACA workflow:
```
chewBBACA.py CreateSchema -i ~/silas_cpo/ -o chewbbaca_output 
chewBBACA.py AlleleCall -i ~/silas_cpo/ -g  chewbbaca_output/ -o chewbbaca_output/ 
chewBBACA.py ExtractCgMLST -i ~/silas_cpo/ -o chewbbaca_output/ 
```
