#!/bin/bash -l     
#SBATCH --time=03:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=klema030@umn.edu
#SBATCH --output=/users/6/klema030/AdjustedHE/output/slurm/%j.out

module load R/4.2.0-rocky8
module load python2

model=${1}
arch=${2}
t=${3}
P=${4}

for rep in {1..10}; do \

# Rscript /users/6/klema030/AdjustedHE/GRMld.R \
#    /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/plink/${model} \
#    admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
#   /home/aazaidi/klema030/AdjustedHE/output/grm/gcta/GRMld/${model}
# 
# # HE regression without correction GCTA with GRMld
# ./gcta --HEreg \
#      --grm /home/aazaidi/klema030/AdjustedHE/output/grm/gcta/GRMld/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
#      --pheno /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno \
#      --out /home/aazaidi/klema030/AdjustedHE/output/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}
# 
# # HE regression without correction manual with GRMld
# python /home/aazaidi/aazaidi/projects/mmhe/mmhe.py \
#     --grm /home/aazaidi/klema030/AdjustedHE/grm/gcta/GRMld/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
#     --pheno /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno > \
#     /home/aazaidi/klema030/AdjustedHE/output/${model}/mmhe/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.vg;

######## with ancestry correction############
# HE regression with correction manual with GRMld
python /home/aazaidi/aazaidi/projects/mmhe/mmhe.py \
    --grm /home/aazaidi/klema030/AdjustedHE/output/grm/gcta/GRMld/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno > \
    /users/6/klema030/AdjustedHE/output/${model}/mmhe/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.cov.ld.vg;

# HE regression with correction manual with GRMvarX
python /home/aazaidi/aazaidi/projects/mmhe/mmhe.py \
    --grm /home/aazaidi/aazaidi/projects/admix_heritability/data/jinguo.sims/${model}/grm/Varx/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno > \
    /users/6/klema030/AdjustedHE/output/${model}/mmhe/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.cov.varX.vg;

# HE regression with correction manual with standard GRM
python /home/aazaidi/aazaidi/projects/mmhe/mmhe.py \
    --grm /home/aazaidi/klema030/AdjustedHE/output/grm/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno /home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno > \
    /users/6/klema030/AdjustedHE/output/${model}/mmhe/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.cov.std.vg; 

done


