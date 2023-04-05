#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 4) {
   print("",quote=F)
   print("Usage: plot_assoc_mirror.r [assoc_result_1] [assoc_result_1_name] [assoc_result_2] [assoc_result_2_name]",quote=F)
   print("assoc_result: should have the following columns; CHR, SNP, BP, P",quote=F)
   print("",quote=F)
   quit(save="no")
} else {
     result_a <- args[1]
     result_a_name <- gsub(" ", "_", args[2])
     result_b <- args[3]
     result_b_name <- gsub(" ", "_", args[4])
     data_names <- levels(as.factor(c(result_a_name, result_b_name)))

     png_plt_name <- paste0(result_a_name, "_", result_b_name, "_manhattan.png")
     pdf_plt_name <- paste0(result_a_name, "_", result_b_name, "_manhattan.pdf")
     qq_name <- paste0(result_a_name, "_", result_b_name, "_qq.png")

     require(qqman)
     require(data.table)

     assoc_a <- fread(result_a, h=T, data.table=F, fill=T, nThread = 24)
     minylim_a <- ceiling(as.numeric(-log10(max(assoc_a$P))))
     maxylim_a <- ceiling(as.numeric(-log10(min(assoc_a$P))))+2
     assoc_b <- fread(result_b, h=T, data.table=F, fill=T, nThread = 24)
     minylim_b <- ceiling(as.numeric(-log10(max(assoc_b$P))))
     maxylim_b <- ceiling(as.numeric(-log10(min(assoc_b$P))))+2
     
     print(paste0("max(ylim) ", result_a_name, ": ", maxylim_a), quote=F)
     print(paste0("max(ylim) ", result_b_name, ": ", maxylim_b), quote=F)

     change_chr_code <- function(x=assoc_result) {
          assoc <- x
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
          return(assoc)
     }

     get_chr_labels <- function(x=assoc_result) {
          assoc <- x
          chr_labs <- unique(assoc$CHR)
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
          return(chr_lab)
     }

     plot_mirror_manhattan <- function(x=data_a, y=data_b) {
          data_a <- x
          data_b <- y
          #png(png_plt_name, height = 600, width = 1200, units = "px", res = NA, pointsize = 15)
          png(png_plt_name, height = 15, width = 28, units = "cm", res = 300, pointsize = 10)
          #pdf(pdf_plt_name, colormodel='cmyk')
          par(fig=c(0,1,0.41,1))
          print(paste0("Plotting manhattan for ", result_a_name, "..."), quote=F)
          manhattan(data_a, ylim = c(minylim_a, maxylim_a), col = c("dodgerblue4", "coral"), genomewideline = F, suggestiveline = F, cex.axis = 0.8, logp=T, xlab=NA)
          #mtext(text=result_a_name, side=3)
          abline(h=c(-log10(1e-05), -log10(5e-08)), lty = 2, lwd = 0.7, col = c("blue","red"))
          par(fig=c(0,1,0,0.59), new=TRUE)
          print(paste0("Plotting manhattan for ", result_b_name, "..."), quote=F)
          manhattan(data_b, ylim = rev(c(minylim_b, maxylim_b)), col = c("dodgerblue4", "coral"), genomewideline = F, suggestiveline = F, cex.axis = 0.8, logp=T, xaxt='n', xlab=NA)
          #mtext(text=result_b_name, side=1)
          abline(h=c(-log10(1e-05), -log10(5e-08)), lty = 2, lwd = 0.7, col = c("blue","red"))
          dev.off()
     }

     assoc_a <- change_chr_code(x=assoc_a)
     assoc_b <- change_chr_code(x=assoc_b)
     assoc_a_chr_lab <- get_chr_labels(x=assoc_a)
     assoc_b_chr_lab <- get_chr_labels(x=assoc_b)
     plot_mirror_manhattan(x=assoc_a, y=assoc_b)

     #qq_a <- -log10(min(assoc_b$P))
     #qq_b <- -(-log10(min(assoc_b$P)))
     #qq <- as.data.frame(P_a = qq_a, P_b = qq_b)

     #lamd <- prettyNum(as.numeric(median(qchisq(assoc$P, df=1, lower.tail = F), na.rm = T)/0.456), digits = 4)
     #print(paste0("Lambda: ", lamd), quote=F)
     #png(qq_name, height = 620, width = 620, units = "px", res = NA, pointsize = 16)
     #qq(assoc$P_a, main = qq_name)
     #qq(assoc$P_b, main = qq_name, new=T)
     #text(1, 5, expression(lambda[GC]))
     #text(1.7, 5, paste0(" = ", lamd))
     #dev.off()
}
