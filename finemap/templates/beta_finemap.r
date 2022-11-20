#!/usr/bin/env Rscript

library(susieR)
require(data.table)

out <- paste0("${params.out_prefix}", ".pdf")

n <- as.numeric("${params.sample_size}")
ld <- fread("${ld_mat}", h=F, nThread=24, data.table=F)
ld <- as.matrix(ld)
sumstats <- read.table("${sum_stat}", h=T)
print(head(sumstats))

#z_scores <- sumstats\$beta / sumstats\$se

if(${params.in_sample_ref} == "true") {
  fitted_rss1 <- susie_rss(bhat = sumstats\$beta,
                         shat = sumstats\$se,
                         n = n,
                         R = ld,
                         L = 10,
                         estimate_residual_variance = TRUE)
} else {
  fitted_rss1 <- susie_rss(bhat = sumstats\$beta,
                         shat = sumstats\$se,
                         n = n,
                         R = ld,
                         L = 10,
                         estimate_residual_variance = FALSE)
}
pdf(out, colormodel="cmyk")
susie_plot(fitted_rss1, y="PIP")
dev.off()
