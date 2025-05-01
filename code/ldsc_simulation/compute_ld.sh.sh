#!/bin/bash

cd ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38

plink2.1 --pfile admix/pgen/admix_CGF_g2_1 \
--r-unphased ref-based --ld-window-kb 9999999 \
--ld-window-r2 0 --ld-snp-list ceu.yri/1kg_hm3_chr2_p0.01.min.effects \
--out admix/vcor/admix_CGF_g2_1
