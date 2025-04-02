#!/bin/bash


#HE regression concat from GCTA output
for model in {HI,CGF}; do for arch in {pos,neg}; do for t in {0..20}; do for rep in {1..10}; do for P in {0,0.9}; do for grm in {standard,Varx,LD}; do \
    grep "V(G)/Vp" ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/${grm}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y.HEreg | \
    awk -v OFS=" " -v m=$model -v a=$arch -v t=$t -v r=$rep -v P=$P -v grm=$grm 'NR==1{print m,a,t,r,P,grm,$0}'; \
done; done; done; done; done; done > ~/projects/admix_heritability/data/jinguo.sims/HE/admix_all.y.HEreg

for model in {HI,CGF}; do for arch in {pos,neg}; do for t in {0..20}; do for rep in {1..10}; do for P in {0,0.9}; do for grm in {standard,Varx,LD}; do \
    awk -v OFS=" " -v m=$model -v a=$arch -v t=$t -v r=$rep -v P=$P -v grm=$grm '{print m,a,t,r,P,grm,$0}' ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/${grm}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y.hsq; \
done; done; done; done; done; done > ~/projects/admix_heritability/data/jinguo.sims/MMHE/admix_all.y.MMHE


for model in {HI,CGF}; do for arch in {pos,neg}; do for t in {0..20}; do for rep in {1..10}; do for P in {0,0.9}; do \
    awk -v OFS="\t" -v m=$model -v a=$arch -v t=$t -v r=$rep -v P=$P  'NR>1{print m,a,t,r,P,grm,$0}' ~/lab/klema030/AdjustedHE/output/plink/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno; \
done; done; done; done; done > ~/projects/admix_heritability/data/jinguo.sims/admix_all.pheno

