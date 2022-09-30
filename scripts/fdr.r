#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 2) {
        message("\nUsage: fdr.r [input] [p-value column name]\n")
        message("\tinput is association test result file with a p-value column\n")
	quit(save="no")
} else {
   if(!require(data.table)) {
        install.packages(data.table, dependencies=T, repo='https://cloud.r-project.org', ask=F)
    }
   assoc_dat <- args[1]
   pval <- args[2]

   calc_fdr <- function(assoc.dat = assoc_result) {
	
	out_name <- paste(assoc.dat,".adj.txt", sep="")

	assoc <- fread(assoc.dat, header=T, data.table=F, nThread=10, fill=T)
	assoc$p.BH <- p.adjust(as.vector(assoc[,pval]), method="BH")		# Benjamini & Hochberg
	#assoc$P_adj_Bonf <- p.adjust(as.vector(assoc$P), method="bonferroni")	# Bonferroni
	#assoc$P_adj_BY <- p.adjust(as.vector(assoc$P), method="BY")   		# Benjamini & Yekutieli
	#assoc$P_adj_Holm <- p.adjust(as.vector(assoc$P), method="holm")   	# Holm
	#assoc$P_adj_Hommel <- p.adjust(as.vector(assoc$P), method="hommel")  	# Hommel
	#assoc$P_adj_Hochberg <- p.adjust(as.vector(assoc$P), method="hochberg") # Hochberg
	write.table(assoc, file=out_name, col.names=T, row.names=F, quote=F, sep="\t")
}
calc_fdr(assoc_dat)
}
