#!/usr/bin/env Rscript

require(data.table)
#require(tidyverse)
require(qqman)

assoc <- fread("/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/multi_manhattan.txt.gz", h = T, nThread = 24, data.table = F)

#cmtop <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/batchassoc/saige/cm/qt/output/cm_topmed_imputed.assoc.gz.qqman.txt.gz', h=T, nThread=24)
cmtop <- assoc[ assoc$pop == "cm", ]
cmtop <- cmtop[ cmtop$P <= 1e-3, ]
cmtop <- cmtop[ cmtop$CHR != "X" || cmtop$CHR != 23, ]
cmtop$CHR <- as.numeric(cmtop$CHR)
cmtop <- na.omit(cmtop)

cmtop_ylim <- as.numeric(
  c( 
    floor( min(-log10(cmtop$P)) ), 
    ceiling( max(-log10(cmtop$P)) )+2 
  )
)

#cmtzcaapa <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_caapa_for_qqman.txt.gz', h=T, nThread=24)
cmtzcaapa <- assoc[ assoc$pop == "cm_tz", ]
cmtzcaapa <- cmtzcaapa[ cmtzcaapa$P <= 1e-3, ]
cmtzcaapa <- cmtzcaapa[ cmtzcaapa$CHR != "X" || cmtzcaapa$CHR != 23, ]
cmtzcaapa$CHR <- as.numeric(cmtzcaapa$CHR)
cmtzcaapa <- na.omit(cmtzcaapa)

cmtzcaapa_ylim <- as.numeric(
  c(
    floor( min(-log10(cmtzcaapa$P)) ) ,
    ceiling( max(-log10(cmtzcaapa$P)) )+2
  )
)

#cmallcustom <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_all_aa_custom_for_qqman.txt.gz', h=T, nThread=24)
cmallcustom <- assoc[ assoc$pop == "cm_tz_bae", ]
#cmallcustom <- cmallcustom[ cmallcustom$P <= 1e-3, ]
cmallcustom <- cmallcustom[ cmallcustom$CHR != "X" || cmallcustom$CHR != 23, ]
cmallcustom$CHR <- as.numeric(cmallcustom$CHR)
cmallcustom <- na.omit(cmallcustom)

cmallcustom_ylim <- as.numeric( 
  c( 
    floor( min(-log10(cmallcustom$P)) ), 
    ceiling(max(-log10(cmallcustom$P)))+2 
  ) 
)

rm(assoc)

get.grid <- function() {
  grid(nx=23, ny=20, lwd=0.5)
}

png(
  "fig3.png", 
  height = 16, 
  width = 25, 
  units = "cm", 
  res = 300, 
  pointsize = 14
)

layout(
   matrix(c(1:4), 
   nrow = 4, 
   ncol = 1), 
   TRUE
)

#--- plot 1
par(
   mar = c(3,4,1,1)
)

plot.new()
get.grid()

par(
   mar = c(3,4,1,1),
   new = T
)

manhattan(
   cmtop, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   col = c("dodgerblue", "coral"), 
   ylim = cmtop_ylim, 
   genomewideline = F, 
   suggestiveline = F
)

abline(
   h = c(-log10(5e-8), -log10(1e-5)), 
   lty = 2, 
   lwd = c(0.6,0.6), 
   col = c("red", "blue")
)

mtext(
   text = expression(-log10(p-value)), 
   side = 2, 
   line = 2, 
   cex = 0.55
)

mtext(
   text = "Discovery",
   side = 2,
   line = 3,
   cex = 0.6
)

#--- plot 2
par(
   mar = c(1,4,0,1)
)

plot.new()
get.grid()

par(
   mar = c(1,4,0,1),
   new = T
)

manhattan(
   cmtzcaapa, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   col = c("dodgerblue", "coral"), 
   ylim = rev(cmtzcaapa_ylim), 
   genomewideline = F, 
   suggestiveline = F, 
   xaxt = "n"
)

abline(
   h = c(-log10(5e-8), -log10(1e-5)), 
   lty = c(2,2), 
   lwd = c(0.6,0.6), 
   col = c("red", "blue")
)

mtext(
   text = expression(-log10(p-value)), 
   side = 2, 
   line = 2, 
   cex = 0.55
)

mtext(
   text = "Discovery-Replication meta-analysis",
   side = 2,
   line = 3,
   cex = 0.6
)

# mtext(
#    text = "Chromosome", 
#    side = 3, 
#    line = 0, 
#    cex = 0.6
# )

#--- plot 3
par(
   mar = c(0.5,4,1,1)
)

plot.new()
get.grid()

par(
   mar = c(0.5,4,1,1),
   new = T
)

manhattan(
   cmallcustom, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   xaxt = "n", 
   col = c("dodgerblue", "coral"), 
   ylim = c(50, cmallcustom_ylim[2]), 
   genomewideline = F, 
   suggestiveline = F
)

abline(
   h = c(-log10(5e-8), 
   -log10(1e-5)), 
   lty = c(2,2), 
   lwd = c(0.6,0.6), 
   col = c("red", "blue")
)

#  mtext(
#     text = expression(-log10(p-value)), 
#     side = 2, 
#     line = 2, 
#     cex=0.7
#  )

#--- plot 4
par(
   mar = c(3,4,0.5,1)
)

plot.new()
get.grid()

par(
   mar = c(3,4,0.5,1),
   new = T
)

manhattan(
   cmallcustom, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   col = c("dodgerblue", "coral"), 
   ylim = c(0,  cmtop_ylim[2]), # cmallcustom_ymax
   genomewideline = F, 
   suggestiveline = F, 
   #xaxt = "n"
)

abline(
   h = c(-log10(5e-8), -log10(1e-5)), 
   lty = c(2,2), 
   lwd = c(0.6,0.6), 
   col = c("red", "blue")
)

mtext(
   text = expression(-log10(p-value)), 
   side = 2, 
   line = 2, 
   cex=0.55
)

mtext(
   text = "Discovery-Global meta-analysis",
   side = 2,
   line = 3,
   cex = 0.6
)   

mtext(
   text = "Chromosome", 
   side = 1, 
   line = 2, 
   cex=0.5
)

dev.off()
