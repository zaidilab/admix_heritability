

library(data.table)
library(ggplot2)
library(patchwork)
F = rprojroot::is_rstudio_project$make_fix_file()

causal = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p0.01.min.effects"))
colnames(causal) = c("id","A1","esize","ref","alt","maf")
same = data.table(idA = causal$id, chromA = 2, posA = 0, refA = causal$ref, 
                  chromB = 2, posB = 0, idB = causal$id, refB = causal$ref, unr = 1,
                  A1 = causal$A1, esize = causal$esize, ref = causal$ref, alt = causal$alt, maf = causal$maf)

load.exp = function(g, model){
  
  r2 = fread(paste("zstdcat ~/projects/admix_heritability/data/ldsc/1kg-ref-hg38/admix/vcor/admix_",model,"_g",g,"_1.vcor.zst", sep = ""))
  colnames(r2) = c("chromA","posA","idA","refA","chromB","posB","idB","refB","unr")
  r2 = r2[order(posB)]
  r2 = merge(r2, causal, by.x = c("idA"), by.y = c("id"))
  r2 = rbind(same, r2)
  
  #r2[, q2 := esize^2 *2*maf*(1-maf)]
  r2.summary = r2[, .(exp.beta = sum(unr*esize)), by = c("idB","refB")]
  
  gwas = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/gwas/admix_",model,"_g",g,"_p0.01_1.min.nocovar.g.glm.linear", sep="")))
  colnames(gwas) = paste("gwas", colnames(gwas), sep = "")
  
  r2.summary = merge(r2.summary, gwas, by.x = "idB", by.y = "gwasID")
  r2.summary[, polB := -gwasBETA]
  r2.summary[, chi2 := gwasT_STAT^2]
  
  r2.summary$g = g
  r2.summary$model = model

  l2 = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/l2/admix_",model,"_g",g,"_1.2000k.l2.ldscore.gz", sep = "")))
  r2.summary = merge(r2.summary, l2, by.x = "idB", by.y = "SNP")
  return(r2.summary)

}

g2.cgf = load.exp(g = 2, model = "CGF")
g20.cgf = load.exp(g = 20, model = "CGF")

g2.hi = load.exp(g = 2, model = "HI")
g20.hi = load.exp(g = 20, model = "HI")

vg = fread(F("data/ldsc/1kg-ref-hg38/admix/admix_all.vg"))
vg = vg[g %in% c(2,20)& rep ==1 & p==0.01 & arch == "min" & trait == "gvalue"]
colnames(vg)[7] = "vg"

freq = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2.frq.strat"))
freq = dcast(freq, SNP + A1 ~ CLST, value.var = "MAF")


rall = rbind(g2.cgf, g20.cgf, g2.hi, g20.hi)
rall2 = merge(rall, freq, by.x = "idB", by.y = "SNP")
rall2[, afr := 1 - AFR]
rall2[, eur := 1 - EUR]

rall2[, maf:=  gwasA1_FREQ]
rall2[gwasA1_FREQ > 0.5, maf := 1 - gwasA1_FREQ]
rall2$model = factor(rall2$model, levels = c("HI","CGF"))

rall2[, exp.q2 := exp.beta^2 * 2* maf*(1-maf)]
rall2[, q2 := polB^2 * 2*maf*(1-maf)]
rall2 = merge(rall2, vg[, .(model, g, vg)], by = c("model","g"))
rall2[, exp.ncp := 5e3*exp.q2/(vg - exp.q2)]



plt_f1 = ggplot(rall2, aes(exp.beta, polB, z = eur))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  stat_summary_hex(bins =50)+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  theme_classic()+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)), 
       fill = bquote(f[EUR]))

plt_n = ggplot(rall2, aes(exp.beta, polB))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  geom_hex(bins =50)+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  theme_classic()+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)), 
       fill = "No. of \n variants")

plt_f2 = ggplot(rall2, aes(exp.beta, polB, z = afr))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  stat_summary_hex(bins =50)+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  theme_classic()+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)), 
       fill = bquote(f[AFR]))


plt_maf = ggplot(rall2, aes(exp.beta, polB, z = maf))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  stat_summary_hex(bins =50)+
  theme_classic()+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)), 
       fill = "MAF")

plt_l2 = ggplot(rall2, aes(exp.beta, polB, z = L2))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  stat_summary_hex(bins =50)+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  theme_classic()+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)),
       fill = "LD score")

plt_chi2 = ggplot(rall2, aes(exp.beta, polB, z = chi2))+
  geom_abline(intercept = 0, slope = 1, color = "black")+
  stat_summary_hex(bins =50)+
  scale_fill_gradient(low = "#92c5de", high = "#d7191c")+
  theme_classic()+
  facet_grid(g~model)+
  labs(x = bquote("E("~hat(beta)~")"), y = bquote(hat(beta)),
       fill = bquote(chi^2))

# plt = (plt_f + plt_chi2) / (plt_maf + plt_l2)
plt = (plt_chi2 + plt_l2) / (plt_n + plt_maf) / (plt_f1 + plt_f2)

plt = plt +  plot_annotation(tag_levels = 'a')& theme(plot.tag = element_text(size = 16, hjust = 0, vjust = 0, face = "bold"))


ggsave(F("plots/plt_ldsc_exp_v_obs_effects.pdf"),plt, height = 15, width = 13)
ggsave(F("plots/plt_ldsc_exp_v_obs_effects.png"),plt, height = 15, width = 13)


