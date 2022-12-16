#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args) < 7) {
   message("\nUsage: finemap.r [sumstat <beta,se|zscore>] [ldmat] [samplesize] [max_causal_snps] [outprefix] [zscore? <true|false>] [in_sample_ref? <true|false>]\n")
   q(save="no")
} else {

require(susieR)
require(data.table)

  sumstat <- args[1]
  ldmat <- args[2]
  n <- as.numeric(args[3])
  max_causal_snps <- as.numeric(args[4])
  outprefix <- args[5]
  mode <- args[6]
  refmode <- args[7]

fig_out <- paste0(outprefix, ".pdf")
res_out <- paste0(outprefix, ".finemap.result.txt")

ld <- fread(ldmat, h=F, nThread=10, data.table=F)
ld <- as.matrix(ld)

if(mode == "true") {
   sumstats <- read.table(sumstat, h=T)
} else {
   sumstats <- read.table(sumstat, h=T)
   sumstats$zscore <- sumstats$beta / sumstats$se
}

if(refmode == "true") {
  fitted_rss <- susie_rss(z = sumstats$zscore,
                         n = n,
                         R = ld,
                         L = max_causal_snps,
                         estimate_residual_variance = TRUE)
} else {
  fitted_rss <- susie_rss(z = sumstats$zscore,
                         n = n,
                         R = ld,
                         L = max_causal_snps,
                         estimate_residual_variance = FALSE)
}

cs.res <- c()
for(credible_set in 1:length(fitted_rss$sets$cs_index)) {
   index <- fitted_rss$sets$cs[[credible_set]]
   z3 <- cbind(rep(credible_set), index, sumstats[index,], fitted_rss$pip[index])
   z3 <- z3[order(z3[,length(names(z3))], decreasing = TRUE),]
   cs.res <- as.data.frame(rbind(cs.res, z3))
}

write.table(cs.res, res_out, col.names=T, row.names=F, quote=F, sep="\t")

pdf(fig_out, colormodel="cmyk")
susie_plot(fitted_rss, y="PIP")
dev.off()

}
