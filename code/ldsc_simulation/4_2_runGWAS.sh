#!/bin/bash -l      


g=${1}
model=${2}
rep=${3}
p=${4}
trait=${5}

cd ~/lab/aazaidi/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/


plink2 --pfile  pgen/admix_${model}_g${g}_${rep} \
  --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref \
  --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait}.pheno \
  --pheno-name g,y \
  --covar pca/admix_${model}_g${g}_${rep}.eigenvec \
  --allow-extra-chr \
  --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.pca


# plink2 --pfile  pgen/admix_${model}_g${g}_${rep} \
#   --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref \
#   local-covar=lanc/admix_${model}_g${g}_${rep}.lanc \
#   local-pvar=bed/admix_${model}_g${g}_${rep}.bim \
#   local-psam=bed/admix_${model}_g${g}_${rep}.fam \
#   --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait}.pheno \
#   --pheno-name g,y \
#   --covar pca/admix_${model}_g${g}_${rep}.eigenvec \
#   --allow-extra-chr \
#   --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.lanc

# plink2 --pfile  pgen/admix_${model}_g${g}_${rep} \
#   --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref \
#   --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait}.pheno \
#   --pheno-name g,y \
#   --covar glanc/admix_${model}_g${g}_${rep}.glanc \
#   --allow-extra-chr \
#   --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.glanc

plink2 --pfile  pgen/admix_${model}_g${g}_${rep} \
  --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref allow-no-covars \
  --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${trait}.pheno \
  --pheno-name g,y \
  --allow-extra-chr \
  --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.nocovar

