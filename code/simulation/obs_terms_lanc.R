library(data.table)

args=commandArgs(TRUE)

plinkdir = args[1]
filename = args[2]
outdir = args[3]
h2 = as.numeric(args[4])
# phenodir = args[5]

#load raw file
prs = fread((paste0(plinkdir, "/", filename, ".sscore")))
colnames(prs) = c("FID","IID","alct","dosage.sum","avg")

#compute genetic value for lanc
prs[, g := avg*alct]  
n = nrow(prs)

#get observed genetic variance
var.prs.lanc = var(prs$g) 

vg = var.prs.lanc 
ve = vg*(1 - h2)/h2  # error variance to achieve desired heritability

#simulate phenotype
prs[, y := g + rnorm(n, 0, sqrt(ve))]

#output phenotype
# pheno_file = paste0(phenodir,"/", filename, ".pheno")
# fwrite(prs[, .(FID,IID, g, y)], pheno_file, row.names=FALSE,col.names=TRUE,quote=FALSE,sep="\t")

#output var.prs.lanc
out <- data.table("var.prs.lanc" = var.prs.lanc)
print(out)
write.table(out, file = paste0(outdir, "/", filename,".obs.vg.lanc"), 
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = T)