#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=20g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=moria


# module load conda
module load R
# source activate admix-kit

p=${1}

# mkdir -p ~/lab/shared/1kg-ref-hg38/pgen
# mkdir -p ~/lab/shared/1kg-ref-hg38/bed


# admix get-1kg-ref --dir ~/lab/shared/data/1kg-ref-hg38 --build hg38

# cd ~/lab/shared/1kg-ref-hg38


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
#    --keep-founders \
#     --chr 2 \
#     --allow-extra-chr \
#     --make-pgen \
#     --out ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/

plink2 \
    --pfile ceu.yri/1kg_hm3_chr2 \
    --thin ${p} \
    --export A --out ceu.yri/1kg_hm3_chr2_p${p}

Rscript ~/projects/admix_heritability/code/ldsc_simulation/hapgen/generate_effects2.r \
  data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p${p}.raw \
  data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p${p}

