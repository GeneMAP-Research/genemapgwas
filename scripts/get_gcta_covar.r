#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args)<1) {
   print("Usage: get.covar.r [evec file]", quote=F)
   print("NB: evec file must NOT contain any header. Otherwise, the header must begin with a comment character '#'", quote=F)
   print("NB: First two columns of evec file must sample IDs (e.g. FID IID) and the rest of the columns must be PCs (e.g. PC1 ... PC10)", quote=F)
   quit(save="no")
} else {
    require(data.table)
    pca <- args[1]
    qcovar_out <- gsub("eigenvec", "qcov", pca)
    covar_out <- gsub("eigenvec", "catcov", pca)
    age <- fread("/home/kesoh/projects/gwas/hbf/famfiles/hbf.fam", h=F, col.names=c("FID","IID", "PID", "MID", "SEX", "HbF", "CC","AGE"))
    pca <- fread(pca, h=F)
    npcs <- ncol(pca)-2
    pcaNames <- c("FID","IID")
    for (pcNumber in 1:npcs) { pcaNames[pcNumber+2] <- paste0("PC",pcNumber) }
    colnames(pca) <- pcaNames
    qpca_age <- merge.data.table(pca, age[,c("FID","AGE")], by="FID", sort=F)
    pca_age <- merge.data.table(pca[,c("FID")], age[,c("FID","IID","SEX")], by="FID", sort=F)
    fwrite(qpca_age, qcovar_out, col.names=F, row.names=F, sep=" ", quote=F, na="NA")
    fwrite(pca_age, covar_out, col.names=F, row.names=F, sep=" ", quote=F, na="NA")
    print(paste0("Covariates file saved to ", covar_out), quote=F)
    quit(save="no")
}
