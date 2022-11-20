#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args)<1) {
   print("Usage: get.covar.r [evec file]", quote=F)
   print("NB: evec file must contain 12 columns (without header) corresponding to: FID IID PC1 ... PC10", quote=F)
   quit(save="no")
} else {
    require(data.table)
    pca <- args[1]
    covar_out <- gsub("eigenvec", "glm.in", pca)
    cc <- fread("/home/kesoh/projects/gwas/hbf/famfiles/hbf.fam", h=F, col.names=c("FID","IID", "PID", "MID", "SEX", "PHENO", "CC","AGE"))
    pca <- fread(pca, h=F, col.names=c("FID","IID","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","PC11","PC12","PC13","PC14","PC15","PC16","PC17","PC18","PC19","PC20","PC21","PC22","PC23","PC24","PC25","PC26","PC27","PC28","PC29","PC30"))
    pca_cc <- merge.data.table(pca, cc[,c("FID","PHENO")], by="FID", sort=F)
    fwrite(pca_cc, covar_out, col.names=T, row.names=F, sep=" ", quote=F, na="NA")
    print(paste0("Covariates file saved to ", covar_out), quote=F)
    quit(save="yes")
}
