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
    covar_out <- gsub("eigenvec", "cov", pca)
    age <- fread("/home/kesoh/projects/gwas/hbf/famfiles/hbf_new_fam.tsv", h=T)
    pca <- fread(pca, h=F)
    npcs <- ncol(pca)-2
    pcaNames <- c("FID","IID")
    for (pcNumber in 1:npcs) { pcaNames[pcNumber+2] <- paste0("PC",pcNumber) }
    colnames(pca) <- pcaNames
    pca_age <- merge.data.table(pca, age[,c("FID","SEX","AGE")], by="FID", sort=F)
    fwrite(pca_age, covar_out, col.names=T, row.names=F, sep=" ", quote=F, na="NA")
    print(paste0("Covariates file saved to ", covar_out), quote=F)
    quit(save="yes")
}

