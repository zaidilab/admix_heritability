
library(data.table)
args = commandArgs(TRUE)

g = as.numeric(args[1])
admix.prop = as.numeric(args[2])
n = args[3]
outpre = args[4]

admix.prop2 = 1-admix.prop
m1 = 1- admix.prop2^(1/g)


dat = data.table(
  gens = c(1:g),
  Admixed = c(0, rep(1-m1, g - 1)),
  CEU = c(m1, rep(m1, g - 1)),
  YRI = c(1-m1, rep(0, g - 1))
)

colnames(dat)[1] = n

fwrite(dat, paste(outpre, ".dat", sep = ""), 
       quote = FALSE,row.names = FALSE, col.names = TRUE, sep = "\t")





