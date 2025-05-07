
suppressWarnings(suppressMessages({
  library(data.table)
  library(ggplot2)
  library(ggh4x)
  library(patchwork)
}))

F = rprojroot::is_rstudio_project$make_fix_file()

greml1 = fread(F("data/ldsc/1kg-ref-hg38/admix/gcta/admix_all.nocov.hsq"))
greml2 = fread(F("data/ldsc/1kg-ref-hg38/admix/gcta/admix_all.cov.hsq"))

colnames(greml1) = colnames(greml2) = c("model","arch","g","trait","p","rep","quantity","estimate","se")
greml2$ancestry = "Ancestry correction"
greml1$ancestry = "No correction"

greml = rbind(greml1, greml2)
greml.summary = greml[, .(estimate = mean(estimate), 
                      l.ci = quantile(estimate, probs = 0.025), 
                      u.ci = quantile(estimate, probs = 0.975)), 
                  by = c("model","arch","g","trait","p","quantity","ancestry")]

greml.summary$model = factor(greml.summary$model, levels = c("HI","CGF"))
greml.summary$ancestry = factor(greml.summary$ancestry, levels = c("No correction","Ancestry correction"))
greml.summary[trait == "g", trait := "gvalue"]
greml.summary = greml.summary[trait == "y"]

#pheno = fread(F("data/ldsc/1kg-ref-hg38/admix/admix_all.pheno"))
#colnames(pheno) = c("model","arch","g","trait","p","rep","IID","gvalue","y")
#pheno$trait = NULL
#pheno = melt(pheno, id.vars = c("model","arch","g","p","rep","IID"), 
#            value.name = "value",variable.name = "trait")

#vg = pheno[, .(var = var(value)), 
           # by = c("model","arch","g","trait","p","rep")]


#fwrite(vg, F("data/ldsc/1kg-ref-hg38/admix/admix_all.vg"), col.names=TRUE, row.names=FALSE, sep = "\t", quote = FALSE)

esize1 = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p0.01.max.effects"))
esize2 = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p0.05.max.effects"))
esize3 = fread(F("data/ldsc/1kg-ref-hg38/ceu.yri/1kg_hm3_chr2_p0.1.max.effects"))
colnames(esize1) = colnames(esize2) = colnames(esize3) = c("rsid","a1","beta","ref","alt","maf")
esize1$p = 0.01; esize2$p = 0.05; esize3$p = 0.1
esizes = rbind(esize1, esize2, esize3)
esizes$maf = NULL


afreq = fread(F('data/ldsc/1kg-ref-hg38/admix/admix_all.afreq'))
colnames(afreq) = c("model","p","g","rep","rsid","maf")
afreq = afreq[, .(maf = mean(maf)), by = c("model","p","g","rsid")]
esizes = merge(esizes, afreq, by = c("rsid","p"))
vgenic = esizes[, .(vg = sum(beta^2*2*maf*(1-maf))), by = c("p","model","g")]
vgenic$arch = "genic"
vgenic = vgenic[, .(model, arch, g, p, vg)]

  
vg = fread(F("data/ldsc/1kg-ref-hg38/admix/admix_all.vg"))
vg.summary = vg[, .(vg = mean(var)),
                by = c("model","arch","g","trait","p")]
vg.summary = vg.summary[trait == "gvalue"]
vg.summary$trait = NULL

vg.summary = rbind(vg.summary, vgenic)

# vg.summary$ancestry = "No correction"
# vgenic3$ancestry = "Ancestry correction"
# vg.summary3 = rbind(vg.summary, vgenic3)

vg.summary$model = factor(vg.summary$model, levels = c("HI","CGF"))
vg.summary$arch = factor(vg.summary$arch, levels = c("max","min","genic"))

vg.summary2 = vg.summary[arch == "genic"]
vg.summary$ancestry = "No correction"
vg.summary2$ancestry = "Ancestry correction"
vg.summary3 = rbind(vg.summary, vg.summary2)
vg.summary3$ancestry = factor(vg.summary3$ancestry, levels = c("No correction","Ancestry correction"))


plt_greml1 = ggplot()+
  geom_line(data = greml.summary[quantity == "V(G)" & ancestry == "No correction"],
            aes(g, estimate, color = arch), 
            show.legend = FALSE)+
  geom_ribbon(data =greml.summary[quantity == "V(G)" & ancestry == "No correction"],
              aes(x = g, ymin = l.ci, ymax = u.ci, fill = arch), alpha = 0.1, 
              show.legend = FALSE)+
  geom_line(data = vg.summary3[ancestry == "No correction"],
            aes(g, vg, color = arch), linetype = "dashed")+
  facet_grid(p ~ model, labeller = labeller(.rows = label_both), 
               scales = "free")+
  theme_classic()+
  theme(strip.background.x = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5))+
  labs(x = "t (generations)", y = bquote(hat(sigma)[u]^2),
       color = "Trait", title = "No correction")+
  scale_color_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing","Genic"))+
  scale_fill_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing","Genic"))


plt_greml2 = ggplot()+
  geom_line(data = greml.summary[quantity == "V(G)" & ancestry == "Ancestry correction"],
            aes(g, estimate, color = arch), 
            show.legend = FALSE)+
  geom_ribbon(data =greml.summary[quantity == "V(G)" & ancestry == "Ancestry correction"],
              aes(x = g, ymin = l.ci, ymax = u.ci, fill = arch), alpha = 0.1, 
              show.legend = FALSE)+
  geom_line(data = vg.summary3[arch == "genic"],
            aes(g, vg), linetype = "dashed", 
            color = "grey")+
  facet_nested(p ~ model, labeller = labeller(.rows = label_both))+
  theme_classic()+
  theme(strip.background.x = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5))+
  labs(x = "t (generations)", y = bquote(hat(sigma)[u]^2),
       color = "Trait", title = "Ancestry correction")+
  scale_color_manual(values = c('#f4a582','#92c5de',"grey"), 
                     labels = c("Divergent", "Stabilizing","Genic"))+
  scale_fill_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing","Genic"))


he1 = fread(F("data/ldsc/1kg-ref-hg38/admix/he/admix_all.HEreg"))
colnames(he1) = c("model","arch","g","trait","p","rep","type","lab")
he1 = he1[, c("estimate","se_ols","se_jk","p_ols","p_jk") := tstrsplit(lab,split = "\\s+", keep = 2:6, type.convert = as.numeric)]
he1$lab = NULL
he1[trait == "g", trait := "gvalue"]
he1 = merge(he1, vg, by = c("model","arch","g","trait","p","rep"))
he1[, est.vg := estimate*var]

he1.summary = he1[type == 1, .(est.vg = mean(est.vg), 
                               l.ci = quantile(est.vg, probs = 0.025), 
                               u.ci = quantile(est.vg, probs = 0.975)), 
                  by = c("model","arch","g","trait","p")]

he1.summary = he1.summary[trait == "y"]
he1.summary$trait = NULL

he2 = fread(F("data/ldsc/1kg-ref-hg38/admix/mmhe/admix_all.mmhe.h2q"))

colnames(he2) = c("model","arch","g","p","rep","estimates")
he2[, c("vg1","vg2","ve") := tstrsplit(estimates, split = " ", type.convert = as.numeric)]
he2$estimates = NULL
he2.summary = he2[, .(est.vg = mean(vg1), 
                               l.ci = quantile(vg1, probs = 0.025), 
                               u.ci = quantile(vg1, probs = 0.975)), 
                  by = c("model","arch","g","p")]

he1.summary$ancestry = "No correction"
he2.summary$ancestry = "Ancestry correction"

he.summary = rbind(he1.summary, he2.summary)

he.summary$model = factor(he.summary$model, levels = c("HI","CGF"))
he.summary$ancestry = factor(he.summary$ancestry, levels = c("No correction","Ancestry correction"))


plt_he1 = ggplot()+
  geom_line(data = he.summary[ancestry == "No correction"],
            aes(g, est.vg, color = arch), show.legend = FALSE)+
  geom_ribbon(data = he.summary[ancestry == "No correction"],
              aes(x = g, ymin = l.ci, ymax = u.ci, fill = arch), alpha = 0.1, 
              show.legend = FALSE)+
  geom_line(data = vg.summary3,
            aes(g, vg, color = arch), linetype = "dashed")+
  facet_nested(p~model, labeller = labeller(.rows = label_both))+
  theme_classic()+
  theme(strip.background.x = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5))+
  labs(x = "t (generations)", y = bquote(hat(sigma)[u]^2),
       color = "Trait", title = "No correction")+
  scale_color_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing", "Genic"))+
  scale_fill_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing","Genic"))

plt_he2 = ggplot()+
  geom_line(data = he.summary[ancestry == "Ancestry correction"],
            aes(g, est.vg, color = arch), show.legend = FALSE)+
  geom_ribbon(data = he.summary[ancestry == "Ancestry correction"],
              aes(x = g, ymin = l.ci, ymax = u.ci, fill = arch), alpha = 0.1, 
              show.legend = FALSE)+
  geom_line(data = vg.summary3[arch == "genic"],
            aes(g, vg), color = "grey", linetype = "dashed")+
  facet_nested(p~model, labeller = labeller(.rows = label_both))+
  theme_classic()+
  theme(strip.background.x = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5))+
  labs(x = "t (generations)", y = bquote(hat(sigma)[u]^2),
       color = "Trait", title = "Ancestry correction")+
  scale_color_manual(values = c('#f4a582','#92c5de',"grey"), 
                     labels = c("Divergent", "Stabilizing", "Genic"))+
  scale_fill_manual(values = c('#f4a582','#92c5de',"grey"), 
                    labels = c("Divergent", "Stabilizing","Genic"))

plt_greml = wrap_elements((plt_greml1 + plt_greml2) + plot_layout(guides = "collect") + plot_annotation(title = "a. GREML"))

plt_he = wrap_elements((plt_he1 + plt_he2) + plot_layout(guides = "collect") + plot_annotation(title = "b. HE regression"))


plt_combined = plt_greml / plt_he
ggsave(F("plots/plt_hapgen_greml_he.pdf"), 
       plt_combined,
       height = 10, width = 10)



