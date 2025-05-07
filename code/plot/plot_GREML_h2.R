#Plot GREML h2 results
library(tidyverse)

# load data
filename="admix_greml_h2_CI_P0_P9_wwo_ganc.txt"
df_CI=read.table(filename, header=T)

#get models separated
df_HI_CI <- df_CI %>% filter(model == "HI")
df_CGF_CI <- df_CI %>% filter(model == "CGF")

#merge with expected values
exp <- fread("admix_sim_expectations_02132025.txt", header = T)
exp_CGF <- exp %>% filter(model == "CGF")
exp_HI <- exp %>% filter (model == "HI")

#rename colnames for cov and t
names(exp_CGF)[names(exp_CGF) == 'arch'] <- 'cov'
names(exp_HI)[names(exp_HI) == 'arch'] <- 'cov'
names(exp_CGF)[names(exp_CGF) == 'time'] <- 't'
names(exp_HI)[names(exp_HI) == 'time'] <- 't'

#merge exp with data
df_HI_CI <- merge(df_HI_CI, exp_HI, by = c("t", "P", "cov"))
df_CGF_CI <- merge(df_CGF_CI, exp_CGF, by = c("t", "P", "cov"))

#save final files
write.table(df_HI_CI, "admix_greml_h2_HI_CI_exp.txt", sep = '\t',
            row.names = F, col.names = T, quote = F)
write.table(df_CGF_CI, "admix_greml_h2_CGF_CI_exp.txt", sep = '\t',
            row.names = F, col.names = T, quote = F)

# A function factory for getting integer y-axis values.
integer_breaks <- function(n = 5, ...) {
  fxn <- function(x) {
    breaks <- floor(pretty(x, n, ...))
    names(breaks) <- attr(breaks, "labels")
    breaks
  }
  return(fxn)
}


# plot gcta estimate and expected 
fig4A=function(data, yobs, ylab, 
               CIl, CIr, title, model,
               legend.position="right"){
  library(ggplot2)
  p <- ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0, #remove the boarder
                aes(x=t, 
                    ymin = CIl, ymax = CIr,
                    group=interaction(P, cov),
                    fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color = "black",
              aes(x=t, y = 0.8, 
                  linetype = "exp",
                  group=interaction(P, cov))) +
    
    # scale_y_log10(limits=c(0.65, 0.82)) +
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(standard)", "h2 = 0.8")) +
    scale_colour_manual("", 
                        values = c('#92c5de','#053061',
                                   '#f4a582','#67001f') ,
                        labels = c("P=0", "P=0.9", 
                                   "P=0", "P=0.9"
                        )) +
    scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                      )) +
    theme_classic() +
    xlab("t") +
    ylab(ylab)  + 
    ggtitle(title) +
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none",# no show color legend
           linetype = guide_legend(order = 2, reverse = T)
    )
  # remove y-axis labels if model == "CGF"
  if (model == "CGF") {
    p <- p + theme(axis.title.y = element_blank(),
                   axis.text.y = element_blank(),
                   axis.ticks.y = element_blank())
  }
  return(p)
}



HIa_wo=fig4A(data=df_HI_CI, 
             yobs = df_HI_CI$h2_standard.mean, 
             ylab = expression(h[GREML]^2),
             CIl = df_HI_CI$h2_standard.CI95l,
             CIr = df_HI_CI$h2_standard.CI95r,
             title = "HI", model = "HI",
             legend.position = "none") 

print(HIa_wo)

CGFa_wo=fig4A(data=df_CGF_CI, 
              yobs = df_CGF_CI$h2_standard.mean, 
              ylab = expression(h[GREML]^2),
              CIl = df_CGF_CI$h2_standard.CI95l,
              CIr = df_CGF_CI$h2_standard.CI95r,
              title = "CGF", model = "CGF",
              legend.position = "right") 
print(CGFa_wo)

HIa_wganc=fig4A(data=df_HI_CI, 
                yobs = df_HI_CI$h2_standard_ganc.mean, 
                ylab = expression(h[GREML]^2),
                CIl = df_HI_CI$h2_standard_ganc.CI95l,
                CIr = df_HI_CI$h2_standard_ganc.CI95r,
                title = "HI", model = "HI",
                legend.position = "none") 
print(HIa_wganc)

CGFa_wganc=fig4A(data=df_CGF_CI, 
                 yobs = df_CGF_CI$h2_standard_ganc.mean,
                 ylab = expression(h[GREML]^2),
                 CIl = df_CGF_CI$h2_standard_ganc.CI95l,
                 CIr = df_CGF_CI$h2_standard_ganc.CI95r,
                 title = "CGF", model = "CGF",
                 legend.position = "right") 
print(CGFa_wganc)


fig4B=function(data, yobs, CIl, CIr, model,
               legend.position="right"){
  library(ggplot2)
  p <- ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
                aes(x=t, 
                    ymin = CIl, ymax = CIr,
                    group=interaction(P, cov),
                    fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color = "black",
              aes(x=t, y = 0.8, 
                  linetype = "exp",
                  group=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    
    # ylim(c(0.93, 1.2))+
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(V(x) scaled)",
                                     "h2 = 0.8")) +
    scale_colour_manual("", 
                        values = c('#92c5de','#053061',
                                   '#f4a582','#67001f') ,
                        labels = c("P=0", "P=0.9", 
                                   "P=0", "P=0.9"
                        )) +
    scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                      )) +
    theme_classic() +
    xlab("t") +
    ylab(expression(h[GREML]^2))  + 
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none", # no show color legend
           linetype = guide_legend(order = 2, reverse = T
           ) )
  # remove y-axis labels if model == "CGF"
  if (model == "CGF") {
    p <- p + theme(axis.title.y = element_blank(),
                   axis.text.y = element_blank(),
                   axis.ticks.y = element_blank())
  }
  return(p)
}


HIb_wo=fig4B(data=df_HI_CI, 
             yobs = df_HI_CI$h2_varX.mean,
             CIl = df_HI_CI$h2_varX.CI95l,
             CIr = df_HI_CI$h2_varX.CI95r,
             legend.position = "none",
             model = "HI")
print(HIb_wo)

CGFb_wo=fig4B(data=df_CGF_CI, 
              yobs = df_CGF_CI$h2_varX.mean,
              CIl = df_CGF_CI$h2_varX.CI95l,
              CIr = df_CGF_CI$h2_varX.CI95r,
              legend.position = "right",
              model = "CGF")
print(CGFb_wo)

HIb_wganc=fig4B(data=df_HI_CI, 
                yobs = df_HI_CI$h2_varX_ganc.mean,
                CIl = df_HI_CI$h2_varX_ganc.CI95l,
                CIr = df_HI_CI$h2_varX_ganc.CI95r,
                legend.position = "none",
                model = "HI")
print(HIb_wganc)

CGFb_wganc=fig4B(data=df_CGF_CI, 
                 yobs = df_CGF_CI$h2_varX_ganc.mean,
                 CIl = df_CGF_CI$h2_varX_ganc.CI95l,
                 CIr = df_CGF_CI$h2_varX_ganc.CI95r,
                 legend.position = "right",
                 model = "CGF")
print(CGFb_wganc)


# LD matrix scaled results panel C
fig4C=function(data, yobs, CIl, CIr, ylab, legend.position="right", model){
  library(ggplot2)
  p <- ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
                aes(x=t, 
                    ymin = CIl, ymax = CIr,
                    group=interaction(P, cov),
                    fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color = "black",
              aes(x=t, y = 0.8, 
                  linetype = "exp",
                  group=interaction(P, cov))) +
    ylim(c(0.79, 0.81))+
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(LD scaled)",
                                     "h2 = 0.8"
                          )) +
    scale_colour_manual("", 
                        values = c('#92c5de','#053061',
                                   '#f4a582','#67001f') ,
                        labels = c("P=0", "P=0.9", 
                                   "P=0", "P=0.9"
                        )) +
    scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                      )) +
    theme_classic() +
    xlab("t") +
    ylab(ylab)  + 
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none",# no show color legend
           linetype = guide_legend(order = 2, reverse = T) 
    )
  # remove y-axis labels if model == "CGF"
  if (model == "CGF") {
    p <- p + theme(axis.title.y = element_blank(),
                   axis.text.y = element_blank(),
                   axis.ticks.y = element_blank())
  }
  return(p)
}



HIc_wo=fig4C(data=df_HI_CI, 
             yobs = df_HI_CI$h2_ld.mean,
             CIl = df_HI_CI$h2_ld.CI95l,
             CIr = df_HI_CI$h2_ld.CI95r,
             ylab = expression(h[GREML]^2),
             legend.position = "none",
             model = "HI")
print(HIc_wo)

CGFc_wo=fig4C(data=df_CGF_CI, 
              yobs = df_CGF_CI$h2_ld.mean,
              CIl = df_CGF_CI$h2_ld.CI95l,
              CIr = df_CGF_CI$h2_ld.CI95r,
              ylab = expression(h[GREML]^2),
              legend.position = "right",
              model = "CGF") 
print(CGFc_wo)


fig4C_w=function(data, yobs, CIl, CIr, ylab, legend.position="right", model){
  library(ggplot2)
  p <- ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
                aes(x=t, 
                    ymin = CIl, ymax = CIr,
                    group=interaction(P, cov),
                    fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color = "black",
              aes(x=t, y = 0.8, 
                  linetype = "exp",
                  group=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    # scale_y_log10(limits=c(0.89, 1.1)) +
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(LD scaled)",
                                     "h2 = 0.8")) +
    scale_colour_manual("", 
                        values = c('#92c5de','#053061',
                                   '#f4a582','#67001f') ,
                        labels = c("P=0", "P=0.9", 
                                   "P=0", "P=0.9"
                        )) +
    scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                      )) +
    theme_classic() +
    xlab("t") +
    ylab(ylab)  + 
    #ggtitle(title) +
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none",# no show color legend
           linetype = guide_legend(order = 2, reverse = T)#, 
    )
  # remove y-axis labels if model == "CGF"
  if (model == "CGF") {
    p <- p + theme(axis.title.y = element_blank(),
                   axis.text.y = element_blank(),
                   axis.ticks.y = element_blank())
  }
  return(p)
}

HIc_wganc=fig4C_w(data=df_HI_CI, 
                  yobs = df_HI_CI$h2_ld_ganc.mean, 
                  CIl = df_HI_CI$h2_ld_ganc.CI95l,
                  CIr = df_HI_CI$h2_ld_ganc.CI95r,
                  ylab = expression(h[GREML]^2),
                  legend.position = "none",
                  model = "HI") 
print(HIc_wganc)

CGFc_wganc=fig4C_w(data=df_CGF_CI, 
                   yobs = df_CGF_CI$h2_ld_ganc.mean, 
                   CIl = df_CGF_CI$h2_ld_ganc.CI95l,
                   CIr = df_CGF_CI$h2_ld_ganc.CI95r,
                   ylab = expression(h[GREML]^2),
                   legend.position = "right",
                   model = "CGF")
print(CGFc_wganc)



#color legend only
fig4color=function(data){
  library(ggplot2)
  ggplot() +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = h2_standard.mean,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, 
              aes(x=t, y = exp.total, 
                  linetype = "exp",
                  group=interaction(P, cov),
                  color=interaction(P, cov))) +
    # scale_y_log10(limits=c(0.9, 2.1)) +
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(standard)",
                                     "Expected")) +
    scale_colour_manual("", 
                        values = c('#92c5de','#053061',
                                   '#f4a582','#67001f') ,
                        labels = c("P=0", "P=0.9", 
                                   "P=0", "P=0.9"
                        )) +
    theme_classic() +
    xlab("t") +
    ylab(expression(h[GREML]^2))  + 
    theme(aspect.ratio = 1, 
          legend.position = "bottom", #hide legend for HI
          text = element_text(size = 12)
    ) + 
    guides(color =  guide_legend(order = 1, nrow=2, 
                                 byrow = T, reverse = T,
                                 override.aes = list(linewidth = 2)),  # thicken the line in legend
           linetype = "none" 
    )}
HI_color=fig4color(df_HI_CI)



# GREML h2 wo and wganc
library(ggpubr)
plt_wo=ggarrange(HIa_wo, CGFa_wo, 
                 HIb_wo, CGFb_wo, 
                 HIc_wo, CGFc_wo,
                 ncol = 2, nrow = 3, 
                 labels = c("a", "", "b", "","c", ""),
                 label.x = 0.1,
                 label.y = 0.98,
                 hjust = -0.5,
                 align = c("h")) %>%
  ggpubr::annotate_figure(plt_wo, 
                          top = text_grob("No correction\n", size = 22))

plt_wganc=ggarrange(HIa_wganc, CGFa_wganc, 
                    HIb_wganc, CGFb_wganc, 
                    HIc_wganc, CGFc_wganc,
                    ncol = 2, nrow = 3, 
                    labels = c("d", "", "e", "", "f", ""),
                    label.x = 0.1,
                    label.y = 0.98,
                    hjust = -0.5,
                    align = c("h")) %>% 
  ggpubr::annotate_figure(plt_wganc, 
                          top = text_grob("Ancestry correction\n", size = 22))

# add space between these two
plt=ggarrange(plt_wo, NULL, plt_wganc, 
                ncol = 3, widths = c(1, 0, 1),
                align = "v") %>% # to move the legend closer 
  gridExtra::grid.arrange(ggpubr::get_legend(HI_color), 
                          heights = unit(c(8.2, 0.8), "in"))

#add to legend
annotated_plot <- ggdraw(plt) +
  draw_text("Divergent", x = 0.44, y = 0.063, hjust = 1, size = 10) +
  draw_text("Stabilizing", x = 0.44, y = 0.025, hjust = 1, size = 10) 

annotated_plot

ggsave("FigureS3_greml_h2.pdf", plot=annotated_plot,
       width = 12.5, height = 9, dpi = 300, units = "in", device='pdf')
