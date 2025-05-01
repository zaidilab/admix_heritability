#!/bin/bash -l      
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall
#SBATCH --output=logs/h2/h2-%j.out



model=${1}
g=${2}
trait=${3}

cd ~/lab/aazaidi/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/

mkdir -p pgen
mkdir -p phenotypes
mkdir -p gwas
mkdir -p h2

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do \

  # simulate phenotypes
  # bash ~/projects/admix_heritability/code/ldsc_simulation/hapgen/4_1_simulate_phenotypes.sh ${g} ${model} ${rep} ${p} ${trait}

  #run gwas
  bash ~/projects/admix_heritability/code/ldsc_simulation/hapgen/4_2_runGWAS.sh ${g} ${model} ${rep} ${p} ${trait}

  #run ldsc to compute heritability
  bash ~/projects/admix_heritability/code/ldsc_simulation/hapgen/4_3_compute_ldsc_h2.sh ${g} ${model} ${rep} ${p} ${trait}

  
done; done



