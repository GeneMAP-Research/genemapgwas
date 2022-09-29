#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 1) {
   print("Usage: palindromic.R [bim_file]",quote=F)
   quit(save="no")
} else {
     b <- args[1]
     bout <- gsub(".bim", ".at-cg.snps", b)
     # Extract palindromic SNPs
     bim = read.table(b, header=F, as.is=T)
     # Get indices of A/T and G/C SNPs
     w = which((bim$V5=="A" & bim$V6=="T") | (bim$V5=="T" & bim$V6=="A") | (bim$V5=="G" & bim$V6=="C") | (bim$V5=="C" & bim$V6=="G"))
     
     # Extract A/T and G/C SNPs
     at.cg.snps = bim[w,]
     
     # Save A/T and G/C snps into a file at-cg.snps
     write.table(at.cg.snps$V2, file=bout, row.names=F, col.names=F, quote=F)
}
