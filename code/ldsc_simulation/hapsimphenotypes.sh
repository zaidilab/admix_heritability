
plink2 --pfile pgen/1kg_hm3_chr2.sim \
    --thin 0.01 \
    --seed 1 \
    --export A --out bed/1kg_hm3_chr2.sim.p0.01.r1

Rscript ~/projects/admix_heritability/code/ldsc_simulation/generate_effects2.r \
  data/ldsc/1kg-ref-hg38/bed/1kg_hm3_chr2.sim.p0.01.r1.raw \
  0.6 \
  data/ldsc/1kg-ref-hg38/phenotypes/1kg_hm3_chr2.sim.p0.01.r1

plink2 --pfile pgen/1kg_hm3_chr2.sim \
    --pca 10 \
    --out pgen/1kg_hm3_chr2.sim

plink2 --pfile pgen/1kg_hm3_chr2.sim \
  --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref \
  --pheno phenotypes/1kg_hm3_chr2.sim.p0.01.r1.pheno \
  --pheno-name y \
  --covar pgen/1kg_hm3_chr2.sim.eigenvec \
  --allow-extra-chr \
  --out gwas/1kg_hm3_chr2.sim.p0.01.r1

python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
  --sumstats gwas/1kg_hm3_chr2.sim.p0.01.r1.y.glm.linear \
  --snp "ID" \
  --a1 REF --a2 A1 \
  --N-col OBS_CT \
  --signed-sumstats T_STAT,0 \
  --frq A1_FREQ \
  --out gwas/1kg_hm3_chr2.sim.p0.01.r1

python ~/lab/aazaidi/bin/ldsc/ldsc.py \
  --h2 gwas/1kg_hm3_chr2.sim.p0.01.r1.sumstats.gz \
  --ref-ld l2/1kg_hm3_chr2.sim.1000k  \
  --w-ld l2/1kg_hm3_chr2.sim.1000k \
  --out h2/1kg_hm3_chr2.sim.p0.01.r1


for i in {1..22}; do \
    awk '$1==2{print $0}' ~/lab/shared/data/1kg-ref-hg38/metadata/genetic_map_hg38_withX.txt \
    > ~/lab/shared/data/1kg-ref-hg38/metadata/gmap/genetic_map_hg38_chr${i}.map; done 

head -n1 ~/lab/shared/data/1kg-ref-hg38/metadata/genetic_map_hg38_withX.txt > ~/lab/shared/data/1kg-ref-hg38/metadata/header.txt

for i in {1..22}; do \
    cat  ~/lab/shared/data/1kg-ref-hg38/metadata/header.txt \
    ~/lab/shared/data/1kg-ref-hg38/metadata/genetic_map_hg38_ch${i}.map > tmp && mv tmp \
    ~/lab/shared/data/1kg-ref-hg38/metadata/genetic_map_hg38_ch${i}.map; done



plink2 --pfile pgen/admix \
    --thin 0.01 \
    --seed 1 \
    --export A --out bed/admix


Rscript ~/projects/admix_heritability/code/ldsc_simulation/generate_effects2.r \
  data/ldsc/1kg-ref-hg38/bed/admix.raw \
  0.6 \
  data/ldsc/1kg-ref-hg38/phenotypes/admix

plink2 --bfile bed/admix \
    --pca 10 \
    --out pgen/admix

plink2 --pfile pgen/admix \
  --glm hide-covar cols=chrom,pos,ref,a1freq,beta,se,tz,p,nobs omit-ref \
  --pheno phenotypes/admix.pheno \
  --pheno-name y \
  --covar pgen/admix.eigenvec \
  --allow-extra-chr \
  --out gwas/admix

python ~/lab/aazaidi/bin/ldsc/munge_sumstats.py \
  --sumstats gwas/admix.y.glm.linear \
  --snp "ID" \
  --a1 REF --a2 A1 \
  --N-col OBS_CT \
  --signed-sumstats T_STAT,0 \
  --frq A1_FREQ \
  --out gwas/admix


plink2 --pfile pgen/admix \
    --make-bed --out bed/admix



for i in {1000,2000,5000,10000,20000}; do \
    python ~/lab/aazaidi/bin/ldsc/ldsc.py \
        --h2 gwas/admix.sumstats.gz \
        --ref-ld l2/admix.${i}k \
        --w-ld l2/admix.${i}k \
        --out h2/admix.${i}k; \
done
