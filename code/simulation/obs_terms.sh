#!/bin/bash -l
#SBATCH --time=0:02:00
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

plinkdir=/home/aazaidi/klema030/AdjustedHE/output/plink/theta${theta}_gen${gen}/${model} 
outdir=/users/6/klema030/AdjustedHE/output/ganc/obs

for seed in {1..10}; do
  for t in $(seq 0 "$gen"); do 
    filename=admix_${model}_theta${theta}_gen${gen}_P${P}_${cov}_seed${seed}_t${t}
    
    #get bed, bim, fam files to get sscore
    ./plink2 --import-dosage ${plinkdir}/${filename}.dosage format=1 single-chr=1 noheader \
    --fam ${plinkdir}/${filename}.tfam \
    --make-bed --out ${plinkdir}/${filename}
    
    #get sscore files
    if [ "$cov" == "neg" ]; then
      #negative cov
      ./plink2 --bfile ${plinkdir}/${filename} \
            --score /home/aazaidi/aazaidi/projects/admix_heritability/data/jinguo.sims/admix_FreqBeta_3traits_FIXED_02102025.txt 1 3 8 header \
            --out ${plinkdir}/${filename}
    else 
      #postive cov
      ./plink2 --bfile ${plinkdir}/${filename} \
            --score /home/aazaidi/aazaidi/projects/admix_heritability/data/jinguo.sims/admix_FreqBeta_3traits_FIXED_02102025.txt 1 3 7 header \
            --out ${plinkdir}/${filename}
    fi
    
    #compute observed vg using sscore
    Rscript /users/6/klema030/AdjustedHE/obs_terms.R ${plinkdir} ${filename} ${outdir}
  done;
done
  