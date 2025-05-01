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

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do \

    # awk '{print 0, $1, $2, $3}' phenotypes/admix_${model}_g${g}_p${p}_${rep}.med.pheno > phenotypes/admix_${model}_g${g}_p${p}_${rep}.med.fid.pheno; \
    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.med.fid.pheno --out gcta/admix_${model}_g${g}_p${p}_${rep}.med --mpheno 2; \
    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.med.fid.pheno --covar pca/admix_${model}_g${g}_${rep}.eigenvec --out gcta/admix_${model}_g${g}_p${p}_${rep}.med --mpheno 2; \


    awk '{print 0, $1, $2, $3}' phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.pheno > phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.fid.pheno; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.fid.pheno --out gcta/admix_${model}_g${g}_p${p}_${rep}.min.y --mpheno 2; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.fid.pheno --qcovar pca/admix_${model}_g${g}_${rep}.eigenvec --out gcta/admix_${model}_g${g}_p${p}_${rep}.min.cov.y --mpheno 2 \

    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.fid.pheno --out gcta/admix_${model}_g${g}_p${p}_${rep}.min.g --mpheno 1; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.min.fid.pheno --qcovar pca/admix_${model}_g${g}_${rep}.eigenvec --out gcta/admix_${model}_g${g}_p${p}_${rep}.min.cov.g --mpheno 1

    awk '{print 0, $1, $2, $3}' phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.pheno > phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.fid.pheno; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.fid.pheno --out gcta/admix_${model}_g${g}_p${p}_${rep}.max.y --mpheno 2; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.fid.pheno --qcovar pca/admix_${model}_g${g}_${rep}.eigenvec --out gcta/admix_${model}_g${g}_p${p}_${rep}.max.cov.y --mpheno 2

    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.fid.pheno --out gcta/admix_${model}_g${g}_p${p}_${rep}.max.g --mpheno 1; \
    gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --reml --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.max.fid.pheno --qcovar pca/admix_${model}_g${g}_${rep}.eigenvec --out gcta/admix_${model}_g${g}_p${p}_${rep}.max.cov.g --mpheno 1

done; done

for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for trait in {g,y}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \

    grep "V(G)" gcta/admix_${model}_g${g}_p${p}_${rep}.${arch}.${trait}.hsq | awk -v m=${model} -v a=${arch} -v g=$g -v t=${trait} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,t,p,i,$0}' \

done; done; done; done; done; done > gcta/admix_all.nocov.hsq

for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for trait in {g,y}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \

    grep "V(G)" gcta/admix_${model}_g${g}_p${p}_${rep}.${arch}.cov.${trait}.hsq | awk -v m=${model} -v a=${arch} -v g=${g} -v t=${trait} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,t,p,i,$0}' \

done; done; done; done; done; done > gcta/admix_all.cov.hsq


for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for trait in {g,y}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \

    tail -n+2 -q phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.pheno | awk -v m=${model} -v a=${arch} -v g=${g} -v t=${trait} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,t,p,i,$0}' \

done; done; done; done; done; done > admix_all.pheno
