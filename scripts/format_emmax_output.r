#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args)<2) {
  print("Usage: format.emmax.r [bim-file] [emmax-assoc-result]", quote=F)
} else {
    require(data.table)
    bim <- args[1]
    emax <- args[2]
    new_emax <- gsub(".ps",".fmt.ps",emax)    
    bim <- fread(bim, col.names=c("CHR","SNP","cM","BP","ALT","REF"), nThread=24)
    if("X" %in% bim$CHR) { 
       bim$CHR <- gsub("X", as.numeric(23), bim$CHR)
    }
    if("Y" %in% bim$CHR) { 
       bim$CHR <- gsub("X", as.numeric(24), bim$CHR)
    }
    if("MT" %in% bim$CHR) { 
       bim$CHR <- gsub("X", as.numeric(25), bim$CHR)
    }
    emmax <- fread(emax, col.names=c("SNP","BETA","SE","P"), nThread=24)
    emmax_bim <- merge.data.table(emmax, bim[,-c("cM")], by="SNP", sort=F)
    fwrite(emmax_bim, new_emax, col.names=T, row.names=F, sep="\t", quote=F, nThread=24)
}
