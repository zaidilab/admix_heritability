#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=moria,msismall
#SBATCH --output=hapgen_mmhe-%x.%j.out

module load python2

model=${1}
g=${2}

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix
mkdir -p mmhe/standard/

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do for arch in {min,max}; do \
    echo $rep

    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --HEreg --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.pheno --out he/admix_${model}_g${g}_p${p}_${rep}.${arch}.y --mpheno 2; \

    # gcta --threads 10 --grm grm/admix_${model}_g${g}_${rep} --HEreg --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.pheno --out he/admix_${model}_g${g}_p${p}_${rep}.${arch}.g --mpheno 1; \

    python ~/projects/mmhe/mmhe2.py \
    --pheno phenotypes/admix_${model}_g${g}_p${p}_${rep}.${arch}.fid.noheader.pheno \
    --grm grm/standard/admix_${model}_g${g}_${rep} \
    --covar pca/admix_${model}_g${g}_${rep}.noheader.eigenvec \
    --mpheno 2 > mmhe/standard/admix_${model}_g${g}_p${p}_${rep}.${arch}.h2q


done; done; done


# for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for trait in {g,y}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \

#     grep "V(G)/Vp" he/admix_${model}_g${g}_p${p}_${rep}.${arch}.${trait}.HEreg | awk -v m=${model} -v a=${arch} -v g=${g} -v t=${trait} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,t,p,i,NR,$0}' \

# done; done; done; done; done; done > he/admix_all.HEreg


# for model in {HI,CGF}; do for arch in {min,max}; do for g in {2..20}; do for p in {0.01,0.05,0.1}; do for rep in {1..10}; do \
    
#     awk -v m=${model} -v a=${arch} -v g=${g} -v p=$p -v i=${rep} -v OFS="\t" '{print m,a,g,p,i,$0}' he/admix_${model}_g${g}_p${p}_${rep}.${arch}.cov.h2q \

# done; done; done; done; done > he/admix_all.cov.h2q
