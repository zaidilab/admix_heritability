#!/bin/bash -l

g=${1}
model=${2}
rep=${3}
p=${4}
trait=${5}


module load conda
source activate ldsc

cd ~/lab/aazaidi/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/


python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
  --sumstats gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.pca.g.glm.linear \
  --snp "ID" \
  --a1 REF --a2 A1 \
  --N-col OBS_CT \
  --frq A1_FREQ \
  --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.pca.g.munged


python ~/lab/aazaidi/bin/ldsc/ldsc.py \
  --h2 gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.pca.g.munged.sumstats.gz \
  --ref-ld l2//admix_${model}_g${g}_${rep}.cov.2000k  \
  --w-ld l2//admix_${model}_g${g}_${rep}.cov.2000k \
  --out h2/admix_${model}_g${g}_p${p}_${rep}.${trait}.pca.g.cov


# python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
#   --sumstats gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.lanc.g.glm.linear \
#   --snp "ID" \
#   --a1 REF --a2 A1 \
#   --N-col OBS_CT \
#   --frq A1_FREQ \
#   --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.lanc.g.munged


# python ~/lab/aazaidi/bin/ldsc/ldsc.py \
#   --h2 gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.lanc.g.munged.sumstats.gz \
#   --ref-ld l2//admix_${model}_g${g}_${rep}.cov.2000k  \
#   --w-ld l2//admix_${model}_g${g}_${rep}.cov.2000k \
#   --out h2/admix_${model}_g${g}_p${p}_${rep}.${trait}.lanc.g.cov


# python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
#   --sumstats gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.glanc.g.glm.linear \
#   --snp "ID" \
#   --a1 REF --a2 A1 \
#   --N-col OBS_CT \
#   --frq A1_FREQ \
#   --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.glanc.g.munged


# python ~/lab/aazaidi/bin/ldsc/ldsc.py \
#   --h2 gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.glanc.g.munged.sumstats.gz \
#   --ref-ld l2//admix_${model}_g${g}_${rep}.cov.2000k  \
#   --w-ld l2//admix_${model}_g${g}_${rep}.cov.2000k \
#   --out h2/admix_${model}_g${g}_p${p}_${rep}.${trait}.glanc.g.cov
  

python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
  --sumstats gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.nocovar.g.glm.linear \
  --snp "ID" \
  --a1 REF --a2 A1 \
  --N-col OBS_CT \
  --frq A1_FREQ \
  --out gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.nocovar.g.munged


python ~/lab/aazaidi/bin/ldsc/ldsc.py \
  --h2 gwas/admix_${model}_g${g}_p${p}_${rep}.${trait}.nocovar.g.munged.sumstats.gz \
  --ref-ld l2//admix_${model}_g${g}_${rep}.cov.2000k  \
  --w-ld l2//admix_${model}_g${g}_${rep}.cov.2000k \
  --out h2/admix_${model}_g${g}_p${p}_${rep}.${trait}.nocovar.g.cov