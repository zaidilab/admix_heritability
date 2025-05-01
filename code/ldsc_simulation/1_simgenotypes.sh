#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=20g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall


module load conda
source activate admix-kit

g=${1}
rep=${2}

# mkdir -p ~/lab/shared/1kg-ref-hg38/pgen
# mkdir -p ~/lab/shared/1kg-ref-hg38/bed


# admix get-1kg-ref --dir ~/lab/shared/data/1kg-ref-hg38 --build hg38

cd ~/lab/shared/1kg-ref-hg38


# wget https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1 \
# -O pgen/raw.pgen.zst && wget https://www.dropbox.com/s/ngbo2xm5ojw9koy/all_hg38_noannot.pvar.zst?dl=1 \
# -O pgen/raw.pvar.zst && wget https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1 \
# -O pgen/raw.psam && wget https://www.dropbox.com/s/4zhmxpk5oclfplp/deg2_hg38.king.cutoff.out.id?dl=1 \
# -O pgen/king.cutoff.out.id


# admix subset-hapmap3 \
#     --pfile pgen/raw \
#     --build hg38 \
#     --out pgen/hm3.snp

# grep -E  '(CEU|YRI)' pgen/raw.psam > pgen/1kg_ceu_yri.psam



# plink2 \
#     --pfile pgen/raw \
#     --extract pgen/hm3.snp \
#     --keep pgen/1kg_ceu_yri.psam \
#     --keep-founders \
#     --chr 2 \
#     --allow-extra-chr \
#     --make-pgen \
#     --out ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/

# cut -f1,4 ceu.yri/1kg_hm3_chr2.psam > ceu.yri/1kg_hm3_chr2.sample_info


# Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/generate_HI_model.R \
#     20 0.5 5000 \
#     ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/models/admix_HI_g20

# nlines=$(($g+1))

# head -n ${nlines} admix/models/admix_HI_g20.dat > admix/models/admix_HI_g${g}.dat2

# haptools simgenotype \
#     --ref_vcf ceu.yri/1kg_hm3_chr2.pgen \
#     --chroms 2 \
#     --mapdir ~/lab/shared/recomb_maps/beagle_GRCH38/ \
#     --model admix/models/admix_HI_g${g}.dat2 \
#     --sample_info ceu.yri/1kg_hm3_chr2.sample_info \
#     --out admix/pgen/admix_HI_g${g}_${rep}.pgen


# Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/generate_admix_model.r \
#     20 0.5 5000 \
#     ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/models/admix_CGF_g20

# nlines=$(($g+1))

# head -n ${nlines} admix/models/admix_CGF_g20.dat > admix/models/admix_CGF_g${g}.dat2


# haptools simgenotype \
#     --ref_vcf ceu.yri/1kg_hm3_chr2.pgen \
#     --chroms 2 \
#     --mapdir ~/lab/shared/recomb_maps/beagle_GRCH38/ \
#     --model admix/models/admix_CGF_g${g}.dat2 \
#     --sample_info ceu.yri/1kg_hm3_chr2.sample_info \
#     --out admix/pgen/admix_CGF_g${g}_${rep}.pgen

# conda deactivate
# source activate ldsc

# #convert to bed for loading with ldsc

# plink2 \
#     --pfile admix/pgen/admix_HI_g${g}_${rep} \
#     --threads 2 \
#     --memory 15000 \
#     --make-bed --out admix/bed/admix_HI_g${g}_${rep}

# plink2 \
#     --pfile admix/pgen/admix_CGF_g${g}_${rep} \
#     --threads 2 \
#     --memory 15000 \
#     --make-bed --out admix/bed/admix_CGF_g${g}_${rep}


# ld prune
plink2 --pfile admix/pgen/admix_HI_g${g}_${rep} \
    --indep-pairwise 50 5 0.1 \
    --out admix/pruned/admix_HI_g${g}_${rep}.pruned

plink2 --pfile admix/pgen/admix_HI_g${g}_${rep} \
    --indep-pairwise 50 5 0.1 \
    --out admix/pruned/admix_CGF_g${g}_${rep}.pruned


plink2 --bfile admix/bed/admix_HI_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --extract admix/pruned/admix_HI_g${g}_${rep}.pruned.prune.in \
    --pca 20 --out admix/pca/admix_HI_g${g}_${rep}.pruned

plink2 --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --extract admix/pruned/admix_CGF_g${g}_${rep}.pruned.prune.in \
    --pca 20 --out admix/pca/admix_CGF_g${g}_${rep}.pruned


# # # #carry out PCA
# plink2 --bfile admix/bed/admix_HI_g${g}_${rep} \
#     --threads 2 \
#     --memory 15000 \
#     --pca 20 --out admix/pca/admix_HI_g${g}_${rep}

# plink2 --bfile admix/bed/admix_CGF_g${g}_${rep} \
#     --threads 2 \
#     --memory 15000 \
#     --pca 20 --out admix/pca/admix_CGF_g${g}_${rep}


