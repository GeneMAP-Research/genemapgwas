#!/usr/bin/env Rscript

he <- Sys.readlink("${het}")
imis <- Sys.readlink("${smiss}")
oput <- paste0("${params.out}", "_sample_missingness.png")
out <- paste0("${params.out}", "_fail-missingness-qc.txt")

# read heterozygosity and sample missing data reports
#HET --- #FID	IID	O(HOM)	E(HOM)	OBS_CT	F
het <- read.table(he, header = T, col.names=c("FID","IID","OBS_HOM","EXP_HOM","OBS_CT","F"))
#mis <- read.table(imis, header = T, col.names=c("FID","IID","PHENO1","MISSING_CT","OBS_CT","F_MISS"))
mis <- read.table(imis, header = T)
print(head(het))
print(head(mis))

# Calculate the observed heterozygosity rate per individual by (N(NM) - O(HOM)/N(NM))
mishet <- data.frame(
  FID = het\$FID, 
  IID = het\$IID, 
  het.rate = (het\$OBS_CT - het\$OBS_HOM)/het\$OBS_CT, mis.rate=mis\$F_MISS
)

# Calculated heterozygosity outliers (less than or greater than 3 standard deviations from the mean)
meanhet <- mean(mishet\$het.rate)
sdhet <- sd(mishet\$het.rate, na.rm = F)

if(is.null(${params.hetlower})) {
  hetupper = meanhet + sdhet*3
  hetlower = meanhet - sdhet*3
} else {
  hetlower = as.numeric(${params.hetlower})
  hetupper = as.numeric(${params.hetupper})
}

# Plot the proportion of missing genotypes and the heterozygosity rate
png(filename = oput, width = 8, height = 8, units = "cm", pointsize = 6, res = 300)
par(mfrow=c(1,1))
plot(
  mishet\$het.rate, 
  mishet\$mis.rate, 
  xlab = "Heterozygous rate", 
  ylab = "Proportion of missing genotype", 
  main = "Individual Missingness",
  pch = 20,
  col = ifelse(mishet\$het.rate < hetlower, "brown", 
          ifelse(mishet\$het.rate > hetupper, "brown", 
            ifelse(mishet\$mis.rate > 0.1, "brown", "black")))
)
abline(v=c(hetlower,hetupper), h=0.1, lty=2)
dev.off()

# Extract individuals that will be excluded from further analysis (who didn't pass the filter)
# Individuals with mis.rate > 0.1 (10% missingness)
fail_mis_qc <- mishet[mishet\$mis.rate > 0.1, ]
write.table(fail_mis_qc[,1:2], file = "fail-smiss-qc.txt", row.names = F, col.names = F, quote = F, sep = "\t")

# Individuals with het.rate < hetlower and individuals with het.rate > hetupper
fail_het_qc <- mishet[mishet\$het.rate < hetlower | mishet\$het.rate > hetupper, ]
write.table(fail_het_qc[,1:2], file = "fail-het-qc.txt", row.names = F, col.names = F, quote = F, sep = "\t")

fail_ind_qc <- unique(rbind(fail_mis_qc[,c(1:2)], fail_het_qc[,c(1:2)]))
write.table(fail_ind_qc, file = out, row.names = F, col.names = F, quote = F, sep = "\t")

message("\nDone! ... figure saved in ", oput)
