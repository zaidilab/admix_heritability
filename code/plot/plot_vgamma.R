# Plot behavior of vgamma

# load data
filename1="admix_CGF_vg_vgamma.txt"
df_CGF=read.table(filename1, header=T)
filename2="admix_HI_vg_vgamma.txt"
df_HI=read.table(filename2, header=T)


# A function factory for getting integer y-axis values.
integer_breaks <- function(n = 5, ...) {
  fxn <- function(x) {
    breaks <- floor(pretty(x, n, ...))
    names(breaks) <- attr(breaks, "labels")
    breaks
  }
  return(fxn)
}

plot_vgamma = function(data, yobs, yexp, ylab, title) {
library(ggplot2)
p = ggplot() +
  geom_line(data=data, alpha = 0.65, linewidth=0.5, 
            aes(x=t, y = yobs, linetype = "obs",
                group=interaction(P, cov),
                color=interaction(P, cov))) +
  geom_line(data=data, linewidth=0.5, 
            aes(x=t, y = yexp, linetype = "exp",
                group=interaction(P, cov),
                color=interaction(P, cov))) + 
  scale_linetype_manual("", 
                       breaks = c("obs", "exp"),
                       values = c("solid", "dotted"),
                       labels = c("Observed", "Expected")) +
   scale_colour_manual("", 
                      values = c('#92c5de','#4393c3','#2166ac','#053061',
                                 '#f4a582','#d6604d','#b2182b','#67001f'),
                      labels = c("P=0", "P=0.3", "P=0.6", "P=0.9",
                                 "P=0", "P=0.3", "P=0.6", "P=0.9"
                     )) +
  xlab("t") +
  ylab(ylab)  +  
  ggtitle(title) +
  theme_bw() +
  scale_x_continuous(breaks = integer_breaks()) +
  ylim(0, 1.25) +
  theme(aspect.ratio = 1, 
        plot.title = element_text(hjust = 0.5), # to center the title
        legend.position = "bottom", 
        text = element_text(size = 10)) 

# New facet label names
# theta.labs <- c("\u03B8 = 0.1", "\u03B8 = 0.2", "\u03B8 = 0.5")
# names(theta.labs) <- c("0.1", "0.2", "0.5")
# 
# gen.labs <- c("10 generations", "20 generations","50 generations","100 generations")
# names(gen.labs) <- c("10", "20", "50", "100")

vgCGF = p + facet_grid(rows = vars(theta), cols = vars(gen), #row as theta col as gen
             scale="free_x",  #adjust the xlim for each
  labeller = label_bquote(rows = theta ~ "=" ~ .(theta), cols = .(gen) ~ "generations")) + 
  theme(
    strip.background = element_rect(
      color="black", fill="white", size=0.8, linetype="solid"),
    strip.text.x = element_text(
        size = 6, color = "black", face = "bold"),
    strip.text.y = element_text(
        size = 7, color = "black", face = "bold"),
    panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x=element_text(size=7),
        axis.text.y=element_text(size=7),
        #strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA)
        ) + 
   guides(color = guide_legend(order = 1, ncol=4, 
                              byrow = T, reverse = T,
                              override.aes = list(linewidth = 2)
                             ),  # thicken the line in legend
          linetype = guide_legend(order = 2))
          }

vgammaHI=plot_vgamma(data=df_HI, 
         yobs=df_HI$var.prs.lanc, 
         yexp=df_HI$exp.vgamma,
         ylab=expression(V[gamma]), 
         title="Hybrid Isolation")

vgammaCGF=plot_vgamma(data=df_CGF, 
         yobs=df_CGF$var.prs.lanc, 
         yexp=df_CGF$exp.vgamma,
         ylab=expression(V[gamma]), 
         title="Continuous Gene Flow")

library(ggpubr)
library(cowplot)
plt=ggarrange(vgammaHI, vgammaCGF, ncol = 2, nrow = 1, 
          labels = c("a", "b"),
          align = c("hv"),
          legend = "none") %>% # to move the legend closer 
  gridExtra::grid.arrange(ggpubr::get_legend(vgammaHI), heights = unit(c(100, 5), "mm"))

#add to legend
annotated_plot <- ggdraw(plt) +
  draw_text("Divergent", x = 0.2, y = 0.14, hjust = 1, size = 9) +
  draw_text("Stabilizing", x = 0.2, y = 0.08, hjust = 1, size = 9)

annotated_plot

#save
ggsave("FigureS2_Vgamma.pdf", plot=annotated_plot,
       width = 8, height = 5, dpi = 300, units = "in", device='pdf')

