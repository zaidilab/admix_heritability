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

read.glanc = function(g, model, rep){
  L <- readLines(F(paste("data/ldsc/1kg-ref-hg38/admix/pgen/admix_",model,"_g",g,"_",rep,".bp",sep="")))
  isHdr <- grepl("Sample", L)
  grp <- L[isHdr][cumsum(isHdr)]
  Read <- function(x) read.table(text = x, sep = "\t", fill = TRUE, comment = "S")
  anc = Map(Read, split(L, grp))
  anc = dplyr::bind_rows(anc, .id = "IID")
  colnames(anc) = c("IID","pop","chrom","bp.end","cm")
  anc = as.data.table(anc)
  anc[pop=="YRI", lanc := 1]
  anc[pop=="CEU", lanc := 0]
  anc[, bp.start := shift(bp.end, 1, fill = 0), by = "IID"]
  anc[, bp := bp.end - bp.start]
  glanc = anc[, .(anc = sum(lanc*bp/242148846)), by = c("IID")]
  glanc[, c("sample","ind","hap") := tstrsplit(IID, split = "_")]
  glanc[, IID := paste(sample, ind, sep = "_")]
  glanc = glanc[, .(anc = mean(anc)), by = "IID"]
  return(glanc)
}

glanc2 = read.glanc(g = g, model = model, rep = rep)

fwrite(glanc2, file = F(paste("data/ldsc/1kg-ref-hg38/admix/glanc/admix_",model,"_g",g,"_",rep,".glanc", sep = "")), sep = "\t")