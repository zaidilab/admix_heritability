# estimate vgamma with gcta with and without ancestry as covariate
#!/bin/bash

# make sure have plink2 and gcta installed and executable
# one run for one replicate for each generation

model=${1} #HI or CGF
theta=${2} #0.1 0.2 0.5
gen=${3} #10, 20, 50, 100
P=${4} #0, 0.3, 0.6, 0.9
cov=${5} #pos or neg
seed=${6}
t=${7}

module load R/4.2.0-rocky8

#source files
plinkdir=/home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/plink_lanc/${model} 
phenodir=/home/aazaidi/klema030/AdjustedHE/output/new_pheno/theta0.5_gen20/${model}
gancdir=/home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}
grm_LD=/home/aazaidi/klema030/AdjustedHE/output/grm/gcta/GRMld_lanc/${model}
grm_standard=/home/aazaidi/klema030/AdjustedHE/output/grm/gcta/${model}
grm_varX=/home/aazaidi/klema030/AdjustedHE/output/grm/gcta/GRMvarX_lanc/${model}
#output files
reml_std=/users/6/klema030/AdjustedHE/output/${model}/gcta/GRMstandard_greml_lanc
reml_varX=/users/6/klema030/AdjustedHE/output/${model}/gcta/GRMvarX_greml_lanc
reml_ld=/users/6/klema030/AdjustedHE/output/${model}/gcta/GRMld_greml_lanc


filename=admix_${model}_theta${theta}_gen${gen}_P${P}_${cov}_seed${seed}_t${t}
filename1=admix_${model}_theta${theta}_gen${gen}_P${P}_${cov}_seed${seed}_t${t}_lanc

./plink2 --import-dosage ${plinkdir}/${filename}.dosage format=1 single-chr=1 noheader \
--fam ${plinkdir}/${filename}.tfam \
--make-bed --out ${plinkdir}/${filename}

### get grms for lanc
# construct grm with gcta for standard grm
./gcta64 --bfile ${plinkdir}/${filename1} \
--make-grm --out ${grm_standard}/${filename1} \
--thread-num 4

# construct grm for LD scaled
Rscript /users/6/klema030/AdjustedHE/GRMld.R \
   /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/plink_lanc/${model} \
   admix_${model}_theta0.5_gen20_P${P}_${cov}_seed${seed}_t${t}_lanc \
   ${grm_LD}

# construct grm for varX scaled
Rscript /users/6/klema030/AdjustedHE/GRMvarX.R \
   /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/plink_lanc/${model} \
   admix_${model}_theta0.5_gen20_P${P}_${cov}_seed${seed}_t${t}_lanc \
   ${grm_varX}

###estimate vgamma without ancestry
#standard
./gcta64 --reml \
--grm ${grm_standard}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--out ${reml_std}/${filename1}.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain

#varX
./gcta64 --reml \
--grm ${grm_varX}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--out ${reml_varX}/${filename1}.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain

#LD
./gcta64 --reml \
--grm ${grm_LD}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--out ${reml_ld}/${filename1}.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain

###estimate Vgamma with ganc as covariate
#standard
./gcta64 --reml \
--grm ${grm_standard}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--qcovar ${gancdir}/${filename}.ganc \
--out ${reml_std}/${filename1}.ganc.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain

#varX
./gcta64 --reml \
--grm ${grm_varX}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--qcovar ${gancdir}/${filename}.ganc \
--out ${reml_varX}/${filename1}.ganc.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain

#LD
./gcta64 --reml \
--grm ${grm_LD}/${filename1} \
--pheno ${phenodir}/${filename}.pheno \
--qcovar ${gancdir}/${filename}.ganc \
--out ${reml_ld}/${filename1}.ganc.reml \
--thread-num 4 \
--mpheno 2 \
--reml-no-constrain
