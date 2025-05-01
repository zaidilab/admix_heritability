#!/bin/bash -l

model=${1}

for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Lambda GC" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.pca.g.GC


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Lambda GC" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.pca.g.GC

for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Mean Chi^2" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.pca.g.chi2


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Mean Chi^2" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.pca.g.chi2


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Lambda GC" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.lanc.g.GC


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Lambda GC" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.lanc.g.GC

for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Intercept:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.pca.g.intercept

for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Intercept:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.pca.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.pca.g.intercept


for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Intercept:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.min.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.min.lanc.g.intercept

for g in {2..20}; do \
    for p in {0.01,0.05,0.1}; do \
        for rep in {1..10}; \
            do grep "Intercept:" ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_g${g}_p${p}_${rep}.max.lanc.g.cov.log | \
            awk -v OFS=" " -v p=$p -v g=$g -v i=$rep '{print p,g,i,$0}' ; \
        done; \
    done; \
done > ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/h2/admix_${model}_all.max.lanc.g.intercept

