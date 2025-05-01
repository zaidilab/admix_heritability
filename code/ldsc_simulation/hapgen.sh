#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=15g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --partition=moria,msismall,


module load conda
# module load R
source activate admix-kit

g=${1}
rep=${2}

# mkdir -p ~/lab/shared/data/1kg-ref-hg38/admix/pgen
# mkdir -p ~/lab/shared/data/1kg-ref-hg38/admix/bed
# mkdir -p ~/lab/shared/data/1kg-ref-hg38/admix/phenotypes
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/phenotypes
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/pgen
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/bed
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/models
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/pca
mkdir -p ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/l2


# admix get-1kg-ref --dir ~/lab/shared/data/1kg-ref-hg38 --build hg38

# cd ~/lab/shared/data/1kg-ref-hg38


# wget https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1 \
# -O pgen/raw.pgen.zst && wget https://www.dropbox.com/s/ngbo2xm5ojw9koy/all_hg38_noannot.pvar.zst?dl=1 \
# -O pgen/raw.pvar.zst && wget https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1 \
# -O pgen/raw.psam && wget https://www.dropbox.com/s/4zhmxpk5oclfplp/deg2_hg38.king.cutoff.out.id?dl=1 \
# -O pgen/king.cutoff.out.id


# admix subset-hapmap3 \
#     --pfile pgen/raw \
#     --chrom 2 \
#     --build hg38 \
#     --out ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/hm3_chr2.snp

# grep CEU pgen/raw.psam > pgen/1kg_ceu.psam


# plink2 \
#     --pfile pgen/raw \
#     --extract ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/hm3_chr2.snp \
#     --allow-extra-chr \
#     --make-pgen \
#     --out ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/1kg_hm3_chr2

# plink2 \
#     --pfile ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/1kg_hm3_chr2 \
#     --keep pgen/1kg_ceu.psam \
#     --allow-extra-chr \
#     --make-pgen \
#     --out ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/pgen/1kg_hm3_chr2.ceu

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/

# admix hapgen2 \
#     --pfile pgen/1kg_hm3_chr2.ceu \
#     --build hg38 \
#     --n-indiv 5000 \
#     --out pgen/1kg_hm3_chr2.sim

# simulate admixture under HI model 



# admix haptools-simu-admix \
#     --pfile ceu.yri/1kg_hm3_chr2 \
#     --mapdir ~/lab/shared/recomb_maps/beagle_GRCH38/ \
#     --admix-prop '{"CEU": 0.5, "YRI": 0.5}' \
#     --pop-col Population \
#     --n-gen ${g} \
#     --n-indiv 5000 \
#     --out admix/pgen/admix_HI_g${g}_${rep}

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

# mkdir -p models

# #simulate admixture under CGF model

# Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/generate_admix_model.r \
#     20 0.5 5000 \
#     ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/models/admix_CGF_g20

nlines=$(($g+1))

head -n ${nlines} admix/models/admix_CGF_g20.dat > admix/models/admix_CGF_g${g}.dat2

# cut -f1,6 pgen/1kg_hm3_chr2.psam > pgen/1kg_hm3_chr2.sample_info

haptools simgenotype \
    --ref_vcf ceu.yri/1kg_hm3_chr2.pgen \
    --chroms 2 \
    --mapdir ~/lab/shared/recomb_maps/beagle_GRCH38/ \
    --model admix/models/admix_CGF_g${g}.dat2 \
    --sample_info ceu.yri/1kg_hm3_chr2.sample_info \
    --out admix/pgen/admix_CGF_g${g}_${rep}.pgen

# mkdir -p pca



# #compute LD scores

conda deactivate
source activate ldsc

# #convert to bed for loading with ldsc

plink2 \
    --pfile admix/pgen/admix_HI_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --make-bed --out admix/bed/admix_HI_g${g}_${rep}

plink2 \
    --pfile admix/pgen/admix_CGF_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --make-bed --out admix/bed/admix_CGF_g${g}_${rep}


# # # #carry out PCA
plink2 --bfile admix/bed/admix_HI_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --pca 20 --out admix/pca/admix_HI_g${g}_${rep}

plink2 --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --threads 2 \
    --memory 15000 \
    --pca 20 --out admix/pca/admix_CGF_g${g}_${rep}


# # for i in {1000,2000,5000,10000}; do \
# #     python ~/bin/ldsc/ldsc.py \
# #         --bfile bed/1kg_hm3_chr2.sim \
# #         --l2 --ld-wind-kb ${i} \
# #         --out l2/1kg_hm3_chr2.sim.${i}k; \
# # done

# #compute ldscores

python ~/bin/ldsc/ldsc.py \
    --bfile admix/bed/admix_HI_g${g}_${rep} \
    --l2 --ld-wind-kb 2000 \
    --out admix/l2/admix_HI_g${g}_${rep}.2000k

python ~/bin/ldsc/ldsc.py \
    --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --l2 --ld-wind-kb 2000 \
    --out admix/l2/admix_CGF_g${g}_${rep}.2000k

#strip header from eigenevec file otherwise cov-ldsc will error out
tail -n+2 -q admix/pca/admix_HI_g${g}_${rep}.eigenvec > admix/pca/admix_HI_g${g}_${rep}.noheader.eigenvec

tail -n+2 -q admix/pca/admix_CGF_g${g}_${rep}.eigenvec > admix/pca/admix_CGF_g${g}_${rep}.noheader.eigenvec


python ~/bin/cov-ldsc/ldsc.py \
    --bfile admix/bed/admix_HI_g${g}_${rep} \
    --l2 --ld-wind-kb 2000 \
    --cov admix/pca/admix_HI_g${g}_${rep}.noheader.eigenvec \
    --out admix/l2/admix_HI_g${g}_${rep}.cov.2000k

python ~/bin/cov-ldsc/ldsc.py \
    --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --l2 --ld-wind-kb 2000 \
    --cov admix/pca/admix_CGF_g${g}_${rep}.noheader.eigenvec \
    --out admix/l2/admix_CGF_g${g}_${rep}.cov.2000k

