#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=moria,msismall

module load python2

model=${1}
g=${2}

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix

mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/mmhe

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do for arch in {min,max}; do \

    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --HEreg --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.pheno --out he/admix_${model}_g${g}_p${p}_${rep}.${arch}.y --mpheno 2; \

    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --HEreg --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.pheno --out he/admix_${model}_g${g}_p${p}_${rep}.${arch}.g --mpheno 1; \
    tail -n+2 phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.pheno > phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.noheader.pheno \
    
    python ~/projects/mmhe/mmhe.py \
        --grm grm/admix_${model}_g${g}_${rep} --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.noheader.pheno \
        --mpheno 2 \
        --covar pca/admix_${model}_g${g}_${rep}.noheader.eigenvec > mmhe/admix_${model}_g${g}_p${p}_${rep}.${arch}.y.cov.h2q; \

done; done; done


# for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for trait in {g,y}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \

#     grep "V(G)/Vp" he/admix_${model}_g${g}_p${p}_${rep}.${arch}.${trait}.HEreg | awk -v m=${model} -v a=${arch} -v g=${g} -v t=${trait} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,t,p,i,NR,$0}' \

# done; done; done; done; done; done > he/admix_all.HEreg


# for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \
    
#     awk -v m=${model} -v a=${arch} -v g=${g} -v p=$p -v i=${rep} -v OFS="\t" 'NR==1{print m,a,g,p,i,$0}' mmhe/admix_${model}_g${g}_p${p}_${rep}.${arch}.cov.h2q \

# done; done; done; done; done > mmhe/admix_all.cov.h2q
