#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 1) {
   print("",quote=F)
   print("Usage: assoc.R [assoc_result]",quote=F)
   print("assoc_result: should have the following columns; CHR, SNP, BP, P",quote=F)
   print("",quote=F)
   quit(save="no")
} else {
     f <- args[1]
     oMan <- paste0(f,".assoc.png")
     oQq <- paste0(f,".qq.png")
     #?iconv()

     library(qqman)
     require(data.table)

     assoc <- fread(f, h=T, data.table=F, fill=T, nThread = 30)
     attach(assoc)
     ylim_val <- ceiling(as.numeric(max(-log10(P))))+5
     #if(ylim_val >= 15 ) {
     #   ylim_val <- 20
     #} else if(ylim_val < 15 && ylim_val >= 10) {
     #   ylim_val <- 15
     #} else { 
     #   ylim_val <- 10 
     #}
    
     print(paste0("max(ylim): ", ylim_val), quote=F)
     genomewide_line <- prettyNum(as.numeric(-log10(0.05/length(P))), digits = 3)
     print(paste0("Genome-wide threshold: ", genomewide_line), quote=F)

     chr_labs <- unique(assoc$CHR)
     if("X" %in% chr_labs) {
        assoc$CHR <- as.numeric(gsub("X","23", assoc$CHR))
     }
     if("Y" %in% chr_labs) {
        assoc$CHR <- as.numeric(gsub("Y","24", assoc$CHR))
     }
     if("MT" %in% chr_labs) {
        assoc$CHR <- as.numeric(gsub("MT","25", assoc$CHR))
     }
     print(head(assoc))
     if(length(chr_labs) == 22) {
        chr_lab <- as.character(c(1:22))
     }
     if(length(chr_labs) == 23) {
        chr_lab <- as.character(c(1:22, "X"))
     }
     if(length(chr_labs) == 24 & ("24" %in% chr_labs)) {
        chr_lab <- as.character(c(1:22, "X", "Y"))
     } else if(length(chr_labs) == 24 & ("25" %in% chr_labs)) {
        chr_lab <- as.character(c(1:22, "X", "MT"))
     }
     if(length(chr_labs) == 25) {
        chr_lab <- as.character(c(1:22, "X", "Y", "MT"))
     }

     attach(assoc)
     png(oMan, height = 540, width = 1200, units = "px", res = NA, pointsize = 15)
     manhattan(assoc, ylim = c(0, ylim_val), col = c("gray60", "dodgerblue4"), genomewideline = F, suggestiveline = F, cex.axis = 0.6, chrlabs = chr_lab)
     abline(h=c(-log10(1e-05), -log10(5e-08)), lty = 2, lwd = 0.9, col = c("blue","red"))
     dev.off()
     lamd <- prettyNum(as.numeric(median(qchisq(assoc$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)
     print(paste0("Lambda: ", lamd), quote=F)
     png(oQq, height = 620, width = 620, units = "px", res = NA, pointsize = 16)
     qq(assoc$P)
     text(1, 5, expression(lambda[GC]))
     text(1.7, 5, paste0(" = ", lamd))
     dev.off()
}
