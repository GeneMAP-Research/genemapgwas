#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args) < 3) {
   message("\nUsage: get_boxplot_of_snp_genotype.r [SNP-genotype-file] [pheno-file] [pheno-name] [plot-title]\n")
   message("\tSNP-genotype-file: File must end with '.txt' and contain header (FID Genotype RefAlt)\n")
   message("\tpheno-file: must contain sample and phenotype headings as FID and PHENO\n")
   quit(save="no")
} else {
   require(ggplot2)

   gt_file <- args[1]
   phename <- args[3]
   plt.title <- args[4]
   phenofile <- args[2]
   out_svg <- gsub(".txt", paste0("_with_", phename, ".svg"), gt_file)
   out_png <- gsub(".txt", paste0("_with_", phename, ".png"), gt_file)
   ggout_svg <- gsub(".txt", paste0("_with_", phename, ".gg.svg"), gt_file)
   ggout_png <- gsub(".txt", paste0("_with_", phename, ".gg.png"), gt_file)
   out_data <- gsub(".txt", paste0("_with_", phename, ".txt"), gt_file)
   pheno <- read.table(phenofile, h=T)
   pheno <- pheno[ which(names(pheno) %in% c("FID", "PHENO")) ]
   gtdata <- read.table(gt_file, h=T)
   gtdata$Genotype <- as.factor(gtdata$Genotype)
   gtdata_phenodata <- merge(gtdata, pheno, by = "FID", sort = F)

   write.table(
      gtdata_phenodata, 
      file=out_data, 
      col.names=T, 
      row.names=F, 
      sep=" ", 
      quote=F
   )
 
   #print(head(gtdata_phenodata["Genotype"]))
   #print(head(gtdata_phenodata["PHENO"]))

   hom_ref <- gtdata_phenodata[gtdata_phenodata$Genotype=="11",]
   hom_ref_gt_code <- as.character(unique(hom_ref$Genotype))
   hom_ref_gt <- as.character(unique(hom_ref$RefAlt))
   count_hom_ref_gt <- as.character(length(hom_ref$RefAlt))

   hom_alt <- gtdata_phenodata[gtdata_phenodata$Genotype=="22",]
   hom_alt_gt_code <- as.character(unique(hom_alt$Genotype))
   hom_alt_gt <- as.character(unique(hom_alt$RefAlt))
   count_hom_alt_gt <- as.character(length(hom_alt$RefAlt))

   het <- gtdata_phenodata[gtdata_phenodata$Genotype=="12",]
   het_gt_code <- as.character(unique(het$Genotype))
   het_gt <- as.character(unique(het$RefAlt))
   count_het_gt <- as.character(length(het$RefAlt))

   if(count_hom_ref_gt == 0) {
      plt.info <- data.frame(hom_alt = c(hom_alt_gt_code, hom_alt_gt, count_hom_alt_gt), het = c(het_gt_code, het_gt, count_het_gt))
   } else if(count_hom_alt_gt == 0) {
      plt.info <- data.frame(hom_ref = c(hom_ref_gt_code, hom_ref_gt, count_hom_ref_gt), het = c(het_gt_code, het_gt, count_het_gt))
   } else if(count_het_gt == 0) {
      plt.info <- data.frame(hom_ref = c(hom_ref_gt_code, hom_ref_gt, count_hom_ref_gt), hom_alt = c(hom_alt_gt_code, hom_alt_gt, count_hom_alt_gt))
   } else {
      plt.info <- data.frame(hom_ref = c(hom_ref_gt_code, hom_ref_gt, count_hom_ref_gt), het = c(het_gt_code, het_gt, count_het_gt), hom_alt = c(hom_alt_gt_code, hom_alt_gt, count_hom_alt_gt))
   }

   print(plt.info)

   plt.xlab <- c()
   plt.legend <- c()
   for(i in 1:ncol(plt.info)) {
      plt.legend[i] <- paste0(plt.info[2,i], " (", plt.info[1,i], ") ", " = ", plt.info[3,i])
   }

#   svg(out_svg, width=17, height=17, pointsize=25)
#   #png(out_png)
#      plot.new()
#      grid(lwd=0.8)
#      par(new=T)
#      boxplot(   
#         PHENO ~ Genotype,
#         data = gtdata_phenodata,
#         pch = 21,
#         bg = "brown",
#         col = "lightblue",
#         alpha=0.2,
#         main = plt.title,
#         xlab = "Genotype",
#         ylab = phename
#      )
#      legend("topright", legend=plt.legend, title = "Count", bty="n", title.col = "navy")
#   dev.off()
#
#   p <- ggplot(gtdata_phenodata, aes(x=RefAlt, y=PHENO, color=RefAlt)) + geom_violin() + theme_minimal()
#   p <- p + geom_boxplot(width=0.1) + theme_minimal() + labs(x="Genotype", y=phename, col="Genotype")
#   ggsave(plot = p, filename = ggout_png, device = 'png', dpi = 600)


   #... NEW SCRIPT
   p <- ggplot(
     data = gtdata_phenodata,
     mapping = aes(x=RefAlt, y=PHENO, fill=RefAlt)
   )
   
   gp <- p +
     geom_violin(
       trim = T,
       alpha = 0.3
       ) +
     geom_boxplot(
       width = 0.1,
       position = position_dodge(0.9)
       ) +
     ylab(label = phename) +
     xlab(label = "Genotype") +
     theme_bw() +
     theme(
       axis.text = element_text(size = 16),
       legend.position = "none",
       axis.title = element_text(size=16)
     )
   
   ggsave(
     gp,
     filename = ggout_png,
     height = 3,
     width = 5
)


}
