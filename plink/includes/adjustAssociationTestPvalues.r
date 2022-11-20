#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
	print("",quote=F)
        print("Usage: fdr.R [assoc file] [threads]",quote=F)
        print("file: Association test result file with a p-valuse column labaled 'P'",quote=F)
        print("",quote=F)
	quit(save="no")
} else {
   if(!require(data.table)) {
        install.packages("data.table", dependencies=T, repo='https://cran.r-project.org', ask=F)
    }
   if(!require(R.utils)) {
        install.packages("R.utils")
    }
   assoc_dat <- args[1]
   threads <- as.numeric(args[2])
   calc_fdr <- function(assoc.dat = assoc_result) {
	
	out_name <- gsub(".txt.gz", ".adjusted.txt", basename(assoc.dat))

	assoc <- fread(assoc.dat, header=T, data.table=F, nThread=threads, fill=T)
	assoc$P_BH <- p.adjust(as.vector(assoc$P), method="BH")		# Benjamini & Hochberg
	assoc$P_Bonf <- p.adjust(as.vector(assoc$P), method="bonferroni")	# Bonferroni
	assoc$P_BY <- p.adjust(as.vector(assoc$P), method="BY")   		# Benjamini & Yekutieli
	assoc$P_Holm <- p.adjust(as.vector(assoc$P), method="holm")   	# Holm
	#assoc$P_Hommel <- p.adjust(as.vector(assoc$P), method="hommel")  	# Hommel
	#assoc$P_Hochberg <- p.adjust(as.vector(assoc$P), method="hochberg") # Hochberg
	fwrite(assoc, file=out_name, col.names=T, row.names=F, quote=F, sep="\t", nThread=threads)
}
calc_fdr(assoc_dat)
}

