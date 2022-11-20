#!/usr/bin/env Rscript

require(data.table)

# check if file is symlink
is.symlink <- function(paths) isTRUE(nzchar(Sys.readlink(paths), keepNA=TRUE))

if(is.symlink("${emmaxResult}")) {
   emax <- Sys.readlink("${emmaxResult}")
} else {
   emax <- "${emmaxResult}"
}

bim <- fread("${bedName}.bim", col.names=c("CHR","SNP","cM","BP","ALT","REF"), nThread=${task.cpus})

if("X" %in% bim\$CHR) { 
   bim\$CHR <- gsub("X", as.numeric(23), bim\$CHR)
}
if("Y" %in% bim\$CHR) { 
   bim\$CHR <- gsub("X", as.numeric(24), bim\$CHR)
}
if("MT" %in% bim\$CHR) { 
   bim\$CHR <- gsub("X", as.numeric(25), bim\$CHR)
}

emmax <- fread(emax, col.names=c("SNP","BETA","SE","P"), nThread=${task.cpus})
emmax_bim <- merge.data.table(emmax, bim[,-c("cM")], by="SNP", sort=F)
fwrite(emmax_bim, "${bedName}.fmt.ps", col.names=T, row.names=F, sep="\t", quote=F, nThread=${task.cpus})
system("gzip -f ${bedName}.fmt.ps")
