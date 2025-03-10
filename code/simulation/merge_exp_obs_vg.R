library(data.table)
library(tidyverse)

##avg obs files over seeds and merge with expected values to plot for Fig3

#load data and combine into one df
theta_gen_list <- list() #empty list to store outputs
count <- 1 #list id

#loop to load all and rowbind
theta <- c(0.1,0.2,0.5)
gen <- c(10,20,50,100)
for (i in theta){
  for (j in gen){
    #load obs data
    obs <- fread(paste0("theta",i,"_gen",j,"_obs_all.txt"), header = F)
    colnames(obs) <- c("model","cov","t","seed", "P", "var.prs.geno")
    
    #sum over seeds
    obs_avg <- obs %>%
      group_by(model, cov, t, P) %>%
      summarise(var.prs.geno = mean(var.prs.geno), .groups = "drop")
    
    #load obs_lanc data
    obs_lanc <- fread(paste0("theta",i,"_gen",j,"_obs_all_lanc.txt"), header = F)
    colnames(obs_lanc) <- c("model","cov","t","seed", "P", "var.prs.lanc")
    
    #sum over seeds
    obs_lanc_avg <- obs_lanc %>%
      group_by(model, cov, t, P) %>%
      summarise(var.prs.lanc = mean(var.prs.lanc), .groups = "drop")
    
    #load exp data
    exp_vg <- fread(paste0("theta",i,"_gen",j,"_exp.vg.txt"), header = T)
    colnames(exp_vg) <- c("model","cov","P","t", "vg.term1","vg.term2","vg.term3","vg.term4","vg.sum")
    exp_vg$theta <- i
    exp_vg$gen <- j
    
    #merge datasets
    exp_obs_vg <- merge(exp_vg, obs_avg, by = c("model", "cov", "P", "t"))
    exp_obs_vg <- merge(exp_obs_vg, obs_lanc_avg, by = c("model", "cov", "P", "t"))
    
    #store in list
    theta_gen_list[[count]] <- exp_obs_vg
    count <- count + 1
  }
}

#bind list
theta_gen_all <- rbindlist(theta_gen_list, fill = TRUE)

#separate by model
tg_CGF <- theta_gen_all %>% filter(model == "CGF")
tg_HI <- theta_gen_all %>% filter (model == "HI")

#### get analytical terms 
# expected variance of ancestry in HI
var_theta_HI=function(m, t, P) return(
  m*(1-m)*((1+P)/2)^t
)

# expected ancestry in CGF
exp_theta_CGF=function(m, t, gen){
  alpha=1-(1-m)^(1/gen)
  theta=1-(1-alpha)^(t+1)
  return(theta)
}

# expected variance of ancestry in CGF
var_theta_CGF=function(m, t, gen, P){
  alpha=1-(1-m)^(1/gen)
  X=(1+P)*(1-alpha)/2
  var.t = alpha * ((1-alpha)^(2*t+3) - (1-alpha)*X^(t+1)) / ((1-alpha)^2 -X)
  return(var.t)
}

# update function to calculate vg terms cuz the matrix 
vg_term1 <- function(exp.ganc, f1, f2, beta) return (
  rowSums((2*exp.ganc%*%t((f1)*(1-f1))+2*(1-exp.ganc)%*%t((f2)*(1-f2))) %*% (beta^2)))

vg_term2 <- function(exp.ganc, f1, f2, beta) return (
  rowSums((2*exp.ganc *(1-exp.ganc) %*% t((f1-f2)^2) ) %*% (beta^2))
)

vg_term3 <- function(var.ganc, f1, f2, beta) return (
  rowSums( (2*var.ganc %*% t((f1-f2)^2) ) %*% (beta^2))
)

# adjust for beta according to cov
vg_term4 <- function(var.ganc, f1, f2, beta){
  nloci=1e3
  term4=matrix(, nrow = nloci, ncol = nloci)
  for (i in 1:nloci){
    for (j in 1:nloci){
      term4[i,j]=beta[i]*beta[j]*(f1[i]-f2[i])*(f1[j]-f2[j])
    }
  }
  # make diagnal 0
  diag(term4)=0
  # sum it up
  sum.term4 = sum(term4)
  term4 =  4 * var.ganc %*% t(sum.term4)
  return (term4) } 

#get terms
addvgterms=function(data){
  nloci=1e3
  a=vg_term1(exp.ganc=data$exp.theta, 
             f1=fq_beta$f1, 
             f2=fq_beta$f2, 
             beta=fq_beta$esize_pos)
  
  b=vg_term2(exp.ganc=data$exp.theta, 
             f1=fq_beta$f1, 
             f2=fq_beta$f2, 
             beta=fq_beta$esize_pos)
  
  c=vg_term3(var.ganc=data$exp.var.theta, 
             f1=fq_beta$f1, 
             f2=fq_beta$f2, 
             beta=fq_beta$esize_pos)
  
  d1=vg_term4(var.ganc=data$exp.var.theta, 
              f1=fq_beta$f1, 
              f2=fq_beta$f2, 
              beta=fq_beta$esize_pos)
  
  d2=vg_term4(var.ganc=data$exp.var.theta, 
              f1=fq_beta$f1, 
              f2=fq_beta$f2, 
              beta=fq_beta$esize_neg)
  
  data$va.term4 = d1
  data[which(data$cov=="neg"),]$va.term4 = d2[which(data$cov=="neg")]
  data$va.term1 = a
  data$va.term2 = b
  data$va.term3 = c 
  data$exp.vg = data$va.term1 + data$va.term2 + data$va.term3 + data$va.term4
  data$exp.vgamma = data$va.term2 + data$va.term3 + data$va.term4
  return(data)
}


# load the freq and beta to calculate coefficient for cov and pos respectively
fq_beta <- fread("admix_FreqBeta_3traits_FIXED_02102025.txt", header = T)

#prepare the data, calculate expected value for E(anc), var(anc), and vg terms
# HI and CGF are different in expected E(anc) and Var(anc)

#HI
tg_HI$exp.theta=tg_HI$theta
tg_HI$exp.var.theta=var_theta_HI(m=tg_HI$theta, t=tg_HI$t, P=tg_HI$P)
#CGF
tg_CGF$exp.theta=exp_theta_CGF(m=tg_CGF$theta, t=tg_CGF$t, gen=tg_CGF$gen)
tg_CGF$exp.var.theta=var_theta_CGF(m=tg_CGF$theta, t=tg_CGF$t, P=tg_CGF$P, tg_CGF$gen)

# update datasets
vg_HI=addvgterms(data=tg_HI)
vg_CGF=addvgterms(data=tg_CGF)

#write output
write.table(vg_CGF, "admix_CGF_vg_vgamma.txt", quote = F, col.names = T, row.names = F, sep = '\t')
write.table(vg_HI, "admix_HI_vg_vgamma.txt", quote = F, col.names = T, row.names = F, sep = '\t')

