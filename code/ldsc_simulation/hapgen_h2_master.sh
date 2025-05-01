#!/bin/bash -l     
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=20g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --partition=moria,msismall,

g=${1}
p=${2}

for i in {1..10};
    do bash ~/projects/admix_heritability/code/ldsc_simulation/compute_h2_hapgen.sh \
    HI 
    ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/admix_HI_g${g}.pgen \
    ${2} 0.8 \
    ${i}; \
done 

# for i in {1..10};
#     do bash ~/projects/admix_heritability/code/ldsc_simulation/compute_h2_hapgen.sh \
#     CGF \
#     ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/admix_CGF_g${g}.pgen \
#     ${2} 0.8 \
#     ${i}; \
# done 