#!/usr/bin/env Rscript

library(susieR)
require(data.table)

fig_out <- paste0("${params.out_prefix}", ".pdf")
res_out <- paste0("${params.out_prefix}", ".finemap.result.txt")

n <- as.numeric("${params.sample_size}")
ld <- fread("${ld_mat}", h=F, nThread=24, data.table=F)
ld <- as.matrix(ld)
max_causal_snps <- as.numeric(${params.max_causal_snps})

if("${params.zscore}" == "true") {
   sumstats <- read.table("${sum_stat}", h=T)
} else {
   sumstats <- read.table("${sum_stat}", h=T)
   sumstats\$zscore <- sumstats\$beta / sumstats\$se
}

if("${params.in_sample_ref}" == "true") {
  fitted_rss <- susie_rss(z = sumstats\$zscore,
                         n = n,
                         R = ld,
                         L = max_causal_snps,
                         estimate_residual_variance = TRUE)
} else {
  fitted_rss <- susie_rss(z = sumstats\$zscore,
                         n = n,
                         R = ld,
                         L = max_causal_snps,
                         estimate_residual_variance = FALSE)
}

cs.res <- c()
for(credible_set in 1:length(fitted_rss\$sets\$cs_index)) {
   index <- fitted_rss\$sets\$cs[[credible_set]]
   z3 <- cbind(rep(credible_set), index, sumstats[index,], fitted_rss\$pip[index])
   z3 <- z3[order(z3[,length(names(z3))], decreasing = TRUE),]
   cs.res <- as.data.frame(rbind(cs.res, z3))
}

write.table(cs.res, res_out, col.names=T, row.names=F, quote=F, sep="\t")

pdf(fig_out, colormodel="cmyk")
susie_plot(fitted_rss, y="PIP")
dev.off()
