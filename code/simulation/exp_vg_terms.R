#get expected vg for each theta gen combination
library(data.table)
library(tidyverse)

#get args
args <- commandArgs(trailingOnly = TRUE)
theta <- args[1]
gen <- args[2]

#load ancestry data
ganc <- fread(paste0("/users/6/klema030/AdjustedHE/output/ganc/","theta",theta,"_gen",gen,"_ganc_all.txt"), header = F)
colnames(ganc) <- c("model","cov","t","seed", "P", "FID", "IID","ganc")

#get mean and var of theta for each combination
ganc_sum <- ganc %>%
  group_by(model, cov, t, P) %>%
  summarise(manc = mean(ganc),
            vanc = var(ganc), .groups = "drop")

#load freq_beta
fq_beta <- fread("admix_FreqBeta_3traits_FIXED_02102025.txt", header = T)
nloci <- nrow(fq_beta)

# Calculate 4 terms of genetic variance Vg
# term 1 of Vg
vg_term1 <- function(exp.ganc, f1, f2, beta) return (sum(beta^2*(2*exp.ganc*f1*(1-f1)+2*(1-exp.ganc)*f2*(1-f2))))

# term 2 of Vg
vg_term2 <- function(exp.ganc, f1, f2, beta) return (sum(beta^2*(2*exp.ganc*(1-exp.ganc)*((f1-f2)^2))))

# term 3 of Vg
vg_term3 <- function(var.ganc, f1, f2, beta) return (sum(beta^2*(2*var.ganc*((f1-f2)^2))))

# term 4 of Vg
vg_term4 <- function(var.ganc, f1, f2, beta){
  term4=matrix(, nrow = nloci, ncol = nloci)
  for (i in 1:nloci){
    for (j in 1:nloci){
      term4[i,j]=beta[i]*beta[j]*(f1[i]-f2[i])*(f1[j]-f2[j])
    }
  }
  # make diagnal 0
  diag(term4)=0
  # sum it up
  sum.term4 = sum(term4)*4*var.ganc
  return (sum.term4)} 

#to store final output
vg_list <- list()

#get terms for each combination
for (i in 1:nrow(ganc_sum)){
  manc = ganc_sum$manc[i] #mean in ancestry
  vanc = ganc_sum$vanc[i] #variance in ancestry
  
  if (ganc_sum$cov[i] == "pos"){ #if cov is pos
    exp1 = vg_term1(exp.ganc = manc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_pos)
    
    exp2 = vg_term2(exp.ganc = manc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_pos)
    
    exp3 = vg_term3(var.ganc = vanc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_pos)
    
    exp4 = vg_term4(var.ganc = vanc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_pos)
    exp.vg = exp1 + exp2 + exp3 + exp4
  } 
  else{ #if cov is neg
    exp1 = vg_term1(exp.ganc = manc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_neg)
    
    exp2 = vg_term2(exp.ganc = manc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_neg)
    
    exp3 = vg_term3(var.ganc = vanc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_neg)
    
    exp4 = vg_term4(var.ganc = vanc, 
                    f1 = fq_beta$f1, 
                    f2 = fq_beta$f2, 
                    beta = fq_beta$esize_neg)
    exp.vg = exp1 + exp2 + exp3 + exp4
  }
  
  #save output
  vg_df=data.table(model = ganc_sum$model[i],
                   cov = ganc_sum$cov[i],
                   P = ganc_sum$P[i],
                   t = ganc_sum$t[i],
                   exp1=exp1,
                   exp2=exp2,
                   exp3=exp3,
                   exp4=exp4, 
                   exp.vg=exp.vg,
                   exp.theta=manc,
                   var.theta=vanc)
  
  #to list
  vg_list[[i]] <- vg_df
  
}

#get final df
vg_terms = do.call(rbind, vg_list)
rownames(vg_terms) <- NULL

#save output
write.table(vg_terms, 
            paste0("/users/6/klema030/AdjustedHE/output/ganc/","theta",theta,"_gen",gen,"_exp.vg.txt"), 
            quote = F, sep = '\t',
            row.names = F, col.names = T)
