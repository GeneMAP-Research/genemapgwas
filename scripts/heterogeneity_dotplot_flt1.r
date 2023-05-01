#!/usr/bin/env Rscript

cm.tz.flt1.signif <- read.table("cm_tz_flt1_imputed.assoc.gz.adjusted_fdr0.10_with_pve.txt", h=T)

cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29080292:SNP"] <- "rs115695442"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29084891:SNP"] <- "rs74617914"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29089821:SNP"] <- "rs11840478"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29090283:SNP"] <- "rs114243330"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29093654:SNP"] <- "rs74993145"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29094555:SNP"] <- "rs75294023"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29096667:SNP"] <- "rs78560568"
cm.tz.flt1.signif$snp[cm.tz.flt1.signif$ID == "13:29099043:SNP"] <- "rs11843606"

write.table(
   cm.tz.flt1.signif, 
   "cm_tz_flt1_imputed.assoc.gz.adjusted_fdr0.10_with_pve.txt", 
   col.names=T, 
   row.names=F, 
   quote=F, 
   sep=" "
)

panels <- levels(unique(as.factor(cm.tz.flt1.signif$PANEL)))
colors <- c("dodgerblue", "lightblue", "darkolivegreen", "darkorange1", "seagreen3", "orchid3")
panel_colors <- as.data.frame(panels, colors)
panel_colors$col <- rownames(panel_colors)
colnames(panel_colors) <- c("panel","col")

for(snp in 1:nrow(cm.tz.flt1.signif)) {
   for(panel in panels) {
      if(cm.tz.flt1.signif$PANEL[snp] == panel) {
         cm.tz.flt1.signif$colors[snp] <- panel_colors$col[panel_colors$panel == panel]
      }
   }
}

print(head(cm.tz.flt1.signif))

svg("heterogeneity_dotplot_flt1.svg", height=9, width=8, pointsize=16)
par(mar = c(4,2,1,1))
dotchart(
   cm.tz.flt1.signif$HETISQ, 
   labels = cm.tz.flt1.signif$PANEL, 
   groups = as.factor(cm.tz.flt1.signif$snp), 
   pch = 19,
   color = cm.tz.flt1.signif$colors, 
   pt.cex = 1.5,
   cex.main = 0.9,
   xlab = expression("Heterogeneity" ~ italic(I)^2),
   main = expression("Heterogeneity in" ~ italic("FLT1") ~ "associations with FDR < 0.10")
)
dev.off()
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == panels$] <- "dodgerblue"
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == "h3a"] <- "lightblue"
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == "sanger"] <- "darkolivegreen"
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == "caapa"] <- "darkorange1"
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == "kgp"] <- "seagreen3"
#cm.tz.flt1.signif$colors[cm.tz.flt1.signif$PANEL == "topmed"] <- "orchid3"

