#!/bin/bash

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do for g in {2..20}; do for model in {HI,CGF}; do \
    plink2 --pfile pgen/admix_${model}_g${g}_${rep} --extract ../ceu.yri/1kg_hm3_chr2_p${p}.max.effects --freq --out freq/admix_${model}_g${g}_${rep}_p${p}; 
done; done; done; done

for rep in {1..10}; do for p in {0.01,0.05,0.1}; do for g in {2..20}; do for model in {HI,CGF}; do  \
    awk -v OFS="\t" -v m=$model -v p=$p -v g=$g -v r=$rep 'NR>1{print m,p,g,r,$2,$5}' freq/admix_${model}_g${g}_${rep}_p${p}.afreq; 
done; done; done; done > admix_all.afreq

