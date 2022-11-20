#!/usr/bin/env Rscript

if(!require(data.table)) {
    install.packages("data.table", dependencies=T, repo='https://cloud.r-project.org', ask=F)
}

# check if file is symlink
is.symlink <- function(paths) isTRUE(nzchar(Sys.readlink(paths), keepNA=TRUE))

if(is.symlink("${emmaxResult}")) {
   emax <- Sys.readlink("${emmaxResult}")
} else {
   emax <- "${emmaxResult}"
}

calc_fdr <- function(assoc.dat = assoc_result) {
    assoc <- fread(assoc.dat, header=T, data.table=F, nThread=${task.cpus}, fill=T)
    assoc\$P_BH <- p.adjust(as.vector(assoc\$P), method="BH")
    fwrite(assoc, "${bedName}.fmt.adj.ps", col.names=T, row.names=F, quote=F, sep="\t", nThread = ${task.cpus})
    system("gzip -f ${bedName}.fmt.adj.ps")
}

calc_fdr(emax)
