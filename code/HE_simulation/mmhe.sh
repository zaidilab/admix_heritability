#!/bin/bash -l     
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall
#SBATCH -o HE/%x.%a.out

module load python2
model=${1}
arch=${2}
t=${3}
P=${4}

mkdir -p ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/standard
mkdir -p ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/Varx
mkdir -p ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/LD

mkdir -p ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/standard
mkdir -p ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/Varx
mkdir -p ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/LD

mkdir -p ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}


for rep in {1..10}; do \

awk 'NR>1' /home/aazaidi/klema030/AdjustedHE/output/plink/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.pheno \
> ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno

# Rscript ~/projects/admix_heritability/code/estimation/GRMvarX.R \
#     ~/lab/huan2788/admix_heritability/data/theta0.5_gen20/plink/${model} \
#     admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
#     ~/projects/admix_heritability/data/jinguo.sims/${model}/grm/Varx 

gcta --HEreg \
    --grm ~/projects/admix_heritability/data/jinguo.sims//grm/${model}/Varx/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 \
    --out ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/Varx/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y

python ~/projects/mmhe/mmhe2.py \
    --grm ~/projects/admix_heritability/data/jinguo.sims//grm/${model}/Varx/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar ~/lab/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 > \
    ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/Varx/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y.hsq; 

gcta --HEreg \
    --grm ~/projects/admix_heritability/data/jinguo.sims//grm/${model}/standard/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 \
    --out ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/standard/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y

python ~/projects/mmhe/mmhe2.py \
    --grm ~/projects/admix_heritability/data/jinguo.sims//grm/${model}/standard/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar ~/lab/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 > \
    ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/standard/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y.hsq; 

gcta --HEreg \
    --grm ~/lab/klema030/AdjustedHE/output/grm/gcta/GRMld/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 \
    --out ~/projects/admix_heritability/data/jinguo.sims/HE/${model}/LD/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y

python ~/projects/mmhe/mmhe2.py \
    --grm ~/lab/klema030/AdjustedHE/output/grm/gcta/GRMld/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t} \
    --covar ~/lab/huan2788/admix_heritability/data/theta0.5_gen20/ganc/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.ganc \
    --pheno ~/projects/admix_heritability/data/jinguo.sims/pheno/${model}/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.noheader.pheno \
    --mpheno 2 > \
    ~/projects/admix_heritability/data/jinguo.sims/MMHE/${model}/LD/admix_${model}_theta0.5_gen20_P${P}_${arch}_seed${rep}_t${t}.y.hsq; 

done


