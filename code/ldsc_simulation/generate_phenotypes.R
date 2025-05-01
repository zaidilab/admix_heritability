#!/usr/bin/env Rscript

suppressWarnings(suppressMessages({
  library(data.table)
  library(rprojroot)
}))

F = is_git_root$make_fix_file()

args=commandArgs(TRUE)

prs.prefix = args[1]
h2 = as.numeric(args[2])

#load raw file
prs = fread(F(paste(prs.prefix, ".sscore",sep = "")))
colnames(prs) = c("IID","alct","dosage.sum","avg")
prs[, g := avg*alct]   #compute genetic value
n = nrow(prs)

vg = var(prs$g) # observed genetic variance
ve = vg*(1 - h2)/h2  # error variance to achieve desired heritability

#simulate phenotype
prs[, y := g + rnorm(n, 0, sqrt(ve))]

pheno_file = paste(prs.prefix, ".pheno", sep = "")
fwrite(prs[, .(IID, g, y)], F(pheno_file), row.names=FALSE,col.names=TRUE,quote=FALSE,sep="\t")