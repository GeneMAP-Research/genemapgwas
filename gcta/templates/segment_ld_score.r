#!/usr/bin/env Rscript

library(data.table)
ldfile = "${bed_name}.score.ld"
ld_out_a = "${bed_name}_ld_snp_group1.txt"
ld_out_b = "${bed_name}_ld_snp_group2.txt" 
ld_out_c = "${bed_name}_ld_snp_group3.txt"
ld_out_d = "${bed_name}_ld_snp_group4.txt"

lds_seg = fread(ldfile, header=T, colClasses=c("character",rep("numeric",8)), data.table=F, nThread=${task.cpus})
quartiles=summary(lds_seg\$ldscore_SNP)

lb1 = which(lds_seg\$ldscore_SNP <= quartiles[2])
lb2 = which(lds_seg\$ldscore_SNP > quartiles[2] & lds_seg\$ldscore_SNP <= quartiles[3])
lb3 = which(lds_seg\$ldscore_SNP > quartiles[3] & lds_seg\$ldscore_SNP <= quartiles[5])
lb4 = which(lds_seg\$ldscore_SNP > quartiles[5])

lb1_snp = as.data.frame(lds_seg\$SNP[lb1])
lb2_snp = as.data.frame(lds_seg\$SNP[lb2])
lb3_snp = as.data.frame(lds_seg\$SNP[lb3])
lb4_snp = as.data.frame(lds_seg\$SNP[lb4])

fwrite(lb1_snp, ld_out_a, row.names=F, quote=F, col.names=F, nThread=${task.cpus})
fwrite(lb2_snp, ld_out_b, row.names=F, quote=F, col.names=F, nThread=${task.cpus})
fwrite(lb3_snp, ld_out_c, row.names=F, quote=F, col.names=F, nThread=${task.cpus})
fwrite(lb4_snp, ld_out_d, row.names=F, quote=F, col.names=F, nThread=${task.cpus})

