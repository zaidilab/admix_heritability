library(data.table)

########### CI bands for vg greml estimates #########################
varx_vg <- fread("admix_GRMvarX.vg", header = F)
varx_vg_ganc <- fread("admix_GRMvarX.vg_ganc", header = F)

ld_vg <- fread("admix_GRMld.vg", header = F)
ld_vg_ganc <- fread("admix_GRMld.vg_ganc", header = F)

standard_vg <- fread("admix_GRMstandard.vg", header = F)
standard_vg_ganc <- fread("admix_GRMstandard.vg_ganc", header = F)

#add colnames
colnames(varx_vg) <- c("model", "cov", "t", "seed", "P", "vg_varX", "se_varX")
colnames(varx_vg_ganc) <- c("model", "cov", "t", "seed", "P", "vg_varX_ganc", "se_varX_ganc")
varx <- merge(varx_vg, varx_vg_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

colnames(ld_vg) <- c("model", "cov", "t", "seed", "P", "vg_ld", "se_ld")
colnames(ld_vg_ganc) <- c("model", "cov", "t", "seed", "P", "vg_ld_ganc", "se_ld_ganc")
ld <- merge(ld_vg, ld_vg_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

colnames(standard_vg) <- c("model", "cov", "t", "seed", "P", "vg_standard", "se_standard")
colnames(standard_vg_ganc) <- c("model", "cov", "t", "seed", "P", "vg_standard_ganc", "se_standard_ganc")
standard <- merge(standard_vg, standard_vg_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

#combine grm files
df <- merge(standard, varx, by = c('model', 'cov', 't', 'seed', 'P'))
df <- merge(df, ld, by = c('model', 'cov', 't', 'seed', 'P'))

#output
fwrite(df, "admix_grm_all.txt", sep = '\t',
       col.names=TRUE, row.names=FALSE, quote = FALSE)

# function to bootstrap: return to mean, CI95l, CI95r
meanCI <- function(data){
  library(dplyr)
  # Resample 100 times, and find the mean of each
  boot=tibble(num = 1:100) %>% 
    group_by(num) %>% 
    mutate(mean = mean(sample(data, 
                              replace = TRUE))) 
  boot_mean=mean(boot$mean)
  # Bootstrap 95% percentile confidence interval
  boot_CI=quantile(boot$mean, c(0.025,0.975))
  # report the mean and CI95%
  mean_CIs=tibble(
    mean=boot_mean,
    CI95l=boot_CI[1],
    CI95r=boot_CI[2])  
  return(mean_CIs)  
}


# function to get mean and CIs for each rep
getmeanCI <- function(mydata){
  library(dplyr)
  mydata %>% 
    group_by(t, P, cov, model) %>% 
    summarise_at(vars("vg_standard","vg_standard_ganc","vg_varX","vg_varX_ganc",
                      "vg_ld","vg_ld_ganc"), meanCI)}

#run bootstrap for greml
df_mean <- getmeanCI(df)

#output
write.table(df_mean, file="admix_greml_vg_CI_P0_P9_w-wo_ganc.txt",
            quote = FALSE, sep = "\t",
            row.names = FALSE, col.names = TRUE)

########### CI bands for h2 greml estimates #########################
#load data 
#varX
varx_h2 <- fread("admix_GRMvarX.h2", header = F)
varx_h2_ganc <- fread("admix_GRMvarX.h2_ganc", header = F)

#LD
ld_h2 <- fread("admix_GRMld.h2", header = F)
ld_h2_ganc <- fread("admix_GRMld.h2_ganc", header = F)

#standard 
standard_h2 <- fread("admix_GRMstandard.h2", header = F)
standard_h2_ganc <- fread("admix_GRMstandard.h2_ganc", header = F)

#add colnames
colnames(varx_h2) <- c("model", "cov", "t", "seed", "P", "h2_varX", "se_varX")
colnames(varx_h2_ganc) <- c("model", "cov", "t", "seed", "P", "h2_varX_ganc", "se_varX_ganc")
varx <- merge(varx_h2, varx_h2_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

colnames(ld_h2) <- c("model", "cov", "t", "seed", "P", "h2_ld", "se_ld")
colnames(ld_h2_ganc) <- c("model", "cov", "t", "seed", "P", "h2_ld_ganc", "se_ld_ganc")
ld <- merge(ld_h2, ld_h2_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

colnames(standard_h2) <- c("model", "cov", "t", "seed", "P", "h2_standard", "se_standard")
colnames(standard_h2_ganc) <- c("model", "cov", "t", "seed", "P", "h2_standard_ganc", "se_standard_ganc")
standard <- merge(standard_h2, standard_h2_ganc, by = c('model', 'cov', 't', 'seed', 'P'))

#combine grm files
df <- merge(standard, varx, by = c('model', 'cov', 't', 'seed', 'P'))
df <- merge(df, ld, by = c('model', 'cov', 't', 'seed', 'P'))

# function to bootstrap: return to mean, CI95l, CI95r
meanCI <- function(data){
  library(dplyr)
  # Resample 100 times, and find the mean of each
  boot=tibble(num = 1:100) %>% 
    group_by(num) %>% 
    mutate(mean = mean(sample(data, 
                              replace = TRUE))) 
  boot_mean=mean(boot$mean)
  # Bootstrap 95% percentile confidence interval
  boot_CI=quantile(boot$mean, c(0.025,0.975))
  # report the mean and CI95%
  mean_CIs=tibble(
    mean=boot_mean,
    CI95l=boot_CI[1],
    CI95r=boot_CI[2])  
  return(mean_CIs)  
}


# function to get mean and CIs for each rep
getmeanCIh2 <- function(mydata){
  library(dplyr)
  mydata %>% 
    group_by(t, P, cov, model) %>% 
    summarise_at(vars("h2_standard","h2_standard_ganc","h2_varX","h2_varX_ganc",
                      "h2_ld","h2_ld_ganc"), meanCI)}

#run bootstrap for greml
df_mean <- getmeanCIh2(df)

#output
write.table(df_mean, file="admix_greml_h2_CI_P0_P9_wwo_ganc.txt",
            quote = FALSE, sep = "\t",
            row.names = FALSE, col.names = TRUE)


########### CI bands for vgamma greml estimates #########################
varx_vgamma <- fread("admix_GRMvarX.vg.lanc", header = F)
varx_vgamma_ganc <- fread("admix_GRMvarX.vg_ganc.lanc", header = F)

ld_vgamma <- fread("admix_GRMld.vg.lanc", header = F)
ld_vgamma_ganc <- fread("admix_GRMld.vg_ganc.lanc", header = F)

standard_vgamma <- fread("admix_GRMstandard.vg.lanc", header = F)
standard_vgamma_ganc <- fread("admix_GRMstandard.vg_ganc.lanc", header = F)

#add colnames
colnames(varx_vgamma) <- c("model", "cov", "t", "seed", "P", "vgamma_varX", "se_varX")
colnames(varx_vgamma_ganc) <- c("model", "cov", "t", "seed", "P", "vgamma_varX_ganc", "se_varX_ganc")
varx <- merge(varx_vgamma, varx_vgamma_ganc, by = c('model', 'cov', 't', 'seed', 'P'), all.x = T)

colnames(ld_vgamma) <- c("model", "cov", "t", "seed", "P", "vgamma_ld", "se_ld")
colnames(ld_vgamma_ganc) <- c("model", "cov", "t", "seed", "P", "vgamma_ld_ganc", "se_ld_ganc")
ld <- merge(ld_vgamma, ld_vgamma_ganc, by = c('model', 'cov', 't', 'seed', 'P'), all.x = T)

colnames(standard_vgamma) <- c("model", "cov", "t", "seed", "P", "vgamma_standard", "se_standard")
colnames(standard_vgamma_ganc) <- c("model", "cov", "t", "seed", "P", "vgamma_standard_ganc", "se_standard_ganc")
standard <- merge(standard_vgamma, standard_vgamma_ganc, by = c('model', 'cov', 't', 'seed', 'P'), all.x = T)

#combine grm files
df <- merge(standard, varx, by = c('model', 'cov', 't', 'seed', 'P'), all.x = T)
df <- merge(df, ld, by = c('model', 'cov', 't', 'seed', 'P'), all.x = T)

#output
fwrite(df, "admix_grm_vgamma_all.txt", sep = '\t',
       col.names=TRUE, row.names=FALSE, quote = FALSE)

# function to bootstrap: return to mean, CI95l, CI95r
meanCI <- function(data){
  library(dplyr)
  # Resample 100 times, and find the mean of each
  boot=tibble(num = 1:100) %>% 
    group_by(num) %>% 
    mutate(mean = mean(sample(data, 
                              replace = TRUE), na.rm = TRUE)) 
  boot_mean=mean(boot$mean, na.rm=T)
  # Bootstrap 95% percentile confidence interval
  boot_CI=quantile(boot$mean, c(0.025,0.975), na.rm=T)
  # report the mean and CI95%
  mean_CIs=tibble(
    mean=boot_mean,
    CI95l=boot_CI[1],
    CI95r=boot_CI[2])  
  return(mean_CIs)  
}


# function to get mean and CIs for each rep
getmeanCI <- function(mydata){
  library(dplyr)
  mydata %>% 
    group_by(t, P, cov, model) %>% 
    summarise_at(vars("vgamma_standard","vgamma_standard_ganc","vgamma_varX","vgamma_varX_ganc",
                      "vgamma_ld","vgamma_ld_ganc"), meanCI)}

#run bootstrap for greml
df_mean <- getmeanCI(df)

#output
write.table(df_mean, file="admix_greml_vgamma_CI_P0_P9_w-wo_ganc.txt",
            quote = FALSE, sep = "\t",
            row.names = FALSE, col.names = TRUE)
