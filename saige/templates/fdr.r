#!/usr/bin/env Rscript

require(data.table)

assoc_dat <- "${saige_result}"
pval <- "p.value"
threads <- as.numeric(${task.cpus})

calc_fdr <- function(assoc.dat = assoc_result) {
     
     out_name <- paste0(assoc.dat,".adjusted.txt.gz")

     assoc <- fread(assoc.dat, header=T, data.table=F, nThread = threads, fill=T)
     assoc\$p.BH <- p.adjust(as.vector(assoc[,pval]), method="BH")		# Benjamin & Hochberg
     fwrite(assoc, file=out_name, col.names=T, row.names=F, quote=F, sep="\t", nThread = threads)
}

calc_fdr(assoc_dat)

