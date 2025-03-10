#!/bin/bash -l
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall
#SBATCH --output=/users/6/klema030/AdjustedHE/output/slurm/%j.out

theta=${1}
gen=${2}

module load R/4.2.0-rocky8

#get expected terms for each theta gen combination
Rscript /users/6/klema030/AdjustedHE/exp_vg_terms.R ${theta} ${gen}
