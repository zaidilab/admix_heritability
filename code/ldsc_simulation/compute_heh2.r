#!/usr/bin/env Rscript 
#Part 1: Verify h2
#Step 1 - calculate var(prs)
#Step 2 - calculate var(pheno)
#Step 3 - Verify that var(prs)\var(pheno) is about 0.8 = h2
#Step 4 - g* = g - B0, var(g*) = expectation
library(data.table)


# load data
args = commandArgs(trailingOnly = TRUE)

grm = args[1] #path to grm (only prefix needed)
pheno = args[2] # FID in 1st column, IID in second column, g in 3rd column and y in 4th column
covariates = args[3] # FID in first column, IID in 2nd column, g in 3rd column, and y in 4th column 
output = args[4] # output file name and path

# model = args[1] #model, either HI or CGF
# p = args[2] #proportion of variants
# g = args[3]
# trait = args[4]
# arch = args[5]
# rep = args[6]
# cov <- args[3] 
# # seed <- args[4]
# # t <- args[5]
# grm <- args[6]
# grmdir <- args[7]

# summarydir <- paste0("/home/aazaidi/klema030/AdjustedHE/output/", model, "/gcta/HE_", grm, "/") # directory, can be modified 

# pheno <- fread(paste0("~/projects/admix_heritability/data/tldsc/1kg-ref-hg38/pheno/", model, "/admix_", model, "_theta0.5_gen20_P", P , "_", cov, "_seed", seed, "_t", t, ".pheno"), header=F)$V3

# ganc <- fread(paste0("/home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/", model, "/admix_", model, "_theta0.5_gen20_P", P , "_", cov, "_seed", seed, "_t", t, ".ganc"), header=F)$V3 
# ganc.ids <- fread(paste0("/home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/ganc/", model, "/admix_", model, "_theta0.5_gen20_P", P ,"_", cov, "_seed", seed, "_t", t, ".ganc"), header=F)$V2  

# prs <- fread(paste0("/home/aazaidi/huan2788/admix_heritability/data/theta0.5_gen20/PRS/", model, "/admix_", model, "_theta0.5_gen20_P", P ,"_", cov, "_seed", seed, "_t", t, ".prs"), header=F)$V3 

# filename <- paste0("admix_", model,"_theta0.5_gen20_P", P ,"_", cov, "_seed", seed, "_t", t)

#head(ganc.ids)

print("reading phenotypes")
pheno = fread(pheno)
colnames(pheno) = c("FID","IID","gvalue","y")

print("reading covariates")
covar = fread(covariates)
colnames(covar)[1] = "FID"

pheno = merge(pheno, covar, by = c("FID","IID"))

# #Calculate variance of PRS and Pheno files
# var.prs<- var(pheno$gvalue)

# var.pheno<- var(pheno$y)

pcs = paste("PC", seq(1,20), sep = "")
pcp = paste(pcs, collapse = "+")
# form1 = paste("gvalue ~ ", pcp, sep = "")
# form2 = paste("y ~ ", pcp, sep = "")

# l1 = lm(data = pheno, formula = form1)
# l2 = lm(data = pheno, formula = form2)

# ystar1 = l1$residuals
# ystar2 = l2$residuals

# var.ystar1 = var(ystar1)
# var.ystar2 = var(ystar2)


print("reading GRM")
# R script to read the GRM binary file, From GCTA
ReadGRMBin=function(prefix, AllN=FALSE, size=4){
  sum_i=function(i){
    return(sum(1:i))
  }
  BinFileName=paste(prefix,".grm.bin",sep="")
  NFileName=paste(prefix,".grm.N.bin",sep="")
  IDFileName=paste(prefix,".grm.id",sep="")
  id = read.table(IDFileName)
  n=dim(id)[1]
  BinFile=file(BinFileName, "rb");
  grm=readBin(BinFile, n=n*(n+1)/2, what=numeric(0), size=size)
  NFile=file(NFileName, "rb");
  if(AllN==TRUE){
    N=readBin(NFile, n=n*(n+1)/2, what=numeric(0), size=size)
  }
  else N=readBin(NFile, n=1, what=numeric(0), size=size)
  i=sapply(1:n, sum_i)
  return(list(diag=grm[i], off=grm[-i], id=id, N=N))

  closeAllConnections()
}

G =ReadGRMBin(grm)

G.ids = G$id$V2
G.diag = G$diag
G.off = G$off

#phenotype data.frame is not ordered correctly with respect to the grm
pheno[, sno := tstrsplit(IID, split = "_", keep = 2)]
pheno$sno = as.numeric(pheno$sno)
pheno = pheno[order(sno)]


#function to compute and report regression stats
hereg = function(phenotype){
  pheno$spheno  = scale(pheno[, ..phenotype], center = TRUE, scale=FALSE)
  
  form1 = paste("spheno ~ ", pcp, sep = "")

  #step 1 - regress out ancestry components
  l1 =  lm(data = pheno, formula = form1)
  ystar = l1$residuals

  #Step 2 - calc y*y*' and take lower half of matrix
  yy_star = ystar%*%t(ystar)
  yy_star = yy_star[upper.tri(yy_star)]

  #Step 3 - Calculate 00' and take lower half of matrix
  p = as.matrix(pheno[, ..pcs])
  pp = p %*% t(p)
  pp = pp[upper.tri(pp)]

  l2 = lm(yy_star ~ (G.off + pp))

  G.off.coeff = summary(l2)$coefficients[2, ]
  
  return(G.off.coeff)

}

print("computing heritability")
vg.g = hereg("gvalue")
vg.y = hereg("y")

vg.g = as.data.table(t(vg.g))
vg.y = as.data.table(t(vg.y))
vg.g[, phenotype := "g"]
vg.y[, phenotype := "y"]

dat = rbind(vg.g, vg.y)

fwrite(dat,
       output,
       col.names = FALSE,
       row.names=FALSE,
       quote=FALSE,
       sep="\t")




