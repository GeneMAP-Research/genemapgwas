#!/usr/bin/env Rscript

famFile <- "${bedName}.fam"
phenoFile <- gsub(".fam", ".pheno", famFile)
covFile <- gsub(".fam", ".cov", famFile)
pheno <- read.table("/home/kesoh/projects/gwas/hbf/famfiles/hbf.fam.with.header.tsv", h=T)
fam <- read.table(famFile, h=F, col.names=c("FID","IID","PID","MID","SEX","PHENO"))
fam_pheno <- merge(fam, pheno[,-c(2:4)], by="FID", sort=F)
write.table(fam_pheno, phenoFile, col.names=T, row.names=F, quote=F, sep="\t")
fam_pheno_slice <- fam_pheno[, which(toupper(names(fam_pheno)) %in% c("FID","SEX","AGE"))]
fam_pheno_slice <- fam_pheno_slice[rep(seq_len(nrow(fam_pheno_slice)), each = 2), ]
fam_pheno_slice <- rbind(P = c("FID","SEX","AGE"), fam_pheno_slice, deparse.level = 0)
#head(fam_pheno_slice)
tfam_pheno <- t(fam_pheno_slice)
rownames(tfam_pheno) <- c("P","C","C")
write.table(tfam_pheno, covFile, col.names=F, row.names=T, quote=F, sep=" ")
