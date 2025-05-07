
library(ggplot2)
library(data.table)
library(patchwork)
library(ggh4x)

F = rprojroot::is_rstudio_project$make_fix_file()

#read genetic variance computed previously - for reference
vg = fread(F("data/ldsc/1kg-ref-hg38/admix/admix_all.vg"))
vg = vg[trait == "gvalue"]
vg$trait = NULL
colnames(vg)[c(2,6)] = c("trait","vg")

#function to read heritability estimates from LDSC for a model and trait
read.h2 = function(model, trait){
  h2 = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/h2/admix_",model,"_all.",trait,".pca.g.cov.log", sep = "")))
  h2 = h2[, c(1:3,8,9)]
  colnames(h2) = c("p","g","rep","ghat","se1")
  h2[, se := gsub("^.||.$", "", se1)]
  h2$se = as.numeric(h2$se)
  h2$se1 = NULL
  h2[, trait :=trait]
  h2[, model := model]
  return(h2)
             
}


#for each trait and model, read the LDSC h2 and store in a list
pvector = c(0.01, 0.05, 0.1)
trait.vector = c("max","min")
model.vector = c("HI","CGF")

arr2 = list()
for(tx in 1:2){
  for(mx in 1:2){
    lname = paste(trait.vector[tx], "_",model.vector[mx], sep = "")
    arr2[[lname]] = read.h2(model.vector[mx], trait.vector[tx])
  }
}

#convert the list with h2 tables to data.frame

h2 = dplyr::bind_rows(arr2, .id = "trait_model")
# h2.summary = h2[, .(mghat = mean(ghat), l.ci = quantile(ghat, probs = 0.025), u.ci = quantile(ghat, probs = 0.975)), by = c("g","p","trait","model")]
# 
# h2.summary[trait == "max", arch := "Divergent"]
# # h2.summary[trait == "med", arch := "Neutral"]
# h2.summary[trait == "min", arch := "Stabilizing"]
# 
# h2.summary$model = factor(h2.summary$model, levels = c("HI","CGF"))
# prs.summary2$model = factor(prs.summary2$model, levels = c("HI","CGF"))

# prs.summary2[, quantity := "Vg"]
# h2.summary[, quantity := "Estimate"]
# 
# colnames(prs.summary2)[5] = "value"
# colnames(h2.summary)[5] = "value"
# 
# vg.dat = rbind(prs.summary2, h2.summary)

#function to read genomic inflation (GC)
read.gc = function(model,trait){
  gc = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/h2/admix_",model,"_all.",trait,".pca.g.GC", sep = "")))
  gc = gc[,c(1:3,6)]
  colnames(gc) = c("p","g","rep","GC")
  gc$GC = as.numeric(gc$GC)
  gc$trait = trait
  gc$model = model
  return(gc)
}

#for each trait and model, reach GC and convert to data.frame
arr2 = list()
for(tx in 1:2){
  for(mx in 1:2){
    lname = paste(trait.vector[tx], "_",model.vector[mx], sep = "")
    arr2[[lname]] = read.gc(model.vector[mx], trait.vector[tx])
  }
}
gc = dplyr::bind_rows(arr2, .id = "g_p_rep")
# gc.summary = gc[, .(mgc = mean(GC), l.ci = quantile(GC, probs = 0.025), u.ci = quantile(GC, probs = 0.975)), by = c("g","p","trait","model")]

#function to read LDSC intercept
read.intercept = function(model,trait){
  intercept = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/h2/admix_",model,"_all.",trait,".pca.g.intercept", sep = "")))
  intercept = intercept[,c(1:3,5)]
  colnames(intercept) = c("p","g","rep","intercept")
  intercept$intercept = as.numeric(intercept$intercept)
  intercept$trait = trait
  intercept$model = model
  return(intercept)
}

#for each trait and model, reach LDSC intercept and convert to data.frame
arr2 = list()
for(tx in 1:2){
  for(mx in 1:2){
    lname = paste(trait.vector[tx], "_",model.vector[mx], sep = "")
    arr2[[lname]] = read.intercept(model.vector[mx], trait.vector[tx])
  }
}

intercept = dplyr::bind_rows(arr2, .id = "g_p_rep")
# intercept.summary = intercept[, .(mgc = mean(intercept), l.ci = quantile(intercept, probs = 0.025), u.ci = quantile(intercept, probs = 0.975)), by = c("g","p","trait","model")]


# gc.summary[trait == "max", arch := "Divergent"]
# gc.summary[trait == "med", arch := "Neutral"]
# gc.summary[trait == "min", arch := "Stabilizing"]

# intercept.summary[trait == "max", arch := "Divergent"]
# intercept.summary[trait == "med", arch := "Neutral"]
# intercept.summary[trait == "min", arch := "Stabilizing"]

# gc.summary$model = factor(gc.summary$model, levels = c("HI","CGF"))
# intercept.summary$model = factor(intercept.summary$model, levels = c("HI","CGF"))

# gc.summary[, quantity := "GC"]
# intercept.summary[, quantity := "Estimate"]

# colnames(gc.summary)[5] = "value"
# colnames(intercept.summary)[5] = "value"

# gc.summary[,value := value]
# gc.summary[, l.ci := l.ci]
# gc.summary[, u.ci := u.ci]

# gc.dat = rbind(gc.summary, intercept.summary)

#read mean chi2 (x2)
read.chi2 = function(model,trait){
  x2dat = fread(F(paste("data/ldsc/1kg-ref-hg38/admix/h2/admix_",model,"_all.",trait,".pca.g.chi2", sep = "")))
  x2dat = x2dat[,c(1:3,6)]
  colnames(x2dat) = c("p","g","rep","x2")
  x2dat$x2 = as.numeric(x2dat$x2)
  x2dat$trait = trait
  x2dat$model = model
  return(x2dat)
}

arr2 = list()
for(tx in 1:2){
  for(mx in 1:2){
    lname = paste(trait.vector[tx], "_",model.vector[mx], sep = "")
    arr2[[lname]] = read.chi2(model.vector[mx], trait.vector[tx])
  }
}

x2 = dplyr::bind_rows(arr2, .id = "g_p_rep")
# x2.summary = x2[, .(mx2 = mean(x2), l.ci = quantile(x2, probs = 0.025), 
                           # u.ci = quantile(x2, probs = 0.975)), by = c("g","p","trait","model")]

#merge all tables together for each trait, rep, model, and generation
dat = merge(gc, x2, by = c("g_p_rep","p","g","rep","trait","model"))
dat = merge(dat, intercept, by = c("g_p_rep","g","p","rep","trait","model"))
dat = merge(dat, vg, by = c("g","p","trait","model","rep"))
dat = merge(dat, h2, by = c("g","p","trait","model","rep"))
dat$g_p_rep = NULL
dat$trait_model = NULL
mdat = melt(dat, id.vars = c("g","p","trait","model","rep"))

#for each parameter, estimate the mean and confidence intervals 
dat.summary = mdat[, .(mean = mean(value), 
                        lci = quantile(value, probs = 0.025),
                        uci = quantile(value, probs = 0.975)),
                    by = c("g","p","trait","model", "variable")]

dat.summary$model = factor(dat.summary$model, levels = c("HI","CGF"))

#plot the estimated genetic variance
plt.vg = ggplot()+
  geom_hline(yintercept = 1, linetype = "dotted", alpha = 0.2)+
  geom_line(data = dat.summary[p==0.01 & variable == "ghat"],
            aes(g, mean, color = trait, linetype = "ghat"))+
  geom_line(data = dat.summary[p==0.01 & variable == "vg"],
            aes(g, mean, color = trait, linetype = "vg"))+
  geom_ribbon(data = dat.summary[p==0.01 & variable == "ghat"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  geom_ribbon(data = dat.summary[p==0.01 & variable == "vg"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  facet_grid(trait ~ model, 
             labeller = as_labeller(c("max" = "Divergent", "min" = "Stabilizing",
                                      "HI" = "HI","CGF" = "CGF")))+
  theme_classic()+
  theme(legend.position ="bottom", 
        legend.title.position = "top", 
        legend.direction = "vertical",
        strip.background = element_blank(),
        strip.text.y = element_blank())+
  scale_linetype_manual("Line", values = c('ghat' = 'solid', 'vg' = 'dashed'), 
                        labels = c('ghat' = "Estimate",'vg' = "True"), 
                        name = "Quantity")+
  labs(x = "t", y = bquote(V[g] ~ "(True or Estimated)"), color = "Trait", linetype = "Quantity")+
  scale_color_manual(values = c("#f4a582", "#92c5de"), 
                     labels = c('min' = "Stabilizing","max" = "Divergent"))+
  scale_fill_manual(values = c("#f4a582", "#92c5de"))

#plot for genomic control
plt.gc = ggplot()+
  geom_hline(yintercept = 1, linetype = "dotted", alpha = 0.2)+
  geom_line(data = dat.summary[p==0.01 & variable == "intercept"],
            aes(g, mean, color = trait, linetype = "intercept"))+
  geom_line(data = dat.summary[p==0.01 & variable == "x2"],
            aes(g, mean, color = trait, linetype = "x2"))+
  geom_ribbon(data = dat.summary[p==0.01 & variable == "intercept"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  geom_ribbon(data = dat.summary[p==0.01 & variable == "x2"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  facet_grid(trait ~ model, 
             labeller = as_labeller(c("max" = "Divergent", "min" = "Stabilizing",
                                      "HI" = "HI","CGF" = "CGF")))+
  theme_classic()+
  theme(legend.position ="bottom", 
        legend.title.position = "top", 
        legend.direction = "vertical",
        strip.background = element_blank(),
        strip.text.y = element_blank())+
  scale_linetype_manual("Line", values = c('intercept' = 'dashed', 'x2' = 'solid'), 
                        labels = c('intercept' = bquote(lambda[ldsc]),'x2' = bquote(E(chi^2))), 
                        name = "Quantity")+
  labs(x = "t", y = bquote(E(chi^2)~"or"~lambda[ldsc]), color = "Trait", linetype = "Quantity")+
  scale_color_manual(values = c("#f4a582", "#92c5de"), 
                     labels = c('min' = "Stabilizing","max" = "Divergent"))+
  scale_fill_manual(values = c("#f4a582", "#92c5de"))


#make a single plot with estimated vg and gc
plt_all = plt.vg + plt.gc + plot_annotation(tag_levels = 'a') & theme(plot.tag = element_text(size = 14, face = "bold", hjust=0, vjust=0)) 



ggsave(F("plots/plt_ldsc_main_poster.pdf"),plt_all, height = 5, width = 7)


#supplementary plot for all p=0.01, 0.05, 0.1
plt_all_p = ggplot()+
  geom_hline(yintercept = 1, linetype = "dotted", alpha = 0.2)+
  geom_line(data = dat.summary[variable == "ghat"],
            aes(g, mean, color = trait, linetype = "ghat"))+
  geom_line(data = dat.summary[variable == "vg"],
            aes(g, mean, color = trait, linetype = "vg"))+
  geom_ribbon(data = dat.summary[variable == "ghat"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  geom_ribbon(data = dat.summary[variable == "vg"], 
              aes(g, ymin = lci, ymax = uci, fill = trait), alpha = 0.2,
              show.legend = FALSE)+
  facet_nested(trait + p ~ model, 
             labeller = as_labeller(c("max" = "Divergent", "min" = "Stabilizing",
                                      "HI" = "HI","CGF" = "CGF", 
                                      "0.01" = "0.01", "0.05" = "0.05", "0.1" = "0.1"), 
                                    label_both))+
  theme_classic()+
  theme(legend.position ="bottom", 
        legend.title.position = "top", 
        legend.direction = "vertical",
        strip.background.x = element_blank(),
        strip.text = element_text(face = "bold"))+
  scale_linetype_manual("Line", values = c('ghat' = 'solid', 'vg' = 'dashed'), 
                        labels = c('ghat' = "Estimate",'vg' = "True"), 
                        name = "Quantity")+
  labs(x = "t", y = bquote(V[g]), color = "Trait", linetype = "Quantity")+
  scale_color_manual(values = c("#f4a582", "#92c5de"), 
                     labels = c('min' = "Stabilizing","max" = "Divergent"))+
  scale_fill_manual(values = c("#f4a582", "#92c5de"))

ggsave(F("plots/plt_ldsc_supp_all.pdf"),plt_all_p, height = 7, width = 4)




