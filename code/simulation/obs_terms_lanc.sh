#!/bin/bash -l
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=moria,msismall
#SBATCH --output=/users/6/klema030/AdjustedHE/output/slurm/%j.out

module load R/4.2.0-rocky8

model=${1} #HI or CGF
theta=${2} #0.1 0.2 0.5
gen=${3} #10, 20, 50, 100
P=${4} #0, 0.3, 0.6, 0.9
cov=${5} #pos or neg
# seed=${6}
# t=${7}

plinkdir=/home/aazaidi/klema030/AdjustedHE/output/plink_lanc/theta${theta}_gen${gen}/${model}
outdir=/users/6/klema030/AdjustedHE/output/ganc/obs_lanc

for seed in {1..10}; do
  for t in $(seq 0 "$gen"); do 
    filename=admix_${model}_theta${theta}_gen${gen}_P${P}_${cov}_seed${seed}_t${t}_lanc
    
    #get bed, bim, fam files to get sscore
    ./plink2 --import-dosage ${plinkdir}/${filename}.dosage format=1 single-chr=1 noheader \
    --fam ${plinkdir}/${filename}.tfam \
    --make-bed --out ${plinkdir}/${filename}
    
    #get sscore files
    if [ "$cov" == "neg" ]; then
      #negative cov
      ./plink2 --bfile ${plinkdir}/${filename} \
            --score /users/6/klema030/AdjustedHE/admix_FreqBeta_3traits_FIXED_03062025.txt 1 3 10 header \
            --out ${plinkdir}/${filename}
    else 
      #postive cov
      ./plink2 --bfile ${plinkdir}/${filename} \
            --score /users/6/klema030/AdjustedHE/admix_FreqBeta_3traits_FIXED_03062025.txt 1 3 11 header \
            --out ${plinkdir}/${filename}
    fi
    
    #compute observed vg using sscore and new phenotype
    Rscript /users/6/klema030/AdjustedHE/obs_terms_lanc.R ${plinkdir} ${filename} ${outdir} 0.8 
  done;
done
  
