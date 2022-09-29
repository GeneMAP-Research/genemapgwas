#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
   print("Usage: prep_bolt_covar.r [fam file] [covar file]", quote=F)
   quit(save="no")
} else {
   famfile <- args[1]
   covarfile <- args[2]
   fam <- read.table(famfile, h=F, col.names=c("FID","IID","PID","MID","SEX","PHENO"))
   pca <- read.table(covarfile, h=T)
   pca$SEX <- NULL
   f <- merge(pca, fam[,c("FID","SEX")], by="FID", sort=F)
   write.table(f, gsub(".fam", ".cov", basename(famfile)), col.names=T, row.names=F, quote=F, sep=" ")
   write.table(fam, gsub(".fam", ".pheno", basename(famfile)), col.names=T, row.names=F, quote=F, sep=" ")
}
