#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args) < 2) {
   print("", quote=F)
   print("Usage: get_boxplot_of_snp_genotype.r [SNP-genotype-file] [plot-title] [pheno-file] [pheno-name]", quote=F)
   print("SNP-genotype-file: must end with '.txt'", quote=F)
   print("pheno-file: must have a header", quote=F)
   print("", quote=F)
   quit(save="no")
} else {
   gt_file <- args[1]
   plt_title <- args[2]
   pheno_file <- args[3]
   heno_name <- args[4]
   out_png <- gsub(".txt", ".png", gt_file)
   pheno <- read.table(pheno_file, h=T)
   jazf_gt <- read.table(gt_file, h=T)
   jazf_gt$Genotype <- as.factor(jazf_gt$Genotype)
   jazf_gt_hbf <- merge(jazf_gt, pheno, by = "FID", sort = F)
   hom_ref_gt_code <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="11",]$Genotype)
   hom_ref_gt <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="11",]$RefAlt)
   hom_alt_gt_code <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="22",]$Genotype)
   hom_alt_gt <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="22",]$RefAlt)
   het_gt_code <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="12",]$Genotype)
   het_gt <- unique(jazf_gt_hbf[jazf_gt_hbf$Genotype=="12",]$RefAlt)

   xlab_text <- paste0("Genotype ", 
                       "(", 
                       hom_ref_gt_code, " = ", hom_ref_gt, 
                       ", ", 
                       het_gt_code, " = ", het_gt, 
                       ", ", 
                       hom_alt_gt_code, " = ", hom_alt_gt,
                       ")")

   png(out_png)
   plot( 
      jazf_gt_hbf$Genotype, 
      jazf_gt_hbf[heno_name], 
      pch = 21, 
      bg = "brown", 
      col = "lightblue", 
      alpha=0.2,
      main = plt_title,
      xlab = xlab_text,
      ylab = "HbF level (g/dl)"
   )
   dev.off()
}
