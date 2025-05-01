#!/bin/bash

model=${1}
g=${2}
p=${3}
rep=${4}
pheno=${5}

bolt --bfile=bed/admix_HI_g2_1 --phenoFile=phenotypes/admix_HI_g2_p0.01_1.max.fid.pheno \
--phenoCol=y \
--reml \
--modelSnps=pruned/admix_HI_g2_1.pruned.prune.in