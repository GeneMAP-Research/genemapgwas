#!/usr/bin/env Rscript

require(data.table)
#require(tidyverse)
require(qqman)

cmtop <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/batchassoc/saige/cm/qt/output/cm_topmed_imputed.assoc.gz.qqman.txt.gz', h=T, nThread=24)
cmtop <- cmtop[cmtop$CHR != "X", ]
cmtop_gc <- prettyNum(as.numeric(median(qchisq(cmtop$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)

cmtzcaapa <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_caapa_for_qqman.txt.gz', h=T, nThread=24)
cmtzcaapa_gc <- prettyNum(as.numeric(median(qchisq(cmtzcaapa$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)

cmallcustom <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/formatted_for_qqman/cm_tz_all_aa_custom_for_qqman.txt.gz', h=T, nThread=24)
cmallcustom <- cmallcustom[cmallcustom$CHR != "X", ]
cmallcustom_gc <- prettyNum(as.numeric(median(qchisq(cmallcustom$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)

png("hbfgwas_figure3_qq.png", height = 7.5, width = 25, units = "cm", res = 300, pointsize = 14)

layout(
   matrix(c(1:3), 
   nrow = 1, 
   ncol = 3), 
   TRUE
)

#--- plot 1
par(
   mar = c(3,3,1,1)
)

qq(
   cmtop$P, 
   xlab = "",
   ylab = ""
)

text(
   x = 3,
   y = 18,
   labels = "CAM",
   cex = 1
)

text(
   x = 2,
   y = 10,
   labels = bquote(lambda[GC] ~ "=" ~ .(cmtop_gc)),
   cex = 1.4
)

mtext(
   text=paste0("Expected ", expression(-log10(p-value))), 
   side = 1, 
   line = 2, 
   cex=0.7
)

mtext(
   text=paste0("Observed ", expression(-log10(p-value))),
   side = 2,
   line = 2,
   cex=0.7
)

#--- plot 2
par(
   mar = c(3,3,1,1)
)

qq(
   cmtzcaapa$P,
   xlab = "",
   ylab = ""
)

text(
   x = 3.5,
   y = 40,
   labels = "CAM-TZN meta-analysis",
   cex = 1
)

text(
   x = 2,
   y = 20,
   labels = bquote(lambda[GC] ~ "=" ~ .(cmtzcaapa_gc)),
   cex = 1.4
)

mtext(
   text=paste0("Expected ", expression(-log10(p-value))),
   side = 1, 
   line = 2, 
   cex=0.7
)

mtext(
   text=paste0("Observed ", expression(-log10(p-value))),
   side = 2,
   line = 2,
   cex=0.7
)

#--- plot 3
par(
   mar = c(3,3,1,1)
)

qq(
   cmallcustom$P,
   xlab = "",
   ylab = ""
)

text(
   x = 3,
   y = 98,
   labels = "CAM-TZN-Bae meta-analysis",
   cex = 1
)

text(
   x = 2,
   y = 40,
   labels = bquote(lambda[GC] ~ "=" ~ .(cmallcustom_gc)),
   cex = 1.4
)

mtext(
   text=paste0("Expected ", expression(-log10(p-value))),
   side = 1,
   line = 2,
   cex=0.7
)

mtext(
   text=paste0("Observed ", expression(-log10(p-value))),
   side = 2,
   line = 2,
   cex=0.7
)

dev.off()
