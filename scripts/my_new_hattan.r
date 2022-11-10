#!/usr/bin/env Rscript

require(data.table)
#require(tidyverse)
require(qqman)

cmtop <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/batchassoc/saige/cm/qt/output/cm_topmed_imputed.assoc.gz.qqman.txt.gz', h=T, nThread=24)
cmtop <- cmtop[cmtop$CHR != "X", ]
cmtop$CHR <- as.numeric(cmtop$CHR)
cmtop_ymax <- ceiling(max(-log10(cmtop$P)))+2

cmtzcaapa <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_caapa_for_qqman.txt.gz', h=T, nThread=24)
cmtzcaapa_ymax <- ceiling(max(-log10(cmtzcaapa$P)))+2

cmallcustom <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_all_aa_custom_for_qqman.txt.gz', h=T, nThread=24)
cmallcustom <- cmallcustom[cmallcustom$CHR != "X", ]
cmallcustom$CHR <- as.numeric(cmallcustom$CHR)
cmallcustom_ymax <- ceiling(max(-log10(cmallcustom$P)))+2

#df <- fread("cm_hbf_gwas_non_imputed_saige_assoc.txt.gz", h=T, nThread=15)
#d <- df[, c(1:3,13)]
#colnames(d) <- c("CHR", "BP", "SNP", "P")

#d$colr <- ifelse(df$CHR %% 2 == 0, "dodgerblue", "coral")

#cf <- layout(matrix(c(1:23), 1,23, byrow=F), TRUE)
#layout.show(cf)

png("some_test_manhattan_3.png", height = 16, width = 25, units = "cm", res = 300, pointsize = 14)

# layout(matrix(c(1:23), 1,23, byrow=F), TRUE)
# par(mar = c(4,4,1,1), cex = 1)
# plot(d$BP, -log10(d$P), xlab="", ylab="", xaxt="n", yaxt="n", type="n", bty="n", ylim=c(0,19))
# mtext(text = expression(-log[10](p-value)), side = 2, line = 2)
# axis(side=2, at = c(0:19))
# for(i in 1:22) { 
#    p <- d[d$CHR == i,]
#    par(mar = c(4,0,1,0))
#    plot(p$BP, 
# 	-log10(p$P), 
# 	ylab="", 
# 	xlab="", 
# 	xaxt="n", 
# 	yaxt="n", 
# 	col=levels(as.factor(unique(p$colr))), 
# 	ylim = c(0,19), 
# 	pch=20, 
# 	bty="n"
#     ) 
# }


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

manhattan(
   cmtop, 
   xlab="", 
   ylab="", 
   logp=T, 
   col=c("dodgerblue", "coral"), 
   ylim=c(0,cmtop_ymax), 
   genomewideline=F, 
   suggestiveline=F
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
   text = "CAM",
   side = 2,
   line = 3,
   cex = 0.6
)

#--- plot 2
par(
   mar = c(1,4,0,1)
)

manhattan(
   cmtzcaapa, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   col = c("dodgerblue", "coral"), 
   ylim = rev(c(0, cmtzcaapa_ymax)), 
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
   text = "CAM-TZN meta-analysis",
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

manhattan(
   cmallcustom, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   xaxt = "n", 
   col = c("dodgerblue", "coral"), 
   ylim = c(50, cmallcustom_ymax), 
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

manhattan(
   cmallcustom, 
   xlab = "", 
   ylab = "", 
   logp = T, 
   col = c("dodgerblue", "coral"), 
   ylim = c(0,  cmtop_ymax), # cmallcustom_ymax
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
   text = "CAM-TZN-Bae meta-analysis",
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

#par(fig=c(0.4,0.95,0.15,0.35))
#qq(d$P)
dev.off()
