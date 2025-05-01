#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall

module load R

g=${1}
model=${2}

mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/glanc/

for i in {1..10}; \
    do Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/cal_glanc.r $g $model $i; \
    echo $i; \
done