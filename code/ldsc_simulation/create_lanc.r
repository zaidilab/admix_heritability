
suppressWarnings(suppressMessages({
    library(data.table)
    #library(ggplot2)
    library(intervals)
}))

args = commandArgs(TRUE)

g = args[1]
model = args[2]
rep = args[3]

F = rprojroot::is_rstudio_project$make_fix_file()

read.glanc = function(g, model, rep = 1){
  L <- readLines(F(paste("data/ldsc/1kg-ref-hg38/admix/pgen/admix_",model,"_g",g,"_",rep,".bp",sep="")))
  isHdr <- grepl("Sample", L)
  grp <- L[isHdr][cumsum(isHdr)]
  Read <- function(x) read.table(text = x, sep = "\t", fill = TRUE, comment = "S")
  anc = Map(Read, split(L, grp))
  anc = lapply(anc, function(x){
    x = data.table(x)
    colnames(x) = c("pop","chrom","bp.end","cm")
    x[, bp.start := shift(bp.end, 1, fill=0)]
    x1 = data.table(interval_union(Intervals(x[pop == "YRI", c(5,3)])))
    x2 = data.table(interval_union(Intervals(x[pop == "CEU", c(5,3)])))
    colnames(x1) = colnames(x2) = c("start","stop")
    x1[, lanc := 1]
    x2[, lanc := 0]
    x = rbind(x1, x2)
    return(x)
  })
  anc = dplyr::bind_rows(anc, .id = "IID")
  anc[, c("sample","ind","hap") := tstrsplit(IID, split = "_")]
  anc[, IID := paste(sample, ind, sep = "_")]
  anc = anc[, .(lanc = sum(lanc)), by = c('IID','start','stop')]
  return(anc)
}

glanc = suppressWarnings(suppressMessages({
    read.glanc(g, model, rep)
}))
glanc[, iid := tstrsplit(IID, split = "_", keep = 2)]
glanc[, iid := as.numeric(iid)]
setorder(glanc, iid,start,stop)

bim.file = paste("data/ldsc/1kg-ref-hg38/admix/bed/admix_",model,"_g",g,"_",rep,".bim", sep = "")
bim = fread(F(bim.file))
colnames(bim) = c("chrom","rsid","cm","bp","ref","alt")

fam.file = paste("data/ldsc/1kg-ref-hg38/admix/bed/admix_",model,"_g",g,"_",rep,".fam", sep = "")
fam = fread(F(fam.file))
nsnps = nrow(bim)
ninds = nrow(fam)
nsegments = nrow(glanc)

lmat = matrix(NA, nrow = nsnps, ncol = ninds)

for(i in 1:nsegments){
  ix = glanc[i,iid]
  startx = glanc[i,start]
  stopx = glanc[i,stop]
  lancx = glanc[i,lanc]
  bimx = with(bim, bp > startx & bp < stopx)
  lmat[bimx,ix] = lancx
}

lanc.file = paste("data/ldsc/1kg-ref-hg38/admix/lanc/admix_",model,"_g",g,"_",rep,".lanc", sep = "")

fwrite(lmat, F(lanc.file), sep = "\t", col.names = FALSE)







