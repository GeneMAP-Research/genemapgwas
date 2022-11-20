#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
   print("Usage: normalize_pheno.r [pheno_file] [column_name]", quote=F)
   quit(save="no")
} else {
   if(!require(bestNormalize)) {
     install.packages("bestNormalize")
   }
   phe <- args[1]
   phn <- args[2]
   pho <- paste0(phe,".normalized.txt")
   pheno <- read.table(phe, h=T)
   BNobject <- bestNormalize(pheno[,phn])
   pheno$x.t <- BNobject$x.t
   phe_names <- names(pheno)
   phe_names <- append(phe_names, paste0("n", phn), after = length(phe_names))
   colnames(pheno) <- phe_names
   write.table(pheno, pho, col.names=T, row.names=F, quote=F, sep="\t")
}
