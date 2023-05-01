#!/usr/bin/env Rscript

cm.tz.bae <- read.table("hbf_gwas_table_of_significant_associations_for_heterogeneity_plot.csv", h=T)

colnames(cm.tz.bae) <- toupper(names(cm.tz.bae))

panels <- levels(unique(as.factor(cm.tz.bae$GENE)))

colors <- rev(c("dodgerblue", "lightblue", "darkolivegreen", "darkorange1", "seagreen3", "orchid3", "black", "brown", "navy"))
panel_colors <- as.data.frame(panels, colors[1:length(panels)], fill=T)
panel_colors$col <- rownames(panel_colors)
colnames(panel_colors) <- c("panel","col")

for(snp in 1:nrow(cm.tz.bae)) {
   for(panel in panels) {
      if(cm.tz.bae$GENE[snp] == panel) {
         cm.tz.bae$colors[snp] <- panel_colors$col[panel_colors$panel == panel]
      }
   }
}

cm.tz.bae$snp <- paste0(cm.tz.bae$GENE, "_", cm.tz.bae$RSID)

cm.tz.bae <- cm.tz.bae[order(cm.tz.bae$HETISQ), ]

print(head(cm.tz.bae))

svg("heterogeneity_dotplot.svg", height=5, width=8, pointsize=14)
par(mar = c(4,2,2,1))
dotchart(
   cm.tz.bae$HETISQ, 
   labels = cm.tz.bae$snp, 
   #groups = as.factor(cm.tz.bae$snp), 
   pch = 19,
   xlim = c(0, 85),
   color = cm.tz.bae$colors, 
   #color = "dodgerblue", 
   pt.cex = 1.5,
   cex.main = 0.9,
   xlab = expression("Heterogeneity" ~ italic(I)^2),
   main = expression("Heterogeneity in sentinel variants of HbF-associated loci")
)
abline(v=50, lty=2, col="grey")
dev.off()
