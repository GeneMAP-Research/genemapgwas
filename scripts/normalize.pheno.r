#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
   print("Usage: normalize_pheno.r [pheno_file] [column_name] [file delimiter]", quote=F)
   message("\nFile must be TAB delimited\n")
   quit(save="no")
} else {
   if(!require(bestNormalize)) {
     install.packages("bestNormalize")
   }
   phe <- args[1]
   phn <- args[2]
   pho <- paste0(phe,".normalized.txt")
   pheno <- read.table(phe, h=T, sep="\t")
   print(head(pheno))
   BNobject <- bestNormalize(pheno[,phn])
   pheno[,paste0("n",phn)] <- BNobject$x.t
   write.table(pheno, pho, col.names=T, row.names=F, quote=F, sep="\t")
}
