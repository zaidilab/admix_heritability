#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem=15g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=moria,msismall


module load conda
source activate ldsc

g=${1}
rep=${2}
kb=2000


cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/

mkdir -p admix/pca
mkdir -p admix/l2


python ~/bin/ldsc/ldsc.py \
    --bfile admix/bed/admix_HI_g${g}_${rep} \
    --l2 --ld-wind-kb ${kb} \
    --out admix/l2/admix_HI_g${g}_${rep}.${kb}k

python ~/bin/ldsc/ldsc.py \
    --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --l2 --ld-wind-kb ${kb} \
    --out admix/l2/admix_CGF_g${g}_${rep}.${kb}k

#strip header from eigenevec file otherwise cov-ldsc will error out
tail -n+2 -q admix/pca/admix_HI_g${g}_${rep}.eigenvec > admix/pca/admix_HI_g${g}_${rep}.noheader.eigenvec

tail -n+2 -q admix/pca/admix_CGF_g${g}_${rep}.eigenvec > admix/pca/admix_CGF_g${g}_${rep}.noheader.eigenvec


python ~/bin/cov-ldsc/ldsc.py \
    --bfile admix/bed/admix_HI_g${g}_${rep} \
    --l2 --ld-wind-kb ${kb} \
    --cov admix/pca/admix_HI_g${g}_${rep}.noheader.eigenvec \
    --out admix/l2/admix_HI_g${g}_${rep}.cov.${kb}k

python ~/bin/cov-ldsc/ldsc.py \
    --bfile admix/bed/admix_CGF_g${g}_${rep} \
    --l2 --ld-wind-kb ${kb} \
    --cov admix/pca/admix_CGF_g${g}_${rep}.noheader.eigenvec \
    --out admix/l2/admix_CGF_g${g}_${rep}.cov.${kb}k