#!/usr/bin/env Rscript

snps <- read.table( 
  "flt1_snps_maf_distribution.txt", 
  h = T, 
  as.is = T
)

snps.mat <- as.matrix( snps[,-c(1:3)] )

rownames( snps.mat ) <- snps$snp

legend.label <- paste0(
  snps$snp, 
  " (", 
  snps$source, 
  ")"
)

#png(
#  filename = "flt1_snps_maf_distribution.png", 
#  width = 15, 
#  height = 7, 
#  res = 300, 
#  units = "cm", 
#  pointsize = 8
#)

svg(
  filename = "flt1_snps_maf_distribution.svg",
  width = 15,
  height = 7,
  pointsize = 20
)

par(
  mar = c(3,4,1,1)
)

plot.new()

grid(
  nx = ncol( snps.mat )*2,
  ny = nrow( snps.mat )*2,
  lwd = 0.4
)

bar.col <- c(
  "brown", 
  "dodgerblue4", 
  "coral", 
  "lightblue",
  "khaki3"
)

par(
  mar = c(3,4,1,1),
  new = TRUE,
  las = 1
)

barplot(
  snps.mat, 
  beside = T, 
  ann = T,
  col = bar.col 
)

legend.bg <- bar.col 

legend.col <- bar.col

legend(
  "topleft", 
  legend = legend.label, 
  pch = 22, 
  pt.bg = legend.bg, 
  bty = "n", 
  col = legend.col
)

mtext(
  text = "Population",
  side = 1,
  line = 2,
  cex = 1
)

mtext(
  text = "Minor allele frequency",
  side = 2,
  line = 2.4,
  cex = 1,
  las = 3
)

dev.off()
