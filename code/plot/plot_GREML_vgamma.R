# plot GREML estimated vgamma: genetic variance due to local ancestry

# load files
library(data.table)
filename="admix_greml_vgamma_CI_P0_P9_w-wo_ganc.txt"
df_CI=read.table(filename, header=T)

#get models separated
df_HI_CI <- df_CI %>% filter(model == "HI")
df_CGF_CI <- df_CI %>% filter(model == "CGF")

#merge with expected values
exp_HI <- fread("admix_HI_vg_vgamma.txt", header = T)
exp_CGF <- fread("admix_CGF_vg_vgamma.txt", header = T)
exp_HI_tg <- exp_HI %>% filter(theta == "0.5", gen == "20", P %in% c(0,0.9))
exp_CGF_tg <- exp_CGF %>% filter(theta == "0.5", gen == "20", P %in% c(0,0.9))

#merge exp with data
df_HI_CI <- merge(exp_HI_tg, df_HI_CI, by = c("t", "P", "cov"), all.x = T)
df_CGF_CI <- merge(exp_CGF_tg, df_CGF_CI, by = c("t", "P", "cov"), all.x = T)


# function to plot 
# expectation VS standard scaled GCTA results
fig4A=function(data, yobs, CIl, CIr, title, legend.position="right", model){
  library(ggplot2)
p <-ggplot() +
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
    geom_line(data=data, linewidth=0.9, 
              aes(x=t, y = va.term2+va.term3+va.term4, 
                  linetype = "exp",
                  group=interaction(P, cov),
                  color=interaction(P, cov))) +
    ylim(c(-0.05, 1.20))+
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(standard)",
                                     expression(V[gamma]))) +
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
    ylab(expression(hat(sigma)[v]^2))  + 
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


# standard scale gcta vgamma vs expected (1.2)+(1.3)
fig4B=function(data, yobs, CIl, CIr, legend.position="right", model){
  library(ggplot2)
p <-ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
              aes(x=t, 
                  ymin = CIl, ymax = CIr,
                  group=interaction(P, cov),
                fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color="black", 
              aes(x=t, y = va.term2,
                  linetype = "exp",
                  group=interaction(P, cov)
              )) + 
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,
                  linetype = "obs",
                  group=interaction(P, cov),
                  color=interaction(P, cov))) +
    ylim(c(-0.05, 0.15))+
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c("Estimated\n(standard)",
                                     "(1.2)")) + 
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
    ylab(expression(hat(sigma)[v]^2))  + 
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none",
           linetype = guide_legend(order = 1, reverse = T
           ) )
    # remove y-axis labels if model == "CGF"
    if (model == "CGF") {
      p <- p + theme(axis.title.y = element_blank(),
                     axis.text.y = element_blank(),
                     axis.ticks.y = element_blank())
    }
  return(p)
}


# (1.2)+(1.3) vs GRMvarX scaled vgamma gcta estimates

fig4C=function(data, yobs, CIl, CIr, legend.position="right", model){
  library(ggplot2)
p <-  ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
              aes(x=t, 
                  ymin = CIl, ymax = CIr,
                  group=interaction(P, cov),
                fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, color="black", 
              aes(x=t, y = va.term2+va.term3, 
                  linetype = "exp",
                  group=interaction(P, cov)
              )) +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = yobs,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    # label P
    annotate(geom = "text", x=16, y=0.22, label="P=0.9") +
    annotate(geom = "text", x=16, y=0.05, label="P=0") +
    ylim(c(0, 0.25))+
    scale_linetype_manual("", 
                          breaks = c("obs",   "exp"),
                          values = c("solid",  "11"),
                          labels = c(#bquote("Estimated (" ~ V[gamma] ~ "scaled)"),
                                     bquote(atop("Estimated", "(" ~ V[gamma] ~ "scaled)")),
                                     # "Estimated\n(V[gamma]~scaled)",
                                    #  paste("Estimated\n(V(\u03B3) scaled)"),
                                     "(1.2)+(1.3)")) +
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
    ylab(expression(hat(sigma)[v]^2))  + 
    theme(aspect.ratio = 1, 
          plot.title = element_text(hjust = 0.5), # to center the title
          legend.position = legend.position, 
          legend.text.align = 0, #left align legend
          legend.key.height = unit(2.5, "lines"),
          text = element_text(size = 12),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')
    ) + 
    guides(color = "none", fill = "none",# no show color legend
           linetype = guide_legend(order = 2, reverse = T))
  # remove y-axis labels if model == "CGF"
  if (model == "CGF") {
    p <- p + theme(axis.title.y = element_blank(),
                   axis.text.y = element_blank(),
                   axis.ticks.y = element_blank())
  }
  return(p)
}


fig4D=function(data, yobs, CIl, CIr, legend.position="right", model){
  library(ggplot2)
p <-  ggplot() +
    geom_ribbon(data=data, alpha=0.2, linetype = 0,
            aes(x=t, 
                ymin = CIl, ymax = CIr,
                group=interaction(P, cov),
              fill=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, 
            aes(x=t, y = va.term2+va.term3+va.term4, 
                linetype = "exp",
                group=interaction(P, cov),
                color=interaction(P, cov))) +
  geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
            aes(x=t, y = yobs,                               
                linetype = "obs",
                group=interaction(P, cov), 
                color=interaction(P, cov))) +
  
  ylim(c(-0.05, 1.20))+
  scale_linetype_manual("", 
                       breaks = c("obs",   "exp"),
                       values = c("solid",  "11"),
                       labels = c("Estimated\n(LD scaled)",
                                  expression(V[gamma]))) +
  scale_colour_manual("", 
                     values = c('#92c5de','#053061',
                                '#f4a582','#67001f'),
  ) +
  scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                                 )) +
  theme_classic() +
  xlab("t") +
  ylab(expression(hat(sigma)[v]^2))  + 
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


fig4D_w=function(data, yobs, CIl, CIr, legend.position="right", model){
  library(ggplot2)
p <-  ggplot() +
  geom_ribbon(data=data, alpha=0.2, linetype = 0,
            aes(x=t, 
                ymin = CIl, ymax = CIr,
                group=interaction(P, cov),
              fill=interaction(P, cov))) +
  geom_line(data=data, linewidth=0.9, #color="black",
            aes(x=t, y = va.term2-va.term3, 
                linetype = "exp",
                group=interaction(P, cov),
                color=interaction(P, cov) #in order to keep this order
                )) +
  geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
            aes(x=t, y = yobs,                               
                linetype = "obs",
                group=interaction(P, cov), 
                color=interaction(P, cov))) +
    
    geom_line(data=data, linewidth=0.9, color="black", # cover it
            aes(x=t, y = va.term2-va.term3, 
                linetype = "exp",
                group=interaction(P, cov),
               # color=interaction(P, cov)
                )) +
     # label P
  annotate(geom = "text", x=16, y=0.015, label="P=0.9") +
  annotate(geom = "text", x=16, y=0.11, label="P=0") +
  ylim(c(-0.01, 0.15))+
  scale_linetype_manual("", 
                       breaks = c("obs",   "exp"),
                       values = c("solid",  "11"),
                       labels = c("Estimated\n(LD scaled)",
                                  "(1.2)-(1.3)")) +
  scale_colour_manual("", 
                     values = c('#92c5de','#053061',
                                '#f4a582','#67001f'),
  ) +
  scale_fill_manual("", 
                      values = c('#92c5de','#053061',
                                 '#f4a582','#67001f') ,
                      labels = c("P=0", "P=0.9", 
                                 "P=0", "P=0.9"
                                 )) +
  theme_classic() +
  xlab("t") +
  ylab(expression(hat(sigma)[v]^2))  + 
  theme(aspect.ratio = 1, 
        plot.title = element_text(hjust = 0.5), # to center the title
        legend.position = legend.position, 
        legend.text.align = 0, #left align legend
        text = element_text(size = 12),
        plot.margin = unit(c(0, 0, 0, 0), 'cm')
        ) + 
  guides(color = "none", fill = "none",
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


#color legend 
fig4color=function(data){
  library(ggplot2)
  ggplot() +
    geom_line(data=data, linewidth=0.9, alpha = 0.65, #transparent this line
              aes(x=t, y = vgamma_standard.mean,                               
                  linetype = "obs",
                  group=interaction(P, cov), 
                  color=interaction(P, cov))) +
    geom_line(data=data, linewidth=0.9, 
              aes(x=t, y = va.term2+va.term3+va.term4, 
                  linetype = "exp",
                  group=interaction(P, cov),
                  color=interaction(P, cov))) +
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
    ylab(expression(hat(sigma)[v]^2))  + 
    theme(aspect.ratio = 1, 
          legend.position = "bottom", #hide legend for HI
          text = element_text(size = 12)
    ) + 
    guides(color =  guide_legend(order = 1, nrow=2, 
                                 byrow = T, reverse = T,
                                 override.aes = list(linewidth = 2)),  # thicken the line in legend
           linetype = "none"
    )}

# plot
HI_color=fig4color(data=df_HI_CI)


HIa=fig4A(data=df_HI_CI, 
          yobs=df_HI_CI$vgamma_standard.mean, 
          CIl = df_HI_CI$vgamma_standard.CI95l,
          CIr = df_HI_CI$vgamma_standard.CI95r,
          title="HI", 
          legend.position = "none",
          model = "HI")
print(HIa)
CGFa=fig4A(data=df_CGF_CI, 
          yobs=df_CGF_CI$vgamma_standard.mean, 
          CIl = df_CGF_CI$vgamma_standard.CI95l,
          CIr = df_CGF_CI$vgamma_standard.CI95r, 
          title="CGF", model = "CGF")
print(CGFa)

HIb=fig4B(data=df_HI_CI,
          yobs=df_HI_CI$vgamma_standard.mean, 
          CIl = df_HI_CI$vgamma_standard.CI95l,
          CIr = df_HI_CI$vgamma_standard.CI95r,
          legend.position = "none",
          model = "HI")
print(HIb)

CGFb=fig4B(data=df_CGF_CI,
          yobs=df_CGF_CI$vgamma_standard.mean, 
          CIl = df_CGF_CI$vgamma_standard.CI95l,
          CIr = df_CGF_CI$vgamma_standard.CI95r,
          model = "CGF") 
print(CGFb)

HIc=fig4C(data=df_HI_CI, 
          yobs=df_HI_CI$vgamma_varX.mean, 
          CIl = df_HI_CI$vgamma_varX.CI95l,
          CIr = df_HI_CI$vgamma_varX.CI95r,
          legend.position = "none",
          model = "HI")
print(HIc)

CGFc=fig4C(data=df_CGF_CI,
          yobs=df_CGF_CI$vgamma_varX.mean, 
          CIl = df_CGF_CI$vgamma_varX.CI95l,
          CIr = df_CGF_CI$vgamma_varX.CI95r,
          model = "CGF")
print(CGFc)

HId=fig4D(data=df_HI_CI, 
          yobs=df_HI_CI$vgamma_ld.mean, 
          CIl = df_HI_CI$vgamma_ld.CI95l,
          CIr = df_HI_CI$vgamma_ld.CI95r,
          legend.position = "none",
          model = "HI")
print(HId)

CGFd=fig4D(data=df_CGF_CI,
          yobs=df_CGF_CI$vgamma_ld.mean, 
          CIl = df_CGF_CI$vgamma_ld.CI95l,
          CIr = df_CGF_CI$vgamma_ld.CI95r,
          model = "CGF")
print(CGFd)

# plot for gcta_wganc
HIa_w=fig4A(data=df_HI_CI, 
            yobs = df_HI_CI$vgamma_standard_ganc.mean,
            CIl = df_HI_CI$vgamma_standard_ganc.CI95l,
            CIr = df_HI_CI$vgamma_standard_ganc.CI95r,
            title="HI", 
            legend.position = "none",
            model = "HI")
print(HIa_w)
CGFa_w=fig4A(data=df_CGF_CI, 
            yobs = df_CGF_CI$vgamma_standard_ganc.mean,
            CIl = df_CGF_CI$vgamma_standard_ganc.CI95l,
            CIr = df_CGF_CI$vgamma_standard_ganc.CI95r,
            title="CGF", model = "CGF")
print(CGFa_w)

HIb_w=fig4B(data=df_HI_CI, 
            yobs = df_HI_CI$vgamma_standard_ganc.mean,
            CIl = df_HI_CI$vgamma_standard_ganc.CI95l,
            CIr = df_HI_CI$vgamma_standard_ganc.CI95r,
            legend.position = "none", model = "HI")
print(HIb_w)
CGFb_w=fig4B(data=df_CGF_CI,
            yobs = df_CGF_CI$vgamma_standard_ganc.mean,
            CIl = df_CGF_CI$vgamma_standard_ganc.CI95l,
            CIr = df_CGF_CI$vgamma_standard_ganc.CI95r,
            model = "CGF")
print(CGFb_w)

HIc_w=fig4C(data=df_HI_CI, 
            yobs = df_HI_CI$vgamma_varX_ganc.mean,
            CIl = df_HI_CI$vgamma_varX_ganc.CI95l,
            CIr = df_HI_CI$vgamma_varX_ganc.CI95r,
            legend.position = "none",
            model = "HI")
print(HIc_w)
CGFc_w=fig4C(data=df_CGF_CI,
            yobs = df_CGF_CI$vgamma_varX_ganc.mean,
            CIl = df_CGF_CI$vgamma_varX_ganc.CI95l,
            CIr = df_CGF_CI$vgamma_varX_ganc.CI95r,
            model = "CGF")
print(CGFc_w)

HId_w=fig4D_w(data=df_HI_CI, 
            yobs = df_HI_CI$vgamma_ld_ganc.mean,
            CIl = df_HI_CI$vgamma_ld_ganc.CI95l,
            CIr = df_HI_CI$vgamma_ld_ganc.CI95r,
            legend.position = "none",
            model = "HI")
print(HId_w)
CGFd_w=fig4D_w(data=df_CGF_CI,
            yobs = df_CGF_CI$vgamma_ld_ganc.mean,
            CIl = df_CGF_CI$vgamma_ld_ganc.CI95l,
            CIr = df_CGF_CI$vgamma_ld_ganc.CI95r,
            model = "CGF")
print(CGFd_w)

#combine plots
library(ggpubr)
plt_wo=ggarrange(HIa, CGFa, HIb, CGFb, HIc, CGFc, HId, CGFd,
                 ncol = 2, nrow = 4, 
                 labels = c("A", "", "B", "","C", "","D", ""),
                 label.x = 0.1,
                 label.y = 0.98,
                 hjust = -0.5,
                 align = c("h")) %>%
  ggpubr::annotate_figure(plt_wo, 
                          top = text_grob("No correction\n", size = 22)) 

plt_wganc=ggarrange(HIa_w, CGFa_w, HIb_w, CGFb_w, HIc_w, CGFc_w, HId_w, CGFd_w, 
              ncol = 2, nrow = 4, 
              labels = c("E", "", "F", "","G", "","H", ""),
              label.x = 0.1,
              label.y = 0.98,
              hjust = -0.5,
              align = c("h")) %>% 
  ggpubr::annotate_figure(plt_wganc, 
                          top = text_grob("Ancestry correction\n", size = 22)) 

# add space between these two
plt=ggarrange(plt_wo, NULL, plt_wganc, 
              ncol = 3, nrow = 1, 
             # labels = c("A", "B",  "C", "D"),
              widths = c(1,0,1),
              align = c("v")) %>% # to move the legend closer 
  gridExtra::grid.arrange(ggpubr::get_legend(HI_color), 
                          #heights = unit(c(250, 10), "mm")
                          heights = unit(c(9, 0.8), "in")
                          ) 

annotated_plot <- cowplot::ggdraw(plt) +
  cowplot::draw_text("Divergent", x = 0.44, y = 0.065, hjust = 1, size = 10) +
  cowplot::draw_text("Stabilizing", x = 0.44, y = 0.035, hjust = 1, size = 10) 

annotated_plot

ggsave("Figure7_greml_vgamma.pdf", plot=annotated_plot,
       width = 11, height = 10, dpi = 300, units = "in", device=pdf)

