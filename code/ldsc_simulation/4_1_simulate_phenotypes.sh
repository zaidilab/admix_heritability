#!/bin/bash -l      

g=${1}
model=${2}
rep=${3}
p=${4}
trait=${5}

cd ~/lab/aazaidi/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/

module load R

#generate phenotypes
plink2 --pfile pgen/admix_${model}_g${g}_${rep} \
  --score ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p${p}.${trait}.effects \
  --out phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait} 


# Rscript ~/projects/admix_heritability/code/ldsc_simulation/generate_effects.r ${model} ${p} ${rep} ${g} 0.5

Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/generate_phenotypes.R \
  data/ldsc/1kg-ref-hg38/admix/phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait} \
  0.8