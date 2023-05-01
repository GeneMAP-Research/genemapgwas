#!/usr/bin/env Rscript

require(gtools)

snps <- read.table( 
  "flt1_finemapped_lookup_snps_maf_distribution_pruned.txt", 
  h = T, 
  as.is = T
)

snps.mat <- as.matrix( snps[,-c(1)] )

rownames( snps.mat ) <- snps$snp

legend.label <- paste0(
  snps$snp
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
  filename = "flt1_finemapped_lookup_snps_maf_distribution_pruned.svg",
  width = 15,
  height = 7,
  pointsize = 20
)

par(
  mar = c(3,4,1,1)
)

plot.new()

nsnps <- length(snps$snp)

bar.col <- rainbow(nsnps, s = 0.35, alpha = 0.8)

bar.col <- c("dodgerblue", "darkolivegreen", "darkorange1", "seagreen3", "orchid3", "brown")
bar.col <- c(sort(bar.col), "lightblue")
#[odd(seq(from=1, to=8, by=1)) == "TRUE"]

# bar.col <- c(
#   "brown", 
#   "dodgerblue4", 
#   "coral", 
#   "lightblue",
#   "khaki3"
# )

par(
  mfrow = c(2,1)
)

par(
  fig = c(0,1,0.2,1),
  mar = c(3,4,1,1),
  new = T,
  las = 1
)

grid(
  nx = ncol( snps.mat )*2,
  ny = nrow( snps.mat )*2,
  lwd = 0.4
)

#par(
#  mar = c(3,4,1,1),
#  new = TRUE,
#  las = 1
#)

barplot(
  snps.mat, 
  #ylim = c(0, 0.3),
  #ylim = c(0, max(snps$CAM)+0.01), 
  beside = T, 
  horiz = F,  
  ann = T,
  col = bar.col
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
  line = 3,
  cex = 1,
  las = 3
)

legend.bg <- bar.col 

legend.col <- "black"

par(
  fig = c(0,1,0,0.2),
  mar = c(1,3,1,1),
  new = T,
  las = 1
)

legend(
  "topleft", 
  legend = legend.label, 
  pch = 22, 
  pt.bg = legend.bg, 
  bty = "n", 
  cex = 0.9,
  horiz = T,
  adj = 0.1, 
  #ncol = 4,  
  col = legend.col
)

dev.off()
