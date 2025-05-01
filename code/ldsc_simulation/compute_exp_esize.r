#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(data.table)
  library(rprojroot)
}))

F = is_git_root$make_fix_file()

args=commandArgs(TRUE)
g = args[1]
model = args[2]
rep=args[3]

print("reading genotypes")

raw.file = paste("data/ldsc/1kg-ref-hg38/admix/raw/admix_",model,"_g",g,"_",rep,".raw", sep = "")
dat = fread(F(raw.file))
snps = data.table(snps = colnames(dat)[-c(1:6)])
ix.rm = which(snps$snps =="HGSV_20191_C")
snps = snps[-ix.rm,]
snps[, c("snpnames","a1") := tstrsplit(snps, split = "_")]
nsnps = nrow(snps)
ninds = nrow(dat)
iids = dat$IID 

mat = as.matrix(dat[,-c(1:6)])

print("reading PCs")
pc.file = paste("data/ldsc/1kg-ref-hg38/admix/pca/admix_",model,"_g",g,"_",rep,".eigenvec", sep = "")
pcs = fread(F(pc.file))
pcmat = as.matrix(pcs[,-c(1:2)])
P = pcmat%*%solve(t(pcmat)%*%pcmat) %*% t(pcmat)
resmat = mat - P%*%mat

print("scaling the residual matrix")
resmat = apply(resmat, 2, scale)
mat = apply(mat, 2, scale)

mat = mat[, -ix.rm]
resmat = resmat[, -ix.rm]

causal = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p0.01.min.effects"))
colnames(causal) = c("id","a1","esize","ref","alt","maf")
# snps = merge(snps, causal, by.x = "snpnames", by.y = "id", sort = FALSE)

causal.ix = which(snps$snpnames %in% causal$id)
cmat1 = resmat[,causal.ix]
cmat2 = mat[, causal.ix]
csnps = snps$snpnames[causal.ix]

print("computing correlation between marker and causal genotypes")
ldmat1 = crossprod(resmat, cmat1)
ldmat1 = ldmat1/5000
colnames(ldmat1) = csnps
rownames(ldmat1) = snps$snpnames

print("melting to long format")
r21 = reshape2::melt(ldmat1)
r21$Var1 = as.character(r21$Var1)
r21$Var2 = as.character(r21$Var2)
r21 = as.data.table(r21)
colnames(r21) = c("idmarker","idcausal","unr")

print("outputting r2")
output.r21 = paste("data/ldsc/1kg-ref-hg38/admix/vcor/admix_",model,"_g",g,"_",rep,".pca.r21", sep = "")
fwrite(r21, F(output.r21), col.names=TRUE, row.names=FALSE, quote = FALSE, sep = "\t")

r21 = merge(r21, causal, by.x = c("idcausal"), by.y = c("id"))
r21 = merge(r21, snps, by.y = "snpnames",by.x = "idmarker")
colnames(r21)[4] = "a1.causal"
colnames(r21)[10] = "a1.marker"

r21.summary = r21[, .(exp.beta = sum(unr*esize)), by = c("idmarker","a1.marker")]
output.esize = paste("data/ldsc/1kg-ref-hg38/admix/expB/admix_",model,"_g",g,"_",rep,".resmat.exp.beta", sep = "")
fwrite(r21.summary, F(output.esize), sep = "\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

r21.summary2 = merge(r21.summary, causal, by.x = "idmarker", by.y = "id" )

ggplot(r21.summary2, aes(esize, exp.beta))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1, color = "red")

ldmat2 = crossprod(mat, cmat2)
ldmat2 = ldmat2/5000
colnames(ldmat2) = csnps
rownames(ldmat2) = snps$snpnames

r22 = reshape2::melt(ldmat2)
r22$Var1 = as.character(r22$Var1)
r22$Var2 = as.character(r22$Var2)
r22 = as.data.table(r22)
colnames(r22) = c("idmarker","idcausal","unr")

print("outputting r2")
output.r22 = paste("data/ldsc/1kg-ref-hg38/admix/vcor/admix_",model,"_g",g,"_",rep,".pca.r22", sep = "")
fwrite(r22, F(output.r22), col.names=TRUE, row.names=FALSE, quote = FALSE, sep = "\t")


r22 = merge(r22, causal, by.x = c("idcausal"), by.y = c("id"))

r22 = merge(r22, snps, by.y = "snpnames",by.x = "idmarker")
colnames(r22)[4] = "a1.causal"
colnames(r22)[10] = "a1.marker"


print("computing expected effect sizes")
r22.summary = r22[, .(exp.beta = sum(unr*esize)), by = c("idmarker", "a1.marker")]
output.esize = paste("data/ldsc/1kg-ref-hg38/admix/expB/admix_",model,"_g",g,"_",rep,"mat.exp.beta", sep = "")
fwrite(r22.summary, F(output.esize), sep = "\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

r22.summary2 = merge(r22.summary, causal, by.x = "idmarker", by.y = "id" )

ggplot(r22.summary2, aes(esize, exp.beta))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1, color = "red")

