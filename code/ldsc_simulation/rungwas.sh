#!/bin/bash -l      
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=5g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall

model=${1}

for g in {2..20}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do for trait in {min,max}; do \
    
    bash ~/projects/admix_heritability/code/ldsc_simulation/hapgen/4_2_runGWAS.sh ${g} ${model} ${rep} ${p} ${trait}; \
    
    bash ~/projects/admix_heritability/code/ldsc_simulation/hapgen/4_3_compute_ldsc_h2.sh ${g} ${model} ${rep} ${p} ${trait}; \
done; done; done; done


 