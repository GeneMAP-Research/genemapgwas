#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
   print("",quote=F)
   print("Usage: plot_qq.r [assoc_result] [plot-name]",quote=F)
   print("assoc_result: should have the following columns; CHR, SNP, BP, P",quote=F)
   print("",quote=F)
   quit(save="no")
} else {
     f <- args[1]
     png_qq_name <- paste0(f,".qq.png")
     plt_name <- args[2]

     require(qqman)
     require(data.table)

     assoc <- fread(f, h=T, data.table=F, fill=T, nThread = 30)

     lamd <- prettyNum(as.numeric(median(qchisq(assoc$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)
     print(paste0("Lambda: ", lamd), quote=F)
     png(png_qq_name, height = 8, width = 8, units = "cm", res = 300, pointsize = 7)
     par(mar=c(4,4,1,1))
     qq(assoc$P, main = plt_name)
     text(1, 5, bquote(lambda[GC] ~ "=" ~ .(lamd)))
     #x_mtext <- c(expression(-log[10](italic(p))))
     #y_mtext <- expression(-log[10](italic(p)))
     #mtext(text = paste0("Expected ", x_mtext), side = 1, line = 2)
     #mtext(text = paste0("Observed ", y_mtext), side = 2, line = 2)
     dev.off()
}
