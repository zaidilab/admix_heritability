#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=moria,msismall


model=${1}
g=${2}

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix


for rep in {1..10}; do \
    gcta --bfile bed/admix_${model}_g${g}_${rep} --make-grm --out grm/admix_${model}_g${g}_${rep} --threads 10; 
done    