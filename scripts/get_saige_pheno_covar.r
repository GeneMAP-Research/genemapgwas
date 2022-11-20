#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
   print("Usage: prep_saige_pheno_covar.r [fam file] [covar file]", quote=F)
   quit(save="no")
} else {
   require(data.table)
   famfile <- args[1]
   bimfile <- gsub(".fam",".bim", famfile)
   bim <- fread(bimfile, h=F, data.table=F, nThread=24)
   if("X" %in% bim$V1) {
      bim$V1 <- gsub("X", "23", bim$V1)
   }
   if("Y" %in% bim$V1) {
      bim$V1 <- gsub("Y", "24", bim$V1)
   }
   if("MT" %in% bim$V1) {
      bim$V1 <- gsub("MT", "25", bim$V1)
   }
   fwrite(bim, bimfile, col.names=F, row.names=F, quote=F, sep="\t", nThread=24)
   covarfile <- args[2]
   fam <- read.table(famfile, h=F, col.names=c("FID","IID","PID","MID","SEX","PHENO"))
   pca <- read.table(covarfile, h=T)
   pca$SEX <- NULL
   pheno <- merge(pca[,c("FID","AGE")], fam[,c("FID","PHENO","SEX")], by="FID", sort=F)
   f <- data.frame(FID=pheno$FID, PHENO=pheno$PHENO, SEX=pheno$SEX, AGE=pheno$AGE)
   if(length(levels(as.factor(pheno$PHENO))) == 2 ) {
      pheno$PHENO <- gsub("1","0", pheno$PHENO)
      pheno$PHENO <- gsub("2","1", pheno$PHENO)
   }

   pheno_pca <- merge.data.table(pheno, pca[, -which(names(pca) %in% c('IID','SEX','AGE'))], by="FID", sort=F)

   write.table(pheno_pca, gsub(".fam", ".pheno", basename(famfile)), col.names=T, row.names=F, quote=F, sep="\t")
   #write.table(pheno_pca, gsub(".fam", ".pheno", basename(famfile)), col.names=T, row.names=F, quote=F, sep=" ")
}
