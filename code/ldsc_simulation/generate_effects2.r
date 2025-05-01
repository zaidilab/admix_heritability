#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(data.table)
  library(rprojroot)
}))

F = is_git_root$make_fix_file()

args=commandArgs(TRUE)

# model=args[1]
raw.file=args[1]
# h2=as.numeric(args[2])
out.prefix=args[2]
# p=args[2]
# rep=args[3]

#print(c(model, p, rep, h2))

#set.seed(rep)

# frq.file = args[1]
# frq = fread(F(frq.file))
# # frq.source = frq[CLST %in% c(0,1),],
# frq = dcast(frq, SNP + A1 + A2 ~ CLST, value.var = "MAF")
# colnames(frq)[c(4,5,6)] = c("fpop1","fpop2","fadmix")
# frq[, pbar := (fpop1 + fpop2)/2]
# frq = frq[pbar > 0.01,]
# frq[, fst := (fpop1 - fpop2)^2 / (4*pbar*(1-pbar))]

#polarize by which allele is common in pop1
# frq[, iA1 := A1]
# frq[, iA2 := A2]
# frq[, f1 := fpop1]
# frq[, f2 := fpop2]
# frq[fpop1 < fpop2, iA1 := A2 ]
# frq[fpop1 < fpop2, iA2 := A1 ]
# frq[Pop1 < Pop2, fA1 := 1 - Pop1 ]
# frq[Pop1 < Pop2, fA2 := 1 - Pop2 ]

# nloci = nrow(frq)
# frq[, fdiff := fpop1 - fpop2]
# frq$esize = sapply(frq$pbar, function(x){rnorm(1, 0, sqrt(h2/(nloci*2*x*(1-x))))})

# bmat = with(frq.source2, esize %*% t(esize))
# vgenic = sum(diag(bmat) * 2*frq.source2$pbar*(1-frq.source2$pbar))
# fdiffmat = with(frq.source2, fdiff %*% t(fdiff))

# filename = paste("data/ldsc/plink/",model,"/admix_",model,"_ss10000.cm.p", p , ".r" , rep , ".raw", sep = "")
dat = fread(F(raw.file))
mat = as.matrix(dat[,-c(1:6)])
nloci = ncol(mat)
n = nrow(mat)

samfile = "data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2.psam"
sam = fread(F(samfile))
ceu.ix = which(sam$Population == "CEU")
yri.ix = which(sam$Population == "YRI")

# p1.ix = c(1:100)
# p2.ix = c(101:200)
# admix.ix = c(201:n)

snps = data.table(snps = colnames(mat))
snps = snps[, tstrsplit(snps, split = ":",names = c("chr","pos","ref","alt_a1"))]
snps[, c("alt","a1") := tstrsplit(alt_a1, split = "_")]
snps[, id := paste(chr, ":",pos,":",ref,":",alt, sep = "")]


snps$fbar = apply(mat, 2, mean)/2
snps$varx = apply(mat, 2, var)
poly.ix = with(snps, which(fbar > 0.01 & fbar < 0.99))

snps = snps[poly.ix,]
mat = mat[,poly.ix]
n = nrow(mat)
nloci = nrow(snps)
# h_l = h2/nloci

esize = sapply(snps$varx, function(x){1/sqrt(nloci*x)})

# #sample maf-dependent effects using the model above
vgb.mat = rep(NA, 1000)
for(i in 1:1000){
  set.seed(i)
  esize2 = sample(c(-1,1), size = nloci, replace = TRUE)*esize
  prs.ceu = mat[ceu.ix,]%*%esize2
  prs.yri = mat[yri.ix,]%*%esize2
  vgb.mat[i] = (mean(prs.ceu) - mean(prs.yri))^2
}


min.seed = which.min(vgb.mat)
max.seed = which.max(vgb.mat)
# med.seed = which(abs(vgb.mat - 1.0) == min(abs(vgb.mat - 1.0)))


set.seed(min.seed)
snps[,esize.min := sample(c(-1,1), size = nloci, replace = TRUE)*esize]

set.seed(max.seed)
snps[,esize.max := sample(c(-1,1), size = nloci, replace = TRUE)*esize]

# set.seed(med.seed)
# snps[,esize.med := sample(c(-1,1), size = nloci, replace = TRUE)*esize]

rm(.Random.seed, envir=globalenv())


# let's calculate sigma2_g to confirm that the total genetic variance is indeed 0.8
# sigma2_g = sum( mapply(function(b,p){ b^2* 2*p*(1-p) }, snps2$beta, snps2$ALT_FREQS))

# admix_random_ss10000.cm_p_r1.frq.strat

# effects_file = paste("data/ldsc/effects/",model,"/admix_",model,"_ss10000.cm.p", p , ".r" , rep , ".effects", sep = "")
effects_file.min = paste(out.prefix, ".min.effects", sep = "")
effects_file.max = paste(out.prefix, ".max.effects", sep = "")
# effects_file.med = paste(out.prefix, ".med.effects", sep = "")


#save the effect sizes to file and use plink2 to generate PRS
fwrite(snps[, .(id,a1,esize.min, ref,alt, fbar)], F(effects_file.min), row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")
fwrite(snps[, .(id,a1,esize.max, ref,alt, fbar)], F(effects_file.max), row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")
# fwrite(snps[, .(id,a1,esize.med, ref,alt, fbar)], F(effects_file.med), row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")


# #compute true vg
# g = mat %*% snps$esize
# vg = var(g)

# xvar = apply(mat, 2, var)
# vgenic1 = sum(with(snps, esize^2 *2*fbar*(1-fbar)))
# vgenic2 = sum(with(snps, esize^2 * xvar))
# vld = vg - vgenic2


# #simulate phenotype
# y = g + rnorm(n, 0, sqrt(1-h2))
# pgs = dat[, .(FID, IID)]
# pgs[, g := g ]
# pgs[, y := y]
# # pheno_file = paste("data/ldsc/phenotypes/",model,"/admix_",model,"_ss10000.cm.p", p , ".r" , rep ,".pheno", sep = "")
# pheno_file = paste(out.prefix, ".pheno", sep = "")
# fwrite(pgs, F(pheno_file), row.names=FALSE,col.names=TRUE,quote=FALSE,sep="\t")

# vy = var(y)
# true.arch = data.table(vg = vg, vgenic1 = vgenic1, vgenic2 = vgenic2, vld = vld, vy = vy)
# true.arch.file = paste(out.prefix, ".vg", sep = "")
# # true.arch.file = paste("data/ldsc/phenotypes/",model,"/admix_",model,"_ss10000.cm.p", p , ".r" , rep ,".vg", sep = "")
# fwrite(true.arch, F(true.arch.file), row.names=FALSE,col.names=TRUE,quote=FALSE,sep="\t")




