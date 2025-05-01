#!/bin/bash


model=${1}


#concatenate h2 results

###y 
for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Total Observed scale h2:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.lanc.g.cov.log


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Total Observed scale h2:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.lanc.g.cov.log

## g
for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Total Observed scale h2:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.pca.g.cov.log


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Total Observed scale h2:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.pca.g.cov.log


 