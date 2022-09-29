#!/usr/bin/env Rscript

########################################################
##
## Calculating Proportion of Variance explained per SNP
##
##



require(data.table)
#require(qqman)

df <- fread('/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/batchassoc/saige/cm/qt/output/cm_saige_unimputed_for_pve.txt.gz', h = T, nThread = 24)

get.pve <- function(
   beta = effect_size, 
   se = standard_error_of_effect_size, 
   maf = minor_allele_freq, 
   n = sample_size
) { 
   numerator <- ((2*(beta)^2)*maf)*(1-maf)
   denomenator <- numerator + (se^2)*(2*n)*maf*(1-maf)
   pve <- numerator/denomenator
   return(pve) 
}


for(snp in 1:nrow(df)) {
   df$pve[snp] <- get.pve(
                     beta = df$BETA[snp], 
                     se = df$SE[snp], 
                     maf = df$Allele2_freq[snp], 
                     n = df$N[snp]
                 )
}

fwrite(df, "/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/batchassoc/saige/cm/qt/output/cm_saige_unimputed_with_pve.txt.gz", nThread = 24, col.names=T, row.names=F, sep=" ", quote=F)

print(head(df), quote=F)
