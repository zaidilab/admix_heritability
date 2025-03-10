library(data.table)

args=commandArgs(TRUE)

plinkdir = args[1]
filename = args[2]
outdir = args[3]

#load raw file
prs = fread((paste0(plinkdir, "/", filename, ".sscore")))
colnames(prs) = c("FID","IID","alct","dosage.sum","avg")

#compute genetic value
prs[, g := avg*alct]  

#get observed genetic variance
var.prs.geno = var(prs$g) 

#output
out <- data.table("var.prs.geno" = var.prs.geno)
print(out)
write.table(out, file = paste0(outdir, "/", filename,".obs.vg"), 
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = T)